package com.crm.service;

import com.crm.dao.AccountDAO;
import com.crm.dto.LoginRequest;
import com.crm.exception.AuthenticationException;
import com.crm.model.Account;
import com.crm.security.PasswordUtil;
import com.crm.util.EmailUtil;

import java.sql.Timestamp;
import java.time.LocalDateTime;

/**
 * Service xu ly nghiep vu Xac thuc va Quen mat khau (Password Reset Token).
 */
public class AuthService {

    private final AccountDAO accountDAO;

    public AuthService() {
        this.accountDAO = new AccountDAO();
    }

    public AuthService(AccountDAO accountDAO) {
        this.accountDAO = accountDAO;
    }

    private static final String DUMMY_BCRYPT_HASH = "$2a$12$e8bA.U/W5S.eS12s7H5F2.E/K2B3jP4oN5M6L7K8J9I0H1G2F3E4D";

    public Account authenticate(LoginRequest request) throws AuthenticationException {
        if (request == null) {
            throw new AuthenticationException("Thông tin đăng nhập không hợp lệ.");
        }

        String username = request.getUsername();
        String password = request.getPassword();

        if (username == null || username.trim().isEmpty() || password == null || password.isEmpty()) {
            throw new AuthenticationException("Vui lòng nhập tên đăng nhập và mật khẩu.");
        }

        java.sql.Connection conn = null;
        try {
            conn = com.crm.util.DBConnection.getConnection();
            conn.setAutoCommit(false);

            Account account = accountDAO.findByUsernameForUpdate(conn, username.trim());

            if (account == null) {
                conn.commit();
                PasswordUtil.verify(password, DUMMY_BCRYPT_HASH);
                throw new AuthenticationException("Tên đăng nhập hoặc mật khẩu không chính xác.");
            }

            if (!"ACTIVE".equals(account.getStatus())) {
                conn.commit();
                throw new AuthenticationException("Tài khoản hiện không thể đăng nhập.");
            }

            Timestamp now = new Timestamp(System.currentTimeMillis());
            boolean isLockExpired = (account.getLockoutUntil() != null && !account.getLockoutUntil().after(now));
            boolean isCurrentlyLocked = (account.getLockoutUntil() != null && account.getLockoutUntil().after(now));

            if (isCurrentlyLocked) {
                conn.commit();
                long remainingMinutes = Math.max(1, (account.getLockoutUntil().getTime() - now.getTime() + 59999) / 60000);
                throw new AuthenticationException("Tài khoản hiện đang bị khóa tạm thời. Vui lòng thử lại sau " + remainingMinutes + " phút.");
            }

            boolean passwordValid = PasswordUtil.verify(password, account.getPasswordHash());

            if (!passwordValid) {
                int currentAttempts = isLockExpired ? 0 : account.getFailedAttempts();
                int newAttempts = currentAttempts + 1;
                Timestamp newLockoutUntil = null;

                if (newAttempts >= 5) {
                    newAttempts = 5;
                    newLockoutUntil = new Timestamp(now.getTime() + 15 * 60 * 1000L);
                }

                accountDAO.updateFailedAttemptsAndLockout(conn, account.getAccountId(), newAttempts, newLockoutUntil);
                conn.commit();

                if (newAttempts >= 5) {
                    throw new AuthenticationException("Tài khoản đã bị khóa do đăng nhập sai 5 lần liên tiếp. Vui lòng thử lại sau 15 phút.");
                } else {
                    int attemptsLeft = 5 - newAttempts;
                    if (attemptsLeft == 1) {
                        throw new AuthenticationException("Mật khẩu không chính xác. Bạn còn 1 lần thử trước khi tài khoản bị khóa 15 phút.");
                    } else {
                        throw new AuthenticationException("Mật khẩu không chính xác. Bạn còn " + attemptsLeft + " lần thử.");
                    }
                }
            }

            accountDAO.resetFailedLogin(conn, account.getAccountId());
            conn.commit();
            account.setFailedAttempts(0);
            account.setLockoutUntil(null);

            return account;
        } catch (AuthenticationException e) {
            if (conn != null) try { conn.rollback(); } catch (Exception ignored) {}
            throw e;
        } catch (Exception e) {
            if (conn != null) try { conn.rollback(); } catch (Exception ignored) {}
            e.printStackTrace();
            throw new AuthenticationException("Lỗi hệ thống: " + (e.getMessage() != null ? e.getMessage() : e.toString()), e);
        } finally {
            if (conn != null) try { conn.setAutoCommit(true); conn.close(); } catch (Exception ignored) {}
        }
    }

    /**
     * Sinh token/mật khẩu tạm thời cho email và lưu vào CSDL (hạn 30 phút).
     */
    public String generateResetToken(String email) throws AuthenticationException {
        if (email == null || email.trim().isEmpty()) {
            throw new AuthenticationException("Vui lòng nhập địa chỉ email.");
        }

        Account account = accountDAO.findByEmail(email.trim());
        if (account == null) {
            throw new AuthenticationException("Không tìm thấy tài khoản với địa chỉ email này trong hệ thống.");
        }

        if ("LOCKED".equalsIgnoreCase(account.getStatus())) {
            throw new AuthenticationException("Tài khoản đã bị khóa, không thể yêu cầu đặt lại mật khẩu.");
        }

        String tempPassword = PasswordUtil.generateTemporaryPassword();
        String tokenHash = PasswordUtil.hashToken(tempPassword);
        Timestamp expiryTime = Timestamp.valueOf(LocalDateTime.now().plusMinutes(30));

        boolean saved = accountDAO.saveResetToken(account.getAccountId(), tokenHash, expiryTime);
        if (!saved) {
            throw new AuthenticationException("Lỗi hệ thống khi tạo mật khẩu tạm thời. Vui lòng thử lại.");
        }

        return tempPassword;
    }

    /**
     * Sinh mật khẩu tạm thời ngẫu nhiên cho Quen mat khau, luu token hash (30 phut) va gui qua email.
     */
    public String generateAndSendResetPassword(String email) throws AuthenticationException {
        Account account = accountDAO.findByEmail(email != null ? email.trim() : "");
        String tempPassword = generateResetToken(email);

        try {
            sendResetPasswordEmail(account.getEmail(), account.getFullName(), tempPassword);
        } catch (Exception e) {
            throw new AuthenticationException("Gửi email thất bại: " + e.getMessage());
        }

        return tempPassword;
    }

    public void sendResetPasswordEmail(String toEmail, String fullName, String tempPassword) throws Exception {
        String htmlContent = "<div style=\"font-family: Arial, sans-serif; padding: 20px; color: #333;\">"
            + "<h2>Yêu cầu đặt lại mật khẩu CRM</h2>"
            + "<p>Xin chào <b>" + (fullName != null ? fullName : toEmail) + "</b>,</p>"
            + "<p>Bạn vừa yêu cầu đặt lại mật khẩu cho tài khoản CRM.</p>"
            + "<div style=\"background: #f8fafc; border-left: 4px solid #4f46e5; padding: 15px; margin: 15px 0;\">"
            + "<p style=\"margin: 0; font-size: 14px; color: #64748b;\">Mật khẩu tạm thời của bạn:</p>"
            + "<p style=\"margin: 5px 0; font-size: 20px; font-weight: bold; color: #4f46e5; letter-spacing: 1px;\">" + tempPassword + "</p>"
            + "</div>"
            + "<p>Mật khẩu tạm thời này có hiệu lực trong <b>30 phút</b> và chỉ được dùng <b>một lần</b>.</p>"
            + "<p>Vui lòng nhập mật khẩu tạm thời này tại màn hình Đặt lại mật khẩu để đổi sang mật khẩu mới.</p>"
            + "</div>";

        EmailUtil.sendEmail(toEmail, "Mật khẩu tạm thời đặt lại mật khẩu CRM", htmlContent);
    }

    public boolean validateResetToken(String token) {
        if (token == null || token.trim().isEmpty()) {
            return false;
        }

        String tokenHash = PasswordUtil.hashToken(token.trim());
        Account account = accountDAO.findByResetToken(tokenHash);
        if (account == null || account.getResetTokenExpiry() == null) {
            return false;
        }

        return account.getResetTokenExpiry().after(new Timestamp(System.currentTimeMillis()));
    }

    public void resetPasswordWithToken(String tempPassword, String newPassword, String confirmPassword)
            throws AuthenticationException {

        if (tempPassword == null || tempPassword.trim().isEmpty()) {
            throw new AuthenticationException("Vui lòng nhập mật khẩu tạm thời.");
        }

        if (newPassword == null || newPassword.trim().isEmpty()) {
            throw new AuthenticationException("Vui lòng nhập mật khẩu mới.");
        }

        if (!newPassword.equals(confirmPassword)) {
            throw new AuthenticationException("Xác nhận mật khẩu mới không trùng khớp.");
        }

        if (!PasswordUtil.validatePasswordRules(newPassword)) {
            throw new AuthenticationException("Mật khẩu mới không đáp ứng yêu cầu bảo mật: Phải từ 8 ký tự trở lên, gồm ít nhất 1 chữ cái, 1 chữ số và 1 ký tự đặc biệt.");
        }

        String tokenHash = PasswordUtil.hashToken(tempPassword.trim());
        Account account = accountDAO.findByResetToken(tokenHash);
        if (account == null || account.getResetTokenExpiry() == null || !account.getResetTokenExpiry().after(new Timestamp(System.currentTimeMillis()))) {
            throw new AuthenticationException("Mật khẩu tạm thời không chính xác, đã hết hạn hoặc đã được sử dụng.");
        }

        String newPasswordHash = PasswordUtil.hash(newPassword);
        boolean updated = accountDAO.updatePasswordAndClearResetToken(tokenHash, newPasswordHash);

        if (!updated) {
            throw new AuthenticationException("Không thể cập nhật mật khẩu mới. Vui lòng thử lại.");
        }
    }

    public void changePassword(int userId, String oldPassword, String newPassword, String confirmPassword)
            throws AuthenticationException {

        if (oldPassword == null || oldPassword.trim().isEmpty() ||
            newPassword == null || newPassword.trim().isEmpty() ||
            confirmPassword == null || confirmPassword.trim().isEmpty()) {
            throw new AuthenticationException("Vui lòng nhập đầy đủ các trường thông tin.");
        }

        if (!newPassword.equals(confirmPassword)) {
            throw new AuthenticationException("Mật khẩu mới và xác nhận mật khẩu không trùng khớp.");
        }

        if (!PasswordUtil.validatePasswordRules(newPassword)) {
            throw new AuthenticationException("Mật khẩu mới không đáp ứng yêu cầu bảo mật: Phải từ 8 ký tự trở lên, gồm ít nhất 1 chữ cái, 1 chữ số và 1 ký tự đặc biệt.");
        }

        if (oldPassword.equals(newPassword)) {
            throw new AuthenticationException("Mật khẩu mới không được trùng với mật khẩu hiện tại.");
        }

        Account account = accountDAO.getAccountById(userId);
        if (account == null) {
            throw new AuthenticationException("Tài khoản không tồn tại.");
        }

        if (!PasswordUtil.verify(oldPassword, account.getPasswordHash())) {
            throw new AuthenticationException("Mật khẩu hiện tại không chính xác.");
        }

        String newPasswordHash = PasswordUtil.hash(newPassword);
        boolean updated = accountDAO.updatePassword(userId, newPasswordHash);

        if (!updated) {
            throw new AuthenticationException("Cập nhật mật khẩu thất bại. Vui lòng thử lại sau.");
        }
    }
}
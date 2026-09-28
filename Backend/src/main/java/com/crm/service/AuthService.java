package com.crm.service;

import com.crm.dao.AccountDAO;
import com.crm.dto.LoginRequest;
import com.crm.exception.AuthenticationException;
import com.crm.model.Account;
import com.crm.security.PasswordUtil;

import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.util.UUID;

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

    public Account authenticate(LoginRequest request) throws AuthenticationException {
        if (request == null) {
            throw new AuthenticationException("Thông tin đăng nhập không hợp lệ.");
        }

        String username = request.getUsername();
        String password = request.getPassword();

        if (username == null || username.trim().isEmpty() || password == null || password.isEmpty()) {
            throw new AuthenticationException("Vui lòng nhập tên đăng nhập và mật khẩu.");
        }

        try {
            Account account = accountDAO.findByUsername(username.trim());

            if (account == null) {
                throw new AuthenticationException("Tên đăng nhập hoặc mật khẩu không chính xác.");
            }

            if (!"ACTIVE".equals(account.getStatus())) {
                throw new AuthenticationException("Tài khoản hiện không thể đăng nhập.");
            }

            if (!PasswordUtil.verify(password, account.getPasswordHash())) {
                throw new AuthenticationException("Tên đăng nhập hoặc mật khẩu không chính xác.");
            }

            return account;
        } catch (AuthenticationException e) {
            throw e;
        } catch (Exception e) {
            throw new AuthenticationException("Không thể xử lý đăng nhập.", e);
        }
    }

    /**
     * S1-03: Phien tao Token reset mat khau cho user dua vao Email.
     * Token co thoi han 30 phut.
     */
    
    public String generateResetToken(String email) throws AuthenticationException {
        if (email == null || email.trim().isEmpty()) {
            throw new AuthenticationException("Vui lòng nhập địa chỉ email.");
        }

        Account account = accountDAO.findByEmail(email.trim());
        if (account == null) {
            throw new AuthenticationException("Không tìm thấy tài khoản với email này trong hệ thống.");
        }

        if ("LOCKED".equalsIgnoreCase(account.getStatus())) {
            throw new AuthenticationException("Tài khoản đã bị khóa, không thể yêu cầu đặt lại mật khẩu.");
        }

        java.security.SecureRandom random = new java.security.SecureRandom();
        byte[] bytes = new byte[32];
        random.nextBytes(bytes);
        String rawToken = java.util.Base64.getUrlEncoder().withoutPadding().encodeToString(bytes);
        
        String tokenHash = PasswordUtil.hashToken(rawToken);
        Timestamp expiryTime = Timestamp.valueOf(LocalDateTime.now().plusMinutes(30));

        boolean saved = accountDAO.saveResetToken(account.getAccountId(), tokenHash, expiryTime);
        if (!saved) {
            throw new AuthenticationException("Lỗi hệ thống khi tạo token reset mật khẩu. Vui lòng thử lại.");
        }

        return rawToken;
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

    public void resetPasswordWithToken(String token, String newPassword, String confirmPassword)
            throws AuthenticationException {

        if (token == null || token.trim().isEmpty()) {
            throw new AuthenticationException("Token khôi phục mật khẩu không hợp lệ.");
        }

        if (newPassword == null || newPassword.trim().isEmpty()) {
            throw new AuthenticationException("Vui lòng nhập mật khẩu mới.");
        }

        if (!PasswordUtil.validatePasswordRules(newPassword)) {
            throw new AuthenticationException("Mật khẩu mới phải có tối thiểu 8 ký tự, bao gồm cả chữ cái và chữ số.");
        }

        if (confirmPassword == null || !newPassword.equals(confirmPassword)) {
            throw new AuthenticationException("Xác nhận mật khẩu mới không khớp.");
        }

        String tokenHash = PasswordUtil.hashToken(token.trim());
        Account account = accountDAO.findByResetToken(tokenHash);
        if (account == null || account.getResetTokenExpiry() == null || !account.getResetTokenExpiry().after(new Timestamp(System.currentTimeMillis()))) {
            throw new AuthenticationException("Token khôi phục mật khẩu không hợp lệ hoặc đã hết hạn.");
        }

        String newPasswordHash = PasswordUtil.hash(newPassword);
        boolean updated = accountDAO.updatePasswordAndClearResetToken(tokenHash, newPasswordHash);

        if (!updated) {
            throw new AuthenticationException("Không thể cập nhật mật khẩu mới. Vui lòng thử lại.");
        }
    }

    public void sendResetEmail(String toEmail, String resetUrl) throws Exception {
        String host = System.getenv("SMTP_HOST");
        if (host == null) host = "smtp.gmail.com";
        String port = System.getenv("SMTP_PORT");
        if (port == null) port = "587";
        String username = System.getenv("SMTP_USERNAME");
        String password = System.getenv("SMTP_PASSWORD");
        String from = System.getenv("SMTP_FROM");
        if (from == null) from = "no-reply@crm.com";

        if (username == null || password == null) {
            throw new Exception("SMTP credentials not configured.");
        }

        java.util.Properties props = new java.util.Properties();
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.starttls.enable", "true");
        props.put("mail.smtp.host", host);
        props.put("mail.smtp.port", port);

        jakarta.mail.Session session = jakarta.mail.Session.getInstance(props, new jakarta.mail.Authenticator() {
            @Override
            protected jakarta.mail.PasswordAuthentication getPasswordAuthentication() {
                return new jakarta.mail.PasswordAuthentication(username, password);
            }
        });

        jakarta.mail.Message message = new jakarta.mail.internet.MimeMessage(session);
        message.setFrom(new jakarta.mail.internet.InternetAddress(from));
        message.setRecipients(jakarta.mail.Message.RecipientType.TO, jakarta.mail.internet.InternetAddress.parse(toEmail));
        message.setSubject("Yêu cầu đặt lại mật khẩu CRM");
        
        String htmlContent = "<p>Xin chào,</p>"
            + "<p>Bạn đã yêu cầu đặt lại mật khẩu. Vui lòng nhấp vào liên kết bên dưới để đặt lại mật khẩu của bạn (có hiệu lực trong 30 phút):</p>"
            + "<p><a href=\"" + resetUrl + "\">Đặt lại mật khẩu</a></p>"
            + "<p>Nếu bạn không yêu cầu, vui lòng bỏ qua email này.</p>";
            
        message.setContent(htmlContent, "text/html; charset=utf-8");
        jakarta.mail.Transport.send(message);
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
            throw new AuthenticationException("Mật khẩu mới phải có tối thiểu 8 ký tự, bao gồm cả chữ cái và chữ số.");
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
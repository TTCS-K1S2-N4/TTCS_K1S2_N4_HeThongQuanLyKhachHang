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

        String token = UUID.randomUUID().toString();
        Timestamp expiryTime = Timestamp.valueOf(LocalDateTime.now().plusMinutes(30));

        boolean saved = accountDAO.saveResetToken(account.getAccountId(), token, expiryTime);
        if (!saved) {
            throw new AuthenticationException("Lỗi hệ thống khi tạo token reset mật khẩu. Vui lòng thử lại.");
        }

        return token;
    }

    /**
     * S1-03: Kiem tra token reset mat khau co hop le va con thoi han hay khong.
     */
    public boolean validateResetToken(String token) {
        if (token == null || token.trim().isEmpty()) {
            return false;
        }

        Account account = accountDAO.findByResetToken(token.trim());
        if (account == null || account.getResetTokenExpiry() == null) {
            return false;
        }

        return account.getResetTokenExpiry().after(new Timestamp(System.currentTimeMillis()));
    }

    /**
     * S1-03: Thuc hien dat lai mat khau moi bang Token.
     */
    public void resetPasswordWithToken(String token, String newPassword, String confirmPassword)
            throws AuthenticationException {

        if (token == null || token.trim().isEmpty()) {
            throw new AuthenticationException("Token khôi phục mật khẩu không hợp lệ.");
        }

        if (newPassword == null || newPassword.trim().isEmpty()) {
            throw new AuthenticationException("Vui lòng nhập mật khẩu mới.");
        }

        if (newPassword.length() < 6) {
            throw new AuthenticationException("Mật khẩu mới phải có ít nhất 6 ký tự.");
        }

        if (confirmPassword == null || !newPassword.equals(confirmPassword)) {
            throw new AuthenticationException("Xác nhận mật khẩu mới không khớp.");
        }

        if (!validateResetToken(token)) {
            throw new AuthenticationException("Token khôi phục mật khẩu không hợp lệ hoặc đã hết hạn.");
        }

        Account account = accountDAO.findByResetToken(token.trim());
        if (account == null) {
            throw new AuthenticationException("Tài khoản không tồn tại.");
        }

        String newPasswordHash = PasswordUtil.hash(newPassword);
        boolean updated = accountDAO.updatePasswordAndClearResetToken(account.getAccountId(), newPasswordHash);

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
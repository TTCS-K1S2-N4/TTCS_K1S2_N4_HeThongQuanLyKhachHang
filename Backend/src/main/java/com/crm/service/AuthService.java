package com.crm.service;

import com.crm.dao.AccountDAO;
import com.crm.dto.LoginRequest;
import com.crm.exception.AuthenticationException;
import com.crm.model.Account;
import com.crm.security.PasswordUtil;

public class AuthService {

    private final AccountDAO accountDAO;

    public AuthService() {
        this.accountDAO = new AccountDAO();
    }

    public Account authenticate(LoginRequest request)
            throws AuthenticationException {

        if (request == null) {
            throw new AuthenticationException(
                    "Thông tin đăng nhập không hợp lệ."
            );
        }

        String username = request.getUsername();
        String password = request.getPassword();

        if (username == null || username.trim().isEmpty()
                || password == null || password.isEmpty()) {

            throw new AuthenticationException(
                    "Vui lòng nhập tên đăng nhập và mật khẩu."
            );
        }

        try {

            Account account =
                    accountDAO.findByUsername(username.trim());

            if (account == null) {
                throw new AuthenticationException(
                        "Tên đăng nhập hoặc mật khẩu không chính xác."
                );
            }

            if (!"ACTIVE".equals(account.getStatus())) {
                throw new AuthenticationException(
                        "Tài khoản hiện không thể đăng nhập."
                );
            }

            if (!PasswordUtil.verify(
                    password,
                    account.getPasswordHash())) {

                throw new AuthenticationException(
                        "Tên đăng nhập hoặc mật khẩu không chính xác."
                );
            }

            return account;

        } catch (AuthenticationException e) {
            throw e;

        } catch (Exception e) {
            throw new AuthenticationException(
                    "Không thể xử lý đăng nhập.",
                    e
            );
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
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
}
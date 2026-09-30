package com.crm.controller.account;

import com.crm.service.AccountService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

@WebServlet("/accounts/resend-email")
public class AccountResendEmailServlet extends HttpServlet {
    private final AccountService accountService = new AccountService();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String idStr = req.getParameter("accountId");
        if (idStr == null || idStr.trim().isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/accounts/list?error=missing_id");
            return;
        }

        try {
            int accountId = Integer.parseInt(idStr.trim());
            boolean success = accountService.resendTemporaryPassword(accountId);
            if (success) {
                resp.sendRedirect(req.getContextPath() + "/accounts/list?msg=email_resent_success");
            } else {
                resp.sendRedirect(req.getContextPath() + "/accounts/list?msg=email_resent_failed");
            }
        } catch (Exception e) {
            System.err.println("Lỗi khi gửi lại email thông tin tài khoản: " + e.getMessage());
            resp.sendRedirect(req.getContextPath() + "/accounts/list?msg=email_resent_failed");
        }
    }
}

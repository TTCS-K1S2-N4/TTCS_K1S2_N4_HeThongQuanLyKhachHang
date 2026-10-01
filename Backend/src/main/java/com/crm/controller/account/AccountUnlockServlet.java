package com.crm.controller.account;

import com.crm.service.AccountService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet("/accounts/unlock")
public class AccountUnlockServlet extends HttpServlet {
    private final AccountService accountService = new AccountService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        processUnlock(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        processUnlock(req, resp);
    }

    private void processUnlock(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        String idStr = req.getParameter("accountId");
        if (idStr == null || idStr.trim().isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/accounts/list?error=unlock_failed");
            return;
        }

        try {
            int accountId = Integer.parseInt(idStr.trim());
            boolean success = accountService.unlockAccount(accountId);
            if (success) {
                resp.sendRedirect(req.getContextPath() + "/accounts/list?msg=unlocked");
            } else {
                resp.sendRedirect(req.getContextPath() + "/accounts/list?error=unlock_failed");
            }
        } catch (NumberFormatException e) {
            resp.sendRedirect(req.getContextPath() + "/accounts/list?error=unlock_failed");
        }
    }
}

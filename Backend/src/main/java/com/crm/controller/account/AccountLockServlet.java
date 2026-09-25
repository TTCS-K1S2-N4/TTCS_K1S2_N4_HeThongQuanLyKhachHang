package com.crm.controller.account;

import com.crm.util.SessionListener;
import com.crm.service.AccountService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet("/accounts/lock")
public class AccountLockServlet extends HttpServlet {
    private final AccountService accountService = new AccountService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        int accountId = Integer.parseInt(req.getParameter("accountId"));
        int ownedCount = accountService.countOwnedAssets(accountId);

        if (ownedCount > 0) {
            resp.sendRedirect(req.getContextPath() + "/accounts/transfer-data?accountId=" + accountId);
            return;
        }

        req.setAttribute("account", accountService.getAccountDetail(accountId));
        req.getRequestDispatcher("/WEB-INF/views/accounts/lock.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        int accountId = Integer.parseInt(req.getParameter("accountId"));
        int adminId = 1;

        boolean locked = accountService.lockAndTransferData(accountId, null, adminId);
        if (locked) {
            SessionListener.invalidateUserSession(accountId);
            resp.sendRedirect(req.getContextPath() + "/accounts/list?msg=locked");
        } else {
            resp.sendRedirect(req.getContextPath() + "/accounts/lock?accountId=" + accountId + "&error=failed");
        }
    }
}

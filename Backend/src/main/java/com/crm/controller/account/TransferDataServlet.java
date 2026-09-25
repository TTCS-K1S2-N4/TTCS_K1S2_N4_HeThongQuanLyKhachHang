package com.crm.controller.account;

import com.crm.util.SessionListener;
import com.crm.service.AccountService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet("/accounts/transfer-data")
public class TransferDataServlet extends HttpServlet {
    private final AccountService accountService = new AccountService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        int accountId = Integer.parseInt(req.getParameter("accountId"));
        int ownedCount = accountService.countOwnedAssets(accountId);

        req.setAttribute("account", accountService.getAccountDetail(accountId));
        req.setAttribute("ownedCount", ownedCount);
        req.getRequestDispatcher("/WEB-INF/views/accounts/transfer-data.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        int accountId = Integer.parseInt(req.getParameter("accountId"));
        int receiverId = Integer.parseInt(req.getParameter("receiverId"));
        int adminId = 1;

        boolean ok = accountService.lockAndTransferData(accountId, receiverId, adminId);
        if (ok) {
            SessionListener.invalidateUserSession(accountId);
            resp.sendRedirect(req.getContextPath() + "/accounts/list?msg=transferred_and_locked");
        } else {
            resp.sendRedirect(req.getContextPath() + "/accounts/transfer-data?accountId=" + accountId + "&error=failed");
        }
    }
}

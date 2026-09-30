package com.crm.controller.account;

import com.crm.util.SessionListener;
import com.crm.service.AccountService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.stream.Collectors;

@WebServlet("/accounts/transfer-data")
public class TransferDataServlet extends HttpServlet {
    private final AccountService accountService = new AccountService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        try {
            int accountId = Integer.parseInt(req.getParameter("accountId"));
            if (accountService.getAccountDetail(accountId) == null) {
                resp.sendError(HttpServletResponse.SC_NOT_FOUND);
                return;
            }
            req.setAttribute("account", accountService.getAccountDetail(accountId));
            req.setAttribute("ownedCount", accountService.countOwnedAssets(accountId));
            req.setAttribute("receivers", accountService.getAllActiveAccounts().stream()
                    .filter(candidate -> candidate.getAccountId() != accountId)
                    .collect(Collectors.toList()));
            req.getRequestDispatcher("/WEB-INF/views/accounts/transfer-data.jsp").forward(req, resp);
        } catch (NumberFormatException e) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        int accountId;
        int receiverId;
        try {
            accountId = Integer.parseInt(req.getParameter("accountId"));
            receiverId = Integer.parseInt(req.getParameter("receiverId"));
        } catch (NumberFormatException e) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST);
            return;
        }
        Integer adminId = (Integer) req.getSession().getAttribute("userId");
        String reason = req.getParameter("reason");
        if (adminId == null) {
            resp.sendRedirect(req.getContextPath() + "/auth/login");
            return;
        }

        boolean ok = accountService.lockAndTransferData(accountId, receiverId, adminId, reason);
        if (ok) {
            SessionListener.invalidateUserSession(accountId);
            resp.sendRedirect(req.getContextPath() + "/accounts/list?msg=transferred_and_locked");
        } else {
            resp.sendRedirect(req.getContextPath() + "/accounts/transfer-data?accountId=" + accountId + "&error=failed");
        }
    }
}

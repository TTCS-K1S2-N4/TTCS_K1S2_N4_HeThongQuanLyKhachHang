package com.crm.controller.account;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import com.crm.model.Account;
import com.crm.service.AccountService;
import java.util.stream.Collectors;

@WebServlet("/accounts/lock")
public class AccountLockServlet extends HttpServlet {
    private final AccountService accountService = new AccountService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        try {
            int accountId = Integer.parseInt(req.getParameter("accountId"));
            Account account = accountService.getAccountDetail(accountId);
            if (account == null) {
                resp.sendError(HttpServletResponse.SC_NOT_FOUND);
                return;
            }
            req.setAttribute("account", account);
            req.setAttribute("ownedCount", accountService.countOwnedAssets(accountId));
            req.setAttribute("receivers", accountService.getAllActiveAccounts().stream()
                    .filter(candidate -> candidate.getAccountId() != accountId)
                    .collect(Collectors.toList()));
            req.getRequestDispatcher("/WEB-INF/views/accounts/lock.jsp").forward(req, resp);
        } catch (NumberFormatException e) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST);
        }
    }
}

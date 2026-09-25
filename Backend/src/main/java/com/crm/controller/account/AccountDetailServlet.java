package com.crm.controller.account;

import com.crm.model.Account;
import com.crm.service.AccountService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet("/accounts/detail")
public class AccountDetailServlet extends HttpServlet {
    private final AccountService accountService = new AccountService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String idStr = req.getParameter("accountId");
        if (idStr == null || idStr.isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/accounts/list");
            return;
        }

        int accountId = Integer.parseInt(idStr);
        Account account = accountService.getAccountDetail(accountId);
        if (account == null) {
            resp.sendRedirect(req.getContextPath() + "/accounts/list?error=notfound");
            return;
        }

        req.setAttribute("account", account);
        req.getRequestDispatcher("/WEB-INF/views/accounts/detail.jsp").forward(req, resp);
    }
}

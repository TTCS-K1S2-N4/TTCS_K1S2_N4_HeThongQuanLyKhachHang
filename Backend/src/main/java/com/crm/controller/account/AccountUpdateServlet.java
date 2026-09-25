package com.crm.controller.account;

import com.crm.dto.AccountUpdateRequest;
import com.crm.model.Account;
import com.crm.service.AccountService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet("/accounts/edit")
public class AccountUpdateServlet extends HttpServlet {
    private final AccountService accountService = new AccountService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        int accountId = Integer.parseInt(req.getParameter("accountId"));
        Account account = accountService.getAccountDetail(accountId);
        req.setAttribute("account", account);
        req.getRequestDispatcher("/WEB-INF/views/accounts/edit.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        int accountId = Integer.parseInt(req.getParameter("accountId"));
        String fullName = req.getParameter("fullName");
        String phone = req.getParameter("phone");
        String teamIdStr = req.getParameter("teamId");
        Integer teamId = (teamIdStr != null && !teamIdStr.isEmpty()) ? Integer.parseInt(teamIdStr) : null;

        AccountUpdateRequest updateReq = new AccountUpdateRequest(accountId, fullName, phone, teamId);
        boolean success = accountService.updateAccount(updateReq);
        if (success) {
            resp.sendRedirect(req.getContextPath() + "/accounts/detail?accountId=" + accountId + "&msg=updated");
        } else {
            req.setAttribute("error", "Cập nhật tài khoản thất bại.");
            req.getRequestDispatcher("/WEB-INF/views/accounts/edit.jsp").forward(req, resp);
        }
    }
}

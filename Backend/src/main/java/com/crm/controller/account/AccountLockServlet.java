package com.crm.controller.account;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet("/accounts/lock")
public class AccountLockServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String accountId = req.getParameter("accountId");
        resp.sendRedirect(req.getContextPath() + "/accounts/transfer-data?accountId=" + accountId);
    }
}

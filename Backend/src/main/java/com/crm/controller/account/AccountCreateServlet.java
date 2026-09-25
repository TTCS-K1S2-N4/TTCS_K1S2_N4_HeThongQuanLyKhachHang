package com.crm.controller.account;

import com.crm.dto.AccountCreateRequest;
import com.crm.service.AccountService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet("/accounts/create")
public class AccountCreateServlet extends HttpServlet {
    private final AccountService accountService = new AccountService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.getRequestDispatcher("/WEB-INF/views/accounts/create.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String email = req.getParameter("email");
        String password = req.getParameter("password");
        String fullName = req.getParameter("fullName");
        String phone = req.getParameter("phone");
        String teamIdStr = req.getParameter("teamId");

        Integer teamId = (teamIdStr != null && !teamIdStr.isEmpty()) ? Integer.parseInt(teamIdStr) : null;
        AccountCreateRequest createReq = new AccountCreateRequest(email, password, fullName, phone, teamId);

        boolean success = accountService.createAccount(createReq);
        if (success) {
            resp.sendRedirect(req.getContextPath() + "/accounts/list?msg=created");
        } else {
            req.setAttribute("error", "Email đã tồn tại hoặc thông tin không hợp lệ.");
            req.getRequestDispatcher("/WEB-INF/views/accounts/create.jsp").forward(req, resp);
        }
    }
}

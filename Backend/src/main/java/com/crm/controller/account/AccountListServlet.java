package com.crm.controller.account;

import com.crm.model.Account;
import com.crm.service.AccountService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

@WebServlet("/accounts/list")
public class AccountListServlet extends HttpServlet {
    private final AccountService accountService = new AccountService();
    private final com.crm.dao.RoleDAO roleDAO = new com.crm.dao.RoleDAO();
    private final com.crm.dao.TeamDAO teamDAO = new com.crm.dao.TeamDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String keyword = req.getParameter("keyword");
        String teamIdStr = req.getParameter("teamId");
        String roleIdStr = req.getParameter("roleId");
        String status = req.getParameter("status");
        String pageStr = req.getParameter("page");

        Integer teamId = (teamIdStr != null && !teamIdStr.isEmpty()) ? Integer.parseInt(teamIdStr) : null;
        Integer roleId = (roleIdStr != null && !roleIdStr.isEmpty()) ? Integer.parseInt(roleIdStr) : null;
        int page = (pageStr != null && !pageStr.isEmpty()) ? Integer.parseInt(pageStr) : 1;

        List<Account> list = accountService.getAccountList(keyword, teamId, roleId, status, page);
        int totalAccounts = accountService.countTotalAccounts(keyword, teamId, roleId, status);
        int totalPages = (int) Math.ceil((double) totalAccounts / 20);

        req.setAttribute("accountList", list);
        req.setAttribute("currentPage", page);
        req.setAttribute("totalPages", totalPages);
        req.setAttribute("totalAccounts", totalAccounts);

        try {
            req.setAttribute("roles", roleDAO.findAll());
            req.setAttribute("teams", teamDAO.findAll());
        } catch (java.sql.SQLException e) {
            e.printStackTrace();
        }

        req.getRequestDispatcher("/WEB-INF/views/accounts/list.jsp").forward(req, resp);
    }
}

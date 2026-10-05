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
        String pageSizeStr = req.getParameter("pageSize");

        Integer teamId = parseOptionalInt(teamIdStr);
        Integer roleId = parseOptionalInt(roleIdStr);
        Integer requestedPage = parseOptionalInt(pageStr);
        Integer requestedPageSize = parseOptionalInt(pageSizeStr);

        int pageSize = (requestedPageSize != null && (requestedPageSize == 10 || requestedPageSize == 20 || requestedPageSize == 50))
                ? requestedPageSize : 10;
        int page = requestedPage != null && requestedPage > 0 ? requestedPage : 1;

        int totalAccounts = accountService.countTotalAccounts(keyword, teamId, roleId, status);
        int totalPages = totalAccounts > 0 ? (int) Math.ceil((double) totalAccounts / pageSize) : 1;

        if (page > totalPages) {
            page = totalPages;
        }

        List<Account> list = accountService.getAccountList(keyword, teamId, roleId, status, page, pageSize);

        req.setAttribute("accountList", list);
        req.setAttribute("currentPage", page);
        req.setAttribute("pageSize", pageSize);
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

    private Integer parseOptionalInt(String value) {
        if (value == null || value.trim().isEmpty()) return null;
        try { return Integer.valueOf(value.trim()); } catch (NumberFormatException e) { return null; }
    }
}

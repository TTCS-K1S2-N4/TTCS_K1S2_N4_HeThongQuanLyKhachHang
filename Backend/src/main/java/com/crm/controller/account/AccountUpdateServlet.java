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
import java.util.ArrayList;
import java.util.List;

@WebServlet("/accounts/edit")
public class AccountUpdateServlet extends HttpServlet {
    private final AccountService accountService = new AccountService();
    private final com.crm.dao.RoleDAO roleDAO = new com.crm.dao.RoleDAO();
    private final com.crm.dao.TeamDAO teamDAO = new com.crm.dao.TeamDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        int accountId;
        try {
            accountId = Integer.parseInt(req.getParameter("accountId"));
        } catch (NumberFormatException e) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST);
            return;
        }
        Account account = accountService.getAccountDetail(accountId);
        if (account == null) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }
        req.setAttribute("account", account);
        loadFormData(req);
        req.getRequestDispatcher("/WEB-INF/views/accounts/edit.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        int accountId;
        try {
            accountId = Integer.parseInt(req.getParameter("accountId"));
        } catch (NumberFormatException e) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST);
            return;
        }
        String fullName = req.getParameter("fullName");
        String phone = req.getParameter("phone");
        String teamIdStr = req.getParameter("teamId");
        String[] roleIdValues = req.getParameterValues("roleIds");
        List<Integer> roleIds = new ArrayList<>();
        Integer teamId;
        try {
            teamId = (teamIdStr != null && !teamIdStr.isEmpty()) ? Integer.parseInt(teamIdStr) : null;
            if (roleIdValues != null) {
                for (String value : roleIdValues) roleIds.add(Integer.parseInt(value));
            }
        } catch (NumberFormatException e) {
            req.setAttribute("error", "Vai trò hoặc nhóm không hợp lệ.");
            req.setAttribute("account", accountService.getAccountDetail(accountId));
            loadFormData(req);
            req.getRequestDispatcher("/WEB-INF/views/accounts/edit.jsp").forward(req, resp);
            return;
        }
        if (!com.crm.util.ValidationUtil.isNotEmpty(fullName)
                || !com.crm.util.ValidationUtil.isValidPhone(phone)
                || roleIds.isEmpty()) {
            req.setAttribute("error", "Tài khoản phải có ít nhất một vai trò.");
            req.setAttribute("account", accountService.getAccountDetail(accountId));
            loadFormData(req);
            req.getRequestDispatcher("/WEB-INF/views/accounts/edit.jsp").forward(req, resp);
            return;
        }

        try {
            for (Integer roleId : roleIds) {
                if (roleDAO.findById(roleId) == null) {
                    resp.sendError(HttpServletResponse.SC_BAD_REQUEST);
                    return;
                }
            }
            if (teamId != null && teamDAO.findById(teamId) == null) {
                resp.sendError(HttpServletResponse.SC_BAD_REQUEST);
                return;
            }
        } catch (java.sql.SQLException e) {
            throw new ServletException("Không thể kiểm tra vai trò/nhóm.", e);
        }

        AccountUpdateRequest updateReq = new AccountUpdateRequest(accountId, fullName, phone, teamId, roleIds);
        boolean success = accountService.updateAccount(updateReq);
        if (success) {
            resp.sendRedirect(req.getContextPath() + "/accounts/detail?accountId=" + accountId + "&msg=updated");
        } else {
            req.setAttribute("error", "Cập nhật tài khoản thất bại.");
            req.setAttribute("account", accountService.getAccountDetail(accountId));
            loadFormData(req);
            req.getRequestDispatcher("/WEB-INF/views/accounts/edit.jsp").forward(req, resp);
        }
    }

    private void loadFormData(HttpServletRequest req) throws ServletException {
        try {
            req.setAttribute("roles", roleDAO.findAll());
            req.setAttribute("teams", teamDAO.findAll());
        } catch (java.sql.SQLException e) {
            throw new ServletException("Không thể tải danh sách vai trò/nhóm.", e);
        }
    }
}

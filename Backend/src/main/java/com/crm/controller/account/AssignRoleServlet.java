package com.crm.controller.account;

import com.crm.dao.AccountDAO;
import com.crm.dao.RoleDAO;
import com.crm.model.Account;
import com.crm.model.Role;
import com.crm.service.RoleService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

@WebServlet("/accounts/assign-role")
public class AssignRoleServlet extends HttpServlet {

    private RoleService roleService;
    private AccountDAO accountDAO;
    private RoleDAO roleDAO;

    @Override
    public void init() {
        roleService = new RoleService();
        accountDAO = new AccountDAO();
        roleDAO = new RoleDAO();
    }

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response
    ) throws ServletException, IOException {

        try {

            int accountId = Integer.parseInt(
                    request.getParameter("accountId")
            );

            Account account =
                    accountDAO.findById(accountId);

            if (account == null) {
                response.sendError(
                        HttpServletResponse.SC_NOT_FOUND
                );
                return;
            }

            request.setAttribute("account", account);

            request.setAttribute(
                    "roles",
                    roleService.getAllRoles()
            );

            request.setAttribute(
                    "teams",
                    roleService.getAllTeams()
            );

            request.getRequestDispatcher(
                    "/WEB-INF/views/accounts/assign-role.jsp"
            ).forward(request, response);

        } catch (NumberFormatException e) {

            response.sendError(
                    HttpServletResponse.SC_BAD_REQUEST
            );

        } catch (Exception e) {
            throw new ServletException(e);
        }
    }

    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response
    ) throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        try {

            int accountId = Integer.parseInt(
                    request.getParameter("accountId")
            );

            String[] roleIdValues = request.getParameterValues("roleIds");
            List<Integer> roleIds = new ArrayList<>();
            if (roleIdValues != null) {
                for (String value : roleIdValues) roleIds.add(Integer.parseInt(value));
            }
            String teamIdValue = request.getParameter("teamId");
            Integer teamId = teamIdValue == null || teamIdValue.isBlank() ? null : Integer.valueOf(teamIdValue);

            boolean validRoles = !roleIds.isEmpty();
            boolean isTeamLead = false;
            boolean hasAdminRole = false;

            for (Integer roleId : roleIds) {
                validRoles &= roleService.isValidRole(roleId);
                Role role = roleDAO.findById(roleId);
                if (role != null) {
                    if ("ADMIN".equals(role.getCode())) {
                        hasAdminRole = true;
                    }
                    if ("TEAM_LEAD".equals(role.getCode())) {
                        isTeamLead = true;
                    }
                }
            }

            if (!validRoles || (teamId != null && !roleService.isValidTeam(teamId))) {
                response.sendError(
                        HttpServletResponse.SC_BAD_REQUEST
                );
                return;
            }

            Integer loggedUserId = (Integer) request.getSession().getAttribute("userId");
            if (loggedUserId != null && loggedUserId.equals(accountId) && !hasAdminRole) {
                request.setAttribute("error", "Bạn không thể tự thu hồi vai trò Quản trị (Admin) của chính mình.");
                request.setAttribute("account", accountDAO.findById(accountId));
                request.setAttribute("roles", roleService.getAllRoles());
                request.setAttribute("teams", roleService.getAllTeams());
                request.getRequestDispatcher("/WEB-INF/views/accounts/assign-role.jsp").forward(request, response);
                return;
            }

            if (isTeamLead && teamId == null) {
                request.setAttribute("error", "Trưởng nhóm kinh doanh phải được gán vào một nhóm cụ thể.");
                request.setAttribute("account", accountDAO.findById(accountId));
                request.setAttribute("roles", roleService.getAllRoles());
                request.setAttribute("teams", roleService.getAllTeams());
                request.getRequestDispatcher("/WEB-INF/views/accounts/assign-role.jsp").forward(request, response);
                return;
            }

            com.crm.model.AuditLog auditLog = new com.crm.model.AuditLog();
            auditLog.setAction("ASSIGN_ROLE");
            auditLog.setUserId(loggedUserId != null ? loggedUserId : 0);
            auditLog.setTargetUserId(accountId);
            auditLog.setDetails("Gán vai trò và phòng ban cho tài khoản ID " + accountId);
            auditLog.setOldValue("Account ID: " + accountId);
            auditLog.setNewValue("Roles: " + roleIds.toString() + ", Team: " + teamId);

            boolean updated = accountDAO.updateRoleAndTeam(
                    accountId,
                    roleIds,
                    teamId,
                    auditLog
            );

            if (!updated) {
                response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                return;
            }

            response.sendRedirect(
                    request.getContextPath()
                    + "/accounts/detail?accountId="
                    + accountId
            );

        } catch (NumberFormatException e) {

            response.sendError(
                    HttpServletResponse.SC_BAD_REQUEST
            );

        } catch (Exception e) {
            throw new ServletException(e);
        }
    }
}

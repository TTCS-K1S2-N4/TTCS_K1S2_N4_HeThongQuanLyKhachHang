package com.crm.controller.account;

import com.crm.dao.AccountDAO;
import com.crm.model.Account;
import com.crm.service.RoleService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;

@WebServlet("/accounts/assign-role")
public class AssignRoleServlet extends HttpServlet {

    private RoleService roleService;
    private AccountDAO accountDAO;

    @Override
    public void init() {
        roleService = new RoleService();
        accountDAO = new AccountDAO();
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

            int roleId = Integer.parseInt(
                    request.getParameter("roleId")
            );

            int teamId = Integer.parseInt(
                    request.getParameter("teamId")
            );

            if (!roleService.isValidRole(roleId)
                    || !roleService.isValidTeam(teamId)) {

                response.sendError(
                        HttpServletResponse.SC_BAD_REQUEST
                );
                return;
            }

            accountDAO.updateRoleAndTeam(
                    accountId,
                    roleId,
                    teamId
            );

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
package com.crm.controller.account;

import com.crm.dto.AccountCreateRequest;
import com.crm.service.AccountService;
import com.crm.model.Role;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

@WebServlet("/accounts/create")
public class AccountCreateServlet extends HttpServlet {
    private final AccountService accountService = new AccountService();
    private final com.crm.dao.RoleDAO roleDAO = new com.crm.dao.RoleDAO();
    private final com.crm.dao.TeamDAO teamDAO = new com.crm.dao.TeamDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        try {
            req.setAttribute("roles", roleDAO.findAll());
            req.setAttribute("teams", teamDAO.findAll());
        } catch (java.sql.SQLException e) {
            e.printStackTrace();
        }
        req.getRequestDispatcher("/WEB-INF/views/accounts/create.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String email = req.getParameter("email");
        String fullName = req.getParameter("fullName");
        String phone = req.getParameter("phone");
        String[] roleIdsParam = req.getParameterValues("roleIds");
        String teamIdStr = req.getParameter("teamId");

        if (!com.crm.util.ValidationUtil.isValidEmail(email)
                || !com.crm.util.ValidationUtil.isNotEmpty(fullName)
                || !com.crm.util.ValidationUtil.isValidPhone(phone)) {
            req.setAttribute("error", "Email, họ tên hoặc số điện thoại không hợp lệ.");
            forwardWithData(req, resp);
            return;
        }

        List<Integer> roleIds = new ArrayList<>();
        Integer teamId;
        try {
            if (roleIdsParam != null) {
                for (String rid : roleIdsParam) {
                    if (rid != null && !rid.trim().isEmpty()) roleIds.add(Integer.parseInt(rid.trim()));
                }
            }
            teamId = (teamIdStr != null && !teamIdStr.isEmpty()) ? Integer.parseInt(teamIdStr) : null;
        } catch (NumberFormatException e) {
            req.setAttribute("error", "Vai trò hoặc nhóm không hợp lệ.");
            forwardWithData(req, resp);
            return;
        }
        
        if (roleIds.isEmpty()) {
            req.setAttribute("error", "Người dùng phải có ít nhất một vai trò.");
            forwardWithData(req, resp);
            return;
        }

        try {
            boolean isTeamLead = false;
            for (Integer rId : roleIds) {
                Role r = roleDAO.findById(rId);
                if (r == null) {
                    req.setAttribute("error", "Vai trò được chọn không tồn tại.");
                    forwardWithData(req, resp);
                    return;
                }
                if (r != null && "TEAM_LEAD".equals(r.getCode())) {
                    isTeamLead = true;
                    break;
                }
            }
            if (teamId != null && teamDAO.findById(teamId) == null) {
                req.setAttribute("error", "Nhóm được chọn không tồn tại.");
                forwardWithData(req, resp);
                return;
            }
            if (isTeamLead && teamId == null) {
                req.setAttribute("error", "Trưởng nhóm kinh doanh phải được gán vào một nhóm.");
                forwardWithData(req, resp);
                return;
            }
        } catch (java.sql.SQLException e) {
            throw new ServletException("Không thể kiểm tra vai trò/nhóm.", e);
        }

        AccountCreateRequest createReq = new AccountCreateRequest(email, null, fullName, phone, roleIds, teamId);

        if (accountService.isEmailExists(email)) {
            req.setAttribute("error", "Email này đã được sử dụng.");
            forwardWithData(req, resp);
            return;
        }

        boolean success = accountService.createAccount(createReq);
        if (success) {
            resp.sendRedirect(req.getContextPath() + "/accounts/list?msg=created");
        } else {
            req.setAttribute("error", "Không thể tạo tài khoản, vui lòng thử lại sau.");
            forwardWithData(req, resp);
        }
    }
    
    private void forwardWithData(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        try {
            req.setAttribute("roles", roleDAO.findAll());
            req.setAttribute("teams", teamDAO.findAll());
        } catch (java.sql.SQLException e) {
            e.printStackTrace();
        }
        req.getRequestDispatcher("/WEB-INF/views/accounts/create.jsp").forward(req, resp);
    }
}

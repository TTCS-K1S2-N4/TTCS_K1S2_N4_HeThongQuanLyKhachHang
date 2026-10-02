package com.crm.controller.opportunity;

import com.crm.dao.OpportunityDAO;
import com.crm.model.Opportunity;
import com.crm.service.PermissionService;
import com.crm.exception.AuthorizationException;
import com.crm.util.ValidationUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.Collections;
import java.util.List;

@WebServlet("/deals/detail")
public class OpportunityDetailServlet extends HttpServlet {
    private OpportunityDAO dao = new OpportunityDAO();
    private PermissionService permissionService = new PermissionService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String idStr = req.getParameter("id");
        if (idStr == null || idStr.isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/deals");
            return;
        }

        try {
            int id = Integer.parseInt(idStr);
            Opportunity obj = dao.findById(id);
            if (obj == null) {
                resp.sendError(HttpServletResponse.SC_NOT_FOUND);
                return;
            }

            // Enforce Data Scope here using central PermissionService
            Integer userId = (Integer) req.getSession().getAttribute("userId");
            List<Integer> roleIds = ValidationUtil.getSafeIntegerList(req.getAttribute("effectiveRoleIds"));
            Integer roleId = (Integer) req.getSession().getAttribute("roleId");

            if (userId == null || (roleId == null && (roleIds == null || roleIds.isEmpty()))) {
                resp.sendRedirect(req.getContextPath() + "/auth/login");
                return;
            }

            List<Integer> effectiveRoles = (roleIds != null && !roleIds.isEmpty()) ? roleIds : Collections.singletonList(roleId);

            try {
                permissionService.validateDataAccessForRoles(userId, effectiveRoles, "DEAL", obj.getOwnerId());
            } catch (AuthorizationException e) {
                req.setAttribute("errorMessage", "Bạn không có quyền truy cập dữ liệu này.");
                req.setAttribute("exception", e);
                resp.sendError(HttpServletResponse.SC_FORBIDDEN);
                return;
            }

            req.setAttribute("opportunity", obj);
            req.getRequestDispatcher("/WEB-INF/views/deals/detail.jsp").forward(req, resp);
        } catch (NumberFormatException e) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST);
        } catch (ServletException e) {
            throw e;
        } catch (Exception e) {
            throw new ServletException("Không thể tải chi tiết cơ hội.", e);
        }
    }
}



package com.crm.controller.activity;

import com.crm.dao.ActivityDAO;
import com.crm.model.Activity;
import com.crm.service.PermissionService;
import com.crm.exception.AuthorizationException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet("/activities/detail")
public class ActivityDetailServlet extends HttpServlet {
    private ActivityDAO dao = new ActivityDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String idStr = req.getParameter("id");
        if (idStr == null || idStr.isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/activities");
            return;
        }

        try {
            int id = Integer.parseInt(idStr);
            Activity obj = dao.findById(id);
            if (obj == null) {
                resp.sendError(HttpServletResponse.SC_NOT_FOUND);
                return;
            }

            // Enforce Data Scope here using PermissionService
            PermissionService permissionService = new PermissionService();
            Integer userId = (Integer) req.getSession().getAttribute("userId");
            java.util.List<Integer> roleIds = com.crm.util.ValidationUtil.getSafeIntegerList(req.getAttribute("effectiveRoleIds"));
            Integer roleId = (Integer) req.getSession().getAttribute("roleId");

            if (userId == null || roleId == null) {
                resp.sendRedirect(req.getContextPath() + "/auth/login");
                return;
            }
            
            try {
                permissionService.validateDataAccessForRoles(userId, roleIds != null && !roleIds.isEmpty() ? roleIds : java.util.Collections.singletonList(roleId), "ACTIVITY", obj.getOwnerId());
            } catch (AuthorizationException e) {
                req.setAttribute("errorMessage", "Bạn không có quyền truy cập dữ liệu này.");
                resp.sendError(HttpServletResponse.SC_FORBIDDEN);
                return;
            }

            req.setAttribute("activity", obj);
            req.getRequestDispatcher("/WEB-INF/views/activities/detail.jsp").forward(req, resp);
        } catch (NumberFormatException e) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST);
        } catch (Exception e) {
            throw new ServletException("Không thể tải chi tiết hoạt động.", e);
        }
    }
}



package com.crm.controller.quote;

import com.crm.dao.QuoteDAO;
import com.crm.model.Quote;
import com.crm.service.PermissionService;
import com.crm.exception.AuthorizationException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet("/quotes/detail")
public class QuoteDetailServlet extends HttpServlet {
    private QuoteDAO dao = new QuoteDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String idStr = req.getParameter("id");
        if (idStr == null || idStr.isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/quotes");
            return;
        }

        try {
            int id = Integer.parseInt(idStr);
            Quote obj = dao.findById(id);
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
                permissionService.validateDataAccessForRoles(userId, roleIds != null && !roleIds.isEmpty() ? roleIds : java.util.Collections.singletonList(roleId), "QUOTE", obj.getOwnerId());
            } catch (AuthorizationException e) {
                req.setAttribute("errorMessage", "Bạn không có quyền truy cập dữ liệu này.");
                resp.sendError(HttpServletResponse.SC_FORBIDDEN);
                return;
            }

            req.setAttribute("quote", obj);
            req.getRequestDispatcher("/WEB-INF/views/quotes/detail.jsp").forward(req, resp);
        } catch (NumberFormatException e) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST);
        } catch (Exception e) {
            throw new ServletException("Không thể tải chi tiết báo giá.", e);
        }
    }
}



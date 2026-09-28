package com.crm.controller.customer;

import com.crm.dao.CustomerDAO;
import com.crm.model.Customer;
import com.crm.service.PermissionService;
import com.crm.exception.AuthorizationException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet("/customers/detail")
public class CustomerDetailServlet extends HttpServlet {
    private CustomerDAO dao = new CustomerDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String idStr = req.getParameter("id");
        if (idStr == null || idStr.isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/customers");
            return;
        }

        try {
            int id = Integer.parseInt(idStr);
            Customer obj = dao.findById(id);
            if (obj == null) {
                // Handle not found securely
                req.setAttribute("errorMessage", "BÃ¡ÂºÂ¡n khÃƒÂ´ng cÃƒÂ³ quyÃ¡Â»Ân truy cÃ¡ÂºÂ­p dÃ¡Â»Â¯ liÃ¡Â»â€¡u nÃƒÂ y hoÃ¡ÂºÂ·c dÃ¡Â»Â¯ liÃ¡Â»â€¡u khÃƒÂ´ng tÃ¡Â»â€œn tÃ¡ÂºÂ¡i.");
                req.getRequestDispatcher("/WEB-INF/views/customers/detail.jsp").forward(req, resp);
                return;
            }

            // Enforce Data Scope here using PermissionService
            PermissionService permissionService = new PermissionService();
            Integer userId = (Integer) req.getSession().getAttribute("userId");
            java.util.List<Integer> roleIds = com.crm.util.ValidationUtil.getSafeIntegerList(req.getSession().getAttribute("roleIds"));
            Integer roleId = (Integer) req.getSession().getAttribute("roleId");

            if (userId == null || roleId == null) {
                resp.sendRedirect(req.getContextPath() + "/auth/login");
                return;
            }
            
            try {
                permissionService.validateDataAccessForRoles(userId, roleIds != null ? roleIds : java.util.Collections.singletonList(roleId), "ACCOUNT", obj.getOwnerId());
            } catch (AuthorizationException e) {
                req.setAttribute("errorMessage", "BÃ¡ÂºÂ¡n khÃƒÂ´ng cÃƒÂ³ quyÃ¡Â»Ân truy cÃ¡ÂºÂ­p dÃ¡Â»Â¯ liÃ¡Â»â€¡u nÃƒÂ y.");
                req.getRequestDispatcher("/WEB-INF/views/customer/detail.jsp").forward(req, resp);
                return;
            }

            req.setAttribute("customer", obj);
            req.getRequestDispatcher("/WEB-INF/views/customers/detail.jsp").forward(req, resp);
        } catch (Exception e) {
            req.setAttribute("errorMessage", "BÃ¡ÂºÂ¡n khÃƒÂ´ng cÃƒÂ³ quyÃ¡Â»Ân truy cÃ¡ÂºÂ­p dÃ¡Â»Â¯ liÃ¡Â»â€¡u nÃƒÂ y.");
            req.getRequestDispatcher("/WEB-INF/views/customers/detail.jsp").forward(req, resp);
        }
    }
}



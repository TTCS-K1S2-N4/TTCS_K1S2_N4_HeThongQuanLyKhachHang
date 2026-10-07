package com.crm.controller.customer;

import com.crm.dao.CustomerDAO;
import com.crm.model.Customer;
import com.crm.service.PermissionService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

@WebServlet("/customers")
public class CustomerListServlet extends HttpServlet {
    private CustomerDAO dao = new CustomerDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String keyword = req.getParameter("keyword");
        int page = 1;
        try { page = Integer.parseInt(req.getParameter("page")); } catch (Exception e) {}
        int pageSize = 20;

        PermissionService permissionService = new PermissionService();
        Integer userId = (Integer) req.getSession().getAttribute("userId");
        java.util.List<Integer> roleIds = com.crm.util.ValidationUtil.getSafeIntegerList(req.getAttribute("effectiveRoleIds"));
            Integer roleId = (Integer) req.getSession().getAttribute("roleId");
        
        if (userId == null || roleId == null) {
            resp.sendRedirect(req.getContextPath() + "/auth/login");
            return;
        }
        
        List<Integer> ownerIds = permissionService.getAccessibleAccountIdsForRoles(userId, roleIds != null && !roleIds.isEmpty() ? roleIds : java.util.Collections.singletonList(roleId), "ACCOUNT");

        String filterFieldIdStr = req.getParameter("filterFieldId");
        String filterFieldValue = req.getParameter("filterFieldValue");
        Integer filterFieldId = null;
        if (filterFieldIdStr != null && !filterFieldIdStr.trim().isEmpty()) {
            try { filterFieldId = Integer.parseInt(filterFieldIdStr.trim()); } catch (Exception ignored) {}
        }

        com.crm.service.CustomFieldService customFieldService = new com.crm.service.CustomFieldService();
        List<com.crm.model.CustomFieldDefinition> customFieldDefs = customFieldService.getDefinitions("CUSTOMER", "ACTIVE");

        List<Customer> list = dao.getList(keyword, ownerIds, filterFieldId, filterFieldValue, page, pageSize);
        int total = dao.count(keyword, ownerIds, filterFieldId, filterFieldValue);
        int totalPages = (int) Math.ceil((double) total / pageSize);

        req.setAttribute("list", list);
        req.setAttribute("currentPage", page);
        req.setAttribute("totalPages", totalPages);
        req.setAttribute("keyword", keyword);
        req.setAttribute("customFieldDefinitions", customFieldDefs);
        req.setAttribute("filterFieldId", filterFieldId);
        req.setAttribute("filterFieldValue", filterFieldValue);

        req.getRequestDispatcher("/WEB-INF/views/customers/list.jsp").forward(req, resp);
    }

}



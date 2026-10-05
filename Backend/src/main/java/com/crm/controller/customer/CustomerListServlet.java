package com.crm.controller.customer;

import com.crm.dto.CustomerFilterRequest;
import com.crm.model.Customer;
import com.crm.model.SavedFilter;
import com.crm.service.CustomerFilterService;
import com.crm.util.ValidationUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.Collections;
import java.util.List;

@WebServlet("/customers")
public class CustomerListServlet extends HttpServlet {
    private CustomerFilterService filterService = new CustomerFilterService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");

        Integer userId = (Integer) req.getSession().getAttribute("userId");
        List<Integer> roleIds = ValidationUtil.getSafeIntegerList(req.getAttribute("effectiveRoleIds"));
        Integer roleId = (Integer) req.getSession().getAttribute("roleId");

        if (userId == null || (roleId == null && (roleIds == null || roleIds.isEmpty()))) {
            resp.sendRedirect(req.getContextPath() + "/auth/login");
            return;
        }

        List<Integer> effectiveRoles = (roleIds != null && !roleIds.isEmpty()) ? roleIds : Collections.singletonList(roleId);

        CustomerFilterRequest filterReq = new CustomerFilterRequest();
        filterReq.setKeyword(req.getParameter("keyword"));
        filterReq.setStatus(req.getParameter("status"));
        filterReq.setIndustry(req.getParameter("industry"));
        
        String sizeParam = req.getParameter("size");
        if (sizeParam == null || sizeParam.isEmpty()) {
            sizeParam = req.getParameter("companySize");
        }
        filterReq.setCompanySize(sizeParam);
        filterReq.setRegion(req.getParameter("region"));

        String oidStr = req.getParameter("ownerId");
        if (oidStr != null && !oidStr.trim().isEmpty()) {
            try { filterReq.setOwnerId(Integer.parseInt(oidStr.trim())); } catch (NumberFormatException ignored) {}
        }

        int page = 1;
        try { page = Integer.parseInt(req.getParameter("page")); } catch (Exception ignored) {}
        filterReq.setPage(page);

        int pageSize = 20;
        try { pageSize = Integer.parseInt(req.getParameter("pageSize")); } catch (Exception ignored) {}
        filterReq.setPageSize(pageSize);

        List<Customer> list = filterService.filterCustomers(filterReq, userId, effectiveRoles);
        int total = filterService.countFilteredCustomers(filterReq, userId, effectiveRoles);
        int totalPages = (int) Math.ceil((double) total / pageSize);
        if (totalPages <= 0) totalPages = 1;

        List<SavedFilter> savedFilters = filterService.getSavedFilters(userId);

        boolean isJson = "json".equalsIgnoreCase(req.getParameter("format")) ||
                (req.getHeader("Accept") != null && req.getHeader("Accept").contains("application/json")) ||
                "XMLHttpRequest".equals(req.getHeader("X-Requested-With"));

        if (isJson) {
            resp.setContentType("application/json; charset=UTF-8");
            PrintWriter out = resp.getWriter();
            out.print(buildCustomerListJson(list, total, page, totalPages));
            out.flush();
        } else {
            req.setAttribute("list", list);
            req.setAttribute("total", total);
            req.setAttribute("totalCount", total);
            req.setAttribute("currentPage", page);
            req.setAttribute("totalPages", totalPages);
            req.setAttribute("keyword", filterReq.getKeyword());
            req.setAttribute("status", filterReq.getStatus());
            req.setAttribute("industry", filterReq.getIndustry());
            req.setAttribute("size", filterReq.getCompanySize());
            req.setAttribute("companySize", filterReq.getCompanySize());
            req.setAttribute("region", filterReq.getRegion());
            req.setAttribute("ownerId", filterReq.getOwnerId());
            req.setAttribute("savedFilters", savedFilters);
            req.setAttribute("filterRequest", filterReq);

            req.getRequestDispatcher("/WEB-INF/views/customers/list.jsp").forward(req, resp);
        }
    }

    private String buildCustomerListJson(List<Customer> list, int total, int page, int totalPages) {
        StringBuilder sb = new StringBuilder("{");
        sb.append("\"total\":").append(total).append(",");
        sb.append("\"page\":").append(page).append(",");
        sb.append("\"totalPages\":").append(totalPages).append(",");
        sb.append("\"items\":[");
        for (int i = 0; i < list.size(); i++) {
            Customer c = list.get(i);
            if (i > 0) sb.append(",");
            sb.append("{");
            sb.append("\"customerId\":").append(c.getCustomerId()).append(",");
            sb.append("\"customerName\":\"").append(escapeJson(c.getCustomerName())).append("\",");
            sb.append("\"taxCode\":\"").append(escapeJson(c.getTaxCode())).append("\",");
            sb.append("\"phone\":\"").append(escapeJson(c.getPhone())).append("\",");
            sb.append("\"email\":\"").append(escapeJson(c.getEmail())).append("\",");
            sb.append("\"status\":\"").append(escapeJson(c.getStatus())).append("\",");
            sb.append("\"industry\":\"").append(escapeJson(c.getIndustry())).append("\",");
            sb.append("\"companySize\":\"").append(escapeJson(c.getCompanySize())).append("\",");
            sb.append("\"region\":\"").append(escapeJson(c.getRegion())).append("\",");
            sb.append("\"ownerId\":").append(c.getOwnerId());
            sb.append("}");
        }
        sb.append("]}");
        return sb.toString();
    }

    private String escapeJson(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", "\\n").replace("\r", "\\r");
    }
}

package com.crm.controller.customer;

import com.crm.dto.Customer360Response;
import com.crm.exception.AuthorizationException;
import com.crm.service.Customer360Service;
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

@WebServlet(urlPatterns = {"/customers/360", "/customers/360/*"})
public class Customer360Servlet extends HttpServlet {
    private Customer360Service customer360Service = new Customer360Service();

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

        int customerId = parseCustomerId(req);
        if (customerId <= 0) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Thiếu hoặc sai Customer ID.");
            return;
        }

        try {
            Customer360Response data = customer360Service.getCustomer360(customerId, userId, effectiveRoles);
            if (data == null) {
                resp.sendError(HttpServletResponse.SC_NOT_FOUND, "Không tìm thấy khách hàng.");
                return;
            }

            boolean isJson = "json".equalsIgnoreCase(req.getParameter("format")) ||
                    (req.getHeader("Accept") != null && req.getHeader("Accept").contains("application/json")) ||
                    "XMLHttpRequest".equals(req.getHeader("X-Requested-With"));

            if (isJson) {
                resp.setContentType("application/json; charset=UTF-8");
                PrintWriter out = resp.getWriter();
                out.print(buildJsonResponse(data));
                out.flush();
            } else {
                req.setAttribute("customer360", data);
                req.setAttribute("customer", data.getCustomer());
                req.setAttribute("contacts", data.getContacts());
                req.setAttribute("openOpportunities", data.getOpenOpportunities());
                req.setAttribute("closedOpportunities", data.getClosedOpportunities());
                req.setAttribute("totalOpenOpportunityValue", data.getTotalOpenOpportunityValue());
                req.setAttribute("openOpportunityValue", data.getTotalOpenOpportunityValue());
                req.setAttribute("signedValue", data.getSignedValue());
                req.setAttribute("activities", data.getActivities());
                req.setAttribute("attachments", data.getAttachments());
                req.getRequestDispatcher("/WEB-INF/views/customers/360.jsp").forward(req, resp);
            }
        } catch (AuthorizationException e) {
            req.setAttribute("errorMessage", e.getMessage());
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, e.getMessage());
        } catch (Exception e) {
            throw new ServletException("Lỗi khi tải thông tin Customer 360", e);
        }
    }

    private int parseCustomerId(HttpServletRequest req) {
        String pathInfo = req.getPathInfo();
        if (pathInfo != null && !pathInfo.trim().isEmpty() && !"/".equals(pathInfo)) {
            String clean = pathInfo.replaceAll("^/", "").replaceAll("/360$", "");
            try {
                return Integer.parseInt(clean);
            } catch (NumberFormatException ignored) {}
        }

        String idStr = req.getParameter("customerId");
        if (idStr == null || idStr.isEmpty()) {
            idStr = req.getParameter("id");
        }
        if (idStr != null && !idStr.isEmpty()) {
            try {
                return Integer.parseInt(idStr);
            } catch (NumberFormatException ignored) {}
        }
        return 0;
    }

    private String buildJsonResponse(Customer360Response data) {
        StringBuilder json = new StringBuilder("{");
        json.append("\"customerId\":").append(data.getCustomer().getCustomerId()).append(",");
        json.append("\"customerName\":\"").append(escapeJson(data.getCustomer().getCustomerName())).append("\",");
        json.append("\"phone\":\"").append(escapeJson(data.getCustomer().getPhone())).append("\",");
        json.append("\"ownerId\":").append(data.getCustomer().getOwnerId()).append(",");
        json.append("\"totalOpenOpportunityValue\":").append(data.getTotalOpenOpportunityValue()).append(",");
        json.append("\"openOpportunitiesCount\":").append(data.getOpenOpportunities().size()).append(",");
        json.append("\"closedOpportunitiesCount\":").append(data.getClosedOpportunities().size()).append(",");
        json.append("\"totalActivities\":").append(data.getTotalActivities());
        json.append("}");
        return json.toString();
    }

    private String escapeJson(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", "\\n").replace("\r", "\\r");
    }
}

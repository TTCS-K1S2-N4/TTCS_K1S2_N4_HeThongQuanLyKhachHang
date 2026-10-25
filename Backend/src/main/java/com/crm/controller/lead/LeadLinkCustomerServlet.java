package com.crm.controller.lead;

import com.crm.service.LeadDuplicateService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;

/**
 * Controller xử lý liên kết Lead trùng vào Khách hàng đã có sẵn trong hệ thống.
 * Ánh xạ API D04: POST /leads/link-customer (S4-04-AC-02).
 */
@WebServlet("/leads/link-customer")
public class LeadLinkCustomerServlet extends HttpServlet {

    private LeadDuplicateService duplicateService = new LeadDuplicateService();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");

        HttpSession session = req.getSession(false);
        Integer userId = session != null ? (Integer) session.getAttribute("userId") : null;
        boolean isJson = isJsonRequest(req);

        if (userId == null) {
            if (isJson) {
                resp.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                resp.setContentType("application/json; charset=UTF-8");
                resp.getWriter().write("{\"status\":\"error\",\"message\":\"Vui lòng đăng nhập.\"}");
            } else {
                resp.sendRedirect(req.getContextPath() + "/auth/login");
            }
            return;
        }

        if (!isAuthorizedRole(session)) {
            sendError(resp, "Bạn không có quyền thực hiện thao tác gắn Lead vào Khách hàng.", isJson, HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        String leadIdStr = req.getParameter("leadId");
        String customerIdStr = req.getParameter("customerId");

        if (leadIdStr == null || customerIdStr == null || leadIdStr.trim().isEmpty() || customerIdStr.trim().isEmpty()) {
            sendError(resp, "Cần cung cấp đủ leadId và customerId.", isJson, HttpServletResponse.SC_BAD_REQUEST);
            return;
        }

        int leadId;
        int customerId;
        try {
            leadId = Integer.parseInt(leadIdStr.trim());
            customerId = Integer.parseInt(customerIdStr.trim());
        } catch (NumberFormatException e) {
            sendError(resp, "Tham số leadId hoặc customerId không hợp lệ.", isJson, HttpServletResponse.SC_BAD_REQUEST);
            return;
        }

        try {
            boolean success = duplicateService.linkLeadToCustomer(leadId, customerId, userId);
            if (success) {
                if (isJson) {
                    resp.setStatus(HttpServletResponse.SC_OK);
                    resp.setContentType("application/json; charset=UTF-8");
                    PrintWriter out = resp.getWriter();
                    out.print("{\"status\":\"success\",\"message\":\"Liên kết Lead vào Khách hàng thành công\",\"leadId\":" + leadId + ",\"customerId\":" + customerId + "}");
                    out.flush();
                } else {
                    resp.sendRedirect(req.getContextPath() + "/leads/duplicates?linked=true&leadId=" + leadId + "&customerId=" + customerId);
                }
            } else {
                sendError(resp, "Không thể liên kết Lead vào Khách hàng.", isJson, HttpServletResponse.SC_BAD_REQUEST);
            }
        } catch (IllegalArgumentException e) {
            sendError(resp, e.getMessage(), isJson, HttpServletResponse.SC_BAD_REQUEST);
        } catch (Exception e) {
            sendError(resp, "Lỗi hệ thống khi liên kết: " + e.getMessage(), isJson, HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }

    private boolean isJsonRequest(HttpServletRequest req) {
        return "json".equalsIgnoreCase(req.getParameter("format")) ||
                (req.getHeader("Accept") != null && req.getHeader("Accept").contains("application/json")) ||
                "XMLHttpRequest".equals(req.getHeader("X-Requested-With"));
    }

    private void sendError(HttpServletResponse resp, String message, boolean isJson, int statusCode) throws IOException {
        if (isJson) {
            resp.setStatus(statusCode);
            resp.setContentType("application/json; charset=UTF-8");
            resp.getWriter().write("{\"status\":\"error\",\"message\":\"" + escapeJson(message) + "\"}");
        } else {
            resp.sendError(statusCode, message);
        }
    }

    private String escapeJson(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", "\\n").replace("\r", "\\r");
    }

    @SuppressWarnings("unchecked")
    private boolean isAuthorizedRole(HttpSession session) {
        if (session == null) return false;
        List<Integer> roleIds = (List<Integer>) session.getAttribute("roleIds");
        Integer roleId = (Integer) session.getAttribute("roleId");

        // Quản trị (1), Giám đốc (4), Trưởng nhóm (3), Marketing (5), Nhân viên kinh doanh (2)
        return hasRole(roleIds, roleId, 1) || hasRole(roleIds, roleId, 4) || hasRole(roleIds, roleId, 3) || hasRole(roleIds, roleId, 5) || hasRole(roleIds, roleId, 2);
    }

    private boolean hasRole(List<Integer> roleIds, Integer roleId, int targetRoleId) {
        if (roleId != null && roleId == targetRoleId) return true;
        return roleIds != null && roleIds.contains(targetRoleId);
    }
}

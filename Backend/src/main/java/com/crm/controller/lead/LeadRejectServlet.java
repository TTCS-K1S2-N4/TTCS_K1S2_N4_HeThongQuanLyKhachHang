package com.crm.controller.lead;

import com.crm.model.Account;
import com.crm.service.LeadSlaService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.SQLException;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * LeadRejectServlet - API cho nhân viên từ chối Lead kèm lý do hợp lệ (S4-07).
 * Endpoint: POST /leads/reject
 */
@WebServlet("/leads/reject")
public class LeadRejectServlet extends HttpServlet {
    private static final Logger LOGGER = Logger.getLogger(LeadRejectServlet.class.getName());

    private LeadSlaService slaService;

    @Override
    public void init() throws ServletException {
        super.init();
        this.slaService = new LeadSlaService();
    }

    public void setSlaService(LeadSlaService slaService) {
        this.slaService = slaService;
    }

    @Override
    public void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.setContentType("application/json;charset=UTF-8");

        try {
            // 1. Xác thực người dùng (Authentication from trusted server-side Session exclusively)
            HttpSession session = req.getSession(false);
            Integer currentUserId = (session != null && session.getAttribute("userId") instanceof Integer)
                    ? (Integer) session.getAttribute("userId")
                    : null;

            if (currentUserId == null) {
                sendJsonResponse(resp, HttpServletResponse.SC_UNAUTHORIZED, "error", "Yêu cầu đăng nhập để thực hiện từ chối Lead.");
                return;
            }

            // 2. Xác định vai trò đặc quyền (ADMIN / DIRECTOR)
            Account currentUser = (session.getAttribute("currentUser") instanceof Account)
                    ? (Account) session.getAttribute("currentUser")
                    : null;
            Integer roleId = (session.getAttribute("roleId") instanceof Integer)
                    ? (Integer) session.getAttribute("roleId")
                    : (currentUser != null ? currentUser.getRoleId() : null);

            boolean isElevatedRole = false;
            if (currentUser != null && currentUser.getRoleCodes() != null) {
                for (String code : currentUser.getRoleCodes()) {
                    if ("ADMIN".equalsIgnoreCase(code) || "DIRECTOR".equalsIgnoreCase(code)) {
                        isElevatedRole = true;
                        break;
                    }
                }
            }
            if (!isElevatedRole && roleId != null && (roleId == 1 || roleId == 4)) {
                isElevatedRole = true;
            }

            // 3. Đọc tham số leadId và rejectReason (hỗ trợ cả x-www-form-urlencoded và application/json)
            String leadIdStr = req.getParameter("leadId");
            String rejectReason = req.getParameter("rejectReason");

            if ((leadIdStr == null || leadIdStr.trim().isEmpty() || rejectReason == null) &&
                req.getContentType() != null && req.getContentType().contains("application/json")) {
                StringBuilder sb = new StringBuilder();
                try (java.io.BufferedReader reader = req.getReader()) {
                    String line;
                    while ((line = reader.readLine()) != null) {
                        sb.append(line);
                    }
                }
                String json = sb.toString();
                if (leadIdStr == null || leadIdStr.trim().isEmpty()) {
                    leadIdStr = LeadAssignServlet.extractJsonField(json, "leadId");
                }
                if (rejectReason == null) {
                    rejectReason = LeadAssignServlet.extractJsonField(json, "rejectReason");
                }
            }

            if (leadIdStr == null || leadIdStr.trim().isEmpty()) {
                sendJsonResponse(resp, HttpServletResponse.SC_BAD_REQUEST, "error", "Tham số leadId là bắt buộc.");
                return;
            }

            if (rejectReason == null || rejectReason.trim().isEmpty()) {
                sendJsonResponse(resp, HttpServletResponse.SC_BAD_REQUEST, "error", "Lý do từ chối Lead (rejectReason) là bắt buộc.");
                return;
            }

            int leadId;
            try {
                leadId = Integer.parseInt(leadIdStr.trim());
            } catch (NumberFormatException e) {
                sendJsonResponse(resp, HttpServletResponse.SC_BAD_REQUEST, "error", "Định dạng leadId không hợp lệ.");
                return;
            }

            // 4. Xử lý nghiệp vụ từ chối Lead qua JDBC Transaction
            boolean rejected = slaService.rejectLead(leadId, currentUserId, rejectReason.trim(), isElevatedRole);
            if (rejected) {
                sendJsonSuccess(resp, leadId, "Lead đã được từ chối và quay trở lại hàng chờ phân bổ.");
            } else {
                sendJsonResponse(resp, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "error", "Từ chối Lead thất bại.");
            }

        } catch (SecurityException e) {
            sendJsonResponse(resp, HttpServletResponse.SC_FORBIDDEN, "error", e.getMessage());
        } catch (IllegalArgumentException e) {
            int status = (e.getMessage() != null && e.getMessage().contains("không tồn tại"))
                    ? HttpServletResponse.SC_NOT_FOUND
                    : HttpServletResponse.SC_BAD_REQUEST;
            sendJsonResponse(resp, status, "error", e.getMessage());
        } catch (IllegalStateException e) {
            sendJsonResponse(resp, HttpServletResponse.SC_CONFLICT, "error", e.getMessage());
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Lỗi SQL khi từ chối Lead", e);
            sendJsonResponse(resp, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "error", "Lỗi cơ sở dữ liệu khi từ chối Lead.");
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Lỗi hệ thống khi từ chối Lead", e);
            sendJsonResponse(resp, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "error", "Lỗi hệ thống nội bộ.");
        }
    }

    private void sendJsonSuccess(HttpServletResponse resp, int leadId, String message) throws IOException {
        resp.setStatus(HttpServletResponse.SC_OK);
        PrintWriter out = resp.getWriter();
        out.write("{\"status\": \"success\", \"leadId\": " + leadId + ", \"message\": \"" + escapeJson(message) + "\"}");
        out.flush();
    }

    private void sendJsonResponse(HttpServletResponse resp, int statusCode, String status, String message) throws IOException {
        resp.setStatus(statusCode);
        PrintWriter out = resp.getWriter();
        out.write("{\"status\": \"" + status + "\", \"message\": \"" + escapeJson(message) + "\"}");
        out.flush();
    }

    private String escapeJson(String input) {
        if (input == null) return "";
        return input.replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", "\\n").replace("\r", "");
    }
}

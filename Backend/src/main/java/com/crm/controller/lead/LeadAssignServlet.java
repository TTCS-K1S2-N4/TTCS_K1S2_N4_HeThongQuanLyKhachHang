package com.crm.controller.lead;

import com.crm.model.Account;
import com.crm.service.LeadAssignmentService;
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
 * LeadAssignServlet - API phân bổ Lead thủ công hoặc tự động (S4-06).
 * Endpoint: POST /leads/assign
 */
@WebServlet("/leads/assign")
public class LeadAssignServlet extends HttpServlet {
    private static final Logger LOGGER = Logger.getLogger(LeadAssignServlet.class.getName());
    
    private LeadAssignmentService assignmentService;

    @Override
    public void init() throws ServletException {
        super.init();
        this.assignmentService = new LeadAssignmentService();
        this.assignmentService.startBackgroundWorker();
    }

    public void setAssignmentService(LeadAssignmentService assignmentService) {
        this.assignmentService = assignmentService;
    }

    @Override
    public void destroy() {
        if (this.assignmentService != null) {
            this.assignmentService.stopBackgroundWorker();
        }
        super.destroy();
    }

    @Override
    public void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.setContentType("application/json;charset=UTF-8");

        try {
            // 1. Xác thực người dùng (Authentication from trusted Session exclusively)
            HttpSession session = req.getSession(false);
            Integer currentUserId = (session != null && session.getAttribute("userId") instanceof Integer)
                    ? (Integer) session.getAttribute("userId")
                    : null;

            if (currentUserId == null) {
                sendJsonResponse(resp, HttpServletResponse.SC_UNAUTHORIZED, "error", "Yêu cầu đăng nhập để thực hiện phân bổ Lead.");
                return;
            }

            // 2. Phân quyền & Xác định Data Scope (ADMIN / DIRECTOR -> ALL, TEAM_LEAD -> TEAM, SALES_REP -> CẤM)
            Account currentUser = (session != null && session.getAttribute("currentUser") instanceof Account)
                    ? (Account) session.getAttribute("currentUser")
                    : null;
            Integer roleId = (session != null && session.getAttribute("roleId") instanceof Integer)
                    ? (Integer) session.getAttribute("roleId")
                    : (currentUser != null ? currentUser.getRoleId() : null);

            boolean isAdminOrDirector = false;
            boolean isTeamLead = false;

            if (currentUser != null && currentUser.getRoleCodes() != null) {
                for (String code : currentUser.getRoleCodes()) {
                    if ("ADMIN".equalsIgnoreCase(code) || "DIRECTOR".equalsIgnoreCase(code)) {
                        isAdminOrDirector = true;
                    }
                    if ("TEAM_LEAD".equalsIgnoreCase(code) || "TEAM_LEADER".equalsIgnoreCase(code) || "LEADER".equalsIgnoreCase(code)) {
                        isTeamLead = true;
                    }
                }
            }

            // Đối chiếu theo roleId chuẩn hóa hệ thống: 1: ADMIN, 4: DIRECTOR, 3: TEAM_LEAD
            if (!isAdminOrDirector && !isTeamLead && roleId != null) {
                if (roleId == 1 || roleId == 4) {
                    isAdminOrDirector = true;
                } else if (roleId == 3) {
                    isTeamLead = true;
                }
            }

            if (!isAdminOrDirector && !isTeamLead) {
                sendJsonResponse(resp, HttpServletResponse.SC_FORBIDDEN, "error", "Chỉ Trưởng nhóm hoặc Quản trị viên mới có quyền phân bổ Lead.");
                return;
            }

            // Lấy teamId của người gọi để kiểm soát Data Scope TEAM
            Integer callerTeamId = null;
            if (isTeamLead && !isAdminOrDirector) {
                Object tIdObj = session.getAttribute("teamId");
                if (tIdObj instanceof Integer) {
                    callerTeamId = (Integer) tIdObj;
                } else if (currentUser != null) {
                    callerTeamId = currentUser.getTeamId();
                }
            }

            // 3. Đọc và kiểm tra tính hợp lệ của tham số (hỗ trợ cả form-urlencoded và application/json)
            String leadIdStr = req.getParameter("leadId");
            String assigneeIdStr = req.getParameter("assigneeId");
            if (assigneeIdStr == null || assigneeIdStr.trim().isEmpty()) {
                assigneeIdStr = req.getParameter("userId");
            }
            String region = req.getParameter("region");
            String industry = req.getParameter("industry");

            if ((leadIdStr == null || leadIdStr.trim().isEmpty()) &&
                req.getContentType() != null && req.getContentType().contains("application/json")) {
                StringBuilder sb = new StringBuilder();
                try (java.io.BufferedReader reader = req.getReader()) {
                    String line;
                    while ((line = reader.readLine()) != null) {
                        sb.append(line);
                    }
                }
                String json = sb.toString();
                leadIdStr = extractJsonField(json, "leadId");
                if (assigneeIdStr == null || assigneeIdStr.trim().isEmpty()) {
                    assigneeIdStr = extractJsonField(json, "assigneeId");
                    if (assigneeIdStr == null || assigneeIdStr.trim().isEmpty()) {
                        assigneeIdStr = extractJsonField(json, "userId");
                    }
                }
                if (region == null) region = extractJsonField(json, "region");
                if (industry == null) industry = extractJsonField(json, "industry");
            }

            if (leadIdStr == null || leadIdStr.trim().isEmpty()) {
                sendJsonResponse(resp, HttpServletResponse.SC_BAD_REQUEST, "error", "Tham số leadId là bắt buộc.");
                return;
            }

            int leadId;
            try {
                leadId = Integer.parseInt(leadIdStr.trim());
            } catch (NumberFormatException e) {
                sendJsonResponse(resp, HttpServletResponse.SC_BAD_REQUEST, "error", "Định dạng leadId không hợp lệ.");
                return;
            }

            if (assigneeIdStr != null && !assigneeIdStr.trim().isEmpty()) {
                // PHÂN BỔ THỦ CÔNG (Manual Assignment)
                int assigneeId;
                try {
                    assigneeId = Integer.parseInt(assigneeIdStr.trim());
                } catch (NumberFormatException e) {
                    sendJsonResponse(resp, HttpServletResponse.SC_BAD_REQUEST, "error", "Định dạng assigneeId không hợp lệ.");
                    return;
                }

                // Thực hiện phân bổ thủ công với kiểm tra Data Scope
                boolean success = assignmentService.assignLeadManually(leadId, assigneeId, currentUserId, callerTeamId);
                if (success) {
                    sendJsonSuccess(resp, leadId, assigneeId, "Phân bổ Lead thủ công thành công.");
                } else {
                    sendJsonResponse(resp, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "error", "Phân bổ Lead thất bại.");
                }
            } else {
                // PHÂN BỔ TỰ ĐỘNG (Auto Assignment via Rule Engine & Round-Robin)
                Integer assignedTo = assignmentService.assignLead(leadId, region, industry, currentUserId);
                if (assignedTo != null) {
                    sendJsonSuccess(resp, leadId, assignedTo, "Phân bổ Lead tự động thành công theo quy tắc.");
                } else {
                    sendJsonSuccess(resp, leadId, null, "Lead chưa khớp quy tắc nào, đã đưa vào hàng chờ (QUEUED).");
                }
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
            LOGGER.log(Level.SEVERE, "Lỗi SQL khi phân bổ Lead", e);
            sendJsonResponse(resp, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "error", "Lỗi xử lý cơ sở dữ liệu khi phân bổ Lead.");
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Lỗi hệ thống khi phân bổ Lead", e);
            sendJsonResponse(resp, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "error", "Lỗi hệ thống nội bộ.");
        }
    }

    public static String extractJsonField(String json, String field) {
        if (json == null) return null;
        java.util.regex.Pattern p = java.util.regex.Pattern.compile("\"" + field + "\"\\s*:\\s*\"?([^\",}]+)\"?");
        java.util.regex.Matcher m = p.matcher(json);
        if (m.find()) {
            String val = m.group(1).trim();
            return "null".equalsIgnoreCase(val) ? null : val;
        }
        return null;
    }

    private void sendJsonSuccess(HttpServletResponse resp, int leadId, Integer assigneeId, String message) throws IOException {
        resp.setStatus(HttpServletResponse.SC_OK);
        PrintWriter out = resp.getWriter();
        String assigneeStr = (assigneeId != null) ? String.valueOf(assigneeId) : "null";
        out.write("{\"status\": \"success\", \"leadId\": " + leadId + ", \"assigneeId\": " + assigneeStr + ", \"message\": \"" + escapeJson(message) + "\"}");
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

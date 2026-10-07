package com.crm.controller.audit;

import com.crm.model.AuditLog;
import com.crm.service.AuditLogService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;

@WebServlet("/audit-log")
public class AuditLogListServlet extends HttpServlet {

    private AuditLogService auditLogService;

    @Override
    public void init() {
        this.auditLogService = new AuditLogService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Check authentication
        HttpSession session = request.getSession(false);
        if (session == null || (session.getAttribute("currentUser") == null && session.getAttribute("userId") == null)) {
            sendJsonError(response, HttpServletResponse.SC_UNAUTHORIZED, "Phiên đăng nhập đã hết hạn hoặc chưa đăng nhập.");
            return;
        }

        try {
            String userIdStr = request.getParameter("userId");
            Integer userId = (userIdStr != null && !userIdStr.trim().isEmpty()) ? Integer.parseInt(userIdStr.trim()) : null;

            String entityType = request.getParameter("entityType");
            String fromDate = request.getParameter("fromDate");
            String toDate = request.getParameter("toDate");

            String pageStr = request.getParameter("page");
            int page = (pageStr != null && !pageStr.trim().isEmpty()) ? Integer.parseInt(pageStr.trim()) : 1;

            String pageSizeStr = request.getParameter("pageSize");
            int pageSize = (pageSizeStr != null && !pageSizeStr.trim().isEmpty()) ? Integer.parseInt(pageSizeStr.trim()) : 10;

            List<AuditLog> logs = auditLogService.getAuditLogs(userId, entityType, fromDate, toDate, page, pageSize);
            int totalItems = auditLogService.getTotalAuditLogs(userId, entityType, fromDate, toDate);
            int totalPages = (pageSize > 0) ? (int) Math.ceil((double) totalItems / pageSize) : 1;

            response.setContentType("application/json;charset=UTF-8");
            PrintWriter out = response.getWriter();
            StringBuilder json = new StringBuilder();
            json.append("{");
            json.append("\"auditLogs\":[");
            for (int i = 0; i < logs.size(); i++) {
                AuditLog log = logs.get(i);
                json.append("{");
                json.append("\"logId\":").append(log.getLogId()).append(",");
                json.append("\"userId\":").append(log.getUserId()).append(",");
                json.append("\"performedByName\":").append(toJsonString(log.getPerformedByName())).append(",");
                json.append("\"action\":").append(toJsonString(log.getAction())).append(",");
                json.append("\"entityType\":").append(toJsonString(log.getEntityType())).append(",");
                json.append("\"entityId\":").append(log.getEntityId()).append(",");
                json.append("\"details\":").append(toJsonString(log.getDetails())).append(",");
                json.append("\"createdAt\":").append(toJsonString(log.getFormattedCreatedAt()));
                json.append("}");
                if (i < logs.size() - 1) json.append(",");
            }
            json.append("],");
            json.append("\"totalItems\":").append(totalItems).append(",");
            json.append("\"totalPages\":").append(totalPages).append(",");
            json.append("\"currentPage\":").append(page);
            json.append("}");
            out.print(json.toString());
            out.flush();

        } catch (NumberFormatException e) {
            sendJsonError(response, HttpServletResponse.SC_BAD_REQUEST, "Tham số định dạng không hợp lệ.");
        } catch (Exception e) {
            sendJsonError(response, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Lỗi hệ thống khi tải nhật ký.");
        }
    }

    private void sendJsonError(HttpServletResponse response, int statusCode, String message) throws IOException {
        response.setStatus(statusCode);
        response.setContentType("application/json;charset=UTF-8");
        PrintWriter out = response.getWriter();
        out.print("{\"status\":" + statusCode + ",\"message\":\"" + escapeJson(message) + "\"}");
        out.flush();
    }

    private String toJsonString(String val) {
        if (val == null) return "null";
        return "\"" + escapeJson(val) + "\"";
    }

    private String escapeJson(String text) {
        if (text == null) return "";
        return text.replace("\\", "\\\\")
                   .replace("\"", "\\\"")
                   .replace("\b", "\\b")
                   .replace("\f", "\\f")
                   .replace("\n", "\\n")
                   .replace("\r", "\\r")
                   .replace("\t", "\\t");
    }
}
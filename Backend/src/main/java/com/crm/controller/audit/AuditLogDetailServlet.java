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

@WebServlet(urlPatterns = {"/audit-log/detail", "/audit/detail"})
public class AuditLogDetailServlet extends HttpServlet {

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

        String auditLogIdStr = request.getParameter("auditLogId");
        if (auditLogIdStr == null || auditLogIdStr.trim().isEmpty()) {
            auditLogIdStr = request.getParameter("id");
        }

        if (auditLogIdStr == null || auditLogIdStr.trim().isEmpty()) {
            sendJsonError(response, HttpServletResponse.SC_BAD_REQUEST, "Thiếu tham số auditLogId.");
            return;
        }

        try {
            int auditLogId = Integer.parseInt(auditLogIdStr.trim());
            AuditLog log = auditLogService.getAuditLogById(auditLogId);

            if (log == null) {
                sendJsonError(response, HttpServletResponse.SC_NOT_FOUND, "Không tìm thấy nhật ký thao tác với mã: " + auditLogId);
                return;
            }

            response.setContentType("application/json;charset=UTF-8");
            PrintWriter out = response.getWriter();
            StringBuilder json = new StringBuilder();
            json.append("{");
            json.append("\"auditLog\":{");
            json.append("\"logId\":").append(log.getLogId()).append(",");
            json.append("\"userId\":").append(log.getUserId()).append(",");
            json.append("\"user\":").append(toJsonString(log.getPerformedByName() != null ? log.getPerformedByName() : "User #" + log.getUserId())).append(",");
            json.append("\"performedByName\":").append(toJsonString(log.getPerformedByName())).append(",");
            json.append("\"entityType\":").append(toJsonString(log.getEntityType())).append(",");
            json.append("\"entityId\":").append(log.getEntityId()).append(",");
            json.append("\"targetUserId\":").append(log.getTargetUserId()).append(",");
            json.append("\"action\":").append(toJsonString(log.getAction())).append(",");
            json.append("\"details\":").append(toJsonString(log.getDetails())).append(",");
            json.append("\"oldValue\":").append(toJsonString(log.getOldValue())).append(",");
            json.append("\"newValue\":").append(toJsonString(log.getNewValue())).append(",");
            json.append("\"changedAt\":").append(toJsonString(log.getCreatedAt() != null ? log.getCreatedAt().toString() : "")).append(",");
            json.append("\"createdAt\":").append(toJsonString(log.getCreatedAt() != null ? log.getCreatedAt().toString() : ""));
            json.append("}");
            json.append("}");
            out.print(json.toString());
            out.flush();

        } catch (NumberFormatException e) {
            sendJsonError(response, HttpServletResponse.SC_BAD_REQUEST, "Mã nhật ký auditLogId phải là số nguyên.");
        } catch (Exception e) {
            sendJsonError(response, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Lỗi hệ thống khi xem chi tiết nhật ký.");
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
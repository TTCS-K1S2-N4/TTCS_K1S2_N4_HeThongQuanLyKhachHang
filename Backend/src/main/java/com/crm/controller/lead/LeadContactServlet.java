package com.crm.controller.lead;

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
 * LeadContactServlet - API ghi nhận nhân viên đã liên hệ khách hàng thực tế (TC09).
 * Endpoint: POST /leads/contact
 * Ghi nhận hoạt động vào activities, cập nhật status sang CONTACTED và sla_status sang RESPONDED.
 */
@WebServlet("/leads/contact")
public class LeadContactServlet extends HttpServlet {
    private static final Logger LOGGER = Logger.getLogger(LeadContactServlet.class.getName());

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
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.setContentType("application/json;charset=UTF-8");

        try {
            HttpSession session = req.getSession(false);
            Integer currentUserId = (session != null && session.getAttribute("userId") instanceof Integer)
                    ? (Integer) session.getAttribute("userId")
                    : null;

            if (currentUserId == null) {
                sendJsonResponse(resp, HttpServletResponse.SC_UNAUTHORIZED, "error", "Yêu cầu đăng nhập.");
                return;
            }

            String leadIdStr = req.getParameter("leadId");
            String note = req.getParameter("note");

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

            boolean recorded = slaService.recordLeadContact(leadId, currentUserId, note);
            if (recorded) {
                sendJsonSuccess(resp, leadId, "Đã ghi nhận liên hệ khách hàng thành công. SLA phản hồi được ghi nhận RESPONDED.");
            } else {
                sendJsonResponse(resp, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "error", "Ghi nhận liên hệ thất bại.");
            }

        } catch (IllegalArgumentException e) {
            sendJsonResponse(resp, HttpServletResponse.SC_NOT_FOUND, "error", e.getMessage());
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Lỗi SQL khi ghi nhận liên hệ", e);
            sendJsonResponse(resp, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "error", "Lỗi cơ sở dữ liệu.");
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Lỗi hệ thống khi ghi nhận liên hệ", e);
            sendJsonResponse(resp, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "error", "Lỗi hệ thống.");
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

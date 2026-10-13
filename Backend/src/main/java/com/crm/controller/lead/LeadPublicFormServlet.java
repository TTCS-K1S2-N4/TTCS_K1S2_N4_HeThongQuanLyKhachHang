package com.crm.controller.lead;

import com.crm.model.LeadWebForm;
import com.crm.service.LeadWebFormService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

@WebServlet(urlPatterns = {"/leads/public-form"})
public class LeadPublicFormServlet extends HttpServlet {

    private LeadWebFormService webFormService = new LeadWebFormService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        String formIdStr = req.getParameter("formId");

        if (formIdStr == null || formIdStr.trim().isEmpty()) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Biểu mẫu không hợp lệ.");
            return;
        }

        try {
            int formId = Integer.parseInt(formIdStr.trim());
            LeadWebForm form = webFormService.getWebFormById(formId);
            if (form == null || !form.isActive()) {
                resp.sendError(HttpServletResponse.SC_NOT_FOUND, "Biểu mẫu không tồn tại hoặc đã ngưng hoạt động.");
                return;
            }

            req.setAttribute("webForm", form);
            req.getRequestDispatcher("/WEB-INF/views/leads/public_form.jsp").forward(req, resp);
        } catch (NumberFormatException e) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "ID Biểu mẫu không hợp lệ.");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        boolean isJson = isJsonRequest(req);

        String formIdStr = req.getParameter("formId");
        String fullName = req.getParameter("fullName");
        String email = req.getParameter("email");
        String phone = req.getParameter("phone");
        String company = req.getParameter("company");
        String notes = req.getParameter("notes");
        String honeypot = req.getParameter("website_hp"); // Honeypot trap field
        String referer = req.getHeader("Referer");
        String clientIp = getClientIp(req);

        if (formIdStr == null || formIdStr.trim().isEmpty()) {
            sendErrorResponse(resp, isJson, HttpServletResponse.SC_BAD_REQUEST, "Thiếu tham số formId.");
            return;
        }

        try {
            int formId = Integer.parseInt(formIdStr.trim());
            boolean submitted = webFormService.submitPublicForm(formId, fullName, email, phone, company, notes, referer, clientIp, honeypot);

            LeadWebForm form = webFormService.getWebFormById(formId);
            String redirectUrl = (form != null && form.getSuccessRedirectUrl() != null && !form.getSuccessRedirectUrl().trim().isEmpty())
                    ? form.getSuccessRedirectUrl().trim()
                    : null;

            if (submitted) {
                if (isJson) {
                    resp.setContentType("application/json; charset=UTF-8");
                    resp.getWriter().write("{\"status\":\"success\",\"message\":\"Cảm ơn bạn đã gửi thông tin! Chúng tôi sẽ liên hệ sớm nhất.\"" +
                            (redirectUrl != null ? ",\"redirectUrl\":\"" + escapeJson(redirectUrl) + "\"" : "") + "}");
                } else if (redirectUrl != null) {
                    resp.sendRedirect(redirectUrl);
                } else {
                    req.setAttribute("successMessage", "Cảm ơn bạn đã gửi thông tin! Chúng tôi sẽ liên hệ lại sớm nhất.");
                    req.setAttribute("webForm", form);
                    req.getRequestDispatcher("/WEB-INF/views/leads/public_form_success.jsp").forward(req, resp);
                }
            } else {
                sendErrorResponse(resp, isJson, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Không thể gửi thông tin biểu mẫu.");
            }
        } catch (SecurityException e) {
            sendErrorResponse(resp, isJson, HttpServletResponse.SC_FORBIDDEN, e.getMessage());
        } catch (IllegalArgumentException e) {
            sendErrorResponse(resp, isJson, HttpServletResponse.SC_BAD_REQUEST, e.getMessage());
        } catch (Exception e) {
            sendErrorResponse(resp, isJson, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Lỗi xử lý biểu mẫu: " + e.getMessage());
        }
    }

    private String getClientIp(HttpServletRequest req) {
        String ip = req.getHeader("X-Forwarded-For");
        if (ip == null || ip.isEmpty() || "unknown".equalsIgnoreCase(ip)) {
            ip = req.getHeader("Proxy-Client-IP");
        }
        if (ip == null || ip.isEmpty() || "unknown".equalsIgnoreCase(ip)) {
            ip = req.getRemoteAddr();
        }
        if (ip != null && ip.contains(",")) {
            ip = ip.split(",")[0].trim();
        }
        return ip;
    }

    private void sendErrorResponse(HttpServletResponse resp, boolean isJson, int statusCode, String message) throws IOException {
        resp.setStatus(statusCode);
        if (isJson) {
            resp.setContentType("application/json; charset=UTF-8");
            resp.getWriter().write("{\"status\":\"error\",\"message\":\"" + escapeJson(message) + "\"}");
        } else {
            resp.sendError(statusCode, message);
        }
    }

    private boolean isJsonRequest(HttpServletRequest req) {
        String accept = req.getHeader("Accept");
        String requestedWith = req.getHeader("X-Requested-With");
        return (accept != null && accept.contains("application/json")) || "XMLHttpRequest".equals(requestedWith);
    }

    private String escapeJson(String input) {
        if (input == null) return "";
        return input.replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", "\\n").replace("\r", "\\r");
    }
}

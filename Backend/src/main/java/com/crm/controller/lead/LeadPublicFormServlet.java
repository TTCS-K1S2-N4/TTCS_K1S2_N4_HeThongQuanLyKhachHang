package com.crm.controller.lead;

import com.crm.model.LeadWebForm;
import com.crm.service.LeadWebFormService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

@WebServlet(urlPatterns = {"/leads/public-form", "/public/leads", "/leads/public"})
public class LeadPublicFormServlet extends HttpServlet {

    private LeadWebFormService webFormService = new LeadWebFormService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        String formIdStr = req.getParameter("formId") != null ? req.getParameter("formId") : req.getParameter("id");

        int formId = 1;
        if (formIdStr != null && !formIdStr.trim().isEmpty()) {
            try {
                formId = Integer.parseInt(formIdStr.trim());
            } catch (NumberFormatException e) {
                resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "ID Biểu mẫu không hợp lệ.");
                return;
            }
        }

        LeadWebForm form = webFormService.getWebFormById(formId);
        if (form == null || !form.isActive()) {
            // Thử lấy form đầu tiên còn hoạt động
            var all = webFormService.getAllWebForms();
            for (LeadWebForm f : all) {
                if (f.isActive()) {
                    form = f;
                    break;
                }
            }
        }

        if (form == null) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND, "Biểu mẫu không tồn tại hoặc đã ngưng hoạt động.");
            return;
        }

        req.setAttribute("webForm", form);
        req.getRequestDispatcher("/WEB-INF/views/leads/public-form.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        boolean isJson = isJsonRequest(req);

        String formIdStr = req.getParameter("formId") != null ? req.getParameter("formId") : req.getParameter("id");
        String fullName = req.getParameter("fullName");
        String email = req.getParameter("email");
        String phone = req.getParameter("phone");
        String company = req.getParameter("company");
        String notes = req.getParameter("interest") != null ? req.getParameter("interest") : req.getParameter("notes");
        String honeypot = req.getParameter("website_hp") != null ? req.getParameter("website_hp") : req.getParameter("hp");
        String referer = req.getHeader("Referer");
        String clientIp = getClientIp(req);

        int formId = 1;
        if (formIdStr != null && !formIdStr.trim().isEmpty()) {
            try {
                formId = Integer.parseInt(formIdStr.trim());
            } catch (NumberFormatException e) {
                sendErrorResponse(req, resp, isJson, HttpServletResponse.SC_BAD_REQUEST, "ID Biểu mẫu không hợp lệ.");
                return;
            }
        }

        try {
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
                    resp.sendRedirect(req.getContextPath() + "/public/leads?formId=" + formId + "&success=1");
                }
            } else {
                sendErrorResponse(req, resp, isJson, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Không thể gửi thông tin biểu mẫu.");
            }
        } catch (SecurityException e) {
            sendErrorResponse(req, resp, isJson, HttpServletResponse.SC_FORBIDDEN, e.getMessage());
        } catch (IllegalArgumentException e) {
            sendErrorResponse(req, resp, isJson, HttpServletResponse.SC_BAD_REQUEST, e.getMessage());
        } catch (Exception e) {
            sendErrorResponse(req, resp, isJson, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Lỗi xử lý biểu mẫu: " + e.getMessage());
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

    private void sendErrorResponse(HttpServletRequest req, HttpServletResponse resp, boolean isJson, int statusCode, String message) throws ServletException, IOException {
        resp.setStatus(statusCode);
        if (isJson) {
            resp.setContentType("application/json; charset=UTF-8");
            resp.getWriter().write("{\"status\":\"error\",\"message\":\"" + escapeJson(message) + "\"}");
        } else {
            req.setAttribute("errorMessage", message);
            req.getRequestDispatcher("/WEB-INF/views/leads/public-form.jsp").forward(req, resp);
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

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
    public void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        String formIdStr = req.getParameter("formId") != null ? req.getParameter("formId") : req.getParameter("id");

        int formId = -1;
        if (formIdStr != null && !formIdStr.trim().isEmpty()) {
            try {
                formId = Integer.parseInt(formIdStr.trim());
            } catch (NumberFormatException e) {
                resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "ID Biểu mẫu không hợp lệ.");
                return;
            }
        }

        LeadWebForm form = null;
        if (formId > 0) {
            form = webFormService.getWebFormById(formId);
        } else {
            // Khi không truyền formId, tìm form đầu tiên còn hoạt động làm mặc định
            var all = webFormService.getAllWebForms();
            for (LeadWebForm f : all) {
                if (f.isActive()) {
                    form = f;
                    break;
                }
            }
        }

        // Nếu form không tồn tại hoặc đã bị vô hiệu hóa, hiển thị thông báo lỗi 404 rõ ràng
        if (form == null || !form.isActive()) {
            resp.setStatus(HttpServletResponse.SC_NOT_FOUND);
            req.setAttribute("webForm", null);
            req.getRequestDispatcher("/WEB-INF/views/leads/public-form.jsp").forward(req, resp);
            return;
        }

        if ("1".equals(req.getParameter("success")) || req.getParameter("success") != null) {
            req.setAttribute("successMessage", "Cảm ơn bạn đã gửi thông tin! Chúng tôi sẽ liên hệ lại sớm nhất.");
        }

        req.setAttribute("webForm", form);
        req.getRequestDispatcher("/WEB-INF/views/leads/public-form.jsp").forward(req, resp);
    }

    @Override
    public void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        boolean isJson = isJsonRequest(req);

        String formIdStr = req.getParameter("formId") != null ? req.getParameter("formId") : req.getParameter("id");
        String fullName = req.getParameter("fullName");
        String email = req.getParameter("email");
        String phone = req.getParameter("phone");
        String company = req.getParameter("company");
        String notes = req.getParameter("interest") != null ? req.getParameter("interest") : req.getParameter("notes");
        String honeypot = req.getParameter("website_hp") != null ? req.getParameter("website_hp") : req.getParameter("hp");
        String campaignIdStr = req.getParameter("campaignId");
        String referer = req.getHeader("Referer");
        String clientIp = getClientIp(req);

        if (formIdStr == null || formIdStr.trim().isEmpty()) {
            sendErrorResponse(req, resp, isJson, -1, HttpServletResponse.SC_BAD_REQUEST, "Thiếu thông tin ID biểu mẫu (formId).");
            return;
        }

        int formId;
        try {
            formId = Integer.parseInt(formIdStr.trim());
        } catch (NumberFormatException e) {
            sendErrorResponse(req, resp, isJson, -1, HttpServletResponse.SC_BAD_REQUEST, "ID Biểu mẫu không hợp lệ.");
            return;
        }

        Integer campaignId = null;
        if (campaignIdStr != null && !campaignIdStr.trim().isEmpty()) {
            try {
                campaignId = Integer.parseInt(campaignIdStr.trim());
            } catch (NumberFormatException ignored) {}
        }

        try {
            com.crm.model.Lead createdLead = webFormService.submitAndCreateLead(
                    formId, fullName, email, phone, company, notes, referer, clientIp, honeypot, campaignId);

            LeadWebForm form = webFormService.getWebFormById(formId);
            String redirectUrl = (form != null && form.getSuccessRedirectUrl() != null && !form.getSuccessRedirectUrl().trim().isEmpty())
                    ? form.getSuccessRedirectUrl().trim()
                    : null;

            if (createdLead != null && createdLead.getLeadId() > 0) {
                if (isJson) {
                    resp.setStatus(HttpServletResponse.SC_OK);
                    resp.setContentType("application/json; charset=UTF-8");
                    resp.getWriter().write("{\"status\":\"success\",\"message\":\"Cảm ơn bạn đã gửi thông tin! Chúng tôi sẽ liên hệ lại sớm nhất.\",\"leadId\":" +
                            createdLead.getLeadId() +
                            (redirectUrl != null ? ",\"redirectUrl\":\"" + escapeJson(redirectUrl) + "\"" : "") + "}");
                } else if (redirectUrl != null) {
                    resp.sendRedirect(redirectUrl);
                } else {
                    resp.sendRedirect(req.getContextPath() + "/leads/public-form?formId=" + formId + "&success=1");
                }
            } else {
                sendErrorResponse(req, resp, isJson, formId, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Không thể lưu thông tin vào cơ sở dữ liệu.");
            }
        } catch (SecurityException e) {
            sendErrorResponse(req, resp, isJson, formId, HttpServletResponse.SC_FORBIDDEN, e.getMessage());
        } catch (IllegalArgumentException e) {
            sendErrorResponse(req, resp, isJson, formId, HttpServletResponse.SC_BAD_REQUEST, e.getMessage());
        } catch (IllegalStateException e) {
            sendErrorResponse(req, resp, isJson, formId, HttpServletResponse.SC_NOT_FOUND, e.getMessage());
        } catch (Exception e) {
            sendErrorResponse(req, resp, isJson, formId, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Đã xảy ra lỗi trong quá trình xử lý biểu mẫu. Vui lòng thử lại sau.");
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

    private void sendErrorResponse(HttpServletRequest req, HttpServletResponse resp, boolean isJson, int formId, int statusCode, String message) throws ServletException, IOException {
        resp.setStatus(statusCode);
        if (isJson) {
            resp.setContentType("application/json; charset=UTF-8");
            resp.getWriter().write("{\"status\":\"error\",\"message\":\"" + escapeJson(message) + "\"}");
        } else {
            req.setAttribute("errorMessage", message);
            if (formId > 0) {
                try {
                    LeadWebForm form = webFormService.getWebFormById(formId);
                    req.setAttribute("webForm", form);
                } catch (Exception ignored) {}
            }
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

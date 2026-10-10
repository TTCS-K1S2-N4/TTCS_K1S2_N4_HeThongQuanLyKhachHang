package com.crm.controller.lead;

import com.crm.model.LeadWebForm;
import com.crm.service.LeadWebFormService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebServlet(urlPatterns = {"/leads/web-forms/embed-code"})
public class LeadEmbedCodeServlet extends HttpServlet {

    private LeadWebFormService webFormService = new LeadWebFormService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
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

        String formIdStr = req.getParameter("formId");
        if (formIdStr == null || formIdStr.trim().isEmpty()) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Thiếu tham số formId.");
            return;
        }

        try {
            int formId = Integer.parseInt(formIdStr.trim());
            LeadWebForm form = webFormService.getWebFormById(formId);
            if (form == null) {
                resp.sendError(HttpServletResponse.SC_NOT_FOUND, "Biểu mẫu nhúng không tồn tại.");
                return;
            }

            String baseUrl = req.getScheme() + "://" + req.getServerName() + ":" + req.getServerPort() + req.getContextPath();
            String embedCode = form.getEmbedCode();
            if (embedCode == null || embedCode.trim().isEmpty()) {
                embedCode = webFormService.generateEmbedCode(formId, baseUrl);
            }

            if (isJson) {
                resp.setContentType("application/json; charset=UTF-8");
                resp.getWriter().write("{\"formId\":" + formId + ",\"formName\":\"" + escapeJson(form.getFormName()) + "\",\"embedCode\":\"" + escapeJson(embedCode) + "\"}");
            } else {
                req.setAttribute("webForm", form);
                req.setAttribute("embedCode", embedCode);
                req.getRequestDispatcher("/WEB-INF/views/leads/web_form_embed.jsp").forward(req, resp);
            }
        } catch (NumberFormatException e) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "ID Biểu mẫu không hợp lệ.");
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

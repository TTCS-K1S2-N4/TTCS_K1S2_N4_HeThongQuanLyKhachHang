package com.crm.controller.lead;

import com.crm.dao.LeadSourceDAO;
import com.crm.dto.LeadWebFormRequest;
import com.crm.model.LeadSource;
import com.crm.model.LeadWebForm;
import com.crm.service.LeadWebFormService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;

@WebServlet(urlPatterns = {"/leads/web-forms", "/lead-forms"})
public class LeadWebFormServlet extends HttpServlet {

    private LeadWebFormService webFormService = new LeadWebFormService();
    private LeadSourceDAO sourceDAO = new LeadSourceDAO();

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

        List<LeadSource> sources = sourceDAO.getActiveSources();
        List<LeadWebForm> forms = webFormService.getAllWebForms();
        req.setAttribute("sources", sources);
        req.setAttribute("webForms", forms);

        String formIdStr = req.getParameter("id");
        if (formIdStr != null && !formIdStr.trim().isEmpty()) {
            try {
                int formId = Integer.parseInt(formIdStr.trim());
                LeadWebForm form = webFormService.getWebFormById(formId);
                if (form == null) {
                    resp.sendError(HttpServletResponse.SC_NOT_FOUND, "Biểu mẫu không tồn tại.");
                    return;
                }
                if (isJson) {
                    resp.setContentType("application/json; charset=UTF-8");
                    resp.getWriter().write(buildFormJson(form));
                    return;
                } else {
                    req.setAttribute("webForm", form);
                    req.setAttribute("formName", form.getFormName());
                    req.setAttribute("source", form.getLeadSourceId());
                }
            } catch (NumberFormatException e) {
                resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "ID Biểu mẫu không hợp lệ.");
                return;
            }
        }

        if (req.getParameter("success") != null) {
            req.setAttribute("successMessage", "Lưu cấu hình biểu mẫu Web Form thành công!");
        }

        if (isJson) {
            resp.setContentType("application/json; charset=UTF-8");
            resp.getWriter().write(buildFormListJson(forms));
        } else {
            req.getRequestDispatcher("/WEB-INF/views/leads/web-form.jsp").forward(req, resp);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        HttpSession session = req.getSession(false);
        Integer userId = session != null ? (Integer) session.getAttribute("userId") : null;
        boolean isJson = isJsonRequest(req);

        if (userId == null) {
            resp.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            if (isJson) {
                resp.setContentType("application/json; charset=UTF-8");
                resp.getWriter().write("{\"status\":\"error\",\"message\":\"Vui lòng đăng nhập.\"}");
            } else {
                resp.sendRedirect(req.getContextPath() + "/auth/login");
            }
            return;
        }

        String formIdStr = req.getParameter("id") != null ? req.getParameter("id") : req.getParameter("formId");
        String formName = req.getParameter("formName") != null ? req.getParameter("formName") : req.getParameter("name");
        String description = req.getParameter("description");
        String allowedDomains = req.getParameter("allowedDomains");
        String successRedirectUrl = req.getParameter("successRedirectUrl");
        String sourceStr = req.getParameter("source") != null ? req.getParameter("source") : req.getParameter("leadSourceId");

        boolean active = req.getParameter("active") == null || "true".equalsIgnoreCase(req.getParameter("active")) || "on".equalsIgnoreCase(req.getParameter("active"));
        boolean spamProtection = req.getParameter("spamProtection") == null || "true".equalsIgnoreCase(req.getParameter("spamProtection")) || "on".equalsIgnoreCase(req.getParameter("spamProtection"));
        String fieldsJson = req.getParameter("fieldsJson");

        LeadWebFormRequest formReq = new LeadWebFormRequest();
        formReq.setFormName(formName);
        formReq.setDescription(description);
        formReq.setAllowedDomains(allowedDomains != null ? allowedDomains : "*");
        formReq.setSuccessRedirectUrl(successRedirectUrl);
        formReq.setActive(active);
        formReq.setSpamProtectionEnabled(spamProtection);
        formReq.setFieldsJson(fieldsJson);

        if (sourceStr != null && !sourceStr.trim().isEmpty()) {
            try {
                formReq.setLeadSourceId(Integer.parseInt(sourceStr.trim()));
            } catch (NumberFormatException ignore) {}
        }

        String baseUrl = req.getScheme() + "://" + req.getServerName() + ":" + req.getServerPort() + req.getContextPath();

        try {
            if (formIdStr != null && !formIdStr.trim().isEmpty()) {
                int formId = Integer.parseInt(formIdStr.trim());
                boolean updated = webFormService.updateWebForm(formId, formReq, baseUrl);
                if (updated) {
                    if (isJson) {
                        resp.setContentType("application/json; charset=UTF-8");
                        resp.getWriter().write("{\"status\":\"success\",\"message\":\"Cập nhật biểu mẫu thành công.\"}");
                    } else {
                        resp.sendRedirect(req.getContextPath() + "/lead-forms?success=true");
                    }
                } else {
                    resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Không thể cập nhật biểu mẫu.");
                }
            } else {
                LeadWebForm created = webFormService.createWebForm(formReq, userId, baseUrl);
                if (created != null) {
                    if (isJson) {
                        resp.setContentType("application/json; charset=UTF-8");
                        resp.getWriter().write("{\"status\":\"success\",\"message\":\"Tạo biểu mẫu mới thành công.\",\"formId\":" + created.getFormId() + "}");
                    } else {
                        resp.sendRedirect(req.getContextPath() + "/lead-forms?success=true");
                    }
                } else {
                    resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Không thể tạo biểu mẫu.");
                }
            }
        } catch (Exception e) {
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            if (isJson) {
                resp.setContentType("application/json; charset=UTF-8");
                resp.getWriter().write("{\"status\":\"error\",\"message\":\"" + escapeJson(e.getMessage()) + "\"}");
            } else {
                req.setAttribute("error", e.getMessage());
                req.setAttribute("sources", sourceDAO.getActiveSources());
                req.setAttribute("webForms", webFormService.getAllWebForms());
                req.getRequestDispatcher("/WEB-INF/views/leads/web-form.jsp").forward(req, resp);
            }
        }
    }

    private boolean isJsonRequest(HttpServletRequest req) {
        String accept = req.getHeader("Accept");
        String requestedWith = req.getHeader("X-Requested-With");
        return (accept != null && accept.contains("application/json")) || "XMLHttpRequest".equals(requestedWith);
    }

    private String buildFormJson(LeadWebForm f) {
        return "{\"formId\":" + f.getFormId() +
               ",\"formName\":\"" + escapeJson(f.getFormName()) + "\"" +
               ",\"description\":\"" + escapeJson(f.getDescription()) + "\"" +
               ",\"embedCode\":\"" + escapeJson(f.getEmbedCode()) + "\"" +
               ",\"allowedDomains\":\"" + escapeJson(f.getAllowedDomains()) + "\"" +
               ",\"successRedirectUrl\":\"" + escapeJson(f.getSuccessRedirectUrl()) + "\"" +
               ",\"active\":" + f.isActive() +
               ",\"spamProtectionEnabled\":" + f.isSpamProtectionEnabled() + "}";
    }

    private String buildFormListJson(List<LeadWebForm> list) {
        StringBuilder sb = new StringBuilder("[");
        for (int i = 0; i < list.size(); i++) {
            sb.append(buildFormJson(list.get(i)));
            if (i < list.size() - 1) sb.append(",");
        }
        sb.append("]");
        return sb.toString();
    }

    private String escapeJson(String input) {
        if (input == null) return "";
        return input.replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", "\\n").replace("\r", "\\r");
    }
}

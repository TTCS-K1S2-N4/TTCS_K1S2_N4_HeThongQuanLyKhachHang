package com.crm.controller.lead;

import com.crm.dao.LeadSourceDAO;
import com.crm.dto.LeadRequest;
import com.crm.dto.LeadResponse;
import com.crm.model.LeadSource;
import com.crm.service.LeadService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;

@WebServlet(urlPatterns = {"/leads/update"})
public class LeadUpdateServlet extends HttpServlet {

    private LeadService leadService = new LeadService();
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

        String leadIdStr = req.getParameter("id");
        if (leadIdStr == null || leadIdStr.trim().isEmpty()) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Thiếu tham số ID Lead.");
            return;
        }

        try {
            int leadId = Integer.parseInt(leadIdStr.trim());
            LeadResponse lead = leadService.getLeadById(leadId);
            if (lead == null) {
                resp.sendError(HttpServletResponse.SC_NOT_FOUND, "Không tìm thấy Lead.");
                return;
            }

            List<LeadSource> sources = sourceDAO.getActiveSources();

            if (isJson) {
                resp.setContentType("application/json; charset=UTF-8");
                resp.getWriter().write(buildLeadJson(lead));
            } else {
                req.setAttribute("lead", lead);
                req.setAttribute("sources", sources);
                req.getRequestDispatcher("/WEB-INF/views/leads/update.jsp").forward(req, resp);
            }
        } catch (NumberFormatException e) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "ID Lead không hợp lệ.");
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

        String leadIdStr = req.getParameter("id");
        if (leadIdStr == null || leadIdStr.trim().isEmpty()) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Thiếu tham số ID Lead.");
            return;
        }

        try {
            int leadId = Integer.parseInt(leadIdStr.trim());
            String fullName = req.getParameter("fullName");
            String title = req.getParameter("title");
            String company = req.getParameter("company");
            String email = req.getParameter("email");
            String phone = req.getParameter("phone");
            String sourceIdStr = req.getParameter("leadSourceId");
            String status = req.getParameter("status");
            String rating = req.getParameter("rating");
            String industry = req.getParameter("industry");
            String address = req.getParameter("address");
            String city = req.getParameter("city");
            String state = req.getParameter("state");
            String country = req.getParameter("country");
            String zipCode = req.getParameter("zipCode");
            String ownerIdStr = req.getParameter("ownerId");
            String notes = req.getParameter("notes");

            LeadRequest request = new LeadRequest();
            request.setFullName(fullName);
            request.setTitle(title);
            request.setCompany(company);
            request.setEmail(email);
            request.setPhone(phone);
            if (sourceIdStr != null && !sourceIdStr.trim().isEmpty()) {
                try { request.setLeadSourceId(Integer.parseInt(sourceIdStr.trim())); } catch (NumberFormatException ignore) {}
            }
            request.setStatus(status);
            request.setRating(rating);
            request.setIndustry(industry);
            request.setAddress(address);
            request.setCity(city);
            request.setState(state);
            request.setCountry(country);
            request.setZipCode(zipCode);
            if (ownerIdStr != null && !ownerIdStr.trim().isEmpty()) {
                try { request.setOwnerId(Integer.parseInt(ownerIdStr.trim())); } catch (NumberFormatException ignore) {}
            }
            request.setNotes(notes);

            boolean updated = leadService.updateLead(leadId, request);
            if (updated) {
                if (isJson) {
                    resp.setContentType("application/json; charset=UTF-8");
                    resp.getWriter().write("{\"status\":\"success\",\"message\":\"Cập nhật thông tin Lead thành công.\"}");
                } else {
                    resp.sendRedirect(req.getContextPath() + "/leads/detail?id=" + leadId + "&updated=true");
                }
            } else {
                resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Không thể cập nhật Lead.");
            }
        } catch (Exception e) {
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            if (isJson) {
                resp.setContentType("application/json; charset=UTF-8");
                resp.getWriter().write("{\"status\":\"error\",\"message\":\"" + escapeJson(e.getMessage()) + "\"}");
            } else {
                req.setAttribute("error", e.getMessage());
                doGet(req, resp);
            }
        }
    }

    private boolean isJsonRequest(HttpServletRequest req) {
        String accept = req.getHeader("Accept");
        String requestedWith = req.getHeader("X-Requested-With");
        return (accept != null && accept.contains("application/json")) || "XMLHttpRequest".equals(requestedWith);
    }

    private String buildLeadJson(LeadResponse l) {
        return "{\"leadId\":" + l.getLeadId() +
               ",\"fullName\":\"" + escapeJson(l.getFullName()) + "\"" +
               ",\"title\":\"" + escapeJson(l.getTitle()) + "\"" +
               ",\"company\":\"" + escapeJson(l.getCompany()) + "\"" +
               ",\"email\":\"" + escapeJson(l.getEmail()) + "\"" +
               ",\"phone\":\"" + escapeJson(l.getPhone()) + "\"" +
               ",\"status\":\"" + escapeJson(l.getStatus()) + "\"" +
               ",\"rating\":\"" + escapeJson(l.getRating()) + "\"}";
    }

    private String escapeJson(String input) {
        if (input == null) return "";
        return input.replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", "\\n").replace("\r", "\\r");
    }
}

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

@WebServlet(urlPatterns = {"/leads/create"})
public class LeadCreateServlet extends HttpServlet {

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

        List<LeadSource> sources = sourceDAO.getActiveSources();
        if (isJson) {
            resp.setContentType("application/json; charset=UTF-8");
            resp.getWriter().write(buildSourcesJson(sources));
        } else {
            req.setAttribute("sources", sources);
            req.getRequestDispatcher("/WEB-INF/views/leads/create.jsp").forward(req, resp);
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

        String fullName = req.getParameter("fullName");
        String firstName = req.getParameter("firstName");
        String lastName = req.getParameter("lastName");
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
        request.setFirstName(firstName);
        request.setLastName(lastName);
        request.setTitle(title);
        request.setCompany(company);
        request.setEmail(email);
        request.setPhone(phone);
        if (sourceIdStr != null && !sourceIdStr.trim().isEmpty()) {
            try { request.setLeadSourceId(Integer.parseInt(sourceIdStr.trim())); } catch (NumberFormatException ignore) {}
        }
        request.setStatus(status != null && !status.trim().isEmpty() ? status : "NEW");
        request.setRating(rating != null && !rating.trim().isEmpty() ? rating : "WARM");
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

        try {
            LeadResponse created = leadService.createLead(request, userId);
            if (created != null) {
                if (isJson) {
                    resp.setContentType("application/json; charset=UTF-8");
                    resp.getWriter().write("{\"status\":\"success\",\"message\":\"Tạo Lead thành công!\",\"leadId\":" + created.getLeadId() + "}");
                } else {
                    resp.sendRedirect(req.getContextPath() + "/leads/detail?id=" + created.getLeadId() + "&created=true");
                }
            } else {
                resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                if (isJson) {
                    resp.setContentType("application/json; charset=UTF-8");
                    resp.getWriter().write("{\"status\":\"error\",\"message\":\"Không thể tạo Lead.\"}");
                } else {
                    req.setAttribute("error", "Không thể tạo Lead.");
                    doGet(req, resp);
                }
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

    private String buildSourcesJson(List<LeadSource> sources) {
        StringBuilder sb = new StringBuilder("[");
        for (int i = 0; i < sources.size(); i++) {
            LeadSource s = sources.get(i);
            sb.append("{\"sourceId\":").append(s.getSourceId())
              .append(",\"sourceCode\":\"").append(escapeJson(s.getSourceCode())).append("\"")
              .append(",\"sourceName\":\"").append(escapeJson(s.getSourceName())).append("\"}");
            if (i < sources.size() - 1) sb.append(",");
        }
        sb.append("]");
        return sb.toString();
    }

    private String escapeJson(String input) {
        if (input == null) return "";
        return input.replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", "\\n").replace("\r", "\\r");
    }
}

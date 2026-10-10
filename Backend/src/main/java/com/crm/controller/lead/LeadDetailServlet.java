package com.crm.controller.lead;

import com.crm.dto.LeadResponse;
import com.crm.service.LeadService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebServlet(urlPatterns = {"/leads/detail"})
public class LeadDetailServlet extends HttpServlet {

    private LeadService leadService = new LeadService();

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
                resp.sendError(HttpServletResponse.SC_NOT_FOUND, "Không tìm thấy Lead có ID = " + leadId);
                return;
            }

            if (isJson) {
                resp.setContentType("application/json; charset=UTF-8");
                resp.getWriter().write(buildLeadJson(lead));
            } else {
                req.setAttribute("lead", lead);
                req.getRequestDispatcher("/WEB-INF/views/leads/detail.jsp").forward(req, resp);
            }
        } catch (NumberFormatException e) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "ID Lead không hợp lệ.");
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
               ",\"rating\":\"" + escapeJson(l.getRating()) + "\"" +
               ",\"score\":" + l.getScore() +
               ",\"sourceName\":\"" + escapeJson(l.getSourceName()) + "\"" +
               ",\"webFormName\":\"" + escapeJson(l.getWebFormName()) + "\"" +
               ",\"industry\":\"" + escapeJson(l.getIndustry()) + "\"" +
               ",\"address\":\"" + escapeJson(l.getAddress()) + "\"" +
               ",\"city\":\"" + escapeJson(l.getCity()) + "\"" +
               ",\"notes\":\"" + escapeJson(l.getNotes()) + "\"" +
               ",\"ownerName\":\"" + escapeJson(l.getOwnerName()) + "\"}";
    }

    private String escapeJson(String input) {
        if (input == null) return "";
        return input.replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", "\\n").replace("\r", "\\r");
    }
}

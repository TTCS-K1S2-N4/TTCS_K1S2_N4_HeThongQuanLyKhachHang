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
import java.util.List;

@WebServlet(urlPatterns = {"/leads/list"})
public class LeadListServlet extends HttpServlet {

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

        int page = 1;
        int pageSize = 10;
        String pageStr = req.getParameter("page");
        String pageSizeStr = req.getParameter("pageSize");
        if (pageStr != null && !pageStr.trim().isEmpty()) {
            try { page = Math.max(1, Integer.parseInt(pageStr.trim())); } catch (NumberFormatException ignore) {}
        }
        if (pageSizeStr != null && !pageSizeStr.trim().isEmpty()) {
            try { pageSize = Math.max(1, Integer.parseInt(pageSizeStr.trim())); } catch (NumberFormatException ignore) {}
        }

        String search = req.getParameter("search");
        String status = req.getParameter("status");
        String rating = req.getParameter("rating");
        String ownerIdStr = req.getParameter("ownerId");
        Integer ownerId = null;
        if (ownerIdStr != null && !ownerIdStr.trim().isEmpty()) {
            try { ownerId = Integer.parseInt(ownerIdStr.trim()); } catch (NumberFormatException ignore) {}
        }

        List<LeadResponse> leads = leadService.getLeads(page, pageSize, search, status, rating, ownerId);
        int totalLeads = leadService.countLeads(search, status, rating, ownerId);
        int totalPages = (int) Math.ceil((double) totalLeads / pageSize);

        if (isJson) {
            resp.setContentType("application/json; charset=UTF-8");
            resp.getWriter().write(buildLeadListJsonResponse(leads, totalLeads, page, pageSize, totalPages));
        } else {
            req.setAttribute("leads", leads);
            req.setAttribute("totalLeads", totalLeads);
            req.setAttribute("currentPage", page);
            req.setAttribute("pageSize", pageSize);
            req.setAttribute("totalPages", totalPages);
            req.setAttribute("search", search);
            req.setAttribute("status", status);
            req.setAttribute("rating", rating);
            req.getRequestDispatcher("/WEB-INF/views/leads/list.jsp").forward(req, resp);
        }
    }

    private boolean isJsonRequest(HttpServletRequest req) {
        String accept = req.getHeader("Accept");
        String requestedWith = req.getHeader("X-Requested-With");
        return (accept != null && accept.contains("application/json")) || "XMLHttpRequest".equals(requestedWith);
    }

    private String buildLeadListJsonResponse(List<LeadResponse> leads, int total, int page, int pageSize, int totalPages) {
        StringBuilder sb = new StringBuilder("{");
        sb.append("\"total\":").append(total)
          .append(",\"page\":").append(page)
          .append(",\"pageSize\":").append(pageSize)
          .append(",\"totalPages\":").append(totalPages)
          .append(",\"data\":[");

        for (int i = 0; i < leads.size(); i++) {
            LeadResponse l = leads.get(i);
            sb.append("{\"leadId\":").append(l.getLeadId())
              .append(",\"fullName\":\"").append(escapeJson(l.getFullName())).append("\"")
              .append(",\"company\":\"").append(escapeJson(l.getCompany())).append("\"")
              .append(",\"email\":\"").append(escapeJson(l.getEmail())).append("\"")
              .append(",\"phone\":\"").append(escapeJson(l.getPhone())).append("\"")
              .append(",\"status\":\"").append(escapeJson(l.getStatus())).append("\"")
              .append(",\"rating\":\"").append(escapeJson(l.getRating())).append("\"")
              .append(",\"sourceName\":\"").append(escapeJson(l.getSourceName())).append("\"")
              .append(",\"ownerName\":\"").append(escapeJson(l.getOwnerName())).append("\"}");
            if (i < leads.size() - 1) sb.append(",");
        }
        sb.append("]}");
        return sb.toString();
    }

    private String escapeJson(String input) {
        if (input == null) return "";
        return input.replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", "\\n").replace("\r", "\\r");
    }
}

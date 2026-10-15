package com.crm.controller.lead;

import com.crm.dto.LeadFilterRequest;
import com.crm.dto.LeadResponse;
import com.crm.service.LeadFilterService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;

/**
 * Controller API phục vụ tìm kiếm và lọc danh sách Lead (S4-09).
 * URL: /leads/filter và /leads/search
 */
@WebServlet(urlPatterns = {"/leads/filter", "/leads/search"})
public class LeadFilterServlet extends HttpServlet {

    private LeadFilterService filterService = new LeadFilterService();

    public void setFilterService(LeadFilterService filterService) {
        if (filterService != null) {
            this.filterService = filterService;
        }
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        processFilterRequest(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        processFilterRequest(req, resp);
    }

    private void processFilterRequest(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        req.setCharacterEncoding("UTF-8");
        HttpSession session = req.getSession(false);
        Integer userId = session != null ? (Integer) session.getAttribute("userId") : null;

        if (userId == null) {
            resp.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            resp.setContentType("application/json; charset=UTF-8");
            resp.getWriter().write("{\"status\":\"error\",\"message\":\"Vui lòng đăng nhập.\"}");
            return;
        }

        @SuppressWarnings("unchecked")
        List<Integer> roleIds = session != null ? (List<Integer>) session.getAttribute("roleIds") : null;

        LeadFilterRequest filterRequest = extractFilterRequest(req);

        List<LeadResponse> leads = filterService.filterLeads(filterRequest, userId, roleIds);
        int total = filterService.countFilteredLeads(filterRequest, userId, roleIds);
        int totalPages = (int) Math.ceil((double) total / filterRequest.getPageSize());

        resp.setContentType("application/json; charset=UTF-8");
        PrintWriter out = resp.getWriter();
        out.write(buildJsonResponse(leads, total, filterRequest.getPage(), filterRequest.getPageSize(), totalPages));
        out.flush();
    }

    private LeadFilterRequest extractFilterRequest(HttpServletRequest req) {
        LeadFilterRequest r = new LeadFilterRequest();
        String keyword = req.getParameter("keyword");
        if (keyword == null) keyword = req.getParameter("search");
        r.setKeyword(keyword);

        r.setStatus(req.getParameter("status"));
        r.setSource(req.getParameter("source"));

        String cls = req.getParameter("classification");
        if (cls == null) cls = req.getParameter("rating");
        r.setClassification(cls);

        String ownerIdStr = req.getParameter("ownerId");
        if ("MY".equalsIgnoreCase(ownerIdStr)) {
            r.setOwnerScope("MY");
        } else if (ownerIdStr != null && !ownerIdStr.trim().isEmpty()) {
            try {
                r.setOwnerId(Integer.parseInt(ownerIdStr.trim()));
            } catch (NumberFormatException ignore) {}
        }

        r.setFromDate(req.getParameter("fromDate"));
        r.setToDate(req.getParameter("toDate"));

        String overdueStr = req.getParameter("overdue");
        if ("true".equalsIgnoreCase(overdueStr) || "1".equals(overdueStr)) {
            r.setOverdue(true);
        }

        String pageStr = req.getParameter("page");
        if (pageStr != null && !pageStr.trim().isEmpty()) {
            try { r.setPage(Math.max(1, Integer.parseInt(pageStr.trim()))); } catch (NumberFormatException ignore) {}
        }

        String pageSizeStr = req.getParameter("pageSize");
        if (pageSizeStr != null && !pageSizeStr.trim().isEmpty()) {
            try { r.setPageSize(Math.max(1, Integer.parseInt(pageSizeStr.trim()))); } catch (NumberFormatException ignore) {}
        }

        return r;
    }

    private String buildJsonResponse(List<LeadResponse> leads, int total, int page, int pageSize, int totalPages) {
        StringBuilder sb = new StringBuilder("{");
        sb.append("\"total\":").append(total)
          .append(",\"page\":").append(page)
          .append(",\"pageSize\":").append(pageSize)
          .append(",\"totalPages\":").append(totalPages)
          .append(",\"data\":[");

        for (int i = 0; i < leads.size(); i++) {
            LeadResponse l = leads.get(i);
            sb.append("{")
              .append("\"leadId\":").append(l.getLeadId()).append(",")
              .append("\"fullName\":\"").append(escapeJson(l.getFullName())).append("\",")
              .append("\"company\":\"").append(escapeJson(l.getCompany())).append("\",")
              .append("\"email\":\"").append(escapeJson(l.getEmail())).append("\",")
              .append("\"phone\":\"").append(escapeJson(l.getPhone())).append("\",")
              .append("\"status\":\"").append(escapeJson(l.getStatus())).append("\",")
              .append("\"rating\":\"").append(escapeJson(l.getRating())).append("\",")
              .append("\"score\":").append(l.getScore()).append(",")
              .append("\"classification\":\"").append(escapeJson(l.getClassification())).append("\",")
              .append("\"sourceName\":\"").append(escapeJson(l.getSourceName())).append("\",")
              .append("\"ownerName\":\"").append(escapeJson(l.getOwnerName())).append("\",")
              .append("\"slaOverdue\":").append(l.isSlaOverdue())
              .append("}");
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

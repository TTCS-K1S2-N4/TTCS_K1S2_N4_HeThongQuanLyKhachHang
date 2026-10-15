package com.crm.controller.lead;

import com.crm.dao.AccountDAO;
import com.crm.dto.LeadFilterRequest;
import com.crm.dto.LeadResponse;
import com.crm.model.Account;
import com.crm.model.LeadSavedFilter;
import com.crm.service.LeadFilterService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;

/**
 * Controller hiển thị danh sách Lead, tích hợp bộ lọc toàn diện và sắp xếp theo Điểm số / SLA (S4-05 & S4-09).
 * URL: /leads và /leads/list
 */
@WebServlet(urlPatterns = {"/leads", "/leads/list"})
public class LeadListServlet extends HttpServlet {

    private LeadFilterService filterService = new LeadFilterService();
    private AccountDAO accountDAO = new AccountDAO();

    public void setFilterService(LeadFilterService filterService) {
        if (filterService != null) {
            this.filterService = filterService;
        }
    }

    public void setAccountDAO(AccountDAO accountDAO) {
        if (accountDAO != null) {
            this.accountDAO = accountDAO;
        }
    }

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

        @SuppressWarnings("unchecked")
        List<Integer> roleIds = session != null ? (List<Integer>) session.getAttribute("roleIds") : null;

        // Trích xuất toàn bộ tham số bộ lọc (S4-09-AC-01)
        LeadFilterRequest filterReq = extractFilterRequest(req);

        // Lấy danh sách Lead đã lọc theo Data Scope và gắn nhãn SLA quá hạn (S4-09-AC-02)
        List<LeadResponse> leads = filterService.filterLeads(filterReq, userId, roleIds);
        int totalLeads = filterService.countFilteredLeads(filterReq, userId, roleIds);
        int totalPages = (int) Math.ceil((double) totalLeads / filterReq.getPageSize());

        if (isJson) {
            resp.setContentType("application/json; charset=UTF-8");
            resp.getWriter().write(buildLeadListJsonResponse(leads, totalLeads, filterReq.getPage(), filterReq.getPageSize(), totalPages));
        } else {
            // Nạp danh sách bộ lọc đã lưu của cá nhân nhân viên (S4-09-AC-03)
            List<LeadSavedFilter> savedFilters = filterService.getSavedFilters(userId);
            req.setAttribute("savedFilters", savedFilters);

            // Nạp danh sách người phụ trách (Active Accounts) cho dropdown
            List<Account> owners = accountDAO.getAllActiveAccounts();
            req.setAttribute("owners", owners);

            // Nạp dữ liệu danh sách Lead và các tham số phân trang
            req.setAttribute("leads", leads);
            req.setAttribute("totalLeads", totalLeads);
            req.setAttribute("currentPage", filterReq.getPage());
            req.setAttribute("pageSize", filterReq.getPageSize());
            req.setAttribute("totalPages", totalPages);

            // Nạp lại các giá trị lọc để giữ trạng thái trên form
            req.setAttribute("search", filterReq.getKeyword());
            req.setAttribute("keyword", filterReq.getKeyword());
            req.setAttribute("status", filterReq.getStatus());
            req.setAttribute("source", filterReq.getSource());
            req.setAttribute("rating", filterReq.getClassification());
            req.setAttribute("classification", filterReq.getClassification());
            req.setAttribute("ownerId", filterReq.getOwnerId());
            req.setAttribute("fromDate", filterReq.getFromDate());
            req.setAttribute("toDate", filterReq.getToDate());
            req.setAttribute("overdue", filterReq.isOverdue() ? "true" : "false");

            req.getRequestDispatcher("/WEB-INF/views/leads/list.jsp").forward(req, resp);
        }
    }

    private LeadFilterRequest extractFilterRequest(HttpServletRequest req) {
        LeadFilterRequest filter = new LeadFilterRequest();

        // Từ khóa tìm kiếm
        String keyword = req.getParameter("keyword");
        if (keyword == null) keyword = req.getParameter("search");
        filter.setKeyword(keyword);

        // Trạng thái (Status)
        filter.setStatus(req.getParameter("status"));

        // Nguồn (Source)
        filter.setSource(req.getParameter("source"));

        // Phân loại Nóng / Ấm / Lạnh (Classification / Rating)
        String classification = req.getParameter("classification");
        if (classification == null) classification = req.getParameter("rating");
        filter.setClassification(classification);

        // Người phụ trách (Owner)
        String ownerIdStr = req.getParameter("ownerId");
        if ("MY".equalsIgnoreCase(ownerIdStr)) {
            filter.setOwnerScope("MY");
        } else if (ownerIdStr != null && !ownerIdStr.trim().isEmpty()) {
            try {
                filter.setOwnerId(Integer.parseInt(ownerIdStr.trim()));
            } catch (NumberFormatException ignore) {}
        }

        // Khoảng thời gian
        filter.setFromDate(req.getParameter("fromDate"));
        filter.setToDate(req.getParameter("toDate"));

        // Chỉ hiển thị Lead quá SLA (S4-09-AC-02)
        String overdueStr = req.getParameter("overdue");
        if ("true".equalsIgnoreCase(overdueStr) || "1".equals(overdueStr)) {
            filter.setOverdue(true);
        }

        // Phân trang
        String pageStr = req.getParameter("page");
        String pageSizeStr = req.getParameter("pageSize");
        if (pageStr != null && !pageStr.trim().isEmpty()) {
            try { filter.setPage(Math.max(1, Integer.parseInt(pageStr.trim()))); } catch (NumberFormatException ignore) {}
        }
        if (pageSizeStr != null && !pageSizeStr.trim().isEmpty()) {
            try { filter.setPageSize(Math.max(1, Integer.parseInt(pageSizeStr.trim()))); } catch (NumberFormatException ignore) {}
        }

        return filter;
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
              .append(",\"score\":").append(l.getScore())
              .append(",\"classification\":\"").append(escapeJson(l.getClassification())).append("\"")
              .append(",\"sourceName\":\"").append(escapeJson(l.getSourceName())).append("\"")
              .append(",\"ownerName\":\"").append(escapeJson(l.getOwnerName())).append("\"")
              .append(",\"slaOverdue\":").append(l.isSlaOverdue())
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

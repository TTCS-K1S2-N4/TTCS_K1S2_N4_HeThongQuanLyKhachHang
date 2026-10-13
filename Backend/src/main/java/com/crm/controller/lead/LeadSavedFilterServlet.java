package com.crm.controller.lead;

import com.crm.dto.LeadFilterRequest;
import com.crm.model.LeadSavedFilter;
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
 * Controller quản lý Bộ lọc đã lưu cho module Lead (S4-09-AC-03).
 * URLs:
 * - /leads/saved-filters: Trang quản lý danh sách bộ lọc đã lưu (saved-filters.jsp)
 * - /leads/filters: API lấy danh sách / lưu bộ lọc mới (AJAX / JSON)
 * - /leads/filters/delete: API / Thao tác xóa bộ lọc
 */
@WebServlet(urlPatterns = {"/leads/filters", "/leads/filters/delete", "/leads/saved-filters"})
public class LeadSavedFilterServlet extends HttpServlet {

    private LeadFilterService filterService = new LeadFilterService();

    public void setFilterService(LeadFilterService filterService) {
        if (filterService != null) {
            this.filterService = filterService;
        }
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        HttpSession session = req.getSession(false);
        Integer userId = session != null ? (Integer) session.getAttribute("userId") : null;

        if (userId == null) {
            if (isJsonRequest(req)) {
                resp.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                resp.setContentType("application/json; charset=UTF-8");
                resp.getWriter().write("{\"success\":false,\"message\":\"Vui lòng đăng nhập.\"}");
            } else {
                resp.sendRedirect(req.getContextPath() + "/auth/login");
            }
            return;
        }

        List<LeadSavedFilter> list = filterService.getSavedFilters(userId);
        String path = req.getServletPath();

        if ("/leads/saved-filters".equals(path) && !isJsonRequest(req)) {
            req.setAttribute("savedFilters", list);
            req.getRequestDispatcher("/WEB-INF/views/leads/saved-filters.jsp").forward(req, resp);
        } else {
            resp.setContentType("application/json; charset=UTF-8");
            PrintWriter out = resp.getWriter();
            out.print(buildFilterListJson(list));
            out.flush();
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
                resp.getWriter().write("{\"success\":false,\"message\":\"Chưa đăng nhập.\"}");
            } else {
                resp.sendRedirect(req.getContextPath() + "/auth/login");
            }
            return;
        }

        String path = req.getServletPath();
        String action = req.getParameter("action");

        // Thao tác xóa bộ lọc
        if ((path != null && path.endsWith("/delete")) || "delete".equalsIgnoreCase(action)) {
            handleDeleteFilter(req, resp, userId, isJson);
            return;
        }

        // Thao tác lưu bộ lọc mới
        handleSaveFilter(req, resp, userId, isJson);
    }

    private void handleSaveFilter(HttpServletRequest req, HttpServletResponse resp, int userId, boolean isJson) throws IOException {
        String filterName = req.getParameter("filterName");
        if (filterName == null || filterName.trim().isEmpty()) {
            sendError(resp, isJson, HttpServletResponse.SC_BAD_REQUEST, "Tên bộ lọc không được để trống.");
            return;
        }

        // Đóng gói các tiêu chí lọc hiện tại
        LeadFilterRequest filterReq = new LeadFilterRequest();
        filterReq.setKeyword(req.getParameter("keyword") != null ? req.getParameter("keyword") : req.getParameter("search"));
        filterReq.setStatus(req.getParameter("status"));
        filterReq.setSource(req.getParameter("source"));
        filterReq.setClassification(req.getParameter("classification") != null ? req.getParameter("classification") : req.getParameter("rating"));
        filterReq.setOwnerScope(req.getParameter("ownerScope"));

        String ownerIdStr = req.getParameter("ownerId");
        if ("MY".equalsIgnoreCase(ownerIdStr)) {
            filterReq.setOwnerScope("MY");
        } else if (ownerIdStr != null && !ownerIdStr.trim().isEmpty()) {
            try { filterReq.setOwnerId(Integer.parseInt(ownerIdStr.trim())); } catch (NumberFormatException ignore) {}
        }

        filterReq.setFromDate(req.getParameter("fromDate"));
        filterReq.setToDate(req.getParameter("toDate"));

        String overdueStr = req.getParameter("overdue");
        if ("true".equalsIgnoreCase(overdueStr) || "1".equals(overdueStr)) {
            filterReq.setOverdue(true);
        }

        LeadSavedFilter filter = new LeadSavedFilter();
        filter.setUserId(userId);
        filter.setFilterName(filterName.trim());
        filter.setKeyword(filterReq.getKeyword());
        filter.setStatus(filterReq.getStatus());
        filter.setSource(filterReq.getSource());
        filter.setClassification(filterReq.getClassification());
        filter.setOwnerId(filterReq.getOwnerId());
        filter.setFilterQuery(filterReq.toQueryString());

        boolean ok = filterService.saveFilter(filter, userId);
        resp.setContentType("application/json; charset=UTF-8");
        PrintWriter out = resp.getWriter();
        if (ok) {
            out.print("{\"success\":true,\"filterId\":" + filter.getFilterId() + ",\"message\":\"Đã lưu bộ lọc thành công.\"}");
        } else {
            resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.print("{\"success\":false,\"message\":\"Không thể lưu bộ lọc.\"}");
        }
        out.flush();
    }

    private void handleDeleteFilter(HttpServletRequest req, HttpServletResponse resp, int userId, boolean isJson) throws IOException {
        String filterIdStr = req.getParameter("filterId");
        if (filterIdStr == null || filterIdStr.trim().isEmpty()) {
            sendError(resp, isJson, HttpServletResponse.SC_BAD_REQUEST, "Thiếu filterId.");
            return;
        }

        int filterId = 0;
        try {
            filterId = Integer.parseInt(filterIdStr.trim());
        } catch (NumberFormatException e) {
            sendError(resp, isJson, HttpServletResponse.SC_BAD_REQUEST, "filterId không hợp lệ.");
            return;
        }

        boolean ok = filterService.deleteSavedFilter(filterId, userId);
        if (isJson) {
            resp.setContentType("application/json; charset=UTF-8");
            PrintWriter out = resp.getWriter();
            if (ok) {
                out.print("{\"success\":true,\"message\":\"Đã xóa bộ lọc thành công.\"}");
            } else {
                resp.setStatus(HttpServletResponse.SC_NOT_FOUND);
                out.print("{\"success\":false,\"message\":\"Không tìm thấy bộ lọc để xóa.\"}");
            }
            out.flush();
        } else {
            if (ok) {
                req.getSession().setAttribute("successMessage", "Đã xóa bộ lọc thành công!");
            } else {
                req.getSession().setAttribute("errorMessage", "Không thể xóa bộ lọc.");
            }
            resp.sendRedirect(req.getContextPath() + "/leads/saved-filters");
        }
    }

    private void sendError(HttpServletResponse resp, boolean isJson, int statusCode, String message) throws IOException {
        resp.setStatus(statusCode);
        resp.setContentType("application/json; charset=UTF-8");
        PrintWriter out = resp.getWriter();
        out.print("{\"success\":false,\"message\":\"" + escapeJson(message) + "\"}");
        out.flush();
    }

    private boolean isJsonRequest(HttpServletRequest req) {
        String accept = req.getHeader("Accept");
        String requestedWith = req.getHeader("X-Requested-With");
        return (accept != null && accept.contains("application/json")) || "XMLHttpRequest".equals(requestedWith);
    }

    private String buildFilterListJson(List<LeadSavedFilter> list) {
        StringBuilder sb = new StringBuilder("[");
        for (int i = 0; i < list.size(); i++) {
            LeadSavedFilter f = list.get(i);
            if (i > 0) sb.append(",");
            sb.append("{")
              .append("\"filterId\":").append(f.getFilterId()).append(",")
              .append("\"filterName\":\"").append(escapeJson(f.getFilterName())).append("\",")
              .append("\"keyword\":\"").append(escapeJson(f.getKeyword())).append("\",")
              .append("\"status\":\"").append(escapeJson(f.getStatus())).append("\",")
              .append("\"source\":\"").append(escapeJson(f.getSource())).append("\",")
              .append("\"classification\":\"").append(escapeJson(f.getClassification())).append("\",")
              .append("\"filterQuery\":\"").append(escapeJson(f.getFilterQuery())).append("\",")
              .append("\"isDefault\":").append(f.isDefault())
              .append("}");
        }
        sb.append("]");
        return sb.toString();
    }

    private String escapeJson(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", "\\n").replace("\r", "\\r");
    }
}

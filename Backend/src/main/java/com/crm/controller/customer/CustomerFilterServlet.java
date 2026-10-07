package com.crm.controller.customer;

import com.crm.model.SavedFilter;
import com.crm.service.CustomerFilterService;
import com.crm.util.ValidationUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;

@WebServlet("/customers/filters")
public class CustomerFilterServlet extends HttpServlet {
    private CustomerFilterService filterService = new CustomerFilterService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        Integer userId = (Integer) req.getSession().getAttribute("userId");
        if (userId == null) {
            resp.sendRedirect(req.getContextPath() + "/auth/login");
            return;
        }

        List<SavedFilter> list = filterService.getSavedFilters(userId);
        resp.setContentType("application/json; charset=UTF-8");
        PrintWriter out = resp.getWriter();
        out.print(buildFilterListJson(list));
        out.flush();
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        Integer userId = (Integer) req.getSession().getAttribute("userId");
        if (userId == null) {
            resp.sendError(HttpServletResponse.SC_UNAUTHORIZED, "Chưa đăng nhập.");
            return;
        }

        String action = req.getParameter("action");
        if ("delete".equalsIgnoreCase(action)) {
            doDelete(req, resp);
            return;
        }

        String filterName = req.getParameter("filterName");
        if (filterName == null || filterName.trim().isEmpty()) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Tên bộ lọc không được để trống.");
            return;
        }

        SavedFilter filter = new SavedFilter();
        filter.setUserId(userId);
        filter.setFilterName(filterName.trim());
        filter.setKeyword(req.getParameter("keyword"));
        filter.setStatus(req.getParameter("status"));
        filter.setIndustry(req.getParameter("industry"));
        filter.setCompanySize(req.getParameter("companySize") != null ? req.getParameter("companySize") : req.getParameter("size"));
        filter.setRegion(req.getParameter("region"));

        String oidStr = req.getParameter("ownerId");
        if (oidStr != null && !oidStr.trim().isEmpty()) {
            try { filter.setOwnerId(Integer.parseInt(oidStr.trim())); } catch (NumberFormatException ignored) {}
        }

        String isDefStr = req.getParameter("isDefault");
        if ("true".equalsIgnoreCase(isDefStr) || "1".equals(isDefStr)) {
            filter.setDefault(true);
        }

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

    @Override
    protected void doDelete(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        Integer userId = (Integer) req.getSession().getAttribute("userId");
        if (userId == null) {
            resp.sendError(HttpServletResponse.SC_UNAUTHORIZED, "Chưa đăng nhập.");
            return;
        }

        String filterIdStr = req.getParameter("filterId");
        if (filterIdStr == null || filterIdStr.trim().isEmpty()) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Thiếu filterId.");
            return;
        }

        int filterId = 0;
        try { filterId = Integer.parseInt(filterIdStr.trim()); } catch (NumberFormatException ignored) {}

        boolean ok = filterService.deleteSavedFilter(filterId, userId);
        resp.setContentType("application/json; charset=UTF-8");
        PrintWriter out = resp.getWriter();
        if (ok) {
            out.print("{\"success\":true,\"message\":\"Đã xóa bộ lọc thành công.\"}");
        } else {
            resp.setStatus(HttpServletResponse.SC_NOT_FOUND);
            out.print("{\"success\":false,\"message\":\"Không tìm thấy bộ lọc để xóa.\"}");
        }
        out.flush();
    }

    private String buildFilterListJson(List<SavedFilter> list) {
        StringBuilder sb = new StringBuilder("[");
        for (int i = 0; i < list.size(); i++) {
            SavedFilter f = list.get(i);
            if (i > 0) sb.append(",");
            sb.append("{");
            sb.append("\"filterId\":").append(f.getFilterId()).append(",");
            sb.append("\"filterName\":\"").append(escapeJson(f.getFilterName())).append("\",");
            sb.append("\"keyword\":\"").append(escapeJson(f.getKeyword())).append("\",");
            sb.append("\"status\":\"").append(escapeJson(f.getStatus())).append("\",");
            sb.append("\"industry\":\"").append(escapeJson(f.getIndustry())).append("\",");
            sb.append("\"companySize\":\"").append(escapeJson(f.getCompanySize())).append("\",");
            sb.append("\"region\":\"").append(escapeJson(f.getRegion())).append("\",");
            sb.append("\"ownerId\":").append(f.getOwnerId() != null ? f.getOwnerId() : "null").append(",");
            sb.append("\"isDefault\":").append(f.isDefault());
            sb.append("}");
        }
        sb.append("]");
        return sb.toString();
    }

    private String escapeJson(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", "\\n").replace("\r", "\\r");
    }
}

package com.crm.controller.customer;

import com.crm.exception.AuthorizationException;
import com.crm.model.Activity;
import com.crm.service.Customer360Service;
import com.crm.util.ValidationUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.Collections;
import java.util.List;

@WebServlet(urlPatterns = {"/customers/timeline", "/customers/timeline/*"})
public class CustomerTimelineServlet extends HttpServlet {
    private Customer360Service customer360Service = new Customer360Service();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");

        Integer userId = (Integer) req.getSession().getAttribute("userId");
        List<Integer> roleIds = ValidationUtil.getSafeIntegerList(req.getAttribute("effectiveRoleIds"));
        Integer roleId = (Integer) req.getSession().getAttribute("roleId");

        if (userId == null || (roleId == null && (roleIds == null || roleIds.isEmpty()))) {
            resp.sendRedirect(req.getContextPath() + "/auth/login");
            return;
        }

        List<Integer> effectiveRoles = (roleIds != null && !roleIds.isEmpty()) ? roleIds : Collections.singletonList(roleId);

        int customerId = parseCustomerId(req);
        if (customerId <= 0) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Thiếu hoặc sai Customer ID.");
            return;
        }

        int page = 1;
        int pageSize = 20;
        try { page = Integer.parseInt(req.getParameter("page")); } catch (Exception ignored) {}
        try { pageSize = Integer.parseInt(req.getParameter("pageSize")); } catch (Exception ignored) {}

        try {
            long startTime = System.currentTimeMillis();
            List<Activity> activities = customer360Service.getCustomerTimeline(customerId, page, pageSize, userId, effectiveRoles);
            long loadTimeMs = System.currentTimeMillis() - startTime;

            boolean isJson = "json".equalsIgnoreCase(req.getParameter("format")) ||
                    (req.getHeader("Accept") != null && req.getHeader("Accept").contains("application/json")) ||
                    "XMLHttpRequest".equals(req.getHeader("X-Requested-With"));

            if (isJson) {
                resp.setContentType("application/json; charset=UTF-8");
                PrintWriter out = resp.getWriter();
                out.print(buildActivitiesJson(activities, page, pageSize, loadTimeMs));
                out.flush();
            } else {
                req.setAttribute("activities", activities);
                req.setAttribute("currentPage", page);
                req.setAttribute("pageSize", pageSize);
                req.setAttribute("loadTimeMs", loadTimeMs);
                req.getRequestDispatcher("/WEB-INF/views/customers/timeline.jsp").forward(req, resp);
            }
        } catch (AuthorizationException e) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, e.getMessage());
        } catch (Exception e) {
            throw new ServletException("Lỗi khi tải lịch sử hoạt động Customer Timeline", e);
        }
    }

    private int parseCustomerId(HttpServletRequest req) {
        String pathInfo = req.getPathInfo();
        if (pathInfo != null && !pathInfo.trim().isEmpty() && !"/".equals(pathInfo)) {
            String clean = pathInfo.replaceAll("^/", "").replaceAll("/timeline$", "");
            try {
                return Integer.parseInt(clean);
            } catch (NumberFormatException ignored) {}
        }

        String idStr = req.getParameter("customerId");
        if (idStr == null || idStr.isEmpty()) {
            idStr = req.getParameter("id");
        }
        if (idStr != null && !idStr.isEmpty()) {
            try {
                return Integer.parseInt(idStr);
            } catch (NumberFormatException ignored) {}
        }
        return 0;
    }

    private String buildActivitiesJson(List<Activity> list, int page, int pageSize, long loadTimeMs) {
        StringBuilder sb = new StringBuilder("{");
        sb.append("\"page\":").append(page).append(",");
        sb.append("\"pageSize\":").append(pageSize).append(",");
        sb.append("\"loadTimeMs\":").append(loadTimeMs).append(",");
        sb.append("\"hasMore\":").append(list.size() >= pageSize).append(",");
        sb.append("\"activities\":[");
        for (int i = 0; i < list.size(); i++) {
            Activity a = list.get(i);
            if (i > 0) sb.append(",");
            String dateStr = a.getCreatedAt() != null ? a.getCreatedAt().toString() : "";
            sb.append("{");
            sb.append("\"activityId\":").append(a.getActivityId()).append(",");
            sb.append("\"title\":\"").append(escapeJson(a.getTitle())).append("\",");
            sb.append("\"description\":\"").append(escapeJson(a.getDescription())).append("\",");
            sb.append("\"content\":\"").append(escapeJson(a.getDescription())).append("\",");
            sb.append("\"user\":\"").append(a.getOwnerId() > 0 ? "User #" + a.getOwnerId() : "").append("\",");
            sb.append("\"date\":\"").append(escapeJson(dateStr)).append("\",");
            sb.append("\"ownerId\":").append(a.getOwnerId()).append(",");
            sb.append("\"createdAt\":\"").append(escapeJson(dateStr)).append("\"");
            sb.append("}");
        }
        sb.append("]}");
        return sb.toString();
    }

    private String escapeJson(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", "\\n").replace("\r", "\\r");
    }
}

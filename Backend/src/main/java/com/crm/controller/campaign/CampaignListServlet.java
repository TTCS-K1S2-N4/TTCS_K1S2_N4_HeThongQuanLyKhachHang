package com.crm.controller.campaign;

import com.crm.model.Campaign;
import com.crm.service.CampaignService;
import com.crm.util.ValidationUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.Collections;
import java.util.List;

/**
 * Controller hiển thị danh sách Chiến dịch tiếp thị.
 * Ánh xạ API C01: GET /campaigns
 */
@WebServlet(urlPatterns = {"/campaigns", "/campaigns/list"})
public class CampaignListServlet extends HttpServlet {

    private CampaignService campaignService = new CampaignService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");

        HttpSession session = req.getSession(false);
        Integer userId = session != null ? (Integer) session.getAttribute("userId") : null;
        Integer roleId = session != null ? (Integer) session.getAttribute("roleId") : null;
        List<Integer> roleIds = ValidationUtil.getSafeIntegerList(req.getAttribute("effectiveRoleIds"));

        if (userId == null) {
            String isJsonHeader = req.getHeader("Accept");
            if (isJsonHeader != null && isJsonHeader.contains("application/json")) {
                resp.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                resp.setContentType("application/json; charset=UTF-8");
                resp.getWriter().write("{\"error\": \"Unauthorized\", \"message\": \"Vui lòng đăng nhập.\"}");
                return;
            }
            resp.sendRedirect(req.getContextPath() + "/auth/login");
            return;
        }

        String keyword = req.getParameter("keyword");
        String status = req.getParameter("status");
        String channel = req.getParameter("channel");

        int page = 1;
        try {
            String pageStr = req.getParameter("page");
            if (pageStr != null && !pageStr.trim().isEmpty()) {
                page = Math.max(1, Integer.parseInt(pageStr.trim()));
            }
        } catch (NumberFormatException ignored) {}

        int pageSize = 20;
        try {
            String sizeStr = req.getParameter("pageSize");
            if (sizeStr != null && !sizeStr.trim().isEmpty()) {
                pageSize = Math.max(1, Integer.parseInt(sizeStr.trim()));
            }
        } catch (NumberFormatException ignored) {}

        List<Campaign> campaigns = campaignService.getCampaigns(keyword, status, channel, page, pageSize, userId, roleId != null ? roleId : 0, roleIds);
        int total = campaignService.countCampaigns(keyword, status, channel, userId, roleId != null ? roleId : 0, roleIds);
        int totalPages = (int) Math.ceil((double) total / pageSize);
        if (totalPages <= 0) totalPages = 1;

        boolean isJson = "json".equalsIgnoreCase(req.getParameter("format")) ||
                (req.getHeader("Accept") != null && req.getHeader("Accept").contains("application/json")) ||
                "XMLHttpRequest".equals(req.getHeader("X-Requested-With"));

        if (isJson) {
            resp.setContentType("application/json; charset=UTF-8");
            PrintWriter out = resp.getWriter();
            out.print(toJson(campaigns, total, page, totalPages));
            out.flush();
        } else {
            req.setAttribute("campaigns", campaigns);
            req.setAttribute("total", total);
            req.setAttribute("currentPage", page);
            req.setAttribute("totalPages", totalPages);
            req.setAttribute("keyword", keyword);
            req.setAttribute("status", status);
            req.setAttribute("channel", channel);
            req.setAttribute("channels", campaignService.getAvailableChannels());

            req.getRequestDispatcher("/WEB-INF/views/campaigns/list.jsp").forward(req, resp);
        }
    }

    private String toJson(List<Campaign> list, int total, int page, int totalPages) {
        StringBuilder sb = new StringBuilder();
        sb.append("{\"status\":\"success\",");
        sb.append("\"total\":").append(total).append(",");
        sb.append("\"page\":").append(page).append(",");
        sb.append("\"totalPages\":").append(totalPages).append(",");
        sb.append("\"data\":[");
        for (int i = 0; i < list.size(); i++) {
            Campaign c = list.get(i);
            if (i > 0) sb.append(",");
            sb.append("{");
            sb.append("\"campaignId\":").append(c.getCampaignId()).append(",");
            sb.append("\"name\":\"").append(escapeJson(c.getCampaignName())).append("\",");
            sb.append("\"budget\":").append(c.getBudget() != null ? c.getBudget().toPlainString() : "0").append(",");
            sb.append("\"startDate\":").append(c.getStartDate() != null ? "\"" + c.getStartDate().toString() + "\"" : "null").append(",");
            sb.append("\"endDate\":").append(c.getEndDate() != null ? "\"" + c.getEndDate().toString() + "\"" : "null").append(",");
            sb.append("\"channel\":").append(c.getChannel() != null ? "\"" + escapeJson(c.getChannel()) + "\"" : "null").append(",");
            sb.append("\"status\":\"").append(escapeJson(c.getStatus())).append("\",");
            sb.append("\"leadCount\":").append(c.getLeadCount()).append(",");
            sb.append("\"opportunityCount\":").append(c.getOpportunityCount()).append(",");
            sb.append("\"closedValue\":").append(c.getClosedValue() != null ? c.getClosedValue().toPlainString() : "0");
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

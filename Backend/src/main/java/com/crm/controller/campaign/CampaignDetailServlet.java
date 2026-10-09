package com.crm.controller.campaign;

import com.crm.exception.AuthorizationException;
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
import java.util.List;

/**
 * Controller xem chi tiết Chiến dịch và các chỉ số thống kê hiệu quả.
 * Ánh xạ API C04: GET /campaigns/detail?id={id}
 */
@WebServlet("/campaigns/detail")
public class CampaignDetailServlet extends HttpServlet {

    private CampaignService campaignService = new CampaignService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        Integer userId = session != null ? (Integer) session.getAttribute("userId") : null;
        Integer roleId = session != null ? (Integer) session.getAttribute("roleId") : null;
        List<Integer> roleIds = ValidationUtil.getSafeIntegerList(req.getAttribute("effectiveRoleIds"));

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

        String idStr = req.getParameter("id");
        if (idStr == null || idStr.trim().isEmpty()) {
            if (isJson) {
                resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                resp.setContentType("application/json; charset=UTF-8");
                resp.getWriter().write("{\"status\":\"error\",\"message\":\"Thiếu tham số ID chiến dịch.\"}");
            } else {
                resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Thiếu tham số ID chiến dịch.");
            }
            return;
        }

        int campaignId;
        try {
            campaignId = Integer.parseInt(idStr.trim());
        } catch (NumberFormatException e) {
            if (isJson) {
                resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                resp.setContentType("application/json; charset=UTF-8");
                resp.getWriter().write("{\"status\":\"error\",\"message\":\"ID chiến dịch không hợp lệ.\"}");
            } else {
                resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "ID chiến dịch không hợp lệ.");
            }
            return;
        }

        try {
            Campaign campaign = campaignService.getCampaignDetail(campaignId, userId, roleId != null ? roleId : 0, roleIds);
            if (campaign == null) {
                if (isJson) {
                    resp.setStatus(HttpServletResponse.SC_NOT_FOUND);
                    resp.setContentType("application/json; charset=UTF-8");
                    resp.getWriter().write("{\"status\":\"error\",\"message\":\"Không tìm thấy chiến dịch.\"}");
                } else {
                    resp.sendError(HttpServletResponse.SC_NOT_FOUND, "Không tìm thấy chiến dịch với ID: " + campaignId);
                }
                return;
            }

            if (isJson) {
                resp.setContentType("application/json; charset=UTF-8");
                PrintWriter out = resp.getWriter();
                out.print(toJson(campaign));
                out.flush();
            } else {
                req.setAttribute("campaign", campaign);
                req.setAttribute("leadCount", campaign.getLeadCount());
                req.setAttribute("opportunityCount", campaign.getOpportunityCount());
                req.setAttribute("closedValue", campaign.getClosedValue());
                req.getRequestDispatcher("/WEB-INF/views/campaigns/detail.jsp").forward(req, resp);
            }
        } catch (AuthorizationException e) {
            if (isJson) {
                resp.setStatus(HttpServletResponse.SC_FORBIDDEN);
                resp.setContentType("application/json; charset=UTF-8");
                resp.getWriter().write("{\"status\":\"error\",\"message\":\"" + escapeJson(e.getMessage()) + "\"}");
            } else {
                resp.sendError(HttpServletResponse.SC_FORBIDDEN, e.getMessage());
            }
        } catch (Exception e) {
            if (isJson) {
                resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                resp.setContentType("application/json; charset=UTF-8");
                resp.getWriter().write("{\"status\":\"error\",\"message\":\"Lỗi hệ thống khi tải chi tiết chiến dịch.\"}");
            } else {
                resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Lỗi hệ thống khi tải chi tiết chiến dịch.");
            }
        }
    }

    private boolean isJsonRequest(HttpServletRequest req) {
        return "json".equalsIgnoreCase(req.getParameter("format")) ||
                (req.getHeader("Accept") != null && req.getHeader("Accept").contains("application/json")) ||
                "XMLHttpRequest".equals(req.getHeader("X-Requested-With"));
    }

    private String toJson(Campaign c) {
        return "{\"status\":\"success\",\"data\":{" +
                "\"campaignId\":" + c.getCampaignId() + "," +
                "\"name\":\"" + escapeJson(c.getCampaignName()) + "\"," +
                "\"budget\":" + (c.getBudget() != null ? c.getBudget().toPlainString() : "0") + "," +
                "\"startDate\":" + (c.getStartDate() != null ? "\"" + c.getStartDate() + "\"" : "null") + "," +
                "\"endDate\":" + (c.getEndDate() != null ? "\"" + c.getEndDate() + "\"" : "null") + "," +
                "\"channel\":" + (c.getChannel() != null ? "\"" + escapeJson(c.getChannel()) + "\"" : "null") + "," +
                "\"description\":" + (c.getDescription() != null ? "\"" + escapeJson(c.getDescription()) + "\"" : "null") + "," +
                "\"status\":\"" + escapeJson(c.getStatus()) + "\"," +
                "\"leadCount\":" + c.getLeadCount() + "," +
                "\"opportunityCount\":" + c.getOpportunityCount() + "," +
                "\"closedValue\":" + (c.getClosedValue() != null ? c.getClosedValue().toPlainString() : "0") +
                "}}";
    }

    private String escapeJson(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", "\\n").replace("\r", "\\r");
    }
}

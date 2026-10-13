package com.crm.controller.campaign;

import com.crm.dto.CampaignRequest;
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
 * Controller xử lý cập nhật thông tin Chiến dịch tiếp thị.
 * Ánh xạ API C05 (GET /campaigns/edit?id={id}) và API C06 (POST /campaigns/edit).
 */
@WebServlet(urlPatterns = {"/campaigns/edit", "/campaigns/update"})
public class CampaignUpdateServlet extends HttpServlet {

    private CampaignService campaignService = new CampaignService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        Integer userId = session != null ? (Integer) session.getAttribute("userId") : null;
        Integer roleId = session != null ? (Integer) session.getAttribute("roleId") : null;
        List<Integer> roleIds = ValidationUtil.getSafeIntegerList(req.getAttribute("effectiveRoleIds"));

        if (userId == null) {
            resp.sendRedirect(req.getContextPath() + "/auth/login");
            return;
        }

        String idStr = req.getParameter("id");
        if (idStr == null || idStr.trim().isEmpty()) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Thiếu ID chiến dịch.");
            return;
        }

        try {
            int campaignId = Integer.parseInt(idStr.trim());
            Campaign campaign = campaignService.getCampaignDetail(campaignId, userId, roleId != null ? roleId : 0, roleIds);
            if (campaign == null) {
                resp.sendError(HttpServletResponse.SC_NOT_FOUND, "Không tìm thấy chiến dịch.");
                return;
            }

            req.setAttribute("campaign", campaign);
            req.setAttribute("channels", campaignService.getAvailableChannels());
            req.getRequestDispatcher("/WEB-INF/views/campaigns/edit.jsp").forward(req, resp);
        } catch (NumberFormatException e) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "ID chiến dịch không hợp lệ.");
        } catch (AuthorizationException e) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, e.getMessage());
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");

        HttpSession session = req.getSession(false);
        Integer userId = session != null ? (Integer) session.getAttribute("userId") : null;
        Integer roleId = session != null ? (Integer) session.getAttribute("roleId") : null;
        List<Integer> roleIds = ValidationUtil.getSafeIntegerList(req.getAttribute("effectiveRoleIds"));

        boolean isJson = isJsonRequest(req);

        if (userId == null) {
            sendUnauthorized(req, resp);
            return;
        }

        String idStr = req.getParameter("id");
        if (idStr == null || idStr.trim().isEmpty()) {
            idStr = req.getParameter("campaignId");
        }

        if (idStr == null || idStr.trim().isEmpty()) {
            sendBadRequest(resp, "Thiếu ID chiến dịch cần cập nhật.", isJson);
            return;
        }

        int campaignId;
        try {
            campaignId = Integer.parseInt(idStr.trim());
        } catch (NumberFormatException e) {
            sendBadRequest(resp, "ID chiến dịch không hợp lệ.", isJson);
            return;
        }

        CampaignRequest requestDto = new CampaignRequest();
        requestDto.setId(campaignId);
        requestDto.setName(req.getParameter("name") != null ? req.getParameter("name") : req.getParameter("campaignName"));
        requestDto.setBudget(req.getParameter("budget"));
        requestDto.setStartDate(req.getParameter("startDate"));
        requestDto.setEndDate(req.getParameter("endDate"));
        requestDto.setChannel(req.getParameter("channel"));
        requestDto.setDescription(req.getParameter("description"));
        requestDto.setStatus(req.getParameter("status"));

        try {
            Campaign updated = campaignService.updateCampaign(requestDto, userId, roleId != null ? roleId : 0, roleIds);

            if (isJson) {
                resp.setStatus(HttpServletResponse.SC_OK);
                resp.setContentType("application/json; charset=UTF-8");
                PrintWriter out = resp.getWriter();
                out.print("{\"status\":\"success\",\"message\":\"Cập nhật chiến dịch thành công\",\"campaignId\":" + updated.getCampaignId() + "}");
                out.flush();
            } else {
                resp.sendRedirect(req.getContextPath() + "/campaigns/detail?id=" + updated.getCampaignId() + "&updated=true");
            }
        } catch (IllegalArgumentException e) {
            if (isJson) {
                sendBadRequest(resp, e.getMessage(), true);
            } else {
                req.setAttribute("errorMessage", e.getMessage());
                req.setAttribute("campaign", requestDto);
                req.setAttribute("channels", campaignService.getAvailableChannels());
                req.getRequestDispatcher("/WEB-INF/views/campaigns/edit.jsp").forward(req, resp);
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
                resp.getWriter().write("{\"status\":\"error\",\"message\":\"Lỗi hệ thống khi cập nhật chiến dịch.\"}");
            } else {
                req.setAttribute("errorMessage", "Lỗi hệ thống khi cập nhật chiến dịch.");
                req.setAttribute("campaign", requestDto);
                req.setAttribute("channels", campaignService.getAvailableChannels());
                req.getRequestDispatcher("/WEB-INF/views/campaigns/edit.jsp").forward(req, resp);
            }
        }
    }

    private boolean isJsonRequest(HttpServletRequest req) {
        return "json".equalsIgnoreCase(req.getParameter("format")) ||
                (req.getHeader("Accept") != null && req.getHeader("Accept").contains("application/json")) ||
                "XMLHttpRequest".equals(req.getHeader("X-Requested-With"));
    }

    private void sendBadRequest(HttpServletResponse resp, String message, boolean isJson) throws IOException {
        if (isJson) {
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            resp.setContentType("application/json; charset=UTF-8");
            resp.getWriter().write("{\"status\":\"error\",\"message\":\"" + escapeJson(message) + "\"}");
        } else {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, message);
        }
    }

    private void sendUnauthorized(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        if (isJsonRequest(req)) {
            resp.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            resp.setContentType("application/json; charset=UTF-8");
            resp.getWriter().write("{\"status\":\"error\",\"message\":\"Phiên đăng nhập đã hết hạn.\"}");
        } else {
            resp.sendRedirect(req.getContextPath() + "/auth/login");
        }
    }

    private String escapeJson(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", "\\n").replace("\r", "\\r");
    }
}

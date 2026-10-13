package com.crm.controller.campaign;

import com.crm.dto.CampaignRequest;
import com.crm.model.Campaign;
import com.crm.service.CampaignService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.io.PrintWriter;

/**
 * Controller tiếp nhận yêu cầu tạo mới Chiến dịch tiếp thị.
 * Ánh xạ API C02 (GET /campaigns/create) và API C03 (POST /campaigns/create).
 */
@WebServlet("/campaigns/create")
public class CampaignCreateServlet extends HttpServlet {

    private CampaignService campaignService = new CampaignService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        Integer userId = session != null ? (Integer) session.getAttribute("userId") : null;
        if (userId == null) {
            resp.sendRedirect(req.getContextPath() + "/auth/login");
            return;
        }

        req.setAttribute("channels", campaignService.getAvailableChannels());
        req.getRequestDispatcher("/WEB-INF/views/campaigns/create.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");

        HttpSession session = req.getSession(false);
        Integer userId = session != null ? (Integer) session.getAttribute("userId") : null;
        if (userId == null) {
            sendUnauthorized(req, resp);
            return;
        }

        CampaignRequest requestDto = new CampaignRequest();
        requestDto.setName(req.getParameter("name") != null ? req.getParameter("name") : req.getParameter("campaignName"));
        requestDto.setBudget(req.getParameter("budget"));
        requestDto.setStartDate(req.getParameter("startDate"));
        requestDto.setEndDate(req.getParameter("endDate"));
        requestDto.setChannel(req.getParameter("channel"));
        requestDto.setDescription(req.getParameter("description"));
        requestDto.setStatus(req.getParameter("status"));

        boolean isJson = isJsonRequest(req);

        try {
            Campaign created = campaignService.createCampaign(requestDto, userId);

            if (isJson) {
                resp.setStatus(HttpServletResponse.SC_CREATED);
                resp.setContentType("application/json; charset=UTF-8");
                PrintWriter out = resp.getWriter();
                out.print("{\"status\":\"success\",\"message\":\"Tạo chiến dịch thành công\",\"campaignId\":" + created.getCampaignId() + "}");
                out.flush();
            } else {
                resp.sendRedirect(req.getContextPath() + "/campaigns/detail?id=" + created.getCampaignId() + "&created=true");
            }
        } catch (IllegalArgumentException e) {
            if (isJson) {
                resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                resp.setContentType("application/json; charset=UTF-8");
                resp.getWriter().write("{\"status\":\"error\",\"message\":\"" + escapeJson(e.getMessage()) + "\"}");
            } else {
                req.setAttribute("errorMessage", e.getMessage());
                req.setAttribute("requestDto", requestDto);
                req.setAttribute("channels", campaignService.getAvailableChannels());
                req.getRequestDispatcher("/WEB-INF/views/campaigns/create.jsp").forward(req, resp);
            }
        } catch (Exception e) {
            if (isJson) {
                resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                resp.setContentType("application/json; charset=UTF-8");
                resp.getWriter().write("{\"status\":\"error\",\"message\":\"Đã xảy ra lỗi hệ thống khi tạo chiến dịch.\"}");
            } else {
                req.setAttribute("errorMessage", "Đã xảy ra lỗi hệ thống khi tạo chiến dịch.");
                req.setAttribute("requestDto", requestDto);
                req.setAttribute("channels", campaignService.getAvailableChannels());
                req.getRequestDispatcher("/WEB-INF/views/campaigns/create.jsp").forward(req, resp);
            }
        }
    }

    private boolean isJsonRequest(HttpServletRequest req) {
        return "json".equalsIgnoreCase(req.getParameter("format")) ||
                (req.getHeader("Accept") != null && req.getHeader("Accept").contains("application/json")) ||
                "XMLHttpRequest".equals(req.getHeader("X-Requested-With"));
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

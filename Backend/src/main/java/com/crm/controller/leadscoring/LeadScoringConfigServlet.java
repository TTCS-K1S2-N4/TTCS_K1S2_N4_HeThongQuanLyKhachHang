package com.crm.controller.leadscoring;

import com.crm.service.LeadScoringService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

/**
 * Controller cấu hình Ngưỡng Phân loại Lead Nóng / Ấm / Lạnh (S4-05-AC-03).
 * URL: /lead-scoring/config
 */
@WebServlet(urlPatterns = {"/lead-scoring/config"})
public class LeadScoringConfigServlet extends HttpServlet {

    private LeadScoringService scoringService = new LeadScoringService();

    public void setScoringService(LeadScoringService scoringService) {
        if (scoringService != null) {
            this.scoringService = scoringService;
        }
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        int hotThreshold = scoringService.getHotThreshold();
        int warmThreshold = scoringService.getWarmThreshold();

        resp.setContentType("application/json; charset=UTF-8");
        resp.getWriter().write("{\"hotThreshold\":" + hotThreshold + ",\"warmThreshold\":" + warmThreshold + "}");
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
                resp.getWriter().write("{\"success\":false,\"message\":\"Vui lòng đăng nhập.\"}");
            } else {
                resp.sendRedirect(req.getContextPath() + "/auth/login");
            }
            return;
        }

        String hotStr = req.getParameter("hotThreshold");
        String warmStr = req.getParameter("warmThreshold");

        if (hotStr == null || warmStr == null || hotStr.trim().isEmpty() || warmStr.trim().isEmpty()) {
            sendError(req, resp, isJson, HttpServletResponse.SC_BAD_REQUEST, "Vui lòng nhập đầy đủ ngưỡng điểm Lead Nóng và Lead Ấm.");
            return;
        }

        int hotVal;
        int warmVal;
        try {
            hotVal = Integer.parseInt(hotStr.trim());
            warmVal = Integer.parseInt(warmStr.trim());
        } catch (NumberFormatException e) {
            sendError(req, resp, isJson, HttpServletResponse.SC_BAD_REQUEST, "Ngưỡng điểm phải là số nguyên hợp lệ.");
            return;
        }

        if (hotVal <= warmVal) {
            sendError(req, resp, isJson, HttpServletResponse.SC_BAD_REQUEST, "Ngưỡng Lead Nóng (" + hotVal + ") phải lớn hơn ngưỡng Lead Ấm (" + warmVal + ").");
            return;
        }

        try {
            boolean ok = scoringService.updateThresholds(hotVal, warmVal);
            if (ok) {
                if (isJson) {
                    resp.setContentType("application/json; charset=UTF-8");
                    resp.getWriter().write("{\"success\":true,\"message\":\"Cập nhật ngưỡng phân loại Nóng/Ấm/Lạnh thành công!\"}");
                } else {
                    req.getSession().setAttribute("successMessage", "Cập nhật ngưỡng phân loại Nóng/Ấm/Lạnh thành công!");
                    resp.sendRedirect(req.getContextPath() + "/lead-scoring/rules");
                }
            } else {
                sendError(req, resp, isJson, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Không thể cập nhật cấu hình ngưỡng điểm.");
            }
        } catch (IllegalArgumentException ex) {
            sendError(req, resp, isJson, HttpServletResponse.SC_BAD_REQUEST, ex.getMessage());
        } catch (Exception ex) {
            sendError(req, resp, isJson, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Lỗi hệ thống: " + ex.getMessage());
        }
    }

    private void sendError(HttpServletRequest req, HttpServletResponse resp, boolean isJson, int statusCode, String message) throws IOException {
        resp.setStatus(statusCode);
        if (isJson) {
            resp.setContentType("application/json; charset=UTF-8");
            resp.getWriter().write("{\"success\":false,\"message\":\"" + escapeJson(message) + "\"}");
        } else {
            req.getSession().setAttribute("errorMessage", message);
            resp.sendRedirect(req.getContextPath() + "/lead-scoring/rules");
        }
    }

    private boolean isJsonRequest(HttpServletRequest req) {
        String accept = req.getHeader("Accept");
        String requestedWith = req.getHeader("X-Requested-With");
        return (accept != null && accept.contains("application/json")) || "XMLHttpRequest".equals(requestedWith);
    }

    private String escapeJson(String input) {
        if (input == null) return "";
        return input.replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", "\\n").replace("\r", "\\r");
    }
}

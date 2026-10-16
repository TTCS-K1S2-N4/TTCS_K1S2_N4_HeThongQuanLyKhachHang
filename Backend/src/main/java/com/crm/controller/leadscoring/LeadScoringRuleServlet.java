package com.crm.controller.leadscoring;

import com.crm.dto.LeadScoringRuleRequest;
import com.crm.model.LeadScoringRule;
import com.crm.service.LeadScoringService;
import com.crm.util.JsonUtil;
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
 * Controller quản lý Khai báo Tiêu chí và Điểm số cho Lead Scoring (S4-05).
 * URL: /lead-scoring/rules và /lead-scoring/rules/delete
 */
@WebServlet(urlPatterns = {"/lead-scoring/rules", "/lead-scoring/rules/delete"})
public class LeadScoringRuleServlet extends HttpServlet {

    private LeadScoringService scoringService = new LeadScoringService();

    public void setScoringService(LeadScoringService scoringService) {
        if (scoringService != null) {
            this.scoringService = scoringService;
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
                resp.getWriter().write("{\"success\":false,\"message\":\"Vui lòng đăng nhập.\"}");
            } else {
                resp.sendRedirect(req.getContextPath() + "/auth/login");
            }
            return;
        }

        List<LeadScoringRule> rules = scoringService.getAllRules();
        int hotThreshold = scoringService.getHotThreshold();
        int warmThreshold = scoringService.getWarmThreshold();

        if (isJson) {
            resp.setContentType("application/json; charset=UTF-8");
            resp.getWriter().write(buildRulesJson(rules, hotThreshold, warmThreshold));
        } else {
            req.setAttribute("rules", rules);
            req.setAttribute("hotThreshold", hotThreshold);
            req.setAttribute("warmThreshold", warmThreshold);
            req.getRequestDispatcher("/WEB-INF/views/lead-scoring/rules.jsp").forward(req, resp);
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
                resp.getWriter().write("{\"success\":false,\"message\":\"Vui lòng đăng nhập.\"}");
            } else {
                resp.sendRedirect(req.getContextPath() + "/auth/login");
            }
            return;
        }

        String path = req.getServletPath();
        String action = req.getParameter("action");

        // Xử lý Xóa quy tắc
        if ((path != null && path.endsWith("/delete")) || "delete".equalsIgnoreCase(action)) {
            handleDeleteRule(req, resp, isJson);
            return;
        }

        // Xử lý Thêm mới hoặc Cập nhật quy tắc
        handleSaveRule(req, resp, isJson);
    }

    private void handleSaveRule(HttpServletRequest req, HttpServletResponse resp, boolean isJson) throws IOException, ServletException {
        String ruleIdStr = req.getParameter("ruleId");
        String criterion = req.getParameter("criterion");
        String operator = req.getParameter("operator");
        String conditionValue = req.getParameter("conditionValue");
        String scoreStr = req.getParameter("score");

        // Kiểm tra validation nghiêm ngặt tại Backend
        if (criterion == null || criterion.trim().isEmpty()) {
            sendErrorResponse(req, resp, isJson, HttpServletResponse.SC_BAD_REQUEST, "Vui lòng chọn tiêu chí chấm điểm.");
            return;
        }
        if (conditionValue == null || conditionValue.trim().isEmpty()) {
            sendErrorResponse(req, resp, isJson, HttpServletResponse.SC_BAD_REQUEST, "Vui lòng nhập giá trị điều kiện so khớp.");
            return;
        }
        if (scoreStr == null || scoreStr.trim().isEmpty()) {
            sendErrorResponse(req, resp, isJson, HttpServletResponse.SC_BAD_REQUEST, "Số điểm cộng/trừ không được để trống.");
            return;
        }

        int score;
        try {
            score = Integer.parseInt(scoreStr.trim());
        } catch (NumberFormatException e) {
            sendErrorResponse(req, resp, isJson, HttpServletResponse.SC_BAD_REQUEST, "Điểm số phải là số nguyên hợp lệ.");
            return;
        }

        Integer ruleId = null;
        if (ruleIdStr != null && !ruleIdStr.trim().isEmpty()) {
            try {
                ruleId = Integer.parseInt(ruleIdStr.trim());
            } catch (NumberFormatException ignore) {}
        }

        LeadScoringRuleRequest request = new LeadScoringRuleRequest();
        request.setRuleId(ruleId);
        request.setCriterion(criterion.trim());
        request.setOperator(operator != null ? operator.trim() : "EQUALS");
        request.setConditionValue(conditionValue.trim());
        request.setScore(score);

        try {
            boolean ok = scoringService.saveOrUpdateRule(request);
            if (ok) {
                if (isJson) {
                    resp.setContentType("application/json; charset=UTF-8");
                    resp.getWriter().write("{\"success\":true,\"message\":\"Lưu tiêu chí chấm điểm thành công!\"}");
                } else {
                    req.getSession().setAttribute("successMessage", "Lưu tiêu chí chấm điểm thành công!");
                    resp.sendRedirect(req.getContextPath() + "/lead-scoring/rules");
                }
            } else {
                sendErrorResponse(req, resp, isJson, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Không thể lưu tiêu chí chấm điểm.");
            }
        } catch (IllegalArgumentException ex) {
            sendErrorResponse(req, resp, isJson, HttpServletResponse.SC_BAD_REQUEST, ex.getMessage());
        } catch (Exception ex) {
            sendErrorResponse(req, resp, isJson, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Lỗi hệ thống khi lưu tiêu chí: " + ex.getMessage());
        }
    }

    private void handleDeleteRule(HttpServletRequest req, HttpServletResponse resp, boolean isJson) throws IOException, ServletException {
        String ruleIdStr = req.getParameter("ruleId");
        if (ruleIdStr == null || ruleIdStr.trim().isEmpty()) {
            sendErrorResponse(req, resp, isJson, HttpServletResponse.SC_BAD_REQUEST, "Thiếu ID quy tắc cần xóa.");
            return;
        }

        try {
            int ruleId = Integer.parseInt(ruleIdStr.trim());
            boolean ok = scoringService.deleteRule(ruleId);
            if (ok) {
                if (isJson) {
                    resp.setContentType("application/json; charset=UTF-8");
                    resp.getWriter().write("{\"success\":true,\"message\":\"Xóa quy tắc chấm điểm thành công!\"}");
                } else {
                    req.getSession().setAttribute("successMessage", "Xóa quy tắc chấm điểm thành công!");
                    resp.sendRedirect(req.getContextPath() + "/lead-scoring/rules");
                }
            } else {
                sendErrorResponse(req, resp, isJson, HttpServletResponse.SC_NOT_FOUND, "Không tìm thấy quy tắc để xóa.");
            }
        } catch (NumberFormatException e) {
            sendErrorResponse(req, resp, isJson, HttpServletResponse.SC_BAD_REQUEST, "ID quy tắc không hợp lệ.");
        }
    }

    private void sendErrorResponse(HttpServletRequest req, HttpServletResponse resp, boolean isJson, int statusCode, String message) throws IOException, ServletException {
        resp.setStatus(statusCode);
        if (isJson) {
            resp.setContentType("application/json; charset=UTF-8");
            resp.getWriter().write(JsonUtil.errorResponse(message));
        } else {
            req.setAttribute("errorMessage", message);
            doGet(req, resp);
        }
    }

    private boolean isJsonRequest(HttpServletRequest req) {
        String accept = req.getHeader("Accept");
        String requestedWith = req.getHeader("X-Requested-With");
        return (accept != null && accept.contains("application/json")) || "XMLHttpRequest".equals(requestedWith);
    }

    private String buildRulesJson(List<LeadScoringRule> rules, int hotThreshold, int warmThreshold) {
        StringBuilder sb = new StringBuilder("{");
        sb.append("\"success\":true,")
          .append("\"hotThreshold\":").append(hotThreshold).append(",")
          .append("\"warmThreshold\":").append(warmThreshold).append(",")
          .append("\"rules\":[");
        for (int i = 0; i < rules.size(); i++) {
            LeadScoringRule r = rules.get(i);
            sb.append("{")
              .append("\"ruleId\":").append(r.getRuleId()).append(",")
              .append("\"criterion\":\"").append(JsonUtil.escape(r.getCriterion())).append("\",")
              .append("\"operator\":\"").append(JsonUtil.escape(r.getOperator())).append("\",")
              .append("\"conditionValue\":\"").append(JsonUtil.escape(r.getConditionValue())).append("\",")
              .append("\"score\":").append(r.getScore()).append(",")
              .append("\"isActive\":").append(r.isActive())
              .append("}");
            if (i < rules.size() - 1) sb.append(",");
        }
        sb.append("]}");
        return sb.toString();
    }
}

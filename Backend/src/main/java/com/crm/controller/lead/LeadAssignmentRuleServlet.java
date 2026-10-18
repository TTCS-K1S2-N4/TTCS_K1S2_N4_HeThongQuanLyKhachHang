package com.crm.controller.lead;

import com.crm.dao.AccountDAO;
import com.crm.model.Account;
import com.crm.model.LeadAssignmentRule;
import com.crm.model.Team;
import com.crm.service.LeadAssignmentService;
import com.crm.service.OrganizationService;
import com.crm.util.JsonUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * LeadAssignmentRuleServlet - Quản lý cấu hình quy tắc phân bổ Lead tự động (S4-06).
 * Endpoints: /lead-assignment/rules, /lead-assignment/rules/delete
 */
@WebServlet(urlPatterns = {"/lead-assignment/rules", "/lead-assignment/rules/delete"})
public class LeadAssignmentRuleServlet extends HttpServlet {
    private static final Logger LOGGER = Logger.getLogger(LeadAssignmentRuleServlet.class.getName());

    private LeadAssignmentService assignmentService = new LeadAssignmentService();
    private OrganizationService orgService = new OrganizationService();
    private AccountDAO accountDAO = new AccountDAO();

    public void setAssignmentService(LeadAssignmentService assignmentService) {
        this.assignmentService = assignmentService;
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

        Account currentUser = (session.getAttribute("currentUser") instanceof Account)
                ? (Account) session.getAttribute("currentUser")
                : null;
        Integer roleId = (session.getAttribute("roleId") instanceof Integer)
                ? (Integer) session.getAttribute("roleId")
                : (currentUser != null ? currentUser.getRoleId() : null);

        boolean isAdminOrDirector = false;
        if (currentUser != null && currentUser.getRoleCodes() != null) {
            for (String code : currentUser.getRoleCodes()) {
                if ("ADMIN".equalsIgnoreCase(code) || "DIRECTOR".equalsIgnoreCase(code)) isAdminOrDirector = true;
            }
        }
        if (!isAdminOrDirector && roleId != null && (roleId == 1 || roleId == 4)) {
            isAdminOrDirector = true;
        }

        if (!isAdminOrDirector) {
            if (isJson) {
                resp.setStatus(HttpServletResponse.SC_FORBIDDEN);
                resp.setContentType("application/json; charset=UTF-8");
                resp.getWriter().write("{\"success\":false,\"message\":\"Chỉ Giám đốc kinh doanh hoặc Quản trị viên mới có quyền cấu hình quy tắc phân bổ.\"}");
            } else {
                resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền truy cập cấu hình quy tắc phân bổ.");
            }
            return;
        }

        List<LeadAssignmentRule> rules = assignmentService.getAllRules();
        List<Team> teams = orgService.getAllTeams();
        List<Account> salesUsers = accountDAO.getAllActiveAccounts();

        if (isJson) {
            resp.setContentType("application/json; charset=UTF-8");
            resp.getWriter().write(buildRulesJson(rules));
        } else {
            req.setAttribute("rules", rules);
            req.setAttribute("teams", teams);
            req.setAttribute("salesUsers", salesUsers);
            req.getRequestDispatcher("/WEB-INF/views/leads/assignment-rules.jsp").forward(req, resp);
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
        String ruleName = req.getParameter("ruleName");
        String priorityStr = req.getParameter("priority");
        String criterion = req.getParameter("criterion");
        String criterionValue = req.getParameter("criterionValue");
        String teamIdStr = req.getParameter("teamId");
        String assigneeIdStr = req.getParameter("assigneeId");
        String isActiveStr = req.getParameter("isActive");

        if (criterion == null || criterion.trim().isEmpty()) {
            sendError(req, resp, isJson, HttpServletResponse.SC_BAD_REQUEST, "Vui lòng chọn loại tiêu chí (Khu vực, Ngành nghề, hoặc Round-Robin).");
            return;
        }

        criterion = criterion.trim().toUpperCase();

        if ("ROUND_ROBIN".equals(criterion)) {
            if (teamIdStr == null || teamIdStr.trim().isEmpty()) {
                sendError(req, resp, isJson, HttpServletResponse.SC_BAD_REQUEST, "Quy tắc xoay vòng (Round-Robin) bắt buộc phải chọn Nhóm kinh doanh phụ trách.");
                return;
            }
        } else {
            if (criterionValue == null || criterionValue.trim().isEmpty()) {
                sendError(req, resp, isJson, HttpServletResponse.SC_BAD_REQUEST, "Vui lòng nhập giá trị so khớp cho tiêu chí (" + criterion + ").");
                return;
            }
            if (assigneeIdStr == null || assigneeIdStr.trim().isEmpty()) {
                sendError(req, resp, isJson, HttpServletResponse.SC_BAD_REQUEST, "Vui lòng chọn nhân viên kinh doanh tiếp nhận Lead.");
                return;
            }
        }

        int priority = 1;
        if (priorityStr != null && !priorityStr.trim().isEmpty()) {
            try {
                priority = Integer.parseInt(priorityStr.trim());
            } catch (NumberFormatException ignore) {}
        }

        Integer teamId = null;
        if (teamIdStr != null && !teamIdStr.trim().isEmpty()) {
            try { teamId = Integer.parseInt(teamIdStr.trim()); } catch (NumberFormatException ignore) {}
        }

        Integer assigneeId = null;
        if (assigneeIdStr != null && !assigneeIdStr.trim().isEmpty()) {
            try { assigneeId = Integer.parseInt(assigneeIdStr.trim()); } catch (NumberFormatException ignore) {}
        }

        boolean isActive = !"false".equalsIgnoreCase(isActiveStr);

        int ruleId = 0;
        if (ruleIdStr != null && !ruleIdStr.trim().isEmpty()) {
            try { ruleId = Integer.parseInt(ruleIdStr.trim()); } catch (NumberFormatException ignore) {}
        }

        LeadAssignmentRule rule = new LeadAssignmentRule();
        rule.setRuleId(ruleId);
        rule.setRuleName(ruleName != null && !ruleName.trim().isEmpty() ? ruleName.trim() : ("Quy tắc " + criterion));
        rule.setPriority(priority);
        rule.setCriterion(criterion);
        rule.setCriterionValue(criterionValue != null ? criterionValue.trim() : null);
        rule.setTeamId(teamId);
        rule.setAssigneeId(assigneeId);
        rule.setActive(isActive);

        boolean success = assignmentService.saveOrUpdateRule(rule);
        if (success) {
            // Tự động kích hoạt worker xử lý phân bổ ngay các Lead đang chờ
            assignmentService.processUnassignedLeads();

            if (isJson) {
                resp.setContentType("application/json; charset=UTF-8");
                resp.getWriter().write("{\"success\":true,\"message\":\"Lưu quy tắc phân bổ thành công!\"}");
            } else {
                req.getSession().setAttribute("successMessage", "Lưu quy tắc phân bổ thành công!");
                resp.sendRedirect(req.getContextPath() + "/lead-assignment/rules");
            }
        } else {
            sendError(req, resp, isJson, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Không thể lưu quy tắc phân bổ.");
        }
    }

    private void handleDeleteRule(HttpServletRequest req, HttpServletResponse resp, boolean isJson) throws IOException, ServletException {
        String ruleIdStr = req.getParameter("ruleId");
        if (ruleIdStr == null || ruleIdStr.trim().isEmpty()) {
            sendError(req, resp, isJson, HttpServletResponse.SC_BAD_REQUEST, "Thiếu ID quy tắc cần xóa.");
            return;
        }

        try {
            int ruleId = Integer.parseInt(ruleIdStr.trim());
            boolean ok = assignmentService.deleteRule(ruleId);
            if (ok) {
                if (isJson) {
                    resp.setContentType("application/json; charset=UTF-8");
                    resp.getWriter().write("{\"success\":true,\"message\":\"Xóa quy tắc phân bổ thành công!\"}");
                } else {
                    req.getSession().setAttribute("successMessage", "Xóa quy tắc phân bổ thành công!");
                    resp.sendRedirect(req.getContextPath() + "/lead-assignment/rules");
                }
            } else {
                sendError(req, resp, isJson, HttpServletResponse.SC_NOT_FOUND, "Không tìm thấy quy tắc để xóa.");
            }
        } catch (NumberFormatException e) {
            sendError(req, resp, isJson, HttpServletResponse.SC_BAD_REQUEST, "ID quy tắc không hợp lệ.");
        }
    }

    private void sendError(HttpServletRequest req, HttpServletResponse resp, boolean isJson, int statusCode, String message) throws IOException, ServletException {
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

    private String buildRulesJson(List<LeadAssignmentRule> rules) {
        StringBuilder sb = new StringBuilder("{\"success\":true,\"total\":").append(rules.size()).append(",\"rules\":[");
        for (int i = 0; i < rules.size(); i++) {
            LeadAssignmentRule r = rules.get(i);
            sb.append("{\"ruleId\":").append(r.getRuleId())
              .append(",\"ruleName\":\"").append(escapeJson(r.getRuleName())).append("\"")
              .append(",\"priority\":").append(r.getPriority())
              .append(",\"criterion\":\"").append(escapeJson(r.getCriterion())).append("\"")
              .append(",\"criterionValue\":\"").append(escapeJson(r.getCriterionValue())).append("\"")
              .append(",\"teamId\":").append(r.getTeamId())
              .append(",\"teamName\":\"").append(escapeJson(r.getTeamName())).append("\"")
              .append(",\"assigneeId\":").append(r.getAssigneeId())
              .append(",\"assigneeName\":\"").append(escapeJson(r.getAssigneeName())).append("\"")
              .append(",\"isActive\":").append(r.isActive())
              .append("}");
            if (i < rules.size() - 1) sb.append(",");
        }
        sb.append("]}");
        return sb.toString();
    }

    private String escapeJson(String input) {
        if (input == null) return "";
        return input.replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", "\\n").replace("\r", "");
    }
}

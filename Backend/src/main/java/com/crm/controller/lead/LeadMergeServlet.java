package com.crm.controller.lead;

import com.crm.dto.LeadMergeRequest;
import com.crm.service.LeadDuplicateService;
import com.crm.service.LeadDuplicateService.LeadRecord;
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
 * Controller tiếp nhận yêu cầu gộp Lead trùng lặp.
 * Ánh xạ API D03: POST /leads/merge và GET /leads/merge (giao diện gộp).
 */
@WebServlet("/leads/merge")
public class LeadMergeServlet extends HttpServlet {

    private LeadDuplicateService duplicateService = new LeadDuplicateService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        Integer userId = session != null ? (Integer) session.getAttribute("userId") : null;
        if (userId == null) {
            resp.sendRedirect(req.getContextPath() + "/auth/login");
            return;
        }

        if (!isAuthorizedRole(session)) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền truy cập chức năng gộp Lead.");
            return;
        }

        String primaryStr = req.getParameter("primaryId") != null ? req.getParameter("primaryId") : req.getParameter("leftId");
        String duplicateStr = req.getParameter("duplicateId") != null ? req.getParameter("duplicateId") : (req.getParameter("secondaryId") != null ? req.getParameter("secondaryId") : req.getParameter("rightId"));

        if (primaryStr != null && duplicateStr != null) {
            try {
                int primaryId = Integer.parseInt(primaryStr.trim());
                int duplicateId = Integer.parseInt(duplicateStr.trim());

                LeadRecord primaryLead = duplicateService.findLeadById(primaryId);
                LeadRecord duplicateLead = duplicateService.findLeadById(duplicateId);

                if (primaryLead != null && duplicateLead != null) {
                    if (!canUserAccessLeadScope(session, primaryLead, duplicateLead, userId)) {
                        resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền thao tác trên các Lead ngoài phạm vi phân công của mình.");
                        return;
                    }
                }

                req.setAttribute("primaryLead", primaryLead);
                req.setAttribute("duplicateLead", duplicateLead);
                req.setAttribute("primaryId", primaryId);
                req.setAttribute("duplicateId", duplicateId);
            } catch (NumberFormatException ignored) {}
        }

        req.getRequestDispatcher("/WEB-INF/views/leads/merge.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");

        HttpSession session = req.getSession(false);
        Integer userId = session != null ? (Integer) session.getAttribute("userId") : null;
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

        if (!isAuthorizedRole(session)) {
            sendError(resp, "Bạn không có quyền thực hiện thao tác gộp Lead.", isJson, HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        String primaryStr = req.getParameter("primaryLeadId") != null ? req.getParameter("primaryLeadId") : req.getParameter("primaryId");
        if (primaryStr == null) primaryStr = req.getParameter("leftId");

        String duplicateStr = req.getParameter("duplicateLeadId") != null ? req.getParameter("duplicateLeadId") : req.getParameter("duplicateId");
        if (duplicateStr == null) duplicateStr = req.getParameter("secondaryId");
        if (duplicateStr == null) duplicateStr = req.getParameter("rightId");

        if (primaryStr == null || duplicateStr == null || primaryStr.trim().isEmpty() || duplicateStr.trim().isEmpty()) {
            sendError(resp, "Thiếu ID bản ghi Lead chính hoặc Lead trùng.", isJson, HttpServletResponse.SC_BAD_REQUEST);
            return;
        }

        int primaryId;
        int duplicateId;
        try {
            primaryId = Integer.parseInt(primaryStr.trim());
            duplicateId = Integer.parseInt(duplicateStr.trim());
        } catch (NumberFormatException e) {
            sendError(resp, "ID bản ghi Lead không hợp lệ.", isJson, HttpServletResponse.SC_BAD_REQUEST);
            return;
        }

        if (primaryId == duplicateId) {
            sendError(resp, "Không thể gộp một Lead vào chính nó.", isJson, HttpServletResponse.SC_BAD_REQUEST);
            return;
        }

        LeadRecord primaryLead = duplicateService.findLeadById(primaryId);
        LeadRecord duplicateLead = duplicateService.findLeadById(duplicateId);
        if (primaryLead == null || duplicateLead == null) {
            sendError(resp, "Không tìm thấy một trong hai bản ghi Lead.", isJson, HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        if (!canUserAccessLeadScope(session, primaryLead, duplicateLead, userId)) {
            sendError(resp, "Bạn không có quyền gộp các Lead ngoài phạm vi phân công của mình.", isJson, HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        LeadMergeRequest mergeRequest = new LeadMergeRequest(primaryId, duplicateId);
        mergeRequest.setRetainedFullName(req.getParameter("retainedFullName"));
        mergeRequest.setRetainedCompany(req.getParameter("retainedCompany"));
        mergeRequest.setRetainedEmail(req.getParameter("retainedEmail"));
        mergeRequest.setRetainedPhone(req.getParameter("retainedPhone"));
        mergeRequest.setNote(req.getParameter("note"));

        try {
            boolean success = duplicateService.mergeLeads(mergeRequest, userId);
            if (success) {
                if (isJson) {
                    resp.setStatus(HttpServletResponse.SC_OK);
                    resp.setContentType("application/json; charset=UTF-8");
                    PrintWriter out = resp.getWriter();
                    out.print("{\"status\":\"success\",\"message\":\"Gộp Lead thành công\",\"primaryLeadId\":" + primaryId + ",\"mergedLeadId\":" + duplicateId + "}");
                    out.flush();
                } else {
                    resp.sendRedirect(req.getContextPath() + "/leads/duplicates?merged=true&primaryId=" + primaryId);
                }
            } else {
                sendError(resp, "Thao tác gộp Lead không thành công. Vui lòng kiểm tra lại trạng thái bản ghi.", isJson, HttpServletResponse.SC_BAD_REQUEST);
            }
        } catch (IllegalStateException e) {
            sendError(resp, e.getMessage(), isJson, HttpServletResponse.SC_CONFLICT);
        } catch (IllegalArgumentException e) {
            sendError(resp, e.getMessage(), isJson, HttpServletResponse.SC_BAD_REQUEST);
        } catch (Exception e) {
            sendError(resp, "Lỗi hệ thống khi gộp Lead: " + e.getMessage(), isJson, HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }

    @SuppressWarnings("unchecked")
    private boolean isAuthorizedRole(HttpSession session) {
        if (session == null) return false;
        List<Integer> roleIds = (List<Integer>) session.getAttribute("roleIds");
        Integer roleId = (Integer) session.getAttribute("roleId");

        // Quản trị (1), Giám đốc (4), Trưởng nhóm (3), Marketing (5), Nhân viên kinh doanh (2)
        return hasRole(roleIds, roleId, 1) || hasRole(roleIds, roleId, 4) || hasRole(roleIds, roleId, 3) || hasRole(roleIds, roleId, 5) || hasRole(roleIds, roleId, 2);
    }

    @SuppressWarnings("unchecked")
    private boolean canUserAccessLeadScope(HttpSession session, LeadRecord pLead, LeadRecord dLead, Integer userId) {
        if (session == null || userId == null) return false;
        List<Integer> roleIds = (List<Integer>) session.getAttribute("roleIds");
        Integer roleId = (Integer) session.getAttribute("roleId");

        // 1. Quản trị (1), Giám đốc (4), Trưởng nhóm (3), Marketing (5) có quyền gộp trên toàn bộ Leads (lọc trùng lead đầu vào)
        if (hasRole(roleIds, roleId, 1) || hasRole(roleIds, roleId, 4) || hasRole(roleIds, roleId, 3) || hasRole(roleIds, roleId, 5)) {
            return true;
        }

        // 2. Nhân viên kinh doanh (2) chỉ được gộp nếu sở hữu ít nhất một trong hai Lead hoặc Lead chưa phân công
        if (hasRole(roleIds, roleId, 2)) {
            Integer pOwner = pLead.getOwnerId();
            Integer dOwner = dLead.getOwnerId();
            return (pOwner == null || pOwner.equals(userId) || dOwner == null || dOwner.equals(userId));
        }

        return false;
    }

    private boolean hasRole(List<Integer> roleIds, Integer roleId, int targetRoleId) {
        if (roleId != null && roleId == targetRoleId) return true;
        return roleIds != null && roleIds.contains(targetRoleId);
    }

    private boolean isJsonRequest(HttpServletRequest req) {
        return "json".equalsIgnoreCase(req.getParameter("format")) ||
                (req.getHeader("Accept") != null && req.getHeader("Accept").contains("application/json")) ||
                "XMLHttpRequest".equals(req.getHeader("X-Requested-With"));
    }

    private void sendError(HttpServletResponse resp, String message, boolean isJson, int statusCode) throws IOException {
        if (isJson) {
            resp.setStatus(statusCode);
            resp.setContentType("application/json; charset=UTF-8");
            resp.getWriter().write("{\"status\":\"error\",\"message\":\"" + escapeJson(message) + "\"}");
        } else {
            resp.sendError(statusCode, message);
        }
    }

    private String escapeJson(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", "\\n").replace("\r", "\\r");
    }
}

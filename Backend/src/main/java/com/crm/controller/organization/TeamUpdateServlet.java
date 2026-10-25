package com.crm.controller.organization;

import com.crm.model.Account;
import com.crm.model.Team;
import com.crm.service.OrganizationService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.List;

@WebServlet("/organization/teams/update")
public class TeamUpdateServlet extends HttpServlet {

    private OrganizationService organizationService = new OrganizationService();

    public void setOrganizationService(OrganizationService organizationService) {
        if (organizationService != null) {
            this.organizationService = organizationService;
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        Account currentUser = session != null ? (Account) session.getAttribute("currentUser") : null;
        Integer userId = session != null ? (Integer) session.getAttribute("userId") : null;

        if (currentUser == null && userId != null) {
            try {
                currentUser = new com.crm.dao.AccountDAO().getAccountById(userId);
            } catch (Exception ignored) {}
        }

        if (currentUser == null && userId == null) {
            if (isAjaxRequest(req)) {
                resp.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                resp.setContentType("application/json;charset=UTF-8");
                PrintWriter out = resp.getWriter();
                out.print("{\"status\": 401, \"message\": \"Bạn cần đăng nhập để thực hiện chức năng này.\"}");
                out.flush();
                return;
            } else {
                resp.sendRedirect(req.getContextPath() + "/auth/login");
                return;
            }
        }

        List<String> errors = new ArrayList<>();

        String action = req.getParameter("action");
        if ("transferUser".equals(action) || req.getParameter("transferUserId") != null) {
            String sourceTeamIdStr = req.getParameter("sourceTeamId");
            Integer sourceTeamId = null;
            if (sourceTeamIdStr != null && !sourceTeamIdStr.trim().isEmpty()) {
                try {
                    sourceTeamId = Integer.parseInt(sourceTeamIdStr.trim());
                } catch (NumberFormatException e) {
                    errors.add("ID nhóm hiện tại (sourceTeamId) không hợp lệ.");
                }
            }

            String transferUserIdStr = req.getParameter("transferUserId");
            if (transferUserIdStr == null) transferUserIdStr = req.getParameter("userId");
            int transferUserId = 0;
            if (transferUserIdStr != null && !transferUserIdStr.trim().isEmpty()) {
                try {
                    transferUserId = Integer.parseInt(transferUserIdStr.trim());
                } catch (NumberFormatException e) {
                    errors.add("Mã người dùng chuyển nhóm (transferUserId) không hợp lệ.");
                }
            } else {
                errors.add("Vui lòng chọn người dùng cần chuyển nhóm.");
            }

            String targetTeamIdStr = req.getParameter("targetTeamId");
            if (targetTeamIdStr == null) targetTeamIdStr = req.getParameter("newTeamId");
            Integer targetTeamId = null;
            if (targetTeamIdStr != null && !targetTeamIdStr.trim().isEmpty() && !"0".equals(targetTeamIdStr.trim())) {
                try {
                    targetTeamId = Integer.parseInt(targetTeamIdStr.trim());
                } catch (NumberFormatException e) {
                    errors.add("Mã nhóm đích (targetTeamId) không hợp lệ.");
                }
            }

            if (!errors.isEmpty()) {
                handleErrorResponse(req, resp, errors, null);
                return;
            }

            boolean transferred = organizationService.transferUserToTeam(transferUserId, sourceTeamId, targetTeamId, errors);
            if (transferred) {
                if (isAjaxRequest(req)) {
                    resp.setContentType("application/json;charset=UTF-8");
                    PrintWriter out = resp.getWriter();
                    out.print("{\"success\": true, \"message\": \"Chuyển nhân viên sang nhóm mới thành công.\"}");
                    out.flush();
                } else {
                    resp.sendRedirect(req.getContextPath() + "/organization/teams?success=transfer");
                }
            } else {
                handleErrorResponse(req, resp, errors, null);
            }
            return;
        }
        String teamIdStr = req.getParameter("teamId");
        int teamId = 0;
        if (teamIdStr != null && !teamIdStr.trim().isEmpty()) {
            try {
                teamId = Integer.parseInt(teamIdStr.trim());
                if (teamId < 0) {
                    errors.add("Mã nhóm (ID) phải là số không âm.");
                }
            } catch (NumberFormatException e) {
                errors.add("ID nhóm kinh doanh (teamId) không đúng định dạng số.");
            }
        }

        String teamName = req.getParameter("teamName");
        String parentTeamIdStr = req.getParameter("parentTeamId");
        Integer parentTeamId = null;
        if (parentTeamIdStr != null && !parentTeamIdStr.trim().isEmpty()) {
            try {
                parentTeamId = Integer.parseInt(parentTeamIdStr.trim());
                if (parentTeamId < 0) {
                    errors.add("ID nhóm cha (parentTeamId) phải là số không âm.");
                }
            } catch (NumberFormatException e) {
                errors.add("ID nhóm cha (parentTeamId) không đúng định dạng số.");
            }
        }

        String leaderIdStr = req.getParameter("leaderId");
        Integer leaderId = null;
        if (leaderIdStr != null && !leaderIdStr.trim().isEmpty()) {
            try {
                leaderId = Integer.parseInt(leaderIdStr.trim());
                if (leaderId < 0) {
                    errors.add("ID trưởng nhóm (leaderId) phải là số không âm.");
                }
            } catch (NumberFormatException e) {
                errors.add("ID trưởng nhóm (leaderId) không đúng định dạng số.");
            }
        }

        String region = req.getParameter("region");
        String description = req.getParameter("description");

        Team team = new Team();
        team.setId(teamId);
        team.setName(teamName);
        team.setParentTeamId(parentTeamId);
        team.setLeaderId(leaderId);
        team.setRegion(region);
        team.setDescription(description);

        if (!errors.isEmpty()) {
            handleErrorResponse(req, resp, errors, team);
            return;
        }

        boolean saved = organizationService.saveOrUpdateTeam(team, errors);

        if (saved) {
            if (isAjaxRequest(req)) {
                resp.setContentType("application/json;charset=UTF-8");
                PrintWriter out = resp.getWriter();
                out.print("{\"success\": true, \"message\": \"Cập nhật cơ cấu nhóm kinh doanh thành công.\", \"teamId\": " + team.getId() + "}");
                out.flush();
            } else {
                resp.sendRedirect(req.getContextPath() + "/organization/teams?success=update");
            }
        } else {
            handleErrorResponse(req, resp, errors, team);
        }
    }

    private void handleErrorResponse(HttpServletRequest req, HttpServletResponse resp, List<String> errors, Team team)
            throws ServletException, IOException {
        if (isAjaxRequest(req)) {
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            resp.setContentType("application/json;charset=UTF-8");
            PrintWriter out = resp.getWriter();
            StringBuilder json = new StringBuilder();
            json.append("{\"success\": false, \"errors\": [");
            for (int i = 0; i < errors.size(); i++) {
                if (i > 0) json.append(",");
                json.append("\"").append(escapeJson(errors.get(i))).append("\"");
            }
            json.append("]}");
            out.print(json.toString());
            out.flush();
        } else {
            req.setAttribute("errors", errors);
            req.setAttribute("team", team);
            req.setAttribute("teams", organizationService.getAllTeams());
            req.setAttribute("users", organizationService.getAllActiveUsers());
            req.setAttribute("leaderCandidates", organizationService.getLeaderCandidateUsers());
            req.getRequestDispatcher("/WEB-INF/views/organization/teams.jsp").forward(req, resp);
        }
    }

    private boolean isAjaxRequest(HttpServletRequest request) {
        String requestedWith = request.getHeader("X-Requested-With");
        String acceptHeader = request.getHeader("Accept");
        return "XMLHttpRequest".equalsIgnoreCase(requestedWith) ||
                (acceptHeader != null && acceptHeader.contains("application/json"));
    }

    private String escapeJson(String input) {
        if (input == null) return "";
        return input.replace("\\", "\\\\")
                    .replace("\"", "\\\"")
                    .replace("\b", "\\b")
                    .replace("\f", "\\f")
                    .replace("\n", "\\n")
                    .replace("\r", "\\r")
                    .replace("\t", "\\t");
    }
}

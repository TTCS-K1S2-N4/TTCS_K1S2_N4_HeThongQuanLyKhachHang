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
import java.util.List;

@WebServlet("/organization/teams")
public class TeamListServlet extends HttpServlet {

    private OrganizationService organizationService = new OrganizationService();

    public void setOrganizationService(OrganizationService organizationService) {
        if (organizationService != null) {
            this.organizationService = organizationService;
        }
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
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

        List<Team> teams = organizationService.getAllTeams();

        if (isAjaxRequest(req)) {
            resp.setContentType("application/json;charset=UTF-8");
            PrintWriter out = resp.getWriter();
            StringBuilder json = new StringBuilder();
            json.append("{");
            json.append("\"success\": true,");
            json.append("\"teams\":[");
            for (int i = 0; i < teams.size(); i++) {
                Team t = teams.get(i);
                if (i > 0) json.append(",");
                json.append("{");
                json.append("\"teamId\":").append(t.getId()).append(",");
                json.append("\"teamName\":\"").append(escapeJson(t.getName())).append("\",");
                json.append("\"description\":\"").append(escapeJson(t.getDescription())).append("\",");
                if (t.getParentTeamId() != null) {
                    json.append("\"parentTeamId\":").append(t.getParentTeamId()).append(",");
                } else {
                    json.append("\"parentTeamId\":null,");
                }
                json.append("\"parentTeamName\":\"").append(escapeJson(t.getParentTeamName())).append("\",");
                if (t.getLeaderId() != null) {
                    json.append("\"leaderId\":").append(t.getLeaderId()).append(",");
                } else {
                    json.append("\"leaderId\":null,");
                }
                json.append("\"leaderName\":\"").append(escapeJson(t.getLeaderName())).append("\",");
                json.append("\"region\":\"").append(escapeJson(t.getRegion())).append("\",");
                json.append("\"createdAt\":").append(t.getCreatedAt() != null ? "\"" + t.getCreatedAt().toString() + "\"" : "null").append(",");
                json.append("\"updatedAt\":").append(t.getUpdatedAt() != null ? "\"" + t.getUpdatedAt().toString() + "\"" : "null");
                json.append("}");
            }
            json.append("]}");
            out.print(json.toString());
            out.flush();
        } else {
            req.setAttribute("teams", teams);
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

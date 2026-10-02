package com.crm.controller.pipeline;

import com.crm.exception.ValidationException;
import com.crm.model.Competitor;
import com.crm.service.CompetitorService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;

@WebServlet("/pipeline/competitors")
public class CompetitorServlet extends HttpServlet {

    private final CompetitorService competitorService = new CompetitorService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setContentType("application/json;charset=UTF-8");
        PrintWriter out = resp.getWriter();

        try {
            List<Competitor> competitors = competitorService.getAllCompetitors();
            
            StringBuilder json = new StringBuilder("[");
            for (int i = 0; i < competitors.size(); i++) {
                Competitor c = competitors.get(i);
                json.append("{")
                    .append("\"competitorId\":").append(c.getCompetitorId()).append(",")
                    .append("\"competitorName\":\"").append(escapeJson(c.getCompetitorName())).append("\",")
                    .append("\"status\":\"").append(escapeJson(c.getStatus())).append("\"")
                    .append("}");
                if (i < competitors.size() - 1) {
                    json.append(",");
                }
            }
            json.append("]");

            out.print("{\"competitors\":" + json.toString() + "}");
        } catch (Exception e) {
            resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.print("{\"errors\":\"Internal server error\"}");
        }
        out.flush();
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setContentType("application/json;charset=UTF-8");
        PrintWriter out = resp.getWriter();
        
        String action = req.getParameter("action");
        if (action == null || action.trim().isEmpty()) {
            out.print("{\"errors\":\"Missing action\"}");
            out.flush();
            return;
        }

        try {
            switch (action.toUpperCase()) {
                case "CREATE": {
                    String competitorName = req.getParameter("competitorName");
                    String status = req.getParameter("status");
                    competitorService.createCompetitor(competitorName, status);
                    out.print("{\"success\":true}");
                    break;
                }
                case "UPDATE": {
                    int competitorId = parseInt(req.getParameter("competitorId"), -1);
                    String competitorName = req.getParameter("competitorName");
                    String status = req.getParameter("status");
                    competitorService.updateCompetitor(competitorId, competitorName, status);
                    out.print("{\"success\":true}");
                    break;
                }
                default:
                    out.print("{\"errors\":\"Invalid action\"}");
            }
        } catch (ValidationException e) {
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.print("{\"errors\":\"" + escapeJson(e.getMessage()) + "\"}");
        } catch (Exception e) {
            resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.print("{\"errors\":\"Internal server error\"}");
        }
        out.flush();
    }

    private int parseInt(String str, int def) {
        if (str == null || str.trim().isEmpty()) return def;
        try {
            return Integer.parseInt(str.trim());
        } catch (NumberFormatException e) {
            return def;
        }
    }

    private String escapeJson(String input) {
        if (input == null) return "";
        return input.replace("\"", "\\\"").replace("\n", "\\n").replace("\r", "");
    }
}

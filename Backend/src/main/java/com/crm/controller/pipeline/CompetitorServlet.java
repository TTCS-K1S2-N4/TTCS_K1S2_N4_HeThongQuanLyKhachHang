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
        boolean isAjax = isAjaxRequest(req) || "json".equalsIgnoreCase(req.getParameter("format"));
        List<Competitor> competitors = competitorService.getAllCompetitors();

        if (isAjax) {
            resp.setContentType("application/json;charset=UTF-8");
            PrintWriter out = resp.getWriter();
            try {
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
        } else {
            req.setAttribute("competitors", competitors);
            req.getRequestDispatcher("/WEB-INF/views/pipeline/competitors.jsp").forward(req, resp);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String action = req.getParameter("action");
        boolean isAjax = isAjaxRequest(req);

        if (action == null || action.trim().isEmpty()) {
            if (isAjax) {
                resp.setContentType("application/json;charset=UTF-8");
                resp.getWriter().print("{\"errors\":\"Missing action\"}");
            } else {
                resp.sendRedirect(req.getContextPath() + "/pipeline/competitors");
            }
            return;
        }

        try {
            switch (action.toUpperCase()) {
                case "CREATE": {
                    String competitorName = req.getParameter("competitorName");
                    String status = req.getParameter("status");
                    competitorService.createCompetitor(competitorName, status);
                    break;
                }
                case "UPDATE": {
                    int competitorId = parseInt(req.getParameter("competitorId"), -1);
                    String competitorName = req.getParameter("competitorName");
                    String status = req.getParameter("status");
                    competitorService.updateCompetitor(competitorId, competitorName, status);
                    break;
                }
                default:
                    if (isAjax) {
                        resp.setContentType("application/json;charset=UTF-8");
                        resp.getWriter().print("{\"errors\":\"Invalid action\"}");
                        return;
                    }
            }

            if (isAjax) {
                resp.setContentType("application/json;charset=UTF-8");
                resp.getWriter().print("{\"success\":true}");
            } else {
                resp.sendRedirect(req.getContextPath() + "/pipeline/competitors");
            }
        } catch (ValidationException e) {
            if (isAjax) {
                resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                resp.setContentType("application/json;charset=UTF-8");
                resp.getWriter().print("{\"errors\":\"" + escapeJson(e.getMessage()) + "\"}");
            } else {
                req.setAttribute("errorMessage", e.getMessage());
                doGet(req, resp);
            }
        } catch (Exception e) {
            if (isAjax) {
                resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                resp.setContentType("application/json;charset=UTF-8");
                resp.getWriter().print("{\"errors\":\"Internal server error\"}");
            } else {
                req.setAttribute("errorMessage", "Internal server error");
                doGet(req, resp);
            }
        }
    }

    private boolean isAjaxRequest(HttpServletRequest request) {
        String requestedWith = request.getHeader("X-Requested-With");
        String acceptHeader = request.getHeader("Accept");
        return "XMLHttpRequest".equalsIgnoreCase(requestedWith) ||
                (acceptHeader != null && acceptHeader.contains("application/json"));
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

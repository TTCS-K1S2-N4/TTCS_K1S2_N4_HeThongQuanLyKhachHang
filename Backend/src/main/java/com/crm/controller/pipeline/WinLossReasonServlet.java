package com.crm.controller.pipeline;

import com.crm.exception.ValidationException;
import com.crm.model.WinLossReason;
import com.crm.service.WinLossService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;

@WebServlet("/pipeline/win-loss-reasons")
public class WinLossReasonServlet extends HttpServlet {

    private final WinLossService winLossService = new WinLossService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setContentType("application/json;charset=UTF-8");
        String reasonType = req.getParameter("reasonType");
        PrintWriter out = resp.getWriter();

        try {
            List<WinLossReason> reasons = winLossService.getReasons(reasonType);
            
            StringBuilder json = new StringBuilder("[");
            for (int i = 0; i < reasons.size(); i++) {
                WinLossReason r = reasons.get(i);
                json.append("{")
                    .append("\"reasonId\":").append(r.getReasonId()).append(",")
                    .append("\"reasonType\":\"").append(escapeJson(r.getReasonType())).append("\",")
                    .append("\"reasonName\":\"").append(escapeJson(r.getReasonName())).append("\",")
                    .append("\"displayOrder\":").append(r.getDisplayOrder()).append(",")
                    .append("\"status\":\"").append(escapeJson(r.getStatus())).append("\"")
                    .append("}");
                if (i < reasons.size() - 1) {
                    json.append(",");
                }
            }
            json.append("]");

            out.print("{\"winLossReasons\":" + json.toString() + "}");
        } catch (ValidationException e) {
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.print("{\"errors\":\"" + escapeJson(e.getMessage()) + "\"}");
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
                    String reasonType = req.getParameter("reasonType");
                    String reasonName = req.getParameter("reasonName");
                    int displayOrder = parseInt(req.getParameter("displayOrder"), 0);
                    String status = req.getParameter("status");
                    winLossService.createReason(reasonType, reasonName, displayOrder, status);
                    out.print("{\"success\":true}");
                    break;
                }
                case "UPDATE": {
                    int reasonId = parseInt(req.getParameter("reasonId"), -1);
                    String reasonType = req.getParameter("reasonType");
                    String reasonName = req.getParameter("reasonName");
                    int displayOrder = parseInt(req.getParameter("displayOrder"), 0);
                    String status = req.getParameter("status");
                    winLossService.updateReason(reasonId, reasonType, reasonName, displayOrder, status);
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

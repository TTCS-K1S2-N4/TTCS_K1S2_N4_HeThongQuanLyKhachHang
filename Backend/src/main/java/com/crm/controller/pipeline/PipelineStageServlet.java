package com.crm.controller.pipeline;

import com.crm.exception.ValidationException;
import com.crm.model.PipelineStage;
import com.crm.service.PipelineService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;

@WebServlet("/pipeline/stages")
public class PipelineStageServlet extends HttpServlet {

    private final PipelineService pipelineService = new PipelineService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        List<PipelineStage> stages = pipelineService.getAllStages();
        
        if (isAjaxRequest(req) || "json".equalsIgnoreCase(req.getParameter("format"))) {
            resp.setContentType("application/json;charset=UTF-8");
            StringBuilder json = new StringBuilder("[");
            for (int i = 0; i < stages.size(); i++) {
                PipelineStage s = stages.get(i);
                json.append("{")
                    .append("\"pipelineStageId\":").append(s.getPipelineStageId()).append(",")
                    .append("\"stageName\":\"").append(escapeJson(s.getStageName())).append("\",")
                    .append("\"displayOrder\":").append(s.getDisplayOrder()).append(",")
                    .append("\"defaultProbability\":").append(s.getDefaultProbability()).append(",")
                    .append("\"exitCondition\":").append(s.getExitCondition() != null ? "\"" + escapeJson(s.getExitCondition()) + "\"" : "null").append(",")
                    .append("\"status\":\"").append(escapeJson(s.getStatus())).append("\"")
                    .append("}");
                if (i < stages.size() - 1) {
                    json.append(",");
                }
            }
            json.append("]");

            PrintWriter out = resp.getWriter();
            out.print("{\"pipelineStages\":" + json.toString() + "}");
            out.flush();
        } else {
            req.setAttribute("pipelineStages", stages);
            req.getRequestDispatcher("/WEB-INF/views/pipeline/stages.jsp").forward(req, resp);
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
                resp.sendRedirect(req.getContextPath() + "/pipeline/stages");
            }
            return;
        }

        try {
            switch (action.toUpperCase()) {
                case "CREATE": {
                    String stageName = req.getParameter("stageName");
                    int displayOrder = parseInt(req.getParameter("displayOrder"), 0);
                    double defaultProbability = parseDouble(req.getParameter("defaultProbability"), 0.0);
                    String exitCondition = req.getParameter("exitCondition");
                    String status = req.getParameter("status");
                    pipelineService.createStage(stageName, displayOrder, defaultProbability, exitCondition, status);
                    break;
                }
                case "UPDATE": {
                    int pipelineStageId = parseInt(req.getParameter("pipelineStageId"), -1);
                    String stageName = req.getParameter("stageName");
                    int displayOrder = parseInt(req.getParameter("displayOrder"), 0);
                    double defaultProbability = parseDouble(req.getParameter("defaultProbability"), 0.0);
                    String exitCondition = req.getParameter("exitCondition");
                    String status = req.getParameter("status");
                    pipelineService.updateStage(pipelineStageId, stageName, displayOrder, defaultProbability, exitCondition, status);
                    break;
                }
                case "REORDER": {
                    int pipelineStageId = parseInt(req.getParameter("pipelineStageId"), -1);
                    int displayOrder = parseInt(req.getParameter("displayOrder"), 0);
                    pipelineService.updateOrder(pipelineStageId, displayOrder);
                    break;
                }
                case "DEACTIVATE": {
                    int pipelineStageId = parseInt(req.getParameter("pipelineStageId"), -1);
                    pipelineService.deactivateStage(pipelineStageId);
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
                resp.sendRedirect(req.getContextPath() + "/pipeline/stages");
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
                req.setAttribute("errorMessage", "Có lỗi xảy ra trên hệ thống.");
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

    private double parseDouble(String str, double def) {
        if (str == null || str.trim().isEmpty()) return def;
        try {
            return Double.parseDouble(str.trim());
        } catch (NumberFormatException e) {
            return def;
        }
    }

    private String escapeJson(String input) {
        if (input == null) return "";
        return input.replace("\"", "\\\"").replace("\n", "\\n").replace("\r", "");
    }
}

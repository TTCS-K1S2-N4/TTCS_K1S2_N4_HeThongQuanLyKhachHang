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
        String reasonType = req.getParameter("reasonType");
        boolean isAjax = isAjaxRequest(req) || "json".equalsIgnoreCase(req.getParameter("format"));

        try {
            if (isAjax) {
                resp.setContentType("application/json;charset=UTF-8");
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

                PrintWriter out = resp.getWriter();
                out.print("{\"winLossReasons\":" + json.toString() + "}");
                out.flush();
            } else {
                List<WinLossReason> winReasons = winLossService.getReasons("WIN");
                List<WinLossReason> lossReasons = winLossService.getReasons("LOSS");
                req.setAttribute("winReasons", winReasons);
                req.setAttribute("lossReasons", lossReasons);
                req.setAttribute("reasonType", reasonType);
                req.getRequestDispatcher("/WEB-INF/views/pipeline/win_loss.jsp").forward(req, resp);
            }
        } catch (ValidationException e) {
            if (isAjax) {
                resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                resp.setContentType("application/json;charset=UTF-8");
                resp.getWriter().print("{\"errors\":\"" + escapeJson(e.getMessage()) + "\"}");
            } else {
                req.setAttribute("errorMessage", e.getMessage());
                req.getRequestDispatcher("/WEB-INF/views/pipeline/win_loss.jsp").forward(req, resp);
            }
        } catch (Exception e) {
            if (isAjax) {
                resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                resp.setContentType("application/json;charset=UTF-8");
                resp.getWriter().print("{\"errors\":\"Internal server error\"}");
            } else {
                req.setAttribute("errorMessage", "Có lỗi hệ thống xảy ra.");
                req.getRequestDispatcher("/WEB-INF/views/pipeline/win_loss.jsp").forward(req, resp);
            }
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
                resp.sendRedirect(req.getContextPath() + "/pipeline/win-loss-reasons");
            }
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
                    break;
                }
                case "UPDATE": {
                    int reasonId = parseInt(req.getParameter("reasonId"), -1);
                    String reasonType = req.getParameter("reasonType");
                    String reasonName = req.getParameter("reasonName");
                    int displayOrder = parseInt(req.getParameter("displayOrder"), 0);
                    String status = req.getParameter("status");
                    winLossService.updateReason(reasonId, reasonType, reasonName, displayOrder, status);
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
                resp.sendRedirect(req.getContextPath() + "/pipeline/win-loss-reasons");
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

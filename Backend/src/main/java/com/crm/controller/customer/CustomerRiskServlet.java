package com.crm.controller.customer;

import com.crm.exception.AuthorizationException;
import com.crm.exception.ValidationException;
import com.crm.model.CustomerRisk;
import com.crm.service.CustomerRiskService;
import com.crm.util.ValidationUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.Collections;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * Controller trả về thông tin Rủi ro rời bỏ khách hàng (Churn Risk).
 * Cung cấp riskFlag, riskReason, số lượng vé pending cho Customer 360° / Sales Rep.
 * Endpoint: GET /customers/{customerId}/risk
 * Task S30-09 / S3-08.
 */
@WebServlet(urlPatterns = {"/customers/risk", "/customers/risk/*", "/risk"})
public class CustomerRiskServlet extends HttpServlet {

    private static final Pattern CUSTOMER_URI_PATTERN = Pattern.compile(".*/customers/(\\d+)/risk.*");

    private CustomerRiskService customerRiskService = new CustomerRiskService();

    public void setCustomerRiskService(CustomerRiskService service) {
        if (service != null) {
            this.customerRiskService = service;
        }
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        Integer userId = (session != null) ? (Integer) session.getAttribute("userId") : null;
        List<Integer> roleIds = (session != null) ? ValidationUtil.getSafeIntegerList(session.getAttribute("roleIds")) : null;
        Integer roleId = (session != null) ? (Integer) session.getAttribute("roleId") : null;

        if (userId == null) {
            handleUnauthorized(req, resp, "Bạn cần đăng nhập để thực hiện chức năng này.");
            return;
        }

        List<Integer> effectiveRoles = (roleIds != null && !roleIds.isEmpty())
                ? roleIds
                : (roleId != null ? Collections.singletonList(roleId) : Collections.emptyList());

        Integer customerId = extractCustomerId(req);
        if (customerId == null || customerId <= 0) {
            sendErrorResponse(req, resp, HttpServletResponse.SC_BAD_REQUEST, "ID khách hàng không hợp lệ.");
            return;
        }

        int threshold = CustomerRiskService.DEFAULT_CHURN_THRESHOLD;
        String threshStr = req.getParameter("threshold");
        if (threshStr != null && !threshStr.trim().isEmpty()) {
            try { threshold = Integer.parseInt(threshStr.trim()); } catch (NumberFormatException ignored) {}
        }

        try {
            CustomerRisk risk = customerRiskService.getCustomerRisk(customerId, threshold, userId, effectiveRoles);

            if (isJsonRequest(req)) {
                resp.setContentType("application/json;charset=UTF-8");
                PrintWriter out = resp.getWriter();
                out.print("{" +
                        "\"customerId\": " + risk.getCustomerId() + "," +
                        "\"riskFlag\": " + risk.isRiskFlag() + "," +
                        "\"riskReason\": \"" + escapeJson(risk.getRiskReason()) + "\"," +
                        "\"pendingTicketCount\": " + risk.getPendingTicketCount() + "," +
                        "\"threshold\": " + risk.getThreshold() +
                        "}");
                out.flush();
            } else {
                req.setAttribute("customerRisk", risk);
                req.setAttribute("customerId", customerId);
                req.getRequestDispatcher("/WEB-INF/views/customers/risks.jsp").forward(req, resp);
            }
        } catch (ValidationException e) {
            sendErrorResponse(req, resp, HttpServletResponse.SC_NOT_FOUND, e.getMessage());
        } catch (AuthorizationException e) {
            sendErrorResponse(req, resp, HttpServletResponse.SC_FORBIDDEN, e.getMessage());
        } catch (Exception e) {
            sendErrorResponse(req, resp, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Lỗi máy chủ nội bộ: " + e.getMessage());
        }
    }

    private Integer extractCustomerId(HttpServletRequest req) {
        String param = req.getParameter("customerId");
        if (param == null || param.trim().isEmpty()) {
            param = req.getParameter("id");
        }
        if (param != null && !param.trim().isEmpty()) {
            try { return Integer.parseInt(param.trim()); } catch (NumberFormatException ignored) {}
        }

        String pathInfo = req.getPathInfo();
        if (pathInfo != null && pathInfo.length() > 1) {
            String clean = pathInfo.replaceFirst("^/", "");
            int slash = clean.indexOf('/');
            String idStr = slash != -1 ? clean.substring(0, slash) : clean;
            try { return Integer.parseInt(idStr); } catch (NumberFormatException ignored) {}
        }

        String uri = req.getRequestURI();
        if (uri != null) {
            Matcher m = CUSTOMER_URI_PATTERN.matcher(uri);
            if (m.matches()) {
                try { return Integer.parseInt(m.group(1)); } catch (NumberFormatException ignored) {}
            }
        }
        return null;
    }

    private boolean isJsonRequest(HttpServletRequest req) {
        String accept = req.getHeader("Accept");
        String requestedWith = req.getHeader("X-Requested-With");
        return "XMLHttpRequest".equalsIgnoreCase(requestedWith) || (accept != null && accept.contains("application/json"));
    }

    private void handleUnauthorized(HttpServletRequest req, HttpServletResponse resp, String message) throws IOException {
        if (isJsonRequest(req)) {
            resp.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            resp.setContentType("application/json;charset=UTF-8");
            PrintWriter out = resp.getWriter();
            out.print("{\"status\": 401, \"message\": \"" + escapeJson(message) + "\"}");
            out.flush();
        } else {
            resp.sendRedirect(req.getContextPath() + "/auth/login");
        }
    }

    private void sendErrorResponse(HttpServletRequest req, HttpServletResponse resp, int statusCode, String message)
            throws ServletException, IOException {
        if (isJsonRequest(req)) {
            resp.setStatus(statusCode);
            resp.setContentType("application/json;charset=UTF-8");
            PrintWriter out = resp.getWriter();
            out.print("{\"status\": " + statusCode + ", \"message\": \"" + escapeJson(message) + "\"}");
            out.flush();
        } else {
            if (statusCode == HttpServletResponse.SC_FORBIDDEN) {
                req.setAttribute("errorMessage", message);
                req.getRequestDispatcher("/WEB-INF/views/errors/403.jsp").forward(req, resp);
            } else if (statusCode == HttpServletResponse.SC_NOT_FOUND) {
                req.setAttribute("errorMessage", message);
                req.getRequestDispatcher("/WEB-INF/views/errors/404.jsp").forward(req, resp);
            } else {
                resp.sendError(statusCode, message);
            }
        }
    }

    private String escapeJson(String input) {
        if (input == null) return "";
        return input.replace("\\", "\\\\")
                    .replace("\"", "\\\"")
                    .replace("\n", "\\n")
                    .replace("\r", "\\r");
    }
}

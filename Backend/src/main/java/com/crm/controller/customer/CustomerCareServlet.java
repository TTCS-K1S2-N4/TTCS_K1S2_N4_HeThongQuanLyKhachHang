package com.crm.controller.customer;

import com.crm.dto.CustomerCareResponse;
import com.crm.exception.AuthorizationException;
import com.crm.exception.ValidationException;
import com.crm.model.CustomerCareState;
import com.crm.service.CustomerCareService;
import com.crm.util.ValidationUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.PrintWriter;
import java.text.SimpleDateFormat;
import java.util.Collections;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * Controller chăm sóc khách hàng định kỳ N ngày.
 * Endpoints:
 * - GET /customers/care?inactiveDays={N}&page={page}
 * - POST /customers/{customerId}/care/mark-contacted hoặc /customers/care/mark-contacted
 * - GET /customers/care/config
 * - POST /customers/care/config
 * Task S30-10 / S3-09.
 */
@WebServlet(urlPatterns = {"/customers/care", "/customers/care/*", "/care"})
public class CustomerCareServlet extends HttpServlet {

    private static final Pattern MARK_CONTACTED_PATTERN = Pattern.compile(".*/customers/(\\d+)/care/mark-contacted.*");

    private CustomerCareService customerCareService = new CustomerCareService();

    public void setCustomerCareService(CustomerCareService service) {
        if (service != null) {
            this.customerCareService = service;
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

        String pathInfo = req.getPathInfo();
        String action = req.getParameter("action");

        // 1. GET /customers/care/config
        if ((pathInfo != null && pathInfo.contains("config")) || "config".equalsIgnoreCase(action)) {
            int currentDays = customerCareService.getConfiguredInactiveDays();
            if (isJsonRequest(req)) {
                resp.setContentType("application/json;charset=UTF-8");
                PrintWriter out = resp.getWriter();
                out.print("{\"success\": true, \"inactiveThresholdDays\": " + currentDays + "}");
                out.flush();
            } else {
                req.setAttribute("inactiveThresholdDays", currentDays);
                req.getRequestDispatcher("/WEB-INF/views/customers/care-list.jsp").forward(req, resp);
            }
            return;
        }

        // 2. GET /customers/care?inactiveDays={N}&page={page}
        int inactiveDays = 0;
        String inDaysStr = req.getParameter("inactiveDays");
        if (inDaysStr != null && !inDaysStr.trim().isEmpty()) {
            try { inactiveDays = Integer.parseInt(inDaysStr.trim()); } catch (NumberFormatException ignored) {}
        }
        if (inactiveDays <= 0) {
            inactiveDays = customerCareService.getConfiguredInactiveDays();
        }

        int page = 1;
        String pageStr = req.getParameter("page");
        if (pageStr != null && !pageStr.trim().isEmpty()) {
            try { page = Integer.parseInt(pageStr.trim()); } catch (NumberFormatException ignored) {}
        }

        int pageSize = 20;
        String pageSizeStr = req.getParameter("pageSize");
        if (pageSizeStr != null && !pageSizeStr.trim().isEmpty()) {
            try { pageSize = Integer.parseInt(pageSizeStr.trim()); } catch (NumberFormatException ignored) {}
        }

        try {
            List<CustomerCareResponse> list = customerCareService.getInactiveCustomers(inactiveDays, page, pageSize, userId, effectiveRoles);
            int total = customerCareService.countInactiveCustomers(inactiveDays, userId, effectiveRoles);
            int totalPages = (int) Math.ceil((double) total / pageSize);

            if (isJsonRequest(req)) {
                resp.setContentType("application/json;charset=UTF-8");
                PrintWriter out = resp.getWriter();
                StringBuilder json = new StringBuilder("{");
                json.append("\"currentPage\":").append(page).append(",");
                json.append("\"pageSize\":").append(pageSize).append(",");
                json.append("\"total\":").append(total).append(",");
                json.append("\"totalPages\":").append(totalPages).append(",");
                json.append("\"inactiveDays\":").append(inactiveDays).append(",");
                json.append("\"items\":[");
                SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
                for (int i = 0; i < list.size(); i++) {
                    if (i > 0) json.append(",");
                    CustomerCareResponse c = list.get(i);
                    json.append("{")
                        .append("\"customerId\":").append(c.getCustomerId()).append(",")
                        .append("\"customerName\":\"").append(escapeJson(c.getCustomerName())).append("\",")
                        .append("\"phone\":").append(c.getPhone() != null ? "\"" + escapeJson(c.getPhone()) + "\"" : "null").append(",")
                        .append("\"ownerId\":").append(c.getOwnerId()).append(",")
                        .append("\"ownerName\":").append(c.getOwnerName() != null ? "\"" + escapeJson(c.getOwnerName()) + "\"" : "null").append(",")
                        .append("\"lastContactedAt\":").append(c.getLastContactedAt() != null ? "\"" + sdf.format(c.getLastContactedAt()) + "\"" : "null").append(",")
                        .append("\"daysInactive\":").append(c.getDaysInactive()).append(",")
                        .append("\"contractValue\":").append(c.getContractValue() != null ? c.getContractValue() : 0.0).append(",")
                        .append("\"careStatus\":\"").append(escapeJson(c.getCareStatus())).append("\"")
                        .append("}");
                }
                json.append("]}");
                out.print(json.toString());
                out.flush();
            } else {
                req.setAttribute("careList", list);
                req.setAttribute("currentPage", page);
                req.setAttribute("totalPages", totalPages);
                req.setAttribute("inactiveDays", inactiveDays);
                req.getRequestDispatcher("/WEB-INF/views/customers/care-list.jsp").forward(req, resp);
            }
        } catch (Exception e) {
            sendErrorResponse(req, resp, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Lỗi máy chủ nội bộ: " + e.getMessage());
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
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

        String pathInfo = req.getPathInfo();
        String action = req.getParameter("action");

        // 1. POST /customers/care/config
        if ((pathInfo != null && pathInfo.contains("config")) || "config".equalsIgnoreCase(action)) {
            Integer days = null;
            if (req.getContentType() != null && req.getContentType().contains("application/json")) {
                String body = readRequestBody(req);
                days = extractJsonInt(body, "inactiveDays");
                if (days == null) days = extractJsonInt(body, "inactiveThresholdDays");
            } else {
                String dStr = req.getParameter("inactiveDays");
                if (dStr == null || dStr.trim().isEmpty()) {
                    dStr = req.getParameter("inactiveThresholdDays");
                }
                if (dStr != null && !dStr.trim().isEmpty()) {
                    try { days = Integer.parseInt(dStr.trim()); } catch (NumberFormatException ignored) {}
                }
            }

            if (days == null || days <= 0) {
                sendErrorResponse(req, resp, HttpServletResponse.SC_BAD_REQUEST, "Số ngày cấu hình không hợp lệ (> 0).");
                return;
            }

            try {
                boolean updated = customerCareService.updateConfiguredInactiveDays(days, userId, effectiveRoles);
                if (isJsonRequest(req)) {
                    resp.setContentType("application/json;charset=UTF-8");
                    PrintWriter out = resp.getWriter();
                    out.print("{\"success\": " + updated + ", \"message\": \"Cập nhật cấu hình ngày định kỳ thành công.\", \"inactiveThresholdDays\": " + days + "}");
                    out.flush();
                } else {
                    resp.sendRedirect(req.getContextPath() + "/customers/care?success=config");
                }
            } catch (ValidationException e) {
                sendErrorResponse(req, resp, HttpServletResponse.SC_BAD_REQUEST, e.getMessage());
            } catch (Exception e) {
                sendErrorResponse(req, resp, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Lỗi máy chủ nội bộ: " + e.getMessage());
            }
            return;
        }

        // 2. POST /customers/{customerId}/care/mark-contacted
        Integer customerId = extractCustomerIdForMarkContacted(req);
        String note = null;

        if (req.getContentType() != null && req.getContentType().contains("application/json")) {
            String body = readRequestBody(req);
            if (customerId == null) {
                customerId = extractJsonInt(body, "customerId");
            }
            note = extractJsonString(body, "note");
        } else {
            if (customerId == null) {
                String cIdStr = req.getParameter("customerId");
                if (cIdStr != null && !cIdStr.trim().isEmpty()) {
                    try { customerId = Integer.parseInt(cIdStr.trim()); } catch (NumberFormatException ignored) {}
                }
            }
            note = req.getParameter("note");
        }

        if (customerId == null || customerId <= 0) {
            sendErrorResponse(req, resp, HttpServletResponse.SC_BAD_REQUEST, "ID khách hàng không hợp lệ.");
            return;
        }

        try {
            CustomerCareState state = customerCareService.markContacted(customerId, note, userId, effectiveRoles);

            if (isJsonRequest(req)) {
                resp.setContentType("application/json;charset=UTF-8");
                PrintWriter out = resp.getWriter();
                SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
                out.print("{" +
                        "\"success\": true," +
                        "\"message\": \"Ghi nhận chăm sóc khách hàng thành công.\"," +
                        "\"careId\": " + (state != null ? state.getCareId() : 0) + "," +
                        "\"customerId\": " + customerId + "," +
                        "\"lastContactedAt\": " + (state != null && state.getLastContactedAt() != null ? "\"" + sdf.format(state.getLastContactedAt()) + "\"" : "null") + "," +
                        "\"note\": " + (note != null ? "\"" + escapeJson(note) + "\"" : "\"\"") +
                        "}");
                out.flush();
            } else {
                resp.sendRedirect(req.getContextPath() + "/customers/detail?id=" + customerId + "&success=contacted");
            }
        } catch (ValidationException e) {
            sendErrorResponse(req, resp, HttpServletResponse.SC_BAD_REQUEST, e.getMessage());
        } catch (AuthorizationException e) {
            sendErrorResponse(req, resp, HttpServletResponse.SC_FORBIDDEN, e.getMessage());
        } catch (Exception e) {
            sendErrorResponse(req, resp, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Lỗi máy chủ nội bộ: " + e.getMessage());
        }
    }

    private Integer extractCustomerIdForMarkContacted(HttpServletRequest req) {
        String uri = req.getRequestURI();
        if (uri != null) {
            Matcher m = MARK_CONTACTED_PATTERN.matcher(uri);
            if (m.matches()) {
                try { return Integer.parseInt(m.group(1)); } catch (NumberFormatException ignored) {}
            }
        }

        String pathInfo = req.getPathInfo();
        if (pathInfo != null) {
            Pattern p = Pattern.compile("/(\\d+)/mark-contacted");
            Matcher m = p.matcher(pathInfo);
            if (m.find()) {
                try { return Integer.parseInt(m.group(1)); } catch (NumberFormatException ignored) {}
            }
        }

        String param = req.getParameter("customerId");
        if (param == null || param.trim().isEmpty()) {
            param = req.getParameter("id");
        }
        if (param != null && !param.trim().isEmpty()) {
            try { return Integer.parseInt(param.trim()); } catch (NumberFormatException ignored) {}
        }
        return null;
    }

    private String readRequestBody(HttpServletRequest req) throws IOException {
        StringBuilder sb = new StringBuilder();
        try (BufferedReader reader = req.getReader()) {
            String line;
            while ((line = reader.readLine()) != null) {
                sb.append(line);
            }
        }
        return sb.toString();
    }

    private Integer extractJsonInt(String json, String key) {
        Pattern p = Pattern.compile("\"" + key + "\"\\s*:\\s*(\\d+)");
        Matcher m = p.matcher(json);
        if (m.find()) {
            return Integer.parseInt(m.group(1));
        }
        return null;
    }

    private String extractJsonString(String json, String key) {
        Pattern p = Pattern.compile("\"" + key + "\"\\s*:\\s*\"([^\"]*)\"");
        Matcher m = p.matcher(json);
        if (m.find()) {
            return m.group(1);
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

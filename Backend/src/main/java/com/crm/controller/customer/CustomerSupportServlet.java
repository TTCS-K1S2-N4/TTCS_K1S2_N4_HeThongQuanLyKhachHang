package com.crm.controller.customer;

import com.crm.dto.SupportRequestDto;
import com.crm.exception.AuthorizationException;
import com.crm.exception.ValidationException;
import com.crm.service.CustomerSupportService;
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
import java.util.Collections;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * Controller xử lý Yêu cầu hỗ trợ sau bán (Support Request).
 * Endpoints: GET /customers/{customerId}/support, POST /customers/{customerId}/support
 * Task S30-09 / S3-08.
 */
@WebServlet(urlPatterns = {"/customers/support", "/customers/support/*", "/support"})
public class CustomerSupportServlet extends HttpServlet {

    private static final Pattern CUSTOMER_URI_PATTERN = Pattern.compile(".*/customers/(\\d+)/support.*");

    private CustomerSupportService customerSupportService = new CustomerSupportService();

    public void setCustomerSupportService(CustomerSupportService service) {
        if (service != null) {
            this.customerSupportService = service;
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

        try {
            List<SupportRequestDto> list = customerSupportService.getSupportRequestsByCustomer(customerId, userId, effectiveRoles);

            if (isJsonRequest(req)) {
                resp.setContentType("application/json;charset=UTF-8");
                PrintWriter out = resp.getWriter();
                StringBuilder json = new StringBuilder("[");
                for (int i = 0; i < list.size(); i++) {
                    if (i > 0) json.append(",");
                    SupportRequestDto s = list.get(i);
                    json.append("{")
                        .append("\"requestId\":").append(s.getRequestId()).append(",")
                        .append("\"customerId\":").append(s.getCustomerId()).append(",")
                        .append("\"title\":\"").append(escapeJson(s.getTitle())).append("\",")
                        .append("\"description\":").append(s.getDescription() != null ? "\"" + escapeJson(s.getDescription()) + "\"" : "null").append(",")
                        .append("\"priority\":\"").append(escapeJson(s.getPriority())).append("\",")
                        .append("\"status\":\"").append(escapeJson(s.getStatus())).append("\",")
                        .append("\"assigneeId\":").append(s.getAssigneeId() != null ? s.getAssigneeId() : "null").append(",")
                        .append("\"assigneeName\":").append(s.getAssigneeName() != null ? "\"" + escapeJson(s.getAssigneeName()) + "\"" : "null")
                        .append("}");
                }
                json.append("]");
                out.print(json.toString());
                out.flush();
            } else {
                req.setAttribute("supportRequests", list);
                req.setAttribute("customerId", customerId);
                req.setAttribute("customer", new com.crm.dao.CustomerDAO().findById(customerId));
                req.setAttribute("owners", new com.crm.dao.AccountDAO().getAllActiveAccounts());
                req.getRequestDispatcher("/WEB-INF/views/customers/support.jsp").forward(req, resp);
            }
        } catch (ValidationException e) {
            sendErrorResponse(req, resp, HttpServletResponse.SC_NOT_FOUND, e.getMessage());
        } catch (AuthorizationException e) {
            sendErrorResponse(req, resp, HttpServletResponse.SC_FORBIDDEN, e.getMessage());
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

        SupportRequestDto dto = parseSupportRequest(req);
        if (dto.getCustomerId() == null || dto.getCustomerId() <= 0) {
            Integer extracted = extractCustomerId(req);
            if (extracted != null) {
                dto.setCustomerId(extracted);
            }
        }

        try {
            SupportRequestDto created = customerSupportService.createSupportRequest(dto, userId, effectiveRoles);

            if (isJsonRequest(req)) {
                resp.setStatus(HttpServletResponse.SC_CREATED);
                resp.setContentType("application/json;charset=UTF-8");
                PrintWriter out = resp.getWriter();
                out.print("{" +
                        "\"success\": true," +
                        "\"message\": \"Tạo yêu cầu hỗ trợ thành công.\"," +
                        "\"requestId\": " + created.getRequestId() + "," +
                        "\"customerId\": " + created.getCustomerId() + "," +
                        "\"title\": \"" + escapeJson(created.getTitle()) + "\"," +
                        "\"description\": " + (created.getDescription() != null ? "\"" + escapeJson(created.getDescription()) + "\"" : "null") + "," +
                        "\"priority\": \"" + escapeJson(created.getPriority()) + "\"," +
                        "\"status\": \"" + escapeJson(created.getStatus()) + "\"," +
                        "\"assigneeId\": " + (created.getAssigneeId() != null ? created.getAssigneeId() : "null") +
                        "}");
                out.flush();
            } else {
                resp.sendRedirect(req.getContextPath() + "/customers/support?customerId=" + created.getCustomerId());
            }
        } catch (ValidationException e) {
            sendErrorResponse(req, resp, HttpServletResponse.SC_BAD_REQUEST, e.getMessage());
        } catch (AuthorizationException e) {
            sendErrorResponse(req, resp, HttpServletResponse.SC_FORBIDDEN, e.getMessage());
        } catch (Exception e) {
            sendErrorResponse(req, resp, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Lỗi máy chủ nội bộ: " + e.getMessage());
        }
    }

    private SupportRequestDto parseSupportRequest(HttpServletRequest req) throws IOException {
        SupportRequestDto dto = new SupportRequestDto();

        if (req.getContentType() != null && req.getContentType().contains("application/json")) {
            StringBuilder sb = new StringBuilder();
            try (BufferedReader reader = req.getReader()) {
                String line;
                while ((line = reader.readLine()) != null) {
                    sb.append(line);
                }
            }
            String body = sb.toString();
            dto.setCustomerId(extractJsonInt(body, "customerId"));
            dto.setTitle(extractJsonString(body, "title"));
            dto.setDescription(extractJsonString(body, "description"));
            dto.setPriority(extractJsonString(body, "priority"));
            dto.setStatus(extractJsonString(body, "status"));
            dto.setAssigneeId(extractJsonInt(body, "assigneeId"));
        } else {
            String cId = req.getParameter("customerId");
            if (cId != null && !cId.trim().isEmpty()) {
                try { dto.setCustomerId(Integer.parseInt(cId.trim())); } catch (NumberFormatException ignored) {}
            }
            dto.setTitle(req.getParameter("title"));
            dto.setDescription(req.getParameter("description"));
            dto.setPriority(req.getParameter("priority"));
            dto.setStatus(req.getParameter("status"));
            String assIdStr = req.getParameter("assigneeId");
            if (assIdStr != null && !assIdStr.trim().isEmpty()) {
                try { dto.setAssigneeId(Integer.parseInt(assIdStr.trim())); } catch (NumberFormatException ignored) {}
            }
        }

        return dto;
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

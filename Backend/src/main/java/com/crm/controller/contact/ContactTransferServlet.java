package com.crm.controller.contact;

import com.crm.dto.ContactTransferRequest;
import com.crm.exception.AuthorizationException;
import com.crm.exception.ValidationException;
import com.crm.service.ContactService;
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
 * Controller chuyển đổi công ty cho Người liên hệ (Transfer Contact).
 * Thực thi bảo toàn dữ liệu và ghi vết lịch sử trong Transaction.
 * Endpoint: POST /contacts/transfer
 * Task S30-03 / S3-02.
 */
@WebServlet(urlPatterns = {"/contacts/transfer", "/contacts/transfer/*"})
public class ContactTransferServlet extends HttpServlet {

    private ContactService contactService = new ContactService();

    public void setContactService(ContactService contactService) {
        if (contactService != null) {
            this.contactService = contactService;
        }
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        Integer userId = (session != null) ? (Integer) session.getAttribute("userId") : null;
        if (userId == null) {
            handleUnauthorized(req, resp, "Bạn cần đăng nhập để thực hiện chức năng này.");
            return;
        }

        String contactIdStr = req.getParameter("contactId");
        if (contactIdStr == null || contactIdStr.trim().isEmpty()) {
            contactIdStr = req.getParameter("id");
        }
        req.setAttribute("contactId", contactIdStr);
        req.getRequestDispatcher("/WEB-INF/views/contacts/transfer.jsp").forward(req, resp);
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

        ContactTransferRequest transferRequest = parseTransferRequest(req);

        try {
            boolean success = contactService.transferContact(transferRequest, userId, effectiveRoles);

            if (isJsonRequest(req)) {
                resp.setContentType("application/json;charset=UTF-8");
                PrintWriter out = resp.getWriter();
                out.print("{" +
                        "\"success\": " + success + "," +
                        "\"message\": \"Chuyển người liên hệ sang khách hàng mới thành công.\"," +
                        "\"contactId\": " + transferRequest.getContactId() + "," +
                        "\"newCustomerId\": " + transferRequest.getNewCustomerId() +
                        "}");
                out.flush();
            } else {
                resp.sendRedirect(req.getContextPath() + "/contacts/detail?id=" + transferRequest.getContactId() + "&success=transferred");
            }
        } catch (ValidationException e) {
            sendErrorResponse(req, resp, HttpServletResponse.SC_BAD_REQUEST, e.getMessage());
        } catch (AuthorizationException e) {
            sendErrorResponse(req, resp, HttpServletResponse.SC_FORBIDDEN, e.getMessage());
        } catch (Exception e) {
            sendErrorResponse(req, resp, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Lỗi máy chủ nội bộ: " + e.getMessage());
        }
    }

    private ContactTransferRequest parseTransferRequest(HttpServletRequest req) throws IOException {
        ContactTransferRequest dto = new ContactTransferRequest();

        if (req.getContentType() != null && req.getContentType().contains("application/json")) {
            StringBuilder sb = new StringBuilder();
            try (BufferedReader reader = req.getReader()) {
                String line;
                while ((line = reader.readLine()) != null) {
                    sb.append(line);
                }
            }
            String body = sb.toString();
            dto.setContactId(extractJsonInt(body, "contactId"));
            dto.setNewCustomerId(extractJsonInt(body, "newCustomerId"));
            dto.setReason(extractJsonString(body, "reason"));
        } else {
            String cIdStr = req.getParameter("contactId");
            if (cIdStr != null && !cIdStr.trim().isEmpty()) {
                try { dto.setContactId(Integer.parseInt(cIdStr.trim())); } catch (NumberFormatException ignored) {}
            }

            String newCIdStr = req.getParameter("newCustomerId");
            if (newCIdStr != null && !newCIdStr.trim().isEmpty()) {
                try { dto.setNewCustomerId(Integer.parseInt(newCIdStr.trim())); } catch (NumberFormatException ignored) {}
            }

            dto.setReason(req.getParameter("reason"));
        }

        return dto;
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

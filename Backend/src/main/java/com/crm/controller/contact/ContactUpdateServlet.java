package com.crm.controller.contact;

import com.crm.dto.ContactRequest;
import com.crm.dto.ContactResponse;
import com.crm.exception.AuthorizationException;
import com.crm.exception.ValidationException;
import com.crm.model.Contact;
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
 * Controller chỉnh sửa Người liên hệ (Contact).
 * Endpoints: GET /contacts/edit?id={id}, POST /contacts/edit
 * Task S30-03 / S3-02.
 */
@WebServlet("/contacts/edit")
public class ContactUpdateServlet extends HttpServlet {

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
        List<Integer> roleIds = (session != null) ? ValidationUtil.getSafeIntegerList(session.getAttribute("roleIds")) : null;
        Integer roleId = (session != null) ? (Integer) session.getAttribute("roleId") : null;

        if (userId == null) {
            handleUnauthorized(req, resp, "Bạn cần đăng nhập để thực hiện chức năng này.");
            return;
        }

        List<Integer> effectiveRoles = (roleIds != null && !roleIds.isEmpty())
                ? roleIds
                : (roleId != null ? Collections.singletonList(roleId) : Collections.emptyList());

        String idStr = req.getParameter("id");
        if (idStr == null || idStr.trim().isEmpty()) {
            idStr = req.getParameter("contactId");
        }

        int contactId;
        try {
            contactId = Integer.parseInt(idStr.trim());
        } catch (Exception e) {
            sendErrorResponse(req, resp, HttpServletResponse.SC_BAD_REQUEST, "ID người liên hệ không hợp lệ.");
            return;
        }

        try {
            ContactResponse contact = contactService.getContactById(contactId, userId, effectiveRoles);
            req.setAttribute("contact", contact);
            req.setAttribute("buyingRoles", ContactService.BUYING_ROLES);
            req.getRequestDispatcher("/WEB-INF/views/contacts/edit.jsp").forward(req, resp);
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

        ContactRequest requestDto = parseContactRequest(req);

        try {
            Contact updated = contactService.updateContact(requestDto, userId, effectiveRoles);

            if (isJsonRequest(req)) {
                resp.setContentType("application/json;charset=UTF-8");
                PrintWriter out = resp.getWriter();
                out.print("{" +
                        "\"success\": true," +
                        "\"message\": \"Cập nhật người liên hệ thành công.\"," +
                        "\"contactId\": " + updated.getContactId() + "," +
                        "\"customerId\": " + updated.getCustomerId() + "," +
                        "\"fullName\": \"" + escapeJson(updated.getFullName()) + "\"," +
                        "\"title\": " + (updated.getTitle() != null ? "\"" + escapeJson(updated.getTitle()) + "\"" : "null") + "," +
                        "\"email\": " + (updated.getEmail() != null ? "\"" + escapeJson(updated.getEmail()) + "\"" : "null") + "," +
                        "\"phone\": " + (updated.getPhone() != null ? "\"" + escapeJson(updated.getPhone()) + "\"" : "null") + "," +
                        "\"buyingRole\": \"" + escapeJson(updated.getBuyingRole()) + "\"," +
                        "\"isPrimary\": " + updated.isPrimary() +
                        "}");
                out.flush();
            } else {
                resp.sendRedirect(req.getContextPath() + "/contacts/detail?id=" + updated.getContactId());
            }
        } catch (ValidationException e) {
            sendErrorResponse(req, resp, HttpServletResponse.SC_BAD_REQUEST, e.getMessage());
        } catch (AuthorizationException e) {
            sendErrorResponse(req, resp, HttpServletResponse.SC_FORBIDDEN, e.getMessage());
        } catch (Exception e) {
            sendErrorResponse(req, resp, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Lỗi máy chủ nội bộ: " + e.getMessage());
        }
    }

    private ContactRequest parseContactRequest(HttpServletRequest req) throws IOException {
        ContactRequest dto = new ContactRequest();

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
            if (dto.getContactId() == null) {
                dto.setContactId(extractJsonInt(body, "id"));
            }
            dto.setCustomerId(extractJsonInt(body, "customerId"));
            dto.setFullName(extractJsonString(body, "fullName"));
            dto.setTitle(extractJsonString(body, "title"));
            dto.setEmail(extractJsonString(body, "email"));
            dto.setPhone(extractJsonString(body, "phone"));
            dto.setBuyingRole(extractJsonString(body, "buyingRole"));
            dto.setIsPrimary(extractJsonBoolean(body, "isPrimary"));
        } else {
            String cId = req.getParameter("id");
            if (cId == null || cId.trim().isEmpty()) {
                cId = req.getParameter("contactId");
            }
            if (cId != null && !cId.trim().isEmpty()) {
                try { dto.setContactId(Integer.parseInt(cId.trim())); } catch (NumberFormatException ignored) {}
            }

            String custId = req.getParameter("customerId");
            if (custId != null && !custId.trim().isEmpty()) {
                try { dto.setCustomerId(Integer.parseInt(custId.trim())); } catch (NumberFormatException ignored) {}
            }

            dto.setFullName(req.getParameter("fullName"));
            dto.setTitle(req.getParameter("title"));
            dto.setEmail(req.getParameter("email"));
            dto.setPhone(req.getParameter("phone"));
            dto.setBuyingRole(req.getParameter("buyingRole"));
            String primaryStr = req.getParameter("isPrimary");
            dto.setIsPrimary("true".equalsIgnoreCase(primaryStr) || "1".equals(primaryStr) || "on".equalsIgnoreCase(primaryStr));
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

    private Boolean extractJsonBoolean(String json, String key) {
        Pattern p = Pattern.compile("\"" + key + "\"\\s*:\\s*(true|false)", Pattern.CASE_INSENSITIVE);
        Matcher m = p.matcher(json);
        if (m.find()) {
            return Boolean.parseBoolean(m.group(1));
        }
        return false;
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

package com.crm.controller.contact;

import com.crm.dto.ContactResponse;
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

import java.io.IOException;
import java.io.PrintWriter;
import java.util.Collections;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * Controller trả về danh sách Người liên hệ thuộc Customer.
 * Endpoint: GET /customers/{customerId}/contacts hoặc /contacts?customerId={id}
 * Task S30-03 / S3-02.
 */
@WebServlet(urlPatterns = {"/contacts", "/contacts/list", "/customers/contacts", "/customers/contacts/*"})
public class ContactListServlet extends HttpServlet {

    private static final Pattern CUSTOMER_URI_PATTERN = Pattern.compile(".*/customers/(\\d+)/contacts.*");

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

        Integer customerId = extractCustomerId(req);
        if (customerId == null || customerId <= 0) {
            sendErrorResponse(req, resp, HttpServletResponse.SC_BAD_REQUEST, "ID khách hàng không hợp lệ.");
            return;
        }

        try {
            List<ContactResponse> contacts = contactService.getContactsByCustomerId(customerId, userId, effectiveRoles);

            if (isJsonRequest(req)) {
                resp.setContentType("application/json;charset=UTF-8");
                PrintWriter out = resp.getWriter();
                StringBuilder json = new StringBuilder("[");
                for (int i = 0; i < contacts.size(); i++) {
                    if (i > 0) json.append(",");
                    ContactResponse c = contacts.get(i);
                    json.append("{")
                        .append("\"contactId\":").append(c.getContactId()).append(",")
                        .append("\"customerId\":").append(c.getCustomerId()).append(",")
                        .append("\"fullName\":\"").append(escapeJson(c.getFullName())).append("\",")
                        .append("\"title\":").append(c.getTitle() != null ? "\"" + escapeJson(c.getTitle()) + "\"" : "null").append(",")
                        .append("\"email\":").append(c.getEmail() != null ? "\"" + escapeJson(c.getEmail()) + "\"" : "null").append(",")
                        .append("\"phone\":").append(c.getPhone() != null ? "\"" + escapeJson(c.getPhone()) + "\"" : "null").append(",")
                        .append("\"buyingRole\":\"").append(escapeJson(c.getBuyingRole())).append("\",")
                        .append("\"isPrimary\":").append(c.isPrimary())
                        .append("}");
                }
                json.append("]");
                out.print(json.toString());
                out.flush();
            } else {
                req.setAttribute("contacts", contacts);
                req.setAttribute("customerId", customerId);
                req.getRequestDispatcher("/WEB-INF/views/contacts/list.jsp").forward(req, resp);
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

package com.crm.controller.contact;

import com.crm.exception.AuthorizationException;
import com.crm.exception.ValidationException;
import com.crm.service.ContactService;
import com.crm.service.PermissionService;
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
import java.util.logging.Level;
import java.util.logging.Logger;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * Controller xử lý xóa an toàn Người liên hệ (Contact).
 * Endpoint: POST /contacts/delete
 * Task S30-03 / S3-02.
 */
@WebServlet("/contacts/delete")
public class ContactDeleteServlet extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(ContactDeleteServlet.class.getName());

    private ContactService contactService = new ContactService();
    private PermissionService permissionService = new PermissionService();

    public void setContactService(ContactService contactService) {
        if (contactService != null) {
            this.contactService = contactService;
        }
    }

    public void setPermissionService(PermissionService permissionService) {
        if (permissionService != null) {
            this.permissionService = permissionService;
        }
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        sendErrorResponse(req, resp, HttpServletResponse.SC_METHOD_NOT_ALLOWED, "Phương thức GET không được hỗ trợ. Vui lòng sử dụng POST.");
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

        // Kiểm tra quyền ACCOUNT_DELETE phía server theo danh sách vai trò
        if (!permissionService.hasPermissionForRoles(effectiveRoles, "ACCOUNT_DELETE")) {
            sendErrorResponse(req, resp, HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền xóa người liên hệ (yêu cầu quyền ACCOUNT_DELETE).");
            return;
        }

        Integer contactId = null;
        Integer customerId = null;

        if (req.getContentType() != null && req.getContentType().contains("application/json")) {
            StringBuilder sb = new StringBuilder();
            try (BufferedReader reader = req.getReader()) {
                String line;
                while ((line = reader.readLine()) != null) {
                    sb.append(line);
                }
            }
            String body = sb.toString();
            contactId = extractJsonInt(body, "contactId");
            if (contactId == null) {
                contactId = extractJsonInt(body, "id");
            }
            customerId = extractJsonInt(body, "customerId");
        } else {
            String contactIdStr = req.getParameter("contactId");
            if (contactIdStr == null || contactIdStr.trim().isEmpty()) {
                contactIdStr = req.getParameter("id");
            }
            if (contactIdStr != null && !contactIdStr.trim().isEmpty()) {
                try {
                    contactId = Integer.parseInt(contactIdStr.trim());
                } catch (NumberFormatException ignored) {}
            }

            String customerIdStr = req.getParameter("customerId");
            if (customerIdStr != null && !customerIdStr.trim().isEmpty()) {
                try {
                    customerId = Integer.parseInt(customerIdStr.trim());
                } catch (NumberFormatException ignored) {}
            }
        }

        if (contactId == null || contactId <= 0) {
            sendErrorResponse(req, resp, HttpServletResponse.SC_BAD_REQUEST, "ID người liên hệ không hợp lệ.");
            return;
        }

        try {
            boolean deleted = contactService.deleteContact(contactId, userId, effectiveRoles);
            if (!deleted) {
                throw new ValidationException("Không thể xóa người liên hệ từ cơ sở dữ liệu.");
            }

            if (isJsonRequest(req)) {
                resp.setContentType("application/json;charset=UTF-8");
                PrintWriter out = resp.getWriter();
                out.print("{\"success\": true, \"message\": \"Đã xóa người liên hệ thành công.\", \"contactId\": " + contactId + "}");
                out.flush();
            } else {
                session.setAttribute("message", "Đã xóa người liên hệ thành công.");
                if (customerId != null && customerId > 0) {
                    resp.sendRedirect(req.getContextPath() + "/contacts?customerId=" + customerId);
                } else {
                    resp.sendRedirect(req.getContextPath() + "/customers");
                }
            }
        } catch (ValidationException e) {
            if (isJsonRequest(req)) {
                sendErrorResponse(req, resp, HttpServletResponse.SC_BAD_REQUEST, e.getMessage());
            } else {
                session.setAttribute("errorMessage", e.getMessage());
                if (customerId != null && customerId > 0) {
                    resp.sendRedirect(req.getContextPath() + "/contacts?customerId=" + customerId);
                } else {
                    resp.sendRedirect(req.getContextPath() + "/customers");
                }
            }
        } catch (AuthorizationException e) {
            sendErrorResponse(req, resp, HttpServletResponse.SC_FORBIDDEN, e.getMessage());
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Lỗi nội bộ khi xóa Contact: " + contactId, e);
            sendErrorResponse(req, resp, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Lỗi máy chủ nội bộ khi thực hiện xóa người liên hệ.");
        }
    }

    private Integer extractJsonInt(String json, String key) {
        Pattern p = Pattern.compile("\"" + key + "\"\\s*:\\s*(\\d+)");
        Matcher m = p.matcher(json);
        if (m.find()) {
            return Integer.parseInt(m.group(1));
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

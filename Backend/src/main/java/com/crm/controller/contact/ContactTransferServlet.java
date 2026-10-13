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
    private com.crm.dao.CustomerDAO customerDAO = new com.crm.dao.CustomerDAO();
    private com.crm.service.PermissionService permissionService = new com.crm.service.PermissionService();

    public void setContactService(ContactService contactService) {
        if (contactService != null) {
            this.contactService = contactService;
        }
    }

    public void setCustomerDAO(com.crm.dao.CustomerDAO customerDAO) {
        if (customerDAO != null) {
            this.customerDAO = customerDAO;
        }
    }

    public void setPermissionService(com.crm.service.PermissionService permissionService) {
        if (permissionService != null) {
            this.permissionService = permissionService;
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

        String contactIdStr = req.getParameter("contactId");
        if (contactIdStr == null || contactIdStr.trim().isEmpty()) {
            contactIdStr = req.getParameter("id");
        }

        if (contactIdStr == null || contactIdStr.trim().isEmpty()) {
            req.setAttribute("errorMessage", "Chưa chỉ định người liên hệ cần chuyển.");
            req.getRequestDispatcher("/WEB-INF/views/contacts/transfer.jsp").forward(req, resp);
            return;
        }

        int contactId;
        try {
            contactId = Integer.parseInt(contactIdStr.trim());
        } catch (NumberFormatException e) {
            sendErrorResponse(req, resp, HttpServletResponse.SC_BAD_REQUEST, "ID người liên hệ không hợp lệ.");
            return;
        }

        try {
            com.crm.dto.ContactResponse contact = contactService.getContactById(contactId, userId, effectiveRoles);
            com.crm.model.Customer currentCustomer = customerDAO.findById(contact.getCustomerId());

            List<Integer> accessibleOwnerIds = permissionService.getAccessibleAccountIdsForRoles(userId, effectiveRoles, "ACCOUNT");
            List<com.crm.model.Customer> customers = customerDAO.getList(null, accessibleOwnerIds, 1, 1000);

            req.setAttribute("contact", contact);
            req.setAttribute("contactId", contact.getContactId());
            req.setAttribute("currentCustomer", currentCustomer);
            req.setAttribute("customers", customers);
            req.getRequestDispatcher("/WEB-INF/views/contacts/transfer.jsp").forward(req, resp);
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
            if (isJsonRequest(req)) {
                sendErrorResponse(req, resp, HttpServletResponse.SC_BAD_REQUEST, e.getMessage());
            } else {
                // Giữ lại lý do và thông tin form khi có lỗi validation
                try {
                    if (transferRequest.getContactId() != null && transferRequest.getContactId() > 0) {
                        com.crm.dto.ContactResponse contact = contactService.getContactById(transferRequest.getContactId(), userId, effectiveRoles);
                        com.crm.model.Customer currentCustomer = customerDAO.findById(contact.getCustomerId());
                        List<Integer> accessibleOwnerIds = permissionService.getAccessibleAccountIdsForRoles(userId, effectiveRoles, "ACCOUNT");
                        List<com.crm.model.Customer> customers = customerDAO.getList(null, accessibleOwnerIds, 1, 1000);

                        req.setAttribute("contact", contact);
                        req.setAttribute("contactId", contact.getContactId());
                        req.setAttribute("currentCustomer", currentCustomer);
                        req.setAttribute("customers", customers);
                    }
                } catch (Exception ignored) {}
                req.setAttribute("errorMessage", e.getMessage());
                req.getRequestDispatcher("/WEB-INF/views/contacts/transfer.jsp").forward(req, resp);
            }
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

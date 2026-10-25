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

/**
 * Controller xem chi tiết Người liên hệ (Contact).
 * Endpoint: GET /contacts/detail?id={id}
 * Task S30-03 / S3-02.
 */
@WebServlet("/contacts/detail")
public class ContactDetailServlet extends HttpServlet {

    private ContactService contactService = new ContactService();
    private com.crm.dao.CustomerDAO customerDAO = new com.crm.dao.CustomerDAO();

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
            List<com.crm.model.ContactCompanyHistory> historyList = contactService.getTransferHistory(contactId, userId, effectiveRoles);
            com.crm.model.Customer customer = customerDAO.findById(contact.getCustomerId());

            if (isJsonRequest(req)) {
                resp.setContentType("application/json;charset=UTF-8");
                PrintWriter out = resp.getWriter();
                out.print("{" +
                        "\"contactId\": " + contact.getContactId() + "," +
                        "\"customerId\": " + contact.getCustomerId() + "," +
                        "\"fullName\": \"" + escapeJson(contact.getFullName()) + "\"," +
                        "\"title\": " + (contact.getTitle() != null ? "\"" + escapeJson(contact.getTitle()) + "\"" : "null") + "," +
                        "\"email\": " + (contact.getEmail() != null ? "\"" + escapeJson(contact.getEmail()) + "\"" : "null") + "," +
                        "\"phone\": " + (contact.getPhone() != null ? "\"" + escapeJson(contact.getPhone()) + "\"" : "null") + "," +
                        "\"buyingRole\": \"" + escapeJson(contact.getBuyingRole()) + "\"," +
                        "\"isPrimary\": " + contact.isPrimary() + "," +
                        "\"history\": " + serializeHistoryList(historyList) +
                        "}");
                out.flush();
            } else {
                req.setAttribute("contact", contact);
                req.setAttribute("customer", customer);
                req.setAttribute("history", historyList);
                req.getRequestDispatcher("/WEB-INF/views/contacts/detail.jsp").forward(req, resp);
            }
        } catch (ValidationException e) {
            sendErrorResponse(req, resp, HttpServletResponse.SC_NOT_FOUND, e.getMessage());
        } catch (AuthorizationException e) {
            sendErrorResponse(req, resp, HttpServletResponse.SC_FORBIDDEN, e.getMessage());
        } catch (Exception e) {
            sendErrorResponse(req, resp, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Lỗi máy chủ nội bộ: " + e.getMessage());
        }
    }

    private String serializeHistoryList(List<com.crm.model.ContactCompanyHistory> historyList) {
        if (historyList == null || historyList.isEmpty()) {
            return "[]";
        }
        StringBuilder sb = new StringBuilder("[");
        for (int i = 0; i < historyList.size(); i++) {
            com.crm.model.ContactCompanyHistory h = historyList.get(i);
            if (i > 0) sb.append(",");
            sb.append("{")
              .append("\"historyId\": ").append(h.getHistoryId()).append(",")
              .append("\"contactId\": ").append(h.getContactId()).append(",")
              .append("\"fromCustomerId\": ").append(h.getFromCustomerId()).append(",")
              .append("\"fromCustomerName\": ").append(h.getFromCustomerName() != null ? "\"" + escapeJson(h.getFromCustomerName()) + "\"" : "null").append(",")
              .append("\"toCustomerId\": ").append(h.getToCustomerId()).append(",")
              .append("\"toCustomerName\": ").append(h.getToCustomerName() != null ? "\"" + escapeJson(h.getToCustomerName()) + "\"" : "null").append(",")
              .append("\"transferredAt\": ").append(h.getTransferredAt() != null ? "\"" + escapeJson(h.getTransferredAt().toString()) + "\"" : "null").append(",")
              .append("\"reason\": ").append(h.getReason() != null ? "\"" + escapeJson(h.getReason()) + "\"" : "null").append(",")
              .append("\"transferredBy\": ").append(h.getTransferredBy() != null ? h.getTransferredBy() : "null").append(",")
              .append("\"transferredByName\": ").append(h.getTransferredByName() != null ? "\"" + escapeJson(h.getTransferredByName()) + "\"" : "null")
              .append("}");
        }
        sb.append("]");
        return sb.toString();
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

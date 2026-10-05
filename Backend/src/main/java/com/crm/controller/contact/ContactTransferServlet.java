package com.crm.controller.contact;

import com.crm.dao.CustomerDAO;
import com.crm.dto.ContactTransferRequest;
import com.crm.exception.AuthorizationException;
import com.crm.model.Contact;
import com.crm.model.Customer;
import com.crm.service.ContactService;
import com.crm.service.PermissionService;
import com.crm.util.ValidationUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet(urlPatterns = {"/contacts/transfer", "/contacts/transfer-company"})
public class ContactTransferServlet extends HttpServlet {
    private final ContactService contactService = new ContactService();
    private final CustomerDAO customerDAO = new CustomerDAO();
    private final PermissionService permissionService = new PermissionService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        Integer userId = session != null ? (Integer) session.getAttribute("userId") : null;
        Integer roleId = session != null ? (Integer) session.getAttribute("roleId") : null;
        List<Integer> roleIds = ValidationUtil.getSafeIntegerList(req.getAttribute("effectiveRoleIds"));
        if (roleIds == null || roleIds.isEmpty()) {
            roleIds = session != null ? ValidationUtil.getSafeIntegerList(session.getAttribute("roleIds")) : null;
        }

        if (userId == null) {
            resp.sendRedirect(req.getContextPath() + "/auth/login");
            return;
        }

        String idStr = req.getParameter("id");
        if (idStr == null || idStr.trim().isEmpty()) {
            idStr = req.getParameter("contactId");
        }

        if (idStr == null || idStr.trim().isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/customers");
            return;
        }

        try {
            int contactId = Integer.parseInt(idStr.trim());
            Contact contact = contactService.getContactById(contactId, userId, roleId != null ? roleId : 0, roleIds);
            Customer currentCustomer = customerDAO.findById(contact.getCustomerId());

            List<Integer> ownerIds = permissionService.getAccessibleAccountIdsForRoles(
                    userId,
                    (roleIds != null && !roleIds.isEmpty()) ? roleIds : java.util.Collections.singletonList(roleId != null ? roleId : 0),
                    "ACCOUNT"
            );
            List<Customer> accessibleCustomers = customerDAO.getListForExport(null, ownerIds);

            req.setAttribute("contact", contact);
            req.setAttribute("currentCustomer", currentCustomer);
            req.setAttribute("customers", accessibleCustomers);

            req.getRequestDispatcher("/WEB-INF/views/contacts/transfer.jsp").forward(req, resp);
        } catch (NumberFormatException e) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Mã người liên hệ không hợp lệ.");
        } catch (IllegalArgumentException e) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND, e.getMessage());
        } catch (AuthorizationException e) {
            req.setAttribute("errorMessage", e.getMessage());
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, e.getMessage());
        } catch (Exception e) {
            throw new ServletException("Lỗi khi mở giao diện chuyển công ty cho người liên hệ.", e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        HttpSession session = req.getSession(false);
        Integer userId = session != null ? (Integer) session.getAttribute("userId") : null;
        Integer roleId = session != null ? (Integer) session.getAttribute("roleId") : null;
        List<Integer> roleIds = ValidationUtil.getSafeIntegerList(req.getAttribute("effectiveRoleIds"));
        if (roleIds == null || roleIds.isEmpty()) {
            roleIds = session != null ? ValidationUtil.getSafeIntegerList(session.getAttribute("roleIds")) : null;
        }

        if (userId == null) {
            resp.sendRedirect(req.getContextPath() + "/auth/login");
            return;
        }

        String contactIdStr = req.getParameter("contactId");
        if (contactIdStr == null || contactIdStr.trim().isEmpty()) {
            contactIdStr = req.getParameter("id");
        }

        String newCustomerIdStr = req.getParameter("newCustomerId");

        ContactTransferRequest transferRequest = new ContactTransferRequest();
        try {
            if (contactIdStr != null && !contactIdStr.trim().isEmpty()) {
                transferRequest.setContactId(Integer.parseInt(contactIdStr.trim()));
            }
            if (newCustomerIdStr != null && !newCustomerIdStr.trim().isEmpty()) {
                transferRequest.setNewCustomerId(Integer.parseInt(newCustomerIdStr.trim()));
            }
        } catch (NumberFormatException ignored) {}

        transferRequest.setTransferredBy(userId);

        Map<String, String> errors = new HashMap<>();

        try {
            boolean success = contactService.transferContact(transferRequest, userId, roleId != null ? roleId : 0, roleIds, errors);

            if (success) {
                req.getSession().setAttribute("message", "Chuyển người liên hệ sang công ty mới thành công.");
                resp.sendRedirect(req.getContextPath() + "/contacts/detail?id=" + transferRequest.getContactId());
            } else {
                req.setAttribute("errors", errors);
                if (transferRequest.getContactId() != null) {
                    Contact contact = contactService.getContactById(transferRequest.getContactId(), userId, roleId != null ? roleId : 0, roleIds);
                    req.setAttribute("contact", contact);
                    req.setAttribute("currentCustomer", customerDAO.findById(contact.getCustomerId()));
                }

                List<Integer> ownerIds = permissionService.getAccessibleAccountIdsForRoles(
                        userId,
                        (roleIds != null && !roleIds.isEmpty()) ? roleIds : java.util.Collections.singletonList(roleId != null ? roleId : 0),
                        "ACCOUNT"
                );
                List<Customer> accessibleCustomers = customerDAO.getListForExport(null, ownerIds);
                req.setAttribute("customers", accessibleCustomers);

                req.getRequestDispatcher("/WEB-INF/views/contacts/transfer.jsp").forward(req, resp);
            }
        } catch (AuthorizationException e) {
            req.setAttribute("errorMessage", e.getMessage());
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, e.getMessage());
        } catch (Exception e) {
            throw new ServletException("Lỗi khi xử lý chuyển công ty cho người liên hệ.", e);
        }
    }
}

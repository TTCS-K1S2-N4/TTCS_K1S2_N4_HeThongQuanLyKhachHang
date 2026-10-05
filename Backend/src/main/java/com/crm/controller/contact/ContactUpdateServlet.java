package com.crm.controller.contact;

import com.crm.dao.CustomerDAO;
import com.crm.dto.ContactRequest;
import com.crm.exception.AuthorizationException;
import com.crm.model.Contact;
import com.crm.model.Customer;
import com.crm.service.ContactService;
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

@WebServlet(urlPatterns = {"/contacts/edit", "/contacts/update"})
public class ContactUpdateServlet extends HttpServlet {
    private final ContactService contactService = new ContactService();
    private final CustomerDAO customerDAO = new CustomerDAO();

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
            Customer customer = customerDAO.findById(contact.getCustomerId());

            req.setAttribute("contact", contact);
            req.setAttribute("customer", customer);

            req.getRequestDispatcher("/WEB-INF/views/contacts/edit.jsp").forward(req, resp);
        } catch (NumberFormatException e) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Mã người liên hệ không hợp lệ.");
        } catch (IllegalArgumentException e) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND, e.getMessage());
        } catch (AuthorizationException e) {
            req.setAttribute("errorMessage", e.getMessage());
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, e.getMessage());
        } catch (Exception e) {
            throw new ServletException("Lỗi khi mở trang cập nhật người liên hệ.", e);
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

        String fullName = req.getParameter("fullName");
        String title = req.getParameter("title");
        String email = req.getParameter("email");
        String phone = req.getParameter("phone");
        String buyingRole = req.getParameter("buyingRole");
        String isPrimaryStr = req.getParameter("isPrimary");

        ContactRequest requestDTO = new ContactRequest();
        try {
            if (contactIdStr != null && !contactIdStr.trim().isEmpty()) {
                requestDTO.setContactId(Integer.parseInt(contactIdStr.trim()));
            }
        } catch (NumberFormatException ignored) {}

        requestDTO.setFullName(fullName);
        requestDTO.setTitle(title);
        requestDTO.setEmail(email);
        requestDTO.setPhone(phone);
        requestDTO.setBuyingRole(buyingRole);
        requestDTO.setPrimary("true".equalsIgnoreCase(isPrimaryStr) || "1".equals(isPrimaryStr) || "on".equalsIgnoreCase(isPrimaryStr));

        Map<String, String> errors = new HashMap<>();

        try {
            boolean success = contactService.updateContact(requestDTO, userId, roleId != null ? roleId : 0, roleIds, errors);

            if (success) {
                req.getSession().setAttribute("message", "Cập nhật người liên hệ thành công.");
                Contact updated = contactService.getContactById(requestDTO.getContactId(), userId, roleId != null ? roleId : 0, roleIds);
                resp.sendRedirect(req.getContextPath() + "/contacts?customerId=" + updated.getCustomerId());
            } else {
                req.setAttribute("errors", errors);
                req.setAttribute("contact", requestDTO);
                if (requestDTO.getContactId() != null) {
                    Contact orig = contactService.getContactById(requestDTO.getContactId(), userId, roleId != null ? roleId : 0, roleIds);
                    if (orig != null) {
                        req.setAttribute("customer", customerDAO.findById(orig.getCustomerId()));
                    }
                }
                req.getRequestDispatcher("/WEB-INF/views/contacts/edit.jsp").forward(req, resp);
            }
        } catch (AuthorizationException e) {
            req.setAttribute("errorMessage", e.getMessage());
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, e.getMessage());
        } catch (Exception e) {
            throw new ServletException("Lỗi khi xử lý cập nhật người liên hệ.", e);
        }
    }
}

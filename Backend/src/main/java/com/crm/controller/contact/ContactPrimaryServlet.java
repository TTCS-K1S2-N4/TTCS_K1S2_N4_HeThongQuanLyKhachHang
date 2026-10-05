package com.crm.controller.contact;

import com.crm.exception.AuthorizationException;
import com.crm.model.Contact;
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

@WebServlet("/contacts/primary")
public class ContactPrimaryServlet extends HttpServlet {
    private final ContactService contactService = new ContactService();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
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

        if (contactIdStr == null || contactIdStr.trim().isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/customers");
            return;
        }

        try {
            int contactId = Integer.parseInt(contactIdStr.trim());
            Contact contact = contactService.getContactById(contactId, userId, roleId != null ? roleId : 0, roleIds);

            Map<String, String> errors = new HashMap<>();
            boolean success = contactService.setPrimaryContact(contactId, userId, roleId != null ? roleId : 0, roleIds, errors);

            if (success) {
                req.getSession().setAttribute("message", "Đã đánh dấu người liên hệ làm đầu mối chính.");
            } else {
                req.getSession().setAttribute("errorMessage", errors.getOrDefault("system", "Không thể thiết lập đầu mối chính."));
            }

            resp.sendRedirect(req.getContextPath() + "/contacts?customerId=" + contact.getCustomerId());
        } catch (NumberFormatException e) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Mã người liên hệ không hợp lệ.");
        } catch (IllegalArgumentException e) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND, e.getMessage());
        } catch (AuthorizationException e) {
            req.setAttribute("errorMessage", e.getMessage());
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, e.getMessage());
        } catch (Exception e) {
            throw new ServletException("Lỗi khi đánh dấu đầu mối chính.", e);
        }
    }
}

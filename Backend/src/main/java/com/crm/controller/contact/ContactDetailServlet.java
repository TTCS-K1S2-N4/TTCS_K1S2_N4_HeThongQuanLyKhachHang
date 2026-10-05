package com.crm.controller.contact;

import com.crm.dao.CustomerDAO;
import com.crm.exception.AuthorizationException;
import com.crm.model.Contact;
import com.crm.model.ContactCompanyHistory;
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
import java.util.List;

@WebServlet(urlPatterns = {"/contacts/detail", "/contacts/view"})
public class ContactDetailServlet extends HttpServlet {
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
            List<ContactCompanyHistory> history = contactService.getContactHistory(contactId, userId, roleId != null ? roleId : 0, roleIds);
            Customer customer = customerDAO.findById(contact.getCustomerId());

            req.setAttribute("contact", contact);
            req.setAttribute("history", history);
            req.setAttribute("customer", customer);

            req.getRequestDispatcher("/WEB-INF/views/contacts/detail.jsp").forward(req, resp);
        } catch (NumberFormatException e) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Mã người liên hệ không hợp lệ.");
        } catch (IllegalArgumentException e) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND, e.getMessage());
        } catch (AuthorizationException e) {
            req.setAttribute("errorMessage", e.getMessage());
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, e.getMessage());
        } catch (Exception e) {
            throw new ServletException("Lỗi khi hiển thị chi tiết người liên hệ.", e);
        }
    }
}

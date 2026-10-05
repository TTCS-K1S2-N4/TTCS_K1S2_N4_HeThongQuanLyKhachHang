package com.crm.controller.contact;

import com.crm.dao.CustomerDAO;
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
import java.util.List;

@WebServlet(urlPatterns = {"/contacts", "/contacts/list", "/customers/contacts"})
public class ContactListServlet extends HttpServlet {
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

        String customerIdStr = req.getParameter("customerId");
        if (customerIdStr == null || customerIdStr.trim().isEmpty()) {
            String idStr = req.getParameter("id");
            if (idStr != null && !idStr.trim().isEmpty()) {
                customerIdStr = idStr;
            }
        }

        if (customerIdStr == null || customerIdStr.trim().isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/customers");
            return;
        }

        try {
            int customerId = Integer.parseInt(customerIdStr.trim());
            Customer customer = customerDAO.findById(customerId);
            if (customer == null) {
                resp.sendError(HttpServletResponse.SC_NOT_FOUND, "Khách hàng không tồn tại.");
                return;
            }

            List<Contact> contacts = contactService.getContactsByCustomer(customerId, userId, roleId != null ? roleId : 0, roleIds);

            req.setAttribute("contacts", contacts);
            req.setAttribute("customer", customer);
            req.setAttribute("customerId", customerId);

            req.getRequestDispatcher("/WEB-INF/views/contacts/list.jsp").forward(req, resp);
        } catch (NumberFormatException e) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Mã khách hàng không hợp lệ.");
        } catch (AuthorizationException e) {
            req.setAttribute("errorMessage", e.getMessage());
            req.setAttribute("exception", e);
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, e.getMessage());
        } catch (Exception e) {
            throw new ServletException("Không thể tải danh sách người liên hệ.", e);
        }
    }
}

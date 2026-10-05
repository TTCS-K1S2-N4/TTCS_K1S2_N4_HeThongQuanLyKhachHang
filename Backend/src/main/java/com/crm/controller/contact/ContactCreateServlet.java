package com.crm.controller.contact;

import com.crm.dao.CustomerDAO;
import com.crm.dto.ContactRequest;
import com.crm.exception.AuthorizationException;
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

@WebServlet("/contacts/create")
public class ContactCreateServlet extends HttpServlet {
    private final ContactService contactService = new ContactService();
    private final CustomerDAO customerDAO = new CustomerDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        Integer userId = session != null ? (Integer) session.getAttribute("userId") : null;

        if (userId == null) {
            resp.sendRedirect(req.getContextPath() + "/auth/login");
            return;
        }

        String customerIdStr = req.getParameter("customerId");
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

            req.setAttribute("customer", customer);
            req.setAttribute("customerId", customerId);
            req.getRequestDispatcher("/WEB-INF/views/contacts/create.jsp").forward(req, resp);
        } catch (NumberFormatException e) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Mã khách hàng không hợp lệ.");
        } catch (Exception e) {
            throw new ServletException("Không thể mở màn hình tạo người liên hệ.", e);
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

        String customerIdStr = req.getParameter("customerId");
        String fullName = req.getParameter("fullName");
        String title = req.getParameter("title");
        String email = req.getParameter("email");
        String phone = req.getParameter("phone");
        String buyingRole = req.getParameter("buyingRole");
        String isPrimaryStr = req.getParameter("isPrimary");

        ContactRequest requestDTO = new ContactRequest();
        try {
            if (customerIdStr != null && !customerIdStr.trim().isEmpty()) {
                requestDTO.setCustomerId(Integer.parseInt(customerIdStr.trim()));
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
            boolean success = contactService.createContact(requestDTO, userId, roleId != null ? roleId : 0, roleIds, errors);

            if (success) {
                req.getSession().setAttribute("message", "Tạo mới người liên hệ thành công.");
                resp.sendRedirect(req.getContextPath() + "/contacts?customerId=" + requestDTO.getCustomerId());
            } else {
                req.setAttribute("errors", errors);
                req.setAttribute("contactRequest", requestDTO);
                req.setAttribute("customerId", requestDTO.getCustomerId());
                if (requestDTO.getCustomerId() != null) {
                    req.setAttribute("customer", customerDAO.findById(requestDTO.getCustomerId()));
                }
                req.getRequestDispatcher("/WEB-INF/views/contacts/create.jsp").forward(req, resp);
            }
        } catch (AuthorizationException e) {
            req.setAttribute("errorMessage", e.getMessage());
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, e.getMessage());
        } catch (Exception e) {
            throw new ServletException("Lỗi khi xử lý tạo người liên hệ.", e);
        }
    }
}

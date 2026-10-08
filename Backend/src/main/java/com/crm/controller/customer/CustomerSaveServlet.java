package com.crm.controller.customer;

import com.crm.dao.CustomerDAO;
import com.crm.model.Customer;
import com.crm.service.CustomFieldService;
import com.crm.service.PermissionService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet(urlPatterns = {"/customers/create", "/customers/edit", "/customers/delete", "/api/customers/save"})
public class CustomerSaveServlet extends HttpServlet {

    private final CustomerDAO customerDAO = new CustomerDAO();
    private final CustomFieldService customFieldService = new CustomFieldService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String uri = req.getRequestURI();
        Integer userId = (Integer) req.getSession().getAttribute("userId");
        if (userId == null) {
            resp.sendRedirect(req.getContextPath() + "/auth/login");
            return;
        }

        if (uri.endsWith("/edit")) {
            String idStr = req.getParameter("id");
            if (idStr == null || idStr.trim().isEmpty()) {
                idStr = req.getParameter("customerId");
            }
            if (idStr != null && !idStr.trim().isEmpty()) {
                try {
                    int id = Integer.parseInt(idStr.trim());
                    Customer customer = customerDAO.findById(id);
                    if (customer != null) {
                        req.setAttribute("customer", customer);
                        req.getRequestDispatcher("/WEB-INF/views/customers/edit.jsp").forward(req, resp);
                        return;
                    }
                } catch (NumberFormatException ignored) {}
            }
            resp.sendRedirect(req.getContextPath() + "/customers");
            return;
        }

        resp.sendError(HttpServletResponse.SC_METHOD_NOT_ALLOWED, "HTTP method GET is not supported by this URL");
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String uri = req.getRequestURI();
        Integer userId = (Integer) req.getSession().getAttribute("userId");
        if (userId == null) {
            resp.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            resp.getWriter().print("{\"error\":\"Chưa đăng nhập\"}");
            return;
        }

        if (uri.endsWith("/delete")) {
            handleDelete(req, resp);
            return;
        }

        handleSave(req, resp);
    }

    private void handleSave(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        boolean isJsonRequest = req.getRequestURI().contains("/api/")
                || "XMLHttpRequest".equals(req.getHeader("X-Requested-With"))
                || (req.getHeader("Accept") != null && req.getHeader("Accept").contains("application/json"));

        String idStr = req.getParameter("customerId");
        if (idStr == null || idStr.trim().isEmpty()) {
            idStr = req.getParameter("id");
        }

        String customerName = req.getParameter("customerName");
        String phone = req.getParameter("phone");
        String taxCode = req.getParameter("taxCode");
        if (taxCode == null || taxCode.trim().isEmpty()) {
            taxCode = req.getParameter("tax_code");
        }
        String industry = req.getParameter("industry");
        String size = req.getParameter("size");
        String website = req.getParameter("website");
        String address = req.getParameter("address");
        String status = req.getParameter("status");
        String ownerIdStr = req.getParameter("ownerId");

        Integer customerId = null;
        boolean isEdit = (idStr != null && !idStr.trim().isEmpty());
        if (isEdit) {
            try {
                customerId = Integer.parseInt(idStr.trim());
            } catch (NumberFormatException e) {
                sendErrorResponse(req, resp, HttpServletResponse.SC_BAD_REQUEST, "ID khách hàng không hợp lệ", isEdit, isJsonRequest);
                return;
            }
        }

        if (customerName == null || customerName.trim().isEmpty()) {
            sendErrorResponse(req, resp, HttpServletResponse.SC_BAD_REQUEST, "Tên khách hàng không được để trống", isEdit, isJsonRequest);
            return;
        }

        // Validate taxCode (UNIQUE)
        if (taxCode != null && !taxCode.trim().isEmpty()) {
            taxCode = taxCode.trim();
            if (customerDAO.isTaxCodeExists(taxCode, customerId)) {
                sendErrorResponse(req, resp, HttpServletResponse.SC_BAD_REQUEST, "Mã số thuế đã tồn tại trong hệ thống", isEdit, isJsonRequest);
                return;
            }
        }

        // Validate status (Valid statuses: Tiềm năng, Đang giao dịch, Khách hàng, Ngừng hợp tác, POTENTIAL, DEALING, CUSTOMER, STOPPED, ACTIVE)
        List<String> validStatuses = List.of("Tiềm năng", "Đang giao dịch", "Khách hàng", "Ngừng hợp tác", "POTENTIAL", "DEALING", "CUSTOMER", "STOPPED", "ACTIVE");
        if (status == null || status.trim().isEmpty()) {
            status = "POTENTIAL";
        } else {
            status = status.trim();
            if (!validStatuses.contains(status)) {
                sendErrorResponse(req, resp, HttpServletResponse.SC_BAD_REQUEST, "Trạng thái khách hàng không hợp lệ. Các trạng thái hợp lệ: Tiềm năng, Đang giao dịch, Khách hàng, Ngừng hợp tác", isEdit, isJsonRequest);
                return;
            }
            switch (status) {
                case "Tiềm năng": status = "POTENTIAL"; break;
                case "Đang giao dịch": status = "DEALING"; break;
                case "Khách hàng": status = "CUSTOMER"; break;
                case "Ngừng hợp tác": status = "STOPPED"; break;
            }
        }

        Integer ownerId = (Integer) req.getSession().getAttribute("userId");
        if (ownerIdStr != null && !ownerIdStr.trim().isEmpty()) {
            try { ownerId = Integer.parseInt(ownerIdStr.trim()); } catch (Exception ignored) {}
        }

        // Extract custom fields from request parameters
        Map<Integer, String> customFieldValues = new HashMap<>();
        req.getParameterMap().forEach((key, vals) -> {
            if (key.startsWith("customField_") && vals != null && vals.length > 0) {
                try {
                    int fieldId = Integer.parseInt(key.substring("customField_".length()));
                    customFieldValues.put(fieldId, vals[0]);
                } catch (NumberFormatException ignored) {}
            }
        });

        // Backend Required & Data Type Validation
        List<String> validationErrors = customFieldService.validateSubmittedCustomFields("CUSTOMER", customFieldValues);
        if (!validationErrors.isEmpty()) {
            if (isJsonRequest) {
                resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                resp.setContentType("application/json;charset=UTF-8");
                StringBuilder sb = new StringBuilder("{\"error\":\"Validation failed\", \"details\":[");
                for (int i = 0; i < validationErrors.size(); i++) {
                    sb.append("\"").append(escapeJson(validationErrors.get(i))).append("\"");
                    if (i < validationErrors.size() - 1) sb.append(",");
                }
                sb.append("]}");
                resp.getWriter().print(sb.toString());
            } else {
                sendErrorResponse(req, resp, HttpServletResponse.SC_BAD_REQUEST, validationErrors.get(0), isEdit, false);
            }
            return;
        }

        Customer customer = new Customer();
        customer.setCustomerName(customerName.trim());
        customer.setPhone(phone != null ? phone.trim() : "");
        customer.setTaxCode(taxCode != null && !taxCode.trim().isEmpty() ? taxCode.trim() : null);
        customer.setIndustry(industry != null ? industry.trim() : "");
        customer.setSize(size != null ? size.trim() : "");
        customer.setWebsite(website != null ? website.trim() : "");
        customer.setAddress(address != null ? address.trim() : "");
        customer.setStatus(status);
        customer.setOwnerId(ownerId != null ? ownerId : 1);

        boolean success;
        if (isEdit) {
            customer.setCustomerId(customerId);
            success = customerDAO.update(customer);
        } else {
            success = customerDAO.insert(customer);
        }

        if (success) {
            customFieldService.saveBatchValues("CUSTOMER", customer.getCustomerId(), customFieldValues);
            if (isJsonRequest) {
                resp.setContentType("application/json;charset=UTF-8");
                resp.setStatus(isEdit ? HttpServletResponse.SC_OK : HttpServletResponse.SC_CREATED);
                resp.getWriter().print("{\"message\":\"Lưu khách hàng thành công\", \"customerId\":" + customer.getCustomerId() + "}");
            } else {
                resp.sendRedirect(req.getContextPath() + "/customers");
            }
        } else {
            sendErrorResponse(req, resp, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Không thể lưu khách hàng vào cơ sở dữ liệu", isEdit, isJsonRequest);
        }
    }

    private void sendErrorResponse(HttpServletRequest req, HttpServletResponse resp, int statusCode, String message, boolean isEdit, boolean isJsonRequest) throws ServletException, IOException {
        resp.setStatus(statusCode);
        String forwardPath = isEdit ? "/WEB-INF/views/customers/edit.jsp" : "/WEB-INF/views/customers/create.jsp";
        if (isJsonRequest || req.getRequestDispatcher(forwardPath) == null) {
            resp.setContentType("application/json;charset=UTF-8");
            resp.getWriter().print("{\"error\":\"" + escapeJson(message) + "\"}");
        } else {
            req.setAttribute("message", message);
            req.getRequestDispatcher(forwardPath).forward(req, resp);
        }
    }

    private void handleDelete(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setContentType("application/json;charset=UTF-8");
        PrintWriter out = resp.getWriter();
        String idStr = req.getParameter("customerId");
        if (idStr == null || idStr.trim().isEmpty()) {
            idStr = req.getParameter("id");
        }

        if (idStr == null || idStr.trim().isEmpty()) {
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.print("{\"error\":\"Thiếu ID khách hàng cần xóa\"}");
            return;
        }

        try {
            int customerId = Integer.parseInt(idStr.trim());
            customFieldService.deleteValuesByEntity("CUSTOMER", customerId);
            boolean ok = customerDAO.delete(customerId);
            if (ok) {
                out.print("{\"message\":\"Xóa khách hàng thành công\"}");
            } else {
                resp.setStatus(HttpServletResponse.SC_NOT_FOUND);
                out.print("{\"error\":\"Không tìm thấy khách hàng để xóa\"}");
            }
        } catch (NumberFormatException e) {
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.print("{\"error\":\"ID khách hàng không hợp lệ\"}");
        }
    }

    private String escapeJson(String input) {
        if (input == null) return "";
        return input.replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", "\\n").replace("\r", "\\r");
    }
}

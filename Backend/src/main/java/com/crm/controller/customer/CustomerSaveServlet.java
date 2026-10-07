package com.crm.controller.customer;

import com.crm.dao.CustomerDAO;
import com.crm.model.Customer;
import com.crm.service.CustomFieldService;
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
        resp.setContentType("application/json;charset=UTF-8");
        PrintWriter out = resp.getWriter();

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

        if (customerName == null || customerName.trim().isEmpty()) {
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.print("{\"error\":\"Tên khách hàng không được để trống\"}");
            return;
        }

        Integer customerId = null;
        boolean isEdit = (idStr != null && !idStr.trim().isEmpty());
        if (isEdit) {
            try {
                customerId = Integer.parseInt(idStr.trim());
            } catch (NumberFormatException e) {
                resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                out.print("{\"error\":\"ID khách hàng không hợp lệ\"}");
                return;
            }
        }

        // Validate taxCode (UNIQUE)
        if (taxCode != null && !taxCode.trim().isEmpty()) {
            taxCode = taxCode.trim();
            if (customerDAO.isTaxCodeExists(taxCode, customerId)) {
                resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                out.print("{\"error\":\"Mã số thuế đã tồn tại trong hệ thống\"}");
                return;
            }
        }

        // Validate status (4 valid statuses: Tiềm năng, Đang giao dịch, Khách hàng, Ngừng hợp tác)
        List<String> validStatuses = List.of("Tiềm năng", "Đang giao dịch", "Khách hàng", "Ngừng hợp tác");
        if (status == null || status.trim().isEmpty()) {
            status = "Tiềm năng";
        } else {
            status = status.trim();
            if (!validStatuses.contains(status)) {
                resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                out.print("{\"error\":\"Trạng thái khách hàng không hợp lệ. Các trạng thái hợp lệ: Tiềm năng, Đang giao dịch, Khách hàng, Ngừng hợp tác\"}");
                return;
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
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            StringBuilder sb = new StringBuilder("{\"error\":\"Validation failed\", \"details\":[");
            for (int i = 0; i < validationErrors.size(); i++) {
                sb.append("\"").append(escapeJson(validationErrors.get(i))).append("\"");
                if (i < validationErrors.size() - 1) sb.append(",");
            }
            sb.append("]}");
            out.print(sb.toString());
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
            resp.setStatus(isEdit ? HttpServletResponse.SC_OK : HttpServletResponse.SC_CREATED);
            out.print("{\"message\":\"Lưu khách hàng thành công\", \"customerId\":" + customer.getCustomerId() + "}");
        } else {
            resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.print("{\"error\":\"Không thể lưu khách hàng vào cơ sở dữ liệu\"}");
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

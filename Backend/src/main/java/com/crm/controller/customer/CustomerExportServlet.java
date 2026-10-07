package com.crm.controller.customer;

import com.crm.dao.CustomerDAO;
import com.crm.model.Customer;
import com.crm.service.PermissionService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.Collections;
import java.util.List;

@WebServlet("/customers/export")
public class CustomerExportServlet extends HttpServlet {
    private final CustomerDAO customerDAO = new CustomerDAO();
    private final PermissionService permissionService = new PermissionService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        Integer userId = (Integer) req.getSession().getAttribute("userId");
        Integer roleId = (Integer) req.getSession().getAttribute("roleId");
        List<Integer> roleIds = com.crm.util.ValidationUtil.getSafeIntegerList(req.getAttribute("effectiveRoleIds"));

        if (userId == null || (roleId == null && (roleIds == null || roleIds.isEmpty()))) {
            resp.sendRedirect(req.getContextPath() + "/auth/login");
            return;
        }

        List<Integer> effectiveRoles = (roleIds != null && !roleIds.isEmpty()) 
                ? roleIds 
                : Collections.singletonList(roleId);

        List<Integer> ownerIds = permissionService.getAccessibleAccountIdsForRoles(userId, effectiveRoles, "ACCOUNT");
        String keyword = req.getParameter("keyword");

        List<Customer> customers = customerDAO.getListForExport(keyword, ownerIds);

        com.crm.service.CustomFieldService customFieldService = new com.crm.service.CustomFieldService();
        List<com.crm.model.CustomFieldDefinition> customFieldDefs = customFieldService.getDefinitions("CUSTOMER", "ACTIVE");

        resp.setContentType("text/csv; charset=UTF-8");
        resp.setHeader("Content-Disposition", "attachment; filename=\"customers_export.csv\"");

        PrintWriter writer = resp.getWriter();
        writer.write("\uFEFF"); // UTF-8 BOM

        StringBuilder headerSb = new StringBuilder("ID,Tên khách hàng,Số điện thoại,ID Người sở hữu,Ngày tạo");
        for (com.crm.model.CustomFieldDefinition def : customFieldDefs) {
            headerSb.append(",").append(escapeCsvField(def.getFieldLabel()));
        }
        writer.println(headerSb.toString());

        for (Customer c : customers) {
            StringBuilder sb = new StringBuilder();
            sb.append(escapeCsvField(c.getCustomerid())).append(",");
            sb.append(escapeCsvField(c.getCustomername())).append(",");
            sb.append(escapeCsvField(c.getPhone())).append(",");
            sb.append(escapeCsvField(c.getOwnerId())).append(",");
            sb.append(escapeCsvField(c.getCreatedAt()));

            List<com.crm.model.CustomFieldValue> cfValues = customFieldService.getValuesByEntity("CUSTOMER", c.getCustomerId());
            java.util.Map<Integer, String> valMap = new java.util.HashMap<>();
            if (cfValues != null) {
                for (com.crm.model.CustomFieldValue v : cfValues) {
                    valMap.put(v.getFieldId(), v.getFieldValue());
                }
            }

            for (com.crm.model.CustomFieldDefinition def : customFieldDefs) {
                String val = valMap.get(def.getFieldId());
                sb.append(",").append(escapeCsvField(val != null ? val : ""));
            }
            writer.println(sb.toString());
        }
        writer.flush();
    }


    public static String escapeCsvField(Object field) {
        if (field == null) return "";
        String value = field.toString();
        if (value.isEmpty()) return "";

        boolean isNegativeNumber = value.matches("^-[0-9]+(\\.[0-9]+)?$");
        String trimmed = value.stripLeading();

        if (!isNegativeNumber && (trimmed.startsWith("=") || trimmed.startsWith("+") || 
                                  trimmed.startsWith("-") || trimmed.startsWith("@") || 
                                  trimmed.startsWith("\t") || trimmed.startsWith("\r"))) {
            value = "'" + value;
        }

        if (value.contains(",") || value.contains("\"") || value.contains("\n") || value.contains("\r")) {
            value = value.replace("\"", "\"\"");
            return "\"" + value + "\"";
        }
        return value;
    }
}

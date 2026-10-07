package com.crm.controller.opportunity;

import com.crm.dao.OpportunityDAO;
import com.crm.model.CustomFieldDefinition;
import com.crm.model.CustomFieldValue;
import com.crm.model.Opportunity;
import com.crm.service.CustomFieldService;
import com.crm.service.PermissionService;
import com.crm.util.ValidationUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet("/deals/export")
public class OpportunityExportServlet extends HttpServlet {

    private final OpportunityDAO opportunityDAO = new OpportunityDAO();
    private final PermissionService permissionService = new PermissionService();
    private final CustomFieldService customFieldService = new CustomFieldService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        Integer userId = (Integer) req.getSession().getAttribute("userId");
        Integer roleId = (Integer) req.getSession().getAttribute("roleId");
        List<Integer> roleIds = ValidationUtil.getSafeIntegerList(req.getAttribute("effectiveRoleIds"));

        if (userId == null || (roleId == null && (roleIds == null || roleIds.isEmpty()))) {
            resp.sendRedirect(req.getContextPath() + "/auth/login");
            return;
        }

        List<Integer> effectiveRoles = (roleIds != null && !roleIds.isEmpty())
                ? roleIds
                : Collections.singletonList(roleId);

        List<Integer> ownerIds = permissionService.getAccessibleAccountIdsForRoles(userId, effectiveRoles, "OPPORTUNITY");
        String keyword = req.getParameter("keyword");

        List<Opportunity> opportunities = opportunityDAO.getListForExport(keyword, ownerIds);
        List<CustomFieldDefinition> customFieldDefs = customFieldService.getDefinitions("OPPORTUNITY", "ACTIVE");

        resp.setContentType("text/csv; charset=UTF-8");
        resp.setHeader("Content-Disposition", "attachment; filename=\"opportunities_export.csv\"");

        PrintWriter writer = resp.getWriter();
        writer.write("\uFEFF"); // UTF-8 BOM

        StringBuilder headerSb = new StringBuilder("ID,Tiêu đề,Số tiền,ID Người sở hữu,Ngày tạo");
        for (CustomFieldDefinition def : customFieldDefs) {
            headerSb.append(",").append(escapeCsvField(def.getFieldLabel()));
        }
        writer.println(headerSb.toString());

        for (Opportunity opp : opportunities) {
            StringBuilder sb = new StringBuilder();
            sb.append(escapeCsvField(opp.getOpportunityId())).append(",");
            sb.append(escapeCsvField(opp.getTitle())).append(",");
            sb.append(escapeCsvField(opp.getAmount())).append(",");
            sb.append(escapeCsvField(opp.getOwnerId())).append(",");
            sb.append(escapeCsvField(opp.getCreatedAt()));

            List<CustomFieldValue> cfValues = customFieldService.getValuesByEntity("OPPORTUNITY", opp.getOpportunityId());
            Map<Integer, String> valMap = new HashMap<>();
            if (cfValues != null) {
                for (CustomFieldValue v : cfValues) {
                    valMap.put(v.getFieldId(), v.getFieldValue());
                }
            }

            for (CustomFieldDefinition def : customFieldDefs) {
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

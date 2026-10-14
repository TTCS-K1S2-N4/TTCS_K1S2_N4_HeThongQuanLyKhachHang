package com.crm.controller.customfield;

import com.crm.dto.CustomFieldRequest;
import com.crm.model.CustomFieldDefinition;
import com.crm.model.CustomFieldValue;
import com.crm.service.CustomFieldService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;

@WebServlet(urlPatterns = {"/custom-fields", "/api/custom-fields"})
public class CustomFieldServlet extends HttpServlet {

    private CustomFieldService customFieldService = new CustomFieldService();

    public void setCustomFieldService(CustomFieldService customFieldService) {
        if (customFieldService != null) {
            this.customFieldService = customFieldService;
        }
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String entityType = req.getParameter("entityType");
        String entityIdStr = req.getParameter("entityId");
        String acceptHeader = req.getHeader("Accept");
        String requestedWith = req.getHeader("X-Requested-With");
        String uri = req.getRequestURI();

        boolean isApiRequest = uri.contains("/api/")
                || "XMLHttpRequest".equals(requestedWith)
                || (acceptHeader != null && acceptHeader.contains("application/json") && !acceptHeader.contains("text/html"));

        // If direct browser navigation to HTML view
        if (!isApiRequest && (uri.endsWith("/custom-fields") || uri.endsWith("/custom-fields/"))) {
            List<CustomFieldDefinition> customerDefs = customFieldService.getDefinitions("CUSTOMER", null);
            List<CustomFieldDefinition> opportunityDefs = customFieldService.getDefinitions("OPPORTUNITY", null);

            int totalFields = (customerDefs != null ? customerDefs.size() : 0) + (opportunityDefs != null ? opportunityDefs.size() : 0);
            int customerFieldsCount = customerDefs != null ? customerDefs.size() : 0;
            int opportunityFieldsCount = opportunityDefs != null ? opportunityDefs.size() : 0;

            int requiredCount = 0;
            int totalUsageCount = 0;
            if (customerDefs != null) {
                for (CustomFieldDefinition d : customerDefs) {
                    if (d.isRequired()) requiredCount++;
                    totalUsageCount += d.getUsageCount();
                }
            }
            if (opportunityDefs != null) {
                for (CustomFieldDefinition d : opportunityDefs) {
                    if (d.isRequired()) requiredCount++;
                    totalUsageCount += d.getUsageCount();
                }
            }

            req.setAttribute("customerDefs", customerDefs);
            req.setAttribute("opportunityDefs", opportunityDefs);
            req.setAttribute("totalFields", totalFields);
            req.setAttribute("customerFieldsCount", customerFieldsCount);
            req.setAttribute("opportunityFieldsCount", opportunityFieldsCount);
            req.setAttribute("requiredCount", requiredCount);
            req.setAttribute("totalUsageCount", totalUsageCount);

            req.getRequestDispatcher("/WEB-INF/views/customfields/list.jsp").forward(req, resp);
            return;
        }

        resp.setContentType("application/json;charset=UTF-8");
        PrintWriter out = resp.getWriter();
        String status = req.getParameter("status");

        if (entityIdStr != null && !entityIdStr.trim().isEmpty()) {
            try {
                int entityId = Integer.parseInt(entityIdStr.trim());
                List<CustomFieldValue> values = customFieldService.getValuesByEntity(entityType, entityId);
                out.print(toJsonValuesList(values));
                return;
            } catch (NumberFormatException e) {
                resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                out.print("{\"error\":\"ID thực thể không hợp lệ\"}");
                return;
            }
        }

        List<CustomFieldDefinition> definitions = customFieldService.getDefinitions(entityType, status);
        out.print(toJsonDefinitionsList(definitions));
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setContentType("application/json;charset=UTF-8");
        PrintWriter out = resp.getWriter();

        String action = req.getParameter("action");
        if (action == null || action.trim().isEmpty()) {
            action = "CREATE";
        }
        action = action.trim().toUpperCase();

        if ("DELETE".equals(action)) {
            handleDelete(req, resp, out);
            return;
        }

        if ("STATUS".equals(action)) {
            handleToggleStatus(req, resp, out);
            return;
        }

        if ("ORDER".equals(action)) {
            handleUpdateOrder(req, resp, out);
            return;
        }

        if ("UPDATE".equals(action)) {
            handleUpdate(req, resp, out);
            return;
        }

        handleCreate(req, resp, out);
    }

    private void handleCreate(HttpServletRequest req, HttpServletResponse resp, PrintWriter out) {
        String entityType = req.getParameter("entityType");
        String fieldKey = req.getParameter("fieldKey");
        String fieldLabel = req.getParameter("fieldLabel");
        String fieldType = req.getParameter("fieldType");
        String options = req.getParameter("options");
        String isRequiredStr = req.getParameter("isRequired");
        String defaultValue = req.getParameter("defaultValue");
        String displayOrderStr = req.getParameter("displayOrder");
        String status = req.getParameter("status");

        if (entityType == null || entityType.trim().isEmpty() ||
            fieldKey == null || fieldKey.trim().isEmpty() ||
            fieldLabel == null || fieldLabel.trim().isEmpty()) {
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.print("{\"error\":\"Thiếu thông tin bắt buộc (entityType, fieldKey, fieldLabel)\"}");
            return;
        }

        CustomFieldRequest request = new CustomFieldRequest();
        request.setEntityType(entityType.trim().toUpperCase());
        request.setFieldKey(fieldKey.trim().toLowerCase().replaceAll("[^a-z0-9_]", "_"));
        request.setFieldLabel(fieldLabel.trim());
        request.setFieldType(fieldType != null && !fieldType.trim().isEmpty() ? fieldType.trim().toUpperCase() : "TEXT");
        request.setOptions(options != null ? options.trim() : null);
        request.setIsRequired("true".equalsIgnoreCase(isRequiredStr) || "1".equals(isRequiredStr) || "on".equalsIgnoreCase(isRequiredStr));
        request.setDefaultValue(defaultValue != null ? defaultValue.trim() : null);
        if (displayOrderStr != null && !displayOrderStr.trim().isEmpty()) {
            try {
                request.setDisplayOrder(Integer.parseInt(displayOrderStr.trim()));
            } catch (NumberFormatException ignored) {}
        }
        request.setStatus(status != null && !status.trim().isEmpty() ? status.trim().toUpperCase() : "ACTIVE");

        boolean success = customFieldService.createDefinition(request);
        if (success) {
            resp.setStatus(HttpServletResponse.SC_CREATED);
            out.print("{\"success\":true, \"message\":\"Tạo trường tùy chỉnh thành công\"}");
        } else {
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.print("{\"error\":\"Không thể tạo trường tùy chỉnh hoặc mã trường (fieldKey) đã tồn tại\"}");
        }
    }

    private void handleUpdate(HttpServletRequest req, HttpServletResponse resp, PrintWriter out) {
        String fieldIdStr = req.getParameter("fieldId");
        if (fieldIdStr == null || fieldIdStr.trim().isEmpty()) {
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.print("{\"error\":\"Thiếu ID trường tùy chỉnh (fieldId)\"}");
            return;
        }

        try {
            int fieldId = Integer.parseInt(fieldIdStr.trim());
            String fieldLabel = req.getParameter("fieldLabel");
            String fieldType = req.getParameter("fieldType");
            String options = req.getParameter("options");
            String isRequiredStr = req.getParameter("isRequired");
            String defaultValue = req.getParameter("defaultValue");
            String displayOrderStr = req.getParameter("displayOrder");
            String status = req.getParameter("status");

            CustomFieldRequest request = new CustomFieldRequest();
            if (fieldLabel != null) request.setFieldLabel(fieldLabel.trim());
            if (fieldType != null) request.setFieldType(fieldType.trim().toUpperCase());
            if (options != null) request.setOptions(options.trim());
            if (isRequiredStr != null) {
                request.setIsRequired("true".equalsIgnoreCase(isRequiredStr) || "1".equals(isRequiredStr) || "on".equalsIgnoreCase(isRequiredStr));
            }
            if (defaultValue != null) request.setDefaultValue(defaultValue.trim());
            if (displayOrderStr != null && !displayOrderStr.trim().isEmpty()) {
                request.setDisplayOrder(Integer.parseInt(displayOrderStr.trim()));
            }
            if (status != null) request.setStatus(status.trim().toUpperCase());

            boolean ok = customFieldService.updateDefinition(fieldId, request);
            if (ok) {
                out.print("{\"success\":true, \"message\":\"Cập nhật trường tùy chỉnh thành công\"}");
            } else {
                resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                out.print("{\"error\":\"Cập nhật trường tùy chỉnh thất bại\"}");
            }
        } catch (NumberFormatException e) {
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.print("{\"error\":\"ID trường tùy chỉnh không hợp lệ\"}");
        }
    }

    private void handleDelete(HttpServletRequest req, HttpServletResponse resp, PrintWriter out) {
        String fieldIdStr = req.getParameter("fieldId");
        if (fieldIdStr == null || fieldIdStr.trim().isEmpty()) {
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.print("{\"error\":\"Thiếu ID trường tùy chỉnh cần xóa\"}");
            return;
        }

        try {
            int fieldId = Integer.parseInt(fieldIdStr.trim());
            boolean ok = customFieldService.deleteDefinition(fieldId);
            if (ok) {
                out.print("{\"success\":true, \"message\":\"Đã xóa trường tùy chỉnh thành công\"}");
            } else {
                resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                out.print("{\"error\":\"Không thể xóa trường tùy chỉnh\"}");
            }
        } catch (NumberFormatException e) {
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.print("{\"error\":\"ID trường không hợp lệ\"}");
        }
    }

    private void handleToggleStatus(HttpServletRequest req, HttpServletResponse resp, PrintWriter out) {
        String fieldIdStr = req.getParameter("fieldId");
        String newStatus = req.getParameter("status");
        if (fieldIdStr == null || fieldIdStr.trim().isEmpty() || newStatus == null || newStatus.trim().isEmpty()) {
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.print("{\"error\":\"Thiếu fieldId hoặc status\"}");
            return;
        }

        try {
            int fieldId = Integer.parseInt(fieldIdStr.trim());
            CustomFieldRequest request = new CustomFieldRequest();
            request.setStatus(newStatus.trim().toUpperCase());
            boolean ok = customFieldService.updateDefinition(fieldId, request);
            if (ok) {
                out.print("{\"success\":true, \"message\":\"Cập nhật trạng thái thành công\", \"status\":\"" + newStatus.trim().toUpperCase() + "\"}");
            } else {
                resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                out.print("{\"error\":\"Cập nhật trạng thái thất bại\"}");
            }
        } catch (NumberFormatException e) {
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.print("{\"error\":\"ID trường không hợp lệ\"}");
        }
    }

    private void handleUpdateOrder(HttpServletRequest req, HttpServletResponse resp, PrintWriter out) {
        String fieldIdStr = req.getParameter("fieldId");
        String orderStr = req.getParameter("displayOrder");
        if (fieldIdStr == null || orderStr == null) {
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.print("{\"error\":\"Thiếu fieldId hoặc displayOrder\"}");
            return;
        }

        try {
            int fieldId = Integer.parseInt(fieldIdStr.trim());
            int order = Integer.parseInt(orderStr.trim());
            CustomFieldRequest request = new CustomFieldRequest();
            request.setDisplayOrder(order);
            boolean ok = customFieldService.updateDefinition(fieldId, request);
            if (ok) {
                out.print("{\"success\":true, \"message\":\"Cập nhật thứ tự thành công\"}");
            } else {
                resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                out.print("{\"error\":\"Cập nhật thứ tự thất bại\"}");
            }
        } catch (NumberFormatException e) {
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.print("{\"error\":\"Thông số không hợp lệ\"}");
        }
    }

    private String toJsonDefinitionsList(List<CustomFieldDefinition> list) {
        if (list == null) return "[]";
        StringBuilder json = new StringBuilder("[");
        for (int i = 0; i < list.size(); i++) {
            CustomFieldDefinition def = list.get(i);
            json.append("{")
                .append("\"fieldId\":").append(def.getFieldId()).append(",")
                .append("\"entityType\":\"").append(escapeJson(def.getEntityType())).append("\",")
                .append("\"fieldKey\":\"").append(escapeJson(def.getFieldKey())).append("\",")
                .append("\"fieldLabel\":\"").append(escapeJson(def.getFieldLabel())).append("\",")
                .append("\"fieldType\":\"").append(escapeJson(def.getFieldType())).append("\",")
                .append("\"options\":").append(def.getOptions() != null ? "\"" + escapeJson(def.getOptions()) + "\"" : "null").append(",")
                .append("\"isRequired\":").append(def.isRequired()).append(",")
                .append("\"defaultValue\":").append(def.getDefaultValue() != null ? "\"" + escapeJson(def.getDefaultValue()) + "\"" : "null").append(",")
                .append("\"displayOrder\":").append(def.getDisplayOrder()).append(",")
                .append("\"usageCount\":").append(def.getUsageCount()).append(",")
                .append("\"status\":\"").append(escapeJson(def.getStatus())).append("\"")
                .append("}");
            if (i < list.size() - 1) {
                json.append(",");
            }
        }
        json.append("]");
        return json.toString();
    }

    private String toJsonValuesList(List<CustomFieldValue> list) {
        if (list == null) return "[]";
        StringBuilder json = new StringBuilder("[");
        for (int i = 0; i < list.size(); i++) {
            CustomFieldValue val = list.get(i);
            json.append("{")
                .append("\"valueId\":").append(val.getValueId()).append(",")
                .append("\"fieldId\":").append(val.getFieldId()).append(",")
                .append("\"entityType\":\"").append(escapeJson(val.getEntityType())).append("\",")
                .append("\"entityId\":").append(val.getEntityId()).append(",")
                .append("\"fieldValue\":").append(val.getFieldValue() != null ? "\"" + escapeJson(val.getFieldValue()) + "\"" : "null").append(",")
                .append("\"fieldKey\":").append(val.getFieldKey() != null ? "\"" + escapeJson(val.getFieldKey()) + "\"" : "null").append(",")
                .append("\"fieldLabel\":").append(val.getFieldLabel() != null ? "\"" + escapeJson(val.getFieldLabel()) + "\"" : "null").append(",")
                .append("\"fieldType\":").append(val.getFieldType() != null ? "\"" + escapeJson(val.getFieldType()) + "\"" : "null")
                .append("}");
            if (i < list.size() - 1) {
                json.append(",");
            }
        }
        json.append("]");
        return json.toString();
    }

    private String escapeJson(String input) {
        if (input == null) return "";
        return input.replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", "\\n").replace("\r", "\\r");
    }
}

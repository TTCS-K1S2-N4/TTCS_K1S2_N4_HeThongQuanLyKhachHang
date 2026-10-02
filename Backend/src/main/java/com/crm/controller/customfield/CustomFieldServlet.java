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

@WebServlet("/api/custom-fields")
public class CustomFieldServlet extends HttpServlet {

    private CustomFieldService customFieldService = new CustomFieldService();

    public void setCustomFieldService(CustomFieldService customFieldService) {
        if (customFieldService != null) {
            this.customFieldService = customFieldService;
        }
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setContentType("application/json;charset=UTF-8");
        PrintWriter out = resp.getWriter();

        String entityType = req.getParameter("entityType");
        String entityIdStr = req.getParameter("entityId");
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

        String entityType = req.getParameter("entityType");
        String fieldKey = req.getParameter("fieldKey");
        String fieldLabel = req.getParameter("fieldLabel");
        String fieldType = req.getParameter("fieldType");
        String options = req.getParameter("options");
        String isRequiredStr = req.getParameter("isRequired");
        String defaultValue = req.getParameter("defaultValue");
        String displayOrderStr = req.getParameter("displayOrder");
        String status = req.getParameter("status");

        if (entityType == null || fieldKey == null || fieldLabel == null) {
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.print("{\"error\":\"Thiếu thông tin bắt buộc (entityType, fieldKey, fieldLabel)\"}");
            return;
        }

        CustomFieldRequest request = new CustomFieldRequest();
        request.setEntityType(entityType);
        request.setFieldKey(fieldKey);
        request.setFieldLabel(fieldLabel);
        request.setFieldType(fieldType);
        request.setOptions(options);
        request.setIsRequired("true".equalsIgnoreCase(isRequiredStr) || "1".equals(isRequiredStr));
        request.setDefaultValue(defaultValue);
        if (displayOrderStr != null && !displayOrderStr.isEmpty()) {
            try {
                request.setDisplayOrder(Integer.parseInt(displayOrderStr));
            } catch (NumberFormatException ignored) {}
        }
        request.setStatus(status);

        boolean success = customFieldService.createDefinition(request);
        if (success) {
            resp.setStatus(HttpServletResponse.SC_CREATED);
            out.print("{\"message\":\"Tạo trường tùy chỉnh thành công\"}");
        } else {
            resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.print("{\"error\":\"Không thể tạo trường tùy chỉnh hoặc key đã tồn tại\"}");
        }
    }

    private String toJsonDefinitionsList(List<CustomFieldDefinition> list) {
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

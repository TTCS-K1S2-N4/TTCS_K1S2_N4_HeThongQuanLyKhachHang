package com.crm.controller.product;

import com.crm.exception.ValidationException;
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

@WebServlet({"/products/custom-fields", "/custom-fields"})
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

        if (entityType == null || entityType.trim().isEmpty()) {
            entityType = "PRODUCT";
        }

        List<CustomFieldDefinition> definitions = customFieldService.getDefinitionsByEntityType(entityType);
        req.setAttribute("customFieldDefinitions", definitions);

        if (entityIdStr != null && !entityIdStr.trim().isEmpty()) {
            try {
                int entityId = Integer.parseInt(entityIdStr.trim());
                List<CustomFieldValue> values = customFieldService.getValuesByEntityId(entityId);
                req.setAttribute("customFieldValues", values);
            } catch (NumberFormatException ignored) {}
        }

        if (isAjaxRequest(req)) {
            resp.setContentType("application/json;charset=UTF-8");
            PrintWriter out = resp.getWriter();
            StringBuilder json = new StringBuilder();
            json.append("{\"definitions\":[");
            for (int i = 0; i < definitions.size(); i++) {
                CustomFieldDefinition d = definitions.get(i);
                if (i > 0) json.append(",");
                json.append("{");
                json.append("\"fieldId\":").append(d.getFieldId()).append(",");
                json.append("\"entityType\":\"").append(escapeJson(d.getEntityType())).append("\",");
                json.append("\"fieldName\":\"").append(escapeJson(d.getFieldName())).append("\",");
                json.append("\"fieldLabel\":\"").append(escapeJson(d.getFieldLabel())).append("\",");
                json.append("\"fieldType\":\"").append(escapeJson(d.getFieldType())).append("\",");
                json.append("\"isRequired\":").append(Boolean.TRUE.equals(d.getIsRequired()));
                json.append("}");
            }
            json.append("]}");
            out.print(json.toString());
            out.flush();
        } else {
            req.getRequestDispatcher("/WEB-INF/views/products/custom_fields.jsp").forward(req, resp);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String action = req.getParameter("action");
        if ("createDefinition".equalsIgnoreCase(action)) {
            handleCreateDefinition(req, resp);
        } else if ("saveValue".equalsIgnoreCase(action)) {
            handleSaveValue(req, resp);
        } else {
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
        }
    }

    private void handleCreateDefinition(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        String entityType = req.getParameter("entityType");
        String fieldName = req.getParameter("fieldName");
        String fieldLabel = req.getParameter("fieldLabel");
        String fieldType = req.getParameter("fieldType");
        String isRequiredStr = req.getParameter("isRequired");

        CustomFieldDefinition def = new CustomFieldDefinition();
        def.setEntityType(entityType);
        def.setFieldName(fieldName);
        def.setFieldLabel(fieldLabel);
        def.setFieldType(fieldType);
        def.setIsRequired("true".equalsIgnoreCase(isRequiredStr) || "1".equals(isRequiredStr));

        try {
            boolean created = customFieldService.createDefinition(def);
            resp.setContentType("application/json;charset=UTF-8");
            PrintWriter out = resp.getWriter();
            out.print("{\"success\": " + created + "}");
            out.flush();
        } catch (ValidationException e) {
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            resp.setContentType("application/json;charset=UTF-8");
            PrintWriter out = resp.getWriter();
            out.print("{\"success\": false, \"message\": \"" + escapeJson(e.getMessage()) + "\"}");
            out.flush();
        }
    }

    private void handleSaveValue(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        String fieldIdStr = req.getParameter("fieldId");
        String entityIdStr = req.getParameter("entityId");
        String value = req.getParameter("value");

        try {
            int fieldId = Integer.parseInt(fieldIdStr);
            int entityId = Integer.parseInt(entityIdStr);
            boolean saved = customFieldService.saveOrUpdateValue(fieldId, entityId, value);
            resp.setContentType("application/json;charset=UTF-8");
            PrintWriter out = resp.getWriter();
            out.print("{\"success\": " + saved + "}");
            out.flush();
        } catch (Exception e) {
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            resp.setContentType("application/json;charset=UTF-8");
            PrintWriter out = resp.getWriter();
            out.print("{\"success\": false, \"message\": \"" + escapeJson(e.getMessage()) + "\"}");
            out.flush();
        }
    }

    private boolean isAjaxRequest(HttpServletRequest request) {
        String requestedWith = request.getHeader("X-Requested-With");
        String acceptHeader = request.getHeader("Accept");
        return "XMLHttpRequest".equalsIgnoreCase(requestedWith) ||
                (acceptHeader != null && acceptHeader.contains("application/json"));
    }

    private String escapeJson(String input) {
        if (input == null) return "";
        return input.replace("\\", "\\\\")
                    .replace("\"", "\\\"")
                    .replace("\n", "\\n")
                    .replace("\r", "\\r");
    }
}

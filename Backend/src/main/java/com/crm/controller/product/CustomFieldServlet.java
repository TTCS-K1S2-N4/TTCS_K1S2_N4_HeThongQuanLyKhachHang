package com.crm.controller.product;

import com.crm.dto.CustomFieldRequest;
import com.crm.model.Account;
import com.crm.model.CustomFieldDefinition;
import com.crm.model.CustomFieldValue;
import com.crm.service.CustomFieldService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.List;

@WebServlet("/custom-fields")
public class CustomFieldServlet extends HttpServlet {

    private CustomFieldService customFieldService = new CustomFieldService();

    public void setCustomFieldService(CustomFieldService customFieldService) {
        if (customFieldService != null) {
            this.customFieldService = customFieldService;
        }
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        Account currentUser = session != null ? (Account) session.getAttribute("currentUser") : null;
        Integer userId = session != null ? (Integer) session.getAttribute("userId") : null;

        if (currentUser == null && userId == null) {
            if (isAjaxRequest(req)) {
                resp.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                resp.setContentType("application/json;charset=UTF-8");
                PrintWriter out = resp.getWriter();
                out.print("{\"status\": 401, \"message\": \"Bạn cần đăng nhập để thực hiện chức năng này.\"}");
                out.flush();
                return;
            } else {
                resp.sendRedirect(req.getContextPath() + "/auth/login");
                return;
            }
        }

        String entityType = req.getParameter("entityType");
        String entityIdStr = req.getParameter("entityId");
        String status = req.getParameter("status");

        if (entityIdStr != null && !entityIdStr.trim().isEmpty()) {
            try {
                int entityId = Integer.parseInt(entityIdStr.trim());
                List<CustomFieldValue> values = customFieldService.getValuesByEntity(entityType, entityId);
                resp.setContentType("application/json;charset=UTF-8");
                PrintWriter out = resp.getWriter();
                out.print(toJsonValuesList(values));
                out.flush();
                return;
            } catch (NumberFormatException e) {
                resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                resp.setContentType("application/json;charset=UTF-8");
                PrintWriter out = resp.getWriter();
                out.print("{\"error\":\"ID thực thể không hợp lệ\"}");
                out.flush();
                return;
            }
        }

        if (entityType == null || entityType.trim().isEmpty()) {
            entityType = "CUSTOMER";
        } else {
            entityType = entityType.trim().toUpperCase();
        }

        List<CustomFieldDefinition> definitions = customFieldService.getDefinitions(entityType, status);
        req.setAttribute("customFields", definitions);
        req.setAttribute("entityType", entityType);

        if (isAjaxRequest(req)) {
            resp.setContentType("application/json;charset=UTF-8");
            PrintWriter out = resp.getWriter();
            out.print(toJsonDefinitionsList(definitions));
            out.flush();
        } else {
            String jspPath = "/WEB-INF/views/customers/custom-fields.jsp";
            if ("OPPORTUNITY".equals(entityType)) {
                jspPath = "/WEB-INF/views/opportunities/custom-fields.jsp";
            }
            req.getRequestDispatcher(jspPath).forward(req, resp);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        Account currentUser = session != null ? (Account) session.getAttribute("currentUser") : null;
        Integer userId = session != null ? (Integer) session.getAttribute("userId") : null;

        if (currentUser == null && userId == null) {
            if (isAjaxRequest(req)) {
                resp.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                resp.setContentType("application/json;charset=UTF-8");
                PrintWriter out = resp.getWriter();
                out.print("{\"status\": 401, \"message\": \"Bạn cần đăng nhập để thực hiện chức năng này.\"}");
                out.flush();
                return;
            } else {
                resp.sendRedirect(req.getContextPath() + "/auth/login");
                return;
            }
        }

        req.setCharacterEncoding("UTF-8");
        String actionStr = req.getParameter("action");
        String customFieldIdStr = req.getParameter("customFieldId");
        if (customFieldIdStr == null || customFieldIdStr.trim().isEmpty()) {
            customFieldIdStr = req.getParameter("fieldId");
        }
        String entityType = req.getParameter("entityType");
        String fieldName = req.getParameter("fieldName");
        if (fieldName == null || fieldName.trim().isEmpty()) {
            fieldName = req.getParameter("fieldLabel");
        }
        String fieldType = req.getParameter("fieldType");
        String options = req.getParameter("options");
        String isRequiredStr = req.getParameter("required");
        if (isRequiredStr == null || isRequiredStr.trim().isEmpty()) {
            isRequiredStr = req.getParameter("isRequired");
        }
        String defaultValue = req.getParameter("defaultValue");
        String displayOrderStr = req.getParameter("displayOrder");
        String status = req.getParameter("status");

        CustomFieldRequest request = new CustomFieldRequest();
        request.setAction(actionStr);
        request.setEntityType(entityType);
        request.setFieldName(fieldName);
        request.setFieldType(fieldType);
        request.setOptions(options);
        request.setIsRequired("true".equalsIgnoreCase(isRequiredStr) || "1".equals(isRequiredStr) || "on".equalsIgnoreCase(isRequiredStr));
        request.setDefaultValue(defaultValue);
        request.setStatus(status);

        if (customFieldIdStr != null && !customFieldIdStr.trim().isEmpty()) {
            try {
                request.setCustomFieldId(Integer.parseInt(customFieldIdStr.trim()));
            } catch (NumberFormatException ignored) {}
        }

        if (displayOrderStr != null && !displayOrderStr.trim().isEmpty()) {
            try {
                request.setDisplayOrder(Integer.parseInt(displayOrderStr.trim()));
            } catch (NumberFormatException ignored) {}
        }

        List<String> errors = new ArrayList<>();
        String action = actionStr != null ? actionStr.trim().toUpperCase() : "";
        if (action.isEmpty()) {
            if (request.getCustomFieldId() != null) {
                action = "UPDATE";
            } else {
                action = "CREATE";
            }
        }

        boolean success = false;
        switch (action) {
            case "CREATE":
                success = customFieldService.createCustomField(request, errors);
                break;
            case "UPDATE":
                success = customFieldService.updateCustomField(request, errors);
                break;
            case "DEACTIVATE":
                success = customFieldService.deactivateCustomField(request.getCustomFieldId(), errors);
                break;
            default:
                errors.add("Thao tác (action) '" + actionStr + "' không hợp lệ. Chỉ chấp nhận CREATE, UPDATE, DEACTIVATE.");
                break;
        }

        String targetEntityType = request.getEntityType() != null ? request.getEntityType().trim().toUpperCase() : "CUSTOMER";

        if (!success || !errors.isEmpty()) {
            if (isAjaxRequest(req)) {
                resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                resp.setContentType("application/json;charset=UTF-8");
                PrintWriter out = resp.getWriter();
                out.print(toJsonErrors(errors));
                out.flush();
            } else {
                req.setAttribute("errors", errors);
                req.setAttribute("requestData", request);
                req.setAttribute("entityType", targetEntityType);
                List<CustomFieldDefinition> definitions = customFieldService.getDefinitions(targetEntityType, null);
                req.setAttribute("customFields", definitions);
                String jspPath = "/WEB-INF/views/customers/custom-fields.jsp";
                if ("OPPORTUNITY".equals(targetEntityType)) {
                    jspPath = "/WEB-INF/views/opportunities/custom-fields.jsp";
                }
                req.getRequestDispatcher(jspPath).forward(req, resp);
            }
        } else {
            if (isAjaxRequest(req)) {
                resp.setStatus(HttpServletResponse.SC_OK);
                resp.setContentType("application/json;charset=UTF-8");
                PrintWriter out = resp.getWriter();
                out.print("{\"success\": true, \"message\": \"Thực hiện thao tác " + action + " thành công.\"}");
                out.flush();
            } else {
                resp.sendRedirect(req.getContextPath() + "/custom-fields?entityType=" + targetEntityType);
            }
        }
    }

    private boolean isAjaxRequest(HttpServletRequest request) {
        String requestedWith = request.getHeader("X-Requested-With");
        String acceptHeader = request.getHeader("Accept");
        return "XMLHttpRequest".equalsIgnoreCase(requestedWith) ||
                (acceptHeader != null && acceptHeader.contains("application/json"));
    }

    private String toJsonDefinitionsList(List<CustomFieldDefinition> list) {
        StringBuilder json = new StringBuilder("[");
        for (int i = 0; i < list.size(); i++) {
            CustomFieldDefinition def = list.get(i);
            json.append("{")
                .append("\"fieldId\":").append(def.getFieldId()).append(",")
                .append("\"customFieldId\":").append(def.getFieldId()).append(",")
                .append("\"entityType\":\"").append(escapeJson(def.getEntityType())).append("\",")
                .append("\"fieldKey\":\"").append(escapeJson(def.getFieldKey())).append("\",")
                .append("\"fieldName\":\"").append(escapeJson(def.getFieldLabel())).append("\",")
                .append("\"fieldLabel\":\"").append(escapeJson(def.getFieldLabel())).append("\",")
                .append("\"fieldType\":\"").append(escapeJson(def.getFieldType())).append("\",")
                .append("\"options\":").append(def.getOptions() != null ? "\"" + escapeJson(def.getOptions()) + "\"" : "null").append(",")
                .append("\"required\":").append(def.isRequired()).append(",")
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

    private String toJsonErrors(List<String> errors) {
        StringBuilder json = new StringBuilder("{\"success\": false, \"errors\": [");
        for (int i = 0; i < errors.size(); i++) {
            json.append("\"").append(escapeJson(errors.get(i))).append("\"");
            if (i < errors.size() - 1) {
                json.append(",");
            }
        }
        json.append("]}");
        return json.toString();
    }

    private String escapeJson(String input) {
        if (input == null) return "";
        return input.replace("\\", "\\\\")
                    .replace("\"", "\\\"")
                    .replace("\b", "\\b")
                    .replace("\f", "\\f")
                    .replace("\n", "\\n")
                    .replace("\r", "\\r")
                    .replace("\t", "\\t");
    }
}

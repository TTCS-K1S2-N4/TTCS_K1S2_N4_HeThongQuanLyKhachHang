package com.crm.service;

import com.crm.dao.CustomFieldDefinitionDAO;
import com.crm.dao.CustomFieldValueDAO;
import com.crm.dto.CustomFieldRequest;
import com.crm.model.CustomFieldDefinition;
import com.crm.model.CustomFieldValue;

import java.text.Normalizer;
import java.util.ArrayList;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

public class CustomFieldService {

    private CustomFieldDefinitionDAO definitionDAO;
    private CustomFieldValueDAO valueDAO;

    public CustomFieldService() {
        this.definitionDAO = new CustomFieldDefinitionDAO();
        this.valueDAO = new CustomFieldValueDAO();
    }

    public CustomFieldService(CustomFieldDefinitionDAO definitionDAO, CustomFieldValueDAO valueDAO) {
        this.definitionDAO = definitionDAO;
        this.valueDAO = valueDAO;
    }

    public List<CustomFieldDefinition> getDefinitions(String entityType, String status) {
        return definitionDAO.getDefinitions(entityType, status);
    }

    public CustomFieldDefinition getDefinitionById(int fieldId) {
        return definitionDAO.getById(fieldId);
    }

    public String generateUniqueFieldKey(String entityType, String fieldLabel) {
        if (fieldLabel == null) {
            fieldLabel = "field";
        }
        String normalized = Normalizer.normalize(fieldLabel, Normalizer.Form.NFD);
        String withoutDiacritics = normalized.replaceAll("\\p{M}", "")
                .replace("đ", "d").replace("Đ", "d");
        String baseKey = withoutDiacritics.toLowerCase()
                .replaceAll("[^a-z0-9]+", "_")
                .replaceAll("^_+|_+$", "");

        if (baseKey.isEmpty()) {
            baseKey = "custom_field";
        }

        String candidateKey = baseKey;
        int counter = 1;
        while (definitionDAO.getByKey(entityType, candidateKey) != null) {
            candidateKey = baseKey + "_" + counter;
            counter++;
        }
        return candidateKey;
    }

    public String formatOptions(String fieldType, String optionsStr) {
        if (!"SELECT".equalsIgnoreCase(fieldType) || optionsStr == null || optionsStr.trim().isEmpty()) {
            return null;
        }
        String[] parts = optionsStr.split(",");
        Set<String> set = new LinkedHashSet<>();
        for (String p : parts) {
            String trimmed = p.trim();
            if (!trimmed.isEmpty()) {
                set.add(trimmed);
            }
        }
        if (set.isEmpty()) {
            return null;
        }
        return String.join(", ", set);
    }

    public boolean createCustomField(CustomFieldRequest request, List<String> errors) {
        if (errors == null) errors = new ArrayList<>();

        if (request == null) {
            errors.add("Dữ liệu yêu cầu không được rỗng.");
            return false;
        }

        String entityType = request.getEntityType();
        if (entityType == null || (!"CUSTOMER".equalsIgnoreCase(entityType.trim()) && !"OPPORTUNITY".equalsIgnoreCase(entityType.trim()))) {
            errors.add("Đối tượng (entityType) không hợp lệ. Phải là CUSTOMER hoặc OPPORTUNITY.");
        } else {
            entityType = entityType.trim().toUpperCase();
        }

        String fieldName = request.getFieldName();
        if (fieldName == null || fieldName.trim().isEmpty()) {
            errors.add("Tên trường tùy chỉnh (fieldName) không được để trống.");
        } else {
            fieldName = fieldName.trim();
        }

        String fieldType = request.getFieldType();
        if (fieldType == null || fieldType.trim().isEmpty()) {
            fieldType = "TEXT";
        } else {
            fieldType = fieldType.trim().toUpperCase();
            if (!"TEXT".equals(fieldType) && !"NUMBER".equals(fieldType) && !"DATE".equals(fieldType) && !"SELECT".equals(fieldType)) {
                errors.add("Kiểu dữ liệu (fieldType) không hợp lệ. Phải là TEXT, NUMBER, DATE hoặc SELECT.");
            }
        }

        String formattedOptions = formatOptions(fieldType, request.getOptions());
        if ("SELECT".equals(fieldType) && (formattedOptions == null || formattedOptions.isEmpty())) {
            errors.add("Danh sách lựa chọn (options) là bắt buộc đối với kiểu SELECT.");
        }

        if (!errors.isEmpty()) {
            return false;
        }

        String fieldKey = generateUniqueFieldKey(entityType, fieldName);

        CustomFieldDefinition def = new CustomFieldDefinition();
        def.setEntityType(entityType);
        def.setFieldKey(fieldKey);
        def.setFieldLabel(fieldName);
        def.setFieldType(fieldType);
        def.setOptions(formattedOptions);
        def.setRequired(Boolean.TRUE.equals(request.getIsRequired()));
        def.setDefaultValue(request.getDefaultValue() != null ? request.getDefaultValue().trim() : null);
        def.setDisplayOrder(request.getDisplayOrder() != null ? request.getDisplayOrder() : 0);
        def.setStatus(request.getStatus() != null && !request.getStatus().trim().isEmpty() ? request.getStatus().trim().toUpperCase() : "ACTIVE");

        boolean inserted = definitionDAO.insert(def);
        if (!inserted) {
            errors.add("Không thể lưu trường tùy chỉnh vào cơ sở dữ liệu.");
            return false;
        }

        request.setCustomFieldId(def.getFieldId());
        request.setFieldKey(def.getFieldKey());
        return true;
    }

    public boolean updateCustomField(CustomFieldRequest request, List<String> errors) {
        if (errors == null) errors = new ArrayList<>();

        if (request == null || request.getCustomFieldId() == null) {
            errors.add("Thiếu ID trường tùy chỉnh (customFieldId) cần cập nhật.");
            return false;
        }

        CustomFieldDefinition existing = definitionDAO.getById(request.getCustomFieldId());
        if (existing == null) {
            errors.add("Trường tùy chỉnh có ID " + request.getCustomFieldId() + " không tồn tại.");
            return false;
        }

        if (request.getFieldName() != null) {
            if (request.getFieldName().trim().isEmpty()) {
                errors.add("Tên trường tùy chỉnh (fieldName) không được để trống.");
            } else {
                existing.setFieldLabel(request.getFieldName().trim());
            }
        }

        if (request.getFieldType() != null && !request.getFieldType().trim().isEmpty()) {
            String fieldType = request.getFieldType().trim().toUpperCase();
            if (!"TEXT".equals(fieldType) && !"NUMBER".equals(fieldType) && !"DATE".equals(fieldType) && !"SELECT".equals(fieldType)) {
                errors.add("Kiểu dữ liệu (fieldType) không hợp lệ. Phải là TEXT, NUMBER, DATE hoặc SELECT.");
            } else {
                existing.setFieldType(fieldType);
            }
        }

        String targetFieldType = existing.getFieldType();
        String rawOptions = request.getOptions() != null ? request.getOptions() : existing.getOptions();
        String formattedOptions = formatOptions(targetFieldType, rawOptions);
        if ("SELECT".equals(targetFieldType) && (formattedOptions == null || formattedOptions.isEmpty())) {
            errors.add("Danh sách lựa chọn (options) là bắt buộc đối với kiểu SELECT.");
        } else {
            existing.setOptions(formattedOptions);
        }

        if (request.getIsRequired() != null) {
            existing.setRequired(request.getIsRequired());
        }
        if (request.getDefaultValue() != null) {
            existing.setDefaultValue(request.getDefaultValue().trim());
        }
        if (request.getDisplayOrder() != null) {
            existing.setDisplayOrder(request.getDisplayOrder());
        }
        if (request.getStatus() != null && !request.getStatus().trim().isEmpty()) {
            existing.setStatus(request.getStatus().trim().toUpperCase());
        }

        if (!errors.isEmpty()) {
            return false;
        }

        boolean updated = definitionDAO.update(existing);
        if (!updated) {
            errors.add("Không thể cập nhật trường tùy chỉnh vào cơ sở dữ liệu.");
            return false;
        }
        return true;
    }

    public boolean deactivateCustomField(Integer customFieldId, List<String> errors) {
        if (errors == null) errors = new ArrayList<>();

        if (customFieldId == null) {
            errors.add("Thiếu ID trường tùy chỉnh (customFieldId) cần ngừng sử dụng.");
            return false;
        }

        CustomFieldDefinition existing = definitionDAO.getById(customFieldId);
        if (existing == null) {
            errors.add("Trường tùy chỉnh có ID " + customFieldId + " không tồn tại.");
            return false;
        }

        existing.setStatus("INACTIVE");
        boolean updated = definitionDAO.update(existing);
        if (!updated) {
            errors.add("Không thể chuyển trạng thái trường tùy chỉnh sang INACTIVE.");
            return false;
        }
        return true;
    }

    public boolean createDefinition(CustomFieldRequest request) {
        List<String> errors = new ArrayList<>();
        return createCustomField(request, errors);
    }

    public boolean updateDefinition(int fieldId, CustomFieldRequest request) {
        List<String> errors = new ArrayList<>();
        if (request == null) request = new CustomFieldRequest();
        request.setCustomFieldId(fieldId);
        return updateCustomField(request, errors);
    }

    public boolean deleteDefinition(int fieldId) {
        List<String> errors = new ArrayList<>();
        return deactivateCustomField(fieldId, errors);
    }

    public List<CustomFieldValue> getValuesByEntity(String entityType, int entityId) {
        return valueDAO.getValuesByEntity(entityType, entityId);
    }

    public boolean saveValue(int fieldId, String entityType, int entityId, String fieldValue) {
        return valueDAO.saveOrUpdateValue(fieldId, entityType, entityId, fieldValue);
    }

    public boolean saveBatchValues(String entityType, int entityId, Map<Integer, String> fieldValues) {
        return valueDAO.saveBatchValues(entityType, entityId, fieldValues);
    }

    public boolean deleteValuesByEntity(String entityType, int entityId) {
        return valueDAO.deleteValuesByEntity(entityType, entityId);
    }
}

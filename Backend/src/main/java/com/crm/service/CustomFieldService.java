package com.crm.service;

import com.crm.dao.CustomFieldDefinitionDAO;
import com.crm.dao.CustomFieldValueDAO;
import com.crm.exception.ValidationException;
import com.crm.model.CustomFieldDefinition;
import com.crm.model.CustomFieldValue;

import java.util.ArrayList;
import java.util.List;
import java.util.logging.Logger;

public class CustomFieldService {

    private static final Logger LOGGER = Logger.getLogger(CustomFieldService.class.getName());

    private final CustomFieldDefinitionDAO definitionDAO;
    private final CustomFieldValueDAO valueDAO;

    public CustomFieldService() {
        this.definitionDAO = new CustomFieldDefinitionDAO();
        this.valueDAO = new CustomFieldValueDAO();
    }

    public CustomFieldService(CustomFieldDefinitionDAO definitionDAO, CustomFieldValueDAO valueDAO) {
        this.definitionDAO = definitionDAO;
        this.valueDAO = valueDAO;
    }

    public List<CustomFieldDefinition> getDefinitionsByEntityType(String entityType) {
        if (entityType == null || entityType.trim().isEmpty()) {
            return new ArrayList<>();
        }
        List<CustomFieldDefinitionDAO.CustomFieldDefinitionItem> items = definitionDAO.getFieldsByEntityType(entityType.trim().toUpperCase());
        List<CustomFieldDefinition> result = new ArrayList<>();
        for (CustomFieldDefinitionDAO.CustomFieldDefinitionItem item : items) {
            CustomFieldDefinition def = new CustomFieldDefinition();
            def.setFieldId(item.getFieldId());
            def.setEntityType(item.getEntityType());
            def.setFieldName(item.getFieldName());
            def.setFieldLabel(item.getFieldLabel());
            def.setFieldType(item.getFieldType());
            def.setIsRequired(item.isRequired());
            def.setOptionsJson(item.getOptionsJson());
            result.add(def);
        }
        return result;
    }

    public boolean createDefinition(CustomFieldDefinition definition) throws ValidationException {
        if (definition == null) {
            throw new ValidationException("Định nghĩa trường tùy chỉnh không được để null.");
        }
        if (definition.getEntityType() == null || definition.getEntityType().trim().isEmpty()) {
            throw new ValidationException("Loại đối tượng (entityType) không được để trống.");
        }
        if (definition.getFieldName() == null || definition.getFieldName().trim().isEmpty()) {
            throw new ValidationException("Tên trường (fieldName) không được để trống.");
        }
        if (definition.getFieldLabel() == null || definition.getFieldLabel().trim().isEmpty()) {
            throw new ValidationException("Nhãn hiển thị (fieldLabel) không được để trống.");
        }

        CustomFieldDefinitionDAO.CustomFieldDefinitionItem item = new CustomFieldDefinitionDAO.CustomFieldDefinitionItem();
        item.setEntityType(definition.getEntityType().trim().toUpperCase());
        item.setFieldName(definition.getFieldName().trim());
        item.setFieldLabel(definition.getFieldLabel().trim());
        item.setFieldType(definition.getFieldType() != null ? definition.getFieldType().trim().toUpperCase() : "TEXT");
        item.setRequired(Boolean.TRUE.equals(definition.getIsRequired()));
        item.setOptionsJson(definition.getOptionsJson());

        return definitionDAO.createFieldDefinition(item);
    }

    public boolean deleteDefinition(int fieldId) throws ValidationException {
        if (fieldId <= 0) {
            throw new ValidationException("ID trường không hợp lệ.");
        }
        return definitionDAO.deleteFieldDefinition(fieldId);
    }

    public List<CustomFieldValue> getValuesByEntityId(int entityId) {
        if (entityId <= 0) {
            return new ArrayList<>();
        }
        List<CustomFieldValueDAO.CustomFieldValueItem> items = valueDAO.getValuesByEntityId(entityId);
        List<CustomFieldValue> result = new ArrayList<>();
        for (CustomFieldValueDAO.CustomFieldValueItem item : items) {
            CustomFieldValue val = new CustomFieldValue();
            val.setValueId(item.getValueId());
            val.setFieldId(item.getFieldId());
            val.setEntityId(item.getEntityId());
            val.setFieldValue(item.getFieldValue());
            result.add(val);
        }
        return result;
    }

    public boolean saveOrUpdateValue(int fieldId, int entityId, String value) throws ValidationException {
        if (fieldId <= 0 || entityId <= 0) {
            throw new ValidationException("ID trường hoặc ID đối tượng không hợp lệ.");
        }
        return valueDAO.saveOrUpdateValue(fieldId, entityId, value);
    }
}

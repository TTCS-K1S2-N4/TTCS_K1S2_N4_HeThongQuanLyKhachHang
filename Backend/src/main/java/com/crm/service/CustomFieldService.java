package com.crm.service;

import com.crm.dao.CustomFieldDefinitionDAO;
import com.crm.dao.CustomFieldValueDAO;
import com.crm.dto.CustomFieldRequest;
import com.crm.model.CustomFieldDefinition;
import com.crm.model.CustomFieldValue;

import java.util.List;
import java.util.Map;

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

    public boolean createDefinition(CustomFieldRequest request) {
        if (request == null || request.getEntityType() == null || request.getFieldKey() == null || request.getFieldLabel() == null) {
            return false;
        }

        // Check if key already exists for entity
        CustomFieldDefinition existing = definitionDAO.getByKey(request.getEntityType(), request.getFieldKey());
        if (existing != null) {
            return false;
        }

        CustomFieldDefinition def = new CustomFieldDefinition();
        def.setEntityType(request.getEntityType());
        def.setFieldKey(request.getFieldKey());
        def.setFieldLabel(request.getFieldLabel());
        def.setFieldType(request.getFieldType() != null ? request.getFieldType() : "TEXT");
        def.setOptions(request.getOptions());
        def.setRequired(Boolean.TRUE.equals(request.getIsRequired()));
        def.setDefaultValue(request.getDefaultValue());
        def.setDisplayOrder(request.getDisplayOrder() != null ? request.getDisplayOrder() : 0);
        def.setStatus(request.getStatus() != null ? request.getStatus() : "ACTIVE");

        return definitionDAO.insert(def);
    }

    public boolean updateDefinition(int fieldId, CustomFieldRequest request) {
        CustomFieldDefinition existing = definitionDAO.getById(fieldId);
        if (existing == null || request == null) {
            return false;
        }

        if (request.getFieldLabel() != null) existing.setFieldLabel(request.getFieldLabel());
        if (request.getFieldType() != null) existing.setFieldType(request.getFieldType());
        if (request.getOptions() != null) existing.setOptions(request.getOptions());
        if (request.getIsRequired() != null) existing.setRequired(request.getIsRequired());
        if (request.getDefaultValue() != null) existing.setDefaultValue(request.getDefaultValue());
        if (request.getDisplayOrder() != null) existing.setDisplayOrder(request.getDisplayOrder());
        if (request.getStatus() != null) existing.setStatus(request.getStatus());

        return definitionDAO.update(existing);
    }

    public boolean deleteDefinition(int fieldId) {
        return definitionDAO.delete(fieldId);
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

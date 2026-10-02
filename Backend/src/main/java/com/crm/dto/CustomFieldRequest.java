package com.crm.dto;

import java.util.Map;

public class CustomFieldRequest {
    private Integer fieldId;
    private String entityType;
    private String fieldKey;
    private String fieldLabel;
    private String fieldType;
    private String options;
    private Boolean isRequired;
    private String defaultValue;
    private Integer displayOrder;
    private String status;

    private String action;
    private Integer entityId;
    private String fieldValue;
    private Map<Integer, String> fieldValues; // For batch value updates

    public CustomFieldRequest() {
    }

    public String getAction() {
        return action;
    }

    public void setAction(String action) {
        this.action = action;
    }

    public Integer getCustomFieldId() {
        return fieldId;
    }

    public void setCustomFieldId(Integer customFieldId) {
        this.fieldId = customFieldId;
    }

    public String getFieldName() {
        return fieldLabel;
    }

    public void setFieldName(String fieldName) {
        this.fieldLabel = fieldName;
    }

    public Integer getFieldId() {
        return fieldId;
    }

    public void setFieldId(Integer fieldId) {
        this.fieldId = fieldId;
    }

    public String getEntityType() {
        return entityType;
    }

    public void setEntityType(String entityType) {
        this.entityType = entityType;
    }

    public String getFieldKey() {
        return fieldKey;
    }

    public void setFieldKey(String fieldKey) {
        this.fieldKey = fieldKey;
    }

    public String getFieldLabel() {
        return fieldLabel;
    }

    public void setFieldLabel(String fieldLabel) {
        this.fieldLabel = fieldLabel;
    }

    public String getFieldType() {
        return fieldType;
    }

    public void setFieldType(String fieldType) {
        this.fieldType = fieldType;
    }

    public String getOptions() {
        return options;
    }

    public void setOptions(String options) {
        this.options = options;
    }

    public Boolean getIsRequired() {
        return isRequired;
    }

    public void setIsRequired(Boolean isRequired) {
        this.isRequired = isRequired;
    }

    public String getDefaultValue() {
        return defaultValue;
    }

    public void setDefaultValue(String defaultValue) {
        this.defaultValue = defaultValue;
    }

    public Integer getDisplayOrder() {
        return displayOrder;
    }

    public void setDisplayOrder(Integer displayOrder) {
        this.displayOrder = displayOrder;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public Integer getEntityId() {
        return entityId;
    }

    public void setEntityId(Integer entityId) {
        this.entityId = entityId;
    }

    public String getFieldValue() {
        return fieldValue;
    }

    public void setFieldValue(String fieldValue) {
        this.fieldValue = fieldValue;
    }

    public Map<Integer, String> getFieldValues() {
        return fieldValues;
    }

    public void setFieldValues(Map<Integer, String> fieldValues) {
        this.fieldValues = fieldValues;
    }
}

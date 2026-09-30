package com.crm.model;

import java.sql.Timestamp;

public class CustomFieldDefinition {
    private Integer fieldId;
    private String entityType; // PRODUCT, CUSTOMER, DEAL, etc.
    private String fieldName;
    private String fieldLabel;
    private String fieldType; // TEXT, NUMBER, DATE, SELECT, etc.
    private Boolean isRequired;
    private String optionsJson;
    private Timestamp createdAt;
    private Timestamp updatedAt;

    public CustomFieldDefinition() {}

    public CustomFieldDefinition(Integer fieldId, String entityType, String fieldName, String fieldLabel,
                                String fieldType, Boolean isRequired, String optionsJson) {
        this.fieldId = fieldId;
        this.entityType = entityType;
        this.fieldName = fieldName;
        this.fieldLabel = fieldLabel;
        this.fieldType = fieldType;
        this.isRequired = isRequired;
        this.optionsJson = optionsJson;
    }

    public Integer getFieldId() { return fieldId; }
    public void setFieldId(Integer fieldId) { this.fieldId = fieldId; }

    public String getEntityType() { return entityType; }
    public void setEntityType(String entityType) { this.entityType = entityType; }

    public String getFieldName() { return fieldName; }
    public void setFieldName(String fieldName) { this.fieldName = fieldName; }

    public String getFieldLabel() { return fieldLabel; }
    public void setFieldLabel(String fieldLabel) { this.fieldLabel = fieldLabel; }

    public String getFieldType() { return fieldType; }
    public void setFieldType(String fieldType) { this.fieldType = fieldType; }

    public Boolean getIsRequired() { return isRequired; }
    public void setIsRequired(Boolean isRequired) { this.isRequired = isRequired; }

    public String getOptionsJson() { return optionsJson; }
    public void setOptionsJson(String optionsJson) { this.optionsJson = optionsJson; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public Timestamp getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Timestamp updatedAt) { this.updatedAt = updatedAt; }
}

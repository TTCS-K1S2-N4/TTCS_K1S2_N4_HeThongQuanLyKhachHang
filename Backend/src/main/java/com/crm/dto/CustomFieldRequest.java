package com.crm.dto;

public class CustomFieldRequest {
    private Integer fieldId;
    private String entityType;
    private String fieldName;
    private String fieldLabel;
    private String fieldType;
    private Boolean isRequired;
    private String optionsJson;
    private Integer entityId;
    private String fieldValue;

    public CustomFieldRequest() {}

    public CustomFieldRequest(Integer fieldId, String entityType, String fieldName, String fieldLabel,
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

    public Integer getEntityId() { return entityId; }
    public void setEntityId(Integer entityId) { this.entityId = entityId; }

    public String getFieldValue() { return fieldValue; }
    public void setFieldValue(String fieldValue) { this.fieldValue = fieldValue; }
}

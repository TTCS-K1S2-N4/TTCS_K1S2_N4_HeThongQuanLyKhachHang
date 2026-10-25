package com.crm.model;

import java.sql.Timestamp;

public class CustomFieldValue {
    private Integer valueId;
    private Integer fieldId;
    private String entityType;
    private Integer entityId;
    private String fieldValue;
    private Timestamp createdAt;
    private Timestamp updatedAt;

    // Transient helper fields for UI display
    private String fieldKey;
    private String fieldLabel;
    private String fieldType;

    public CustomFieldValue() {
    }

    public CustomFieldValue(Integer valueId, Integer fieldId, String entityType, Integer entityId,
                            String fieldValue, Timestamp createdAt, Timestamp updatedAt) {
        this.valueId = valueId;
        this.fieldId = fieldId;
        this.entityType = entityType;
        this.entityId = entityId;
        this.fieldValue = fieldValue;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
    }

    public Integer getValueId() {
        return valueId;
    }

    public void setValueId(Integer valueId) {
        this.valueId = valueId;
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

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    public Timestamp getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(Timestamp updatedAt) {
        this.updatedAt = updatedAt;
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
}

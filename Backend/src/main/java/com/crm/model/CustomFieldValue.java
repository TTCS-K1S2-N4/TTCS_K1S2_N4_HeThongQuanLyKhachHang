package com.crm.model;

import java.sql.Timestamp;

public class CustomFieldValue {
    private Integer valueId;
    private Integer fieldId;
    private Integer entityId;
    private String fieldValue;
    private Timestamp createdAt;
    private Timestamp updatedAt;

    public CustomFieldValue() {}

    public CustomFieldValue(Integer valueId, Integer fieldId, Integer entityId, String fieldValue) {
        this.valueId = valueId;
        this.fieldId = fieldId;
        this.entityId = entityId;
        this.fieldValue = fieldValue;
    }

    public Integer getValueId() { return valueId; }
    public void setValueId(Integer valueId) { this.valueId = valueId; }

    public Integer getFieldId() { return fieldId; }
    public void setFieldId(Integer fieldId) { this.fieldId = fieldId; }

    public Integer getEntityId() { return entityId; }
    public void setEntityId(Integer entityId) { this.entityId = entityId; }

    public String getFieldValue() { return fieldValue; }
    public void setFieldValue(String fieldValue) { this.fieldValue = fieldValue; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public Timestamp getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Timestamp updatedAt) { this.updatedAt = updatedAt; }
}

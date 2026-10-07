package com.crm.model;

import java.sql.Timestamp;

/**
 * Model đại diện cho Trạng thái Chăm sóc Khách hàng định kỳ.
 * Task S30-10 / S3-09.
 */
public class CustomerCareState {
    private int careId;
    private int customerId;
    private Timestamp lastContactedAt;
    private Integer lastContactedBy;
    private String lastContactedByName;
    private String note;
    private Timestamp createdAt;
    private Timestamp updatedAt;

    public CustomerCareState() {
    }

    public CustomerCareState(int careId, int customerId, Timestamp lastContactedAt, Integer lastContactedBy, String note) {
        this.careId = careId;
        this.customerId = customerId;
        this.lastContactedAt = lastContactedAt;
        this.lastContactedBy = lastContactedBy;
        this.note = note;
    }

    public int getCareId() {
        return careId;
    }

    public void setCareId(int careId) {
        this.careId = careId;
    }

    public int getCustomerId() {
        return customerId;
    }

    public void setCustomerId(int customerId) {
        this.customerId = customerId;
    }

    public Timestamp getLastContactedAt() {
        return lastContactedAt;
    }

    public void setLastContactedAt(Timestamp lastContactedAt) {
        this.lastContactedAt = lastContactedAt;
    }

    public Integer getLastContactedBy() {
        return lastContactedBy;
    }

    public void setLastContactedBy(Integer lastContactedBy) {
        this.lastContactedBy = lastContactedBy;
    }

    public String getLastContactedByName() {
        return lastContactedByName;
    }

    public void setLastContactedByName(String lastContactedByName) {
        this.lastContactedByName = lastContactedByName;
    }

    public String getNote() {
        return note;
    }

    public void setNote(String note) {
        this.note = note;
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
}

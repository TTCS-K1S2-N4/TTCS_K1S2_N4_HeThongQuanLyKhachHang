package com.crm.model;

import java.sql.Timestamp;

/**
 * Model ghi nhận nhật ký gộp Lead (Lead Merge History).
 * Phục vụ cho Story S4-04 (S4-04-AC-03: Gộp giữ nguyên lịch sử của cả hai bản ghi).
 */
public class LeadMergeHistory {
    private int mergeId;
    private int primaryLeadId;
    private int duplicateLeadId;
    private Integer mergedBy;
    private String mergedByName;
    private Timestamp mergedAt;
    private String retainedFields;
    private String note;

    public LeadMergeHistory() {
        this.mergedAt = new Timestamp(System.currentTimeMillis());
    }

    public LeadMergeHistory(int primaryLeadId, int duplicateLeadId, Integer mergedBy, String retainedFields, String note) {
        this.primaryLeadId = primaryLeadId;
        this.duplicateLeadId = duplicateLeadId;
        this.mergedBy = mergedBy;
        this.mergedAt = new Timestamp(System.currentTimeMillis());
        this.retainedFields = retainedFields;
        this.note = note;
    }

    public int getMergeId() {
        return mergeId;
    }

    public void setMergeId(int mergeId) {
        this.mergeId = mergeId;
    }

    public int getPrimaryLeadId() {
        return primaryLeadId;
    }

    public void setPrimaryLeadId(int primaryLeadId) {
        this.primaryLeadId = primaryLeadId;
    }

    public int getDuplicateLeadId() {
        return duplicateLeadId;
    }

    public void setDuplicateLeadId(int duplicateLeadId) {
        this.duplicateLeadId = duplicateLeadId;
    }

    public Integer getMergedBy() {
        return mergedBy;
    }

    public void setMergedBy(Integer mergedBy) {
        this.mergedBy = mergedBy;
    }

    public String getMergedByName() {
        return mergedByName;
    }

    public void setMergedByName(String mergedByName) {
        this.mergedByName = mergedByName;
    }

    public Timestamp getMergedAt() {
        return mergedAt;
    }

    public void setMergedAt(Timestamp mergedAt) {
        this.mergedAt = mergedAt;
    }

    public String getRetainedFields() {
        return retainedFields;
    }

    public void setRetainedFields(String retainedFields) {
        this.retainedFields = retainedFields;
    }

    public String getNote() {
        return note;
    }

    public void setNote(String note) {
        this.note = note;
    }
}

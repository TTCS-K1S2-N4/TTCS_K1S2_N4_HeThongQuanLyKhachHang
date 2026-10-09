package com.crm.dto;

import java.util.ArrayList;
import java.util.List;

/**
 * DTO đại diện yêu cầu gộp Lead trùng.
 * Ánh xạ API D03: POST /leads/merge (S4-04).
 */
public class LeadMergeRequest {
    private int primaryLeadId;
    private int duplicateLeadId;
    private String retainedFullName;
    private String retainedCompany;
    private String retainedEmail;
    private String retainedPhone;
    private Integer retainedOwnerId;
    private String note;

    public LeadMergeRequest() {}

    public LeadMergeRequest(int primaryLeadId, int duplicateLeadId) {
        this.primaryLeadId = primaryLeadId;
        this.duplicateLeadId = duplicateLeadId;
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

    // Alias cho leftId/rightId
    public int getLeftId() {
        return primaryLeadId;
    }

    public void setLeftId(int leftId) {
        this.primaryLeadId = leftId;
    }

    public int getRightId() {
        return duplicateLeadId;
    }

    public void setRightId(int rightId) {
        this.duplicateLeadId = rightId;
    }

    public String getRetainedFullName() {
        return retainedFullName;
    }

    public void setRetainedFullName(String retainedFullName) {
        this.retainedFullName = retainedFullName;
    }

    public String getRetainedCompany() {
        return retainedCompany;
    }

    public void setRetainedCompany(String retainedCompany) {
        this.retainedCompany = retainedCompany;
    }

    public String getRetainedEmail() {
        return retainedEmail;
    }

    public void setRetainedEmail(String retainedEmail) {
        this.retainedEmail = retainedEmail;
    }

    public String getRetainedPhone() {
        return retainedPhone;
    }

    public void setRetainedPhone(String retainedPhone) {
        this.retainedPhone = retainedPhone;
    }

    public Integer getRetainedOwnerId() {
        return retainedOwnerId;
    }

    public void setRetainedOwnerId(Integer retainedOwnerId) {
        this.retainedOwnerId = retainedOwnerId;
    }

    public String getNote() {
        return note;
    }

    public void setNote(String note) {
        this.note = note;
    }

    public List<String> validate() {
        List<String> errors = new ArrayList<>();
        if (primaryLeadId <= 0) {
            errors.add("ID Lead chính (primaryLeadId) không hợp lệ.");
        }
        if (duplicateLeadId <= 0) {
            errors.add("ID Lead trùng (duplicateLeadId) không hợp lệ.");
        }
        if (primaryLeadId > 0 && primaryLeadId == duplicateLeadId) {
            errors.add("Không thể gộp một Lead vào chính nó.");
        }
        return errors;
    }
}

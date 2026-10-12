package com.crm.dto;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;

public class LeadImportRequest implements Serializable {
    private static final long serialVersionUID = 1L;

    private int rowIndex;
    private String fullName;
    private String title;
    private String company;
    private String email;
    private String phone;
    private String sourceName;
    private Integer leadSourceId;
    private String status;
    private String rating;
    private String industry;
    private String address;
    private String city;
    private String state;
    private String country;
    private String zipCode;
    private Integer ownerId;
    private String notes;

    private boolean valid = true;
    private boolean duplicate = false;
    private String duplicateReason;
    private Integer existingLeadId;
    private String error;
    private List<String> fieldErrors = new ArrayList<>();

    public LeadImportRequest() {}

    public int getRowIndex() {
        return rowIndex;
    }

    public void setRowIndex(int rowIndex) {
        this.rowIndex = rowIndex;
    }

    public String getFullName() {
        return fullName;
    }

    public void setFullName(String fullName) {
        this.fullName = fullName;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getCompany() {
        return company;
    }

    public void setCompany(String company) {
        this.company = company;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getPhone() {
        return phone;
    }

    public void setPhone(String phone) {
        this.phone = phone;
    }

    public String getSourceName() {
        return sourceName;
    }

    public void setSourceName(String sourceName) {
        this.sourceName = sourceName;
    }

    public Integer getLeadSourceId() {
        return leadSourceId;
    }

    public void setLeadSourceId(Integer leadSourceId) {
        this.leadSourceId = leadSourceId;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getRating() {
        return rating;
    }

    public void setRating(String rating) {
        this.rating = rating;
    }

    public String getIndustry() {
        return industry;
    }

    public void setIndustry(String industry) {
        this.industry = industry;
    }

    public String getAddress() {
        return address;
    }

    public void setAddress(String address) {
        this.address = address;
    }

    public String getCity() {
        return city;
    }

    public void setCity(String city) {
        this.city = city;
    }

    public String getState() {
        return state;
    }

    public void setState(String state) {
        this.state = state;
    }

    public String getCountry() {
        return country;
    }

    public void setCountry(String country) {
        this.country = country;
    }

    public String getZipCode() {
        return zipCode;
    }

    public void setZipCode(String zipCode) {
        this.zipCode = zipCode;
    }

    public Integer getOwnerId() {
        return ownerId;
    }

    public void setOwnerId(Integer ownerId) {
        this.ownerId = ownerId;
    }

    public String getNotes() {
        return notes;
    }

    public void setNotes(String notes) {
        this.notes = notes;
    }

    public boolean isValid() {
        return valid;
    }

    public void setValid(boolean valid) {
        this.valid = valid;
    }

    public boolean isDuplicate() {
        return duplicate;
    }

    public void setDuplicate(boolean duplicate) {
        this.duplicate = duplicate;
    }

    public String getDuplicateReason() {
        return duplicateReason;
    }

    public void setDuplicateReason(String duplicateReason) {
        this.duplicateReason = duplicateReason;
    }

    public Integer getExistingLeadId() {
        return existingLeadId;
    }

    public void setExistingLeadId(Integer existingLeadId) {
        this.existingLeadId = existingLeadId;
    }

    public String getError() {
        return error;
    }

    public void setError(String error) {
        this.error = error;
    }

    public List<String> getFieldErrors() {
        return fieldErrors;
    }

    public void setFieldErrors(List<String> fieldErrors) {
        this.fieldErrors = fieldErrors;
    }

    public void addFieldError(String fieldError) {
        if (this.fieldErrors == null) {
            this.fieldErrors = new ArrayList<>();
        }
        this.fieldErrors.add(fieldError);
        this.valid = false;
        if (this.error == null || this.error.trim().isEmpty()) {
            this.error = fieldError;
        } else {
            this.error = this.error + "; " + fieldError;
        }
    }
}

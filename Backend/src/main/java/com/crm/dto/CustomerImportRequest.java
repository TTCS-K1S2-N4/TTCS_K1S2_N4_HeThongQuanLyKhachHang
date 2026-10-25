package com.crm.dto;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;

public class CustomerImportRequest implements Serializable {
    private static final long serialVersionUID = 1L;

    private int rowIndex;
    private String customerName;
    private String phone;
    private String taxCode;
    private String industry;
    private String size;
    private String website;
    private String address;
    private String status;
    private Integer ownerId;

    private boolean valid = true;
    private boolean duplicate = false;
    private String duplicateReason;
    private Integer existingCustomerId;
    private String error;
    private List<String> fieldErrors = new ArrayList<>();

    public CustomerImportRequest() {
    }

    public int getRowIndex() {
        return rowIndex;
    }

    public void setRowIndex(int rowIndex) {
        this.rowIndex = rowIndex;
    }

    public String getCustomerName() {
        return customerName;
    }

    public void setCustomerName(String customerName) {
        this.customerName = customerName;
    }

    public String getPhone() {
        return phone;
    }

    public void setPhone(String phone) {
        this.phone = phone;
    }

    public String getTaxCode() {
        return taxCode;
    }

    public void setTaxCode(String taxCode) {
        this.taxCode = taxCode;
    }

    public String getIndustry() {
        return industry;
    }

    public void setIndustry(String industry) {
        this.industry = industry;
    }

    public String getSize() {
        return size;
    }

    public void setSize(String size) {
        this.size = size;
    }

    public String getWebsite() {
        return website;
    }

    public void setWebsite(String website) {
        this.website = website;
    }

    public String getAddress() {
        return address;
    }

    public void setAddress(String address) {
        this.address = address;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public Integer getOwnerId() {
        return ownerId;
    }

    public void setOwnerId(Integer ownerId) {
        this.ownerId = ownerId;
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

    public Integer getExistingCustomerId() {
        return existingCustomerId;
    }

    public void setExistingCustomerId(Integer existingCustomerId) {
        this.existingCustomerId = existingCustomerId;
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

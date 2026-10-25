package com.crm.dto;

/**
 * DTO nhận thông tin chuyển công ty của Contact.
 * Task S30-03 / S3-02.
 */
public class ContactTransferRequest {
    private Integer contactId;
    private Integer newCustomerId;
    private String reason;

    public ContactTransferRequest() {
    }

    public ContactTransferRequest(Integer contactId, Integer newCustomerId, String reason) {
        this.contactId = contactId;
        this.newCustomerId = newCustomerId;
        this.reason = reason;
    }

    public Integer getContactId() {
        return contactId;
    }

    public void setContactId(Integer contactId) {
        this.contactId = contactId;
    }

    public Integer getNewCustomerId() {
        return newCustomerId;
    }

    public void setNewCustomerId(Integer newCustomerId) {
        this.newCustomerId = newCustomerId;
    }

    public String getReason() {
        return reason;
    }

    public void setReason(String reason) {
        this.reason = reason;
    }
}

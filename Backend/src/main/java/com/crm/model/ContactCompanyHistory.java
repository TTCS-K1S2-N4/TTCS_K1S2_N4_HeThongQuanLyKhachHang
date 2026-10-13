package com.crm.model;

import java.sql.Timestamp;

/**
 * Model lưu lịch sử chuyển đổi công ty của Người liên hệ.
 * Task S30-03 / S3-02.
 */
public class ContactCompanyHistory {
    private int historyId;
    private int contactId;
    private int fromCustomerId;
    private int toCustomerId;
    private Timestamp transferredAt;
    private String reason;
    private Integer transferredBy;

    // Display fields for UI joins
    private String fromCustomerName;
    private String toCustomerName;
    private String transferredByName;

    public ContactCompanyHistory() {
    }

    public ContactCompanyHistory(int contactId, int fromCustomerId, int toCustomerId, String reason, Integer transferredBy) {
        this.contactId = contactId;
        this.fromCustomerId = fromCustomerId;
        this.toCustomerId = toCustomerId;
        this.reason = reason;
        this.transferredBy = transferredBy;
    }

    public int getHistoryId() {
        return historyId;
    }

    public void setHistoryId(int historyId) {
        this.historyId = historyId;
    }

    public int getContactId() {
        return contactId;
    }

    public void setContactId(int contactId) {
        this.contactId = contactId;
    }

    public int getFromCustomerId() {
        return fromCustomerId;
    }

    public void setFromCustomerId(int fromCustomerId) {
        this.fromCustomerId = fromCustomerId;
    }

    public int getToCustomerId() {
        return toCustomerId;
    }

    public void setToCustomerId(int toCustomerId) {
        this.toCustomerId = toCustomerId;
    }

    public Timestamp getTransferredAt() {
        return transferredAt;
    }

    public void setTransferredAt(Timestamp transferredAt) {
        this.transferredAt = transferredAt;
    }

    public String getReason() {
        return reason;
    }

    public void setReason(String reason) {
        this.reason = reason;
    }

    public Integer getTransferredBy() {
        return transferredBy;
    }

    public void setTransferredBy(Integer transferredBy) {
        this.transferredBy = transferredBy;
    }

    public String getFromCustomerName() {
        return fromCustomerName;
    }

    public void setFromCustomerName(String fromCustomerName) {
        this.fromCustomerName = fromCustomerName;
    }

    public String getToCustomerName() {
        return toCustomerName;
    }

    public void setToCustomerName(String toCustomerName) {
        this.toCustomerName = toCustomerName;
    }

    public String getTransferredByName() {
        return transferredByName;
    }

    public void setTransferredByName(String transferredByName) {
        this.transferredByName = transferredByName;
    }

    // Convenience aliases for JSP EL compatibility
    public String getOldCustomerName() {
        return fromCustomerName;
    }

    public String getNewCustomerName() {
        return toCustomerName;
    }

    public int getOldCustomerId() {
        return fromCustomerId;
    }

    public int getNewCustomerId() {
        return toCustomerId;
    }
}

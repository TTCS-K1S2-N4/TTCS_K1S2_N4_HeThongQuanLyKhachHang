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
}

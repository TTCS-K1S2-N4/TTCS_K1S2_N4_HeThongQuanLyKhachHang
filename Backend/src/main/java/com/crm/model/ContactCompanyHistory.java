package com.crm.model;

import java.sql.Timestamp;

public class ContactCompanyHistory {
    private int historyId;
    private int contactId;
    private int oldCustomerId;
    private int newCustomerId;
    private Integer transferredBy;
    private Timestamp transferredAt;

    // Joined / Display fields
    private String oldCustomerName;
    private String newCustomerName;
    private String transferredByName;

    public ContactCompanyHistory() {
    }

    public ContactCompanyHistory(int contactId, int oldCustomerId, int newCustomerId, Integer transferredBy) {
        this.contactId = contactId;
        this.oldCustomerId = oldCustomerId;
        this.newCustomerId = newCustomerId;
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

    public int getOldCustomerId() {
        return oldCustomerId;
    }

    public void setOldCustomerId(int oldCustomerId) {
        this.oldCustomerId = oldCustomerId;
    }

    public int getNewCustomerId() {
        return newCustomerId;
    }

    public void setNewCustomerId(int newCustomerId) {
        this.newCustomerId = newCustomerId;
    }

    public Integer getTransferredBy() {
        return transferredBy;
    }

    public void setTransferredBy(Integer transferredBy) {
        this.transferredBy = transferredBy;
    }

    public Timestamp getTransferredAt() {
        return transferredAt;
    }

    public void setTransferredAt(Timestamp transferredAt) {
        this.transferredAt = transferredAt;
    }

    public String getOldCustomerName() {
        return oldCustomerName;
    }

    public void setOldCustomerName(String oldCustomerName) {
        this.oldCustomerName = oldCustomerName;
    }

    public String getNewCustomerName() {
        return newCustomerName;
    }

    public void setNewCustomerName(String newCustomerName) {
        this.newCustomerName = newCustomerName;
    }

    public String getTransferredByName() {
        return transferredByName;
    }

    public void setTransferredByName(String transferredByName) {
        this.transferredByName = transferredByName;
    }
}

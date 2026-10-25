package com.crm.dto;

import java.sql.Timestamp;

/**
 * DTO trả về thông tin Contact cho Client.
 * Task S30-03 / S3-02.
 */
public class ContactResponse {
    private int contactId;
    private int customerId;
    private String fullName;
    private String title;
    private String email;
    private String phone;
    private String buyingRole;
    private boolean isPrimary;
    private Timestamp createdAt;

    public ContactResponse() {
    }

    public ContactResponse(int contactId, int customerId, String fullName, String title, String email,
                           String phone, String buyingRole, boolean isPrimary, Timestamp createdAt) {
        this.contactId = contactId;
        this.customerId = customerId;
        this.fullName = fullName;
        this.title = title;
        this.email = email;
        this.phone = phone;
        this.buyingRole = buyingRole;
        this.isPrimary = isPrimary;
        this.createdAt = createdAt;
    }

    public int getContactId() {
        return contactId;
    }

    public void setContactId(int contactId) {
        this.contactId = contactId;
    }

    public int getCustomerId() {
        return customerId;
    }

    public void setCustomerId(int customerId) {
        this.customerId = customerId;
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

    public String getBuyingRole() {
        return buyingRole;
    }

    public void setBuyingRole(String buyingRole) {
        this.buyingRole = buyingRole;
    }

    public boolean isPrimary() {
        return isPrimary;
    }

    public void setPrimary(boolean primary) {
        isPrimary = primary;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }
}

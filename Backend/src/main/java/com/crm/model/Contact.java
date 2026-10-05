package com.crm.model;

import java.sql.Timestamp;

public class Contact {
    private int contactId;
    private int customerId;
    private String fullName;
    private String title;
    private String email;
    private String phone;
    private String buyingRole; // DECISION_MAKER, INFLUENCER, END_USER, BLOCKER
    private boolean isPrimary;
    private Timestamp createdAt;
    private Timestamp updatedAt;

    // Display / Joined fields
    private String customerName;

    public Contact() {
    }

    public Contact(int contactId, int customerId, String fullName, String title, String email, String phone, String buyingRole, boolean isPrimary) {
        this.contactId = contactId;
        this.customerId = customerId;
        this.fullName = fullName;
        this.title = title;
        this.email = email;
        this.phone = phone;
        this.buyingRole = buyingRole;
        this.isPrimary = isPrimary;
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

    public Timestamp getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(Timestamp updatedAt) {
        this.updatedAt = updatedAt;
    }

    public String getCustomerName() {
        return customerName;
    }

    public void setCustomerName(String customerName) {
        this.customerName = customerName;
    }

    public String getBuyingRoleLabel() {
        if (buyingRole == null) return "";
        switch (buyingRole.toUpperCase()) {
            case "DECISION_MAKER":
                return "Người quyết định";
            case "INFLUENCER":
                return "Người ảnh hưởng";
            case "END_USER":
                return "Người dùng cuối";
            case "BLOCKER":
                return "Người cản trở";
            default:
                return buyingRole;
        }
    }
}

package com.crm.dto;

/**
 * DTO nhận thông tin tạo mới / chỉnh sửa Contact.
 * Task S30-03 / S3-02.
 */
public class ContactRequest {
    private Integer contactId;
    private Integer customerId;
    private String fullName;
    private String title;
    private String email;
    private String phone;
    private String buyingRole; // DECIDER, INFLUENCER, END_USER, BLOCKER
    private Boolean isPrimary;

    public ContactRequest() {
    }

    public ContactRequest(Integer customerId, String fullName, String title, String email, String phone,
                          String buyingRole, Boolean isPrimary) {
        this.customerId = customerId;
        this.fullName = fullName;
        this.title = title;
        this.email = email;
        this.phone = phone;
        this.buyingRole = buyingRole;
        this.isPrimary = isPrimary;
    }

    public Integer getContactId() {
        return contactId;
    }

    public void setContactId(Integer contactId) {
        this.contactId = contactId;
    }

    public Integer getCustomerId() {
        return customerId;
    }

    public void setCustomerId(Integer customerId) {
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

    public Boolean getIsPrimary() {
        return isPrimary;
    }

    public void setIsPrimary(Boolean isPrimary) {
        this.isPrimary = isPrimary;
    }
}

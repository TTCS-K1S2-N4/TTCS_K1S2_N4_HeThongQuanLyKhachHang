package com.crm.dto;

public class ProfileUpdateRequest {
    private String fullName;
    private String phone;
    private String emailSignature;

    public ProfileUpdateRequest() {}

    public ProfileUpdateRequest(String fullName, String phone, String emailSignature) {
        this.fullName = fullName;
        this.phone = phone;
        this.emailSignature = emailSignature;
    }

    public String getFullName() {
        return fullName;
    }

    public void setFullName(String fullName) {
        this.fullName = fullName;
    }

    public String getPhone() {
        return phone;
    }

    public void setPhone(String phone) {
        this.phone = phone;
    }

    public String getEmailSignature() {
        return emailSignature;
    }

    public void setEmailSignature(String emailSignature) {
        this.emailSignature = emailSignature;
    }
}

package com.crm.dto;

public class ProfileUpdateRequest {
    private Integer userId;
    private String fullName;
    private String phone;
    private String currentPassword;
    private String newPassword;
    private String confirmPassword;

    public ProfileUpdateRequest() {}

    public ProfileUpdateRequest(Integer userId, String fullName, String phone, String currentPassword, String newPassword, String confirmPassword) {
        this.userId = userId;
        this.fullName = fullName;
        this.phone = phone;
        this.currentPassword = currentPassword;
        this.newPassword = newPassword;
        this.confirmPassword = confirmPassword;
    }

    public Integer getUserId() { return userId; }
    public void setUserId(Integer userId) { this.userId = userId; }

    public String getFullName() { return fullName; }
    public void setFullName(String fullName) { this.fullName = fullName; }

    public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone; }

    public String getCurrentPassword() { return currentPassword; }
    public void setCurrentPassword(String currentPassword) { this.currentPassword = currentPassword; }

    public String getNewPassword() { return newPassword; }
    public void setNewPassword(String newPassword) { this.newPassword = newPassword; }

    public String getConfirmPassword() { return confirmPassword; }
    public void setConfirmPassword(String confirmPassword) { this.confirmPassword = confirmPassword; }
}

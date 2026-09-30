package com.crm.model;

import java.sql.Timestamp;

public class Account {
    private int accountId;
    private String email;
    private String passwordHash;
    private String fullName;
    private String phone;
    private Integer roleId; // LEGACY COMPATIBILITY ONLY
    private String roleName; // LEGACY COMPATIBILITY ONLY
    
    private java.util.List<Integer> roleIds = new java.util.ArrayList<>();
    private java.util.List<String> roleNames = new java.util.ArrayList<>();
    private java.util.List<String> roleCodes = new java.util.ArrayList<>();
    
    private Integer teamId;
    private String teamName;
    private String status;
    private String resetToken;
    private Timestamp resetTokenExpiry;
    private String activationToken;
    private Timestamp activationTokenExpiry;
    private Timestamp createdAt;
    private int failedAttempts;
    private Timestamp lockoutUntil;
    private Timestamp updatedAt;

    public Account() {
    }

    public Account(int accountId, String email, String fullName, String phone, Integer teamId, String teamName,
            String status) {
        this.accountId = accountId;
        this.email = email;
        this.fullName = fullName;
        this.phone = phone;
        this.teamId = teamId;
        this.teamName = teamName;
        this.status = status;
    }

    public int getAccountId() {
        return accountId;
    }

    public void setAccountId(int accountId) {
        this.accountId = accountId;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getPasswordHash() {
        return passwordHash;
    }

    public void setPasswordHash(String passwordHash) {
        this.passwordHash = passwordHash;
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

    // LEGACY COMPATIBILITY ONLY
    public Integer getRoleId() {
        if (roleIds != null && !roleIds.isEmpty()) return roleIds.get(0);
        return roleId;
    }

    public void setRoleId(Integer roleId) {
        this.roleId = roleId;
    }

    // LEGACY COMPATIBILITY ONLY
    public String getRoleName() {
        if (roleNames != null && !roleNames.isEmpty()) return String.join(", ", roleNames);
        return roleName;
    }

    public void setRoleName(String roleName) {
        this.roleName = roleName;
    }

    public java.util.List<Integer> getRoleIds() {
        return roleIds;
    }

    public void setRoleIds(java.util.List<Integer> roleIds) {
        this.roleIds = roleIds != null ? roleIds : new java.util.ArrayList<>();
    }

    public java.util.List<String> getRoleNames() {
        return roleNames;
    }

    public void setRoleNames(java.util.List<String> roleNames) {
        this.roleNames = roleNames != null ? roleNames : new java.util.ArrayList<>();
    }

    public java.util.List<String> getRoleCodes() {
        return roleCodes;
    }

    public void setRoleCodes(java.util.List<String> roleCodes) {
        this.roleCodes = roleCodes != null ? roleCodes : new java.util.ArrayList<>();
    }

    public Integer getTeamId() {
        return teamId;
    }

    public void setTeamId(Integer teamId) {
        this.teamId = teamId;
    }

    public String getTeamName() {
        return teamName;
    }

    public void setTeamName(String teamName) {
        this.teamName = teamName;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getResetToken() {
        return resetToken;
    }

    public void setResetToken(String resetToken) {
        this.resetToken = resetToken;
    }

    public Timestamp getResetTokenExpiry() {
        return resetTokenExpiry;
    }

    public void setResetTokenExpiry(Timestamp resetTokenExpiry) {
        this.resetTokenExpiry = resetTokenExpiry;
    }

    public String getActivationToken() {
        return activationToken;
    }

    public void setActivationToken(String activationToken) {
        this.activationToken = activationToken;
    }

    public Timestamp getActivationTokenExpiry() {
        return activationTokenExpiry;
    }

    public void setActivationTokenExpiry(Timestamp activationTokenExpiry) {
        this.activationTokenExpiry = activationTokenExpiry;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    public int getFailedAttempts() {
        return failedAttempts;
    }

    public void setFailedAttempts(int failedAttempts) {
        this.failedAttempts = failedAttempts;
    }

    public Timestamp getLockoutUntil() {
        return lockoutUntil;
    }

    public void setLockoutUntil(Timestamp lockoutUntil) {
        this.lockoutUntil = lockoutUntil;
    }

    public Timestamp getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(Timestamp updatedAt) {
        this.updatedAt = updatedAt;
    }
}
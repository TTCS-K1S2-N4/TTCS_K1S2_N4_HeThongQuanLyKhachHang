package com.crm.dto;

public class AccountCreateRequest {
    private String email;
    private String password;
    private String fullName;
    private String phone;
    private Integer roleId; // Legacy
    private java.util.List<Integer> roleIds;
    private Integer teamId;

    public AccountCreateRequest() {}

    public AccountCreateRequest(String email, String password, String fullName, String phone, Integer roleId, Integer teamId) {
        this.email = email;
        this.password = password;
        this.fullName = fullName;
        this.phone = phone;
        this.roleId = roleId;
        this.teamId = teamId;
    }

    public AccountCreateRequest(String email, String password, String fullName, String phone, java.util.List<Integer> roleIds, Integer teamId) {
        this.email = email;
        this.password = password;
        this.fullName = fullName;
        this.phone = phone;
        this.roleIds = roleIds;
        if (roleIds != null && !roleIds.isEmpty()) this.roleId = roleIds.get(0);
        this.teamId = teamId;
    }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }

    public String getFullName() { return fullName; }
    public void setFullName(String fullName) { this.fullName = fullName; }

    public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone; }

    public Integer getTeamId() { return teamId; }
    public void setTeamId(Integer teamId) { this.teamId = teamId; }

    public Integer getRoleId() { 
        if (roleIds != null && !roleIds.isEmpty()) return roleIds.get(0);
        return roleId; 
    }
    public void setRoleId(Integer roleId) { this.roleId = roleId; }

    public java.util.List<Integer> getRoleIds() { return roleIds; }
    public void setRoleIds(java.util.List<Integer> roleIds) { this.roleIds = roleIds; }
}


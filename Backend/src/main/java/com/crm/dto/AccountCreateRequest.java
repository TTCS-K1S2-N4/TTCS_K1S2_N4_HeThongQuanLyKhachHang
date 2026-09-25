package com.crm.dto;

public class AccountCreateRequest {
    private String email;
    private String password;
    private String fullName;
    private String phone;
    private Integer teamId;

    public AccountCreateRequest() {}

    public AccountCreateRequest(String email, String password, String fullName, String phone, Integer teamId) {
        this.email = email;
        this.password = password;
        this.fullName = fullName;
        this.phone = phone;
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
}


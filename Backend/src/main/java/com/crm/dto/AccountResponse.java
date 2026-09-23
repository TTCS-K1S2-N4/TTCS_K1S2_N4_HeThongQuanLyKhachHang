package com.crm.dto;

public class AccountResponse {
    private int accountId;
    private String email;
    private String fullName;
    private String phone;
    private Integer teamId;
    private String teamName;
    private String status;

    public AccountResponse() {}

    public AccountResponse(int accountId, String email, String fullName, String phone, Integer teamId, String teamName, String status) {
        this.accountId = accountId;
        this.email = email;
        this.fullName = fullName;
        this.phone = phone;
        this.teamId = teamId;
        this.teamName = teamName;
        this.status = status;
    }

    public int getAccountId() { return accountId; }
    public void setAccountId(int accountId) { this.accountId = accountId; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getFullName() { return fullName; }
    public void setFullName(String fullName) { this.fullName = fullName; }

    public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone; }

    public Integer getTeamId() { return teamId; }
    public void setTeamId(Integer teamId) { this.teamId = teamId; }

    public String getTeamName() { return teamName; }
    public void setTeamName(String teamName) { this.teamName = teamName; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
}

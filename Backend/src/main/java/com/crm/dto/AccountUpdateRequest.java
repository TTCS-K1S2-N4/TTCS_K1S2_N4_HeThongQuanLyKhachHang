package com.crm.dto;

public class AccountUpdateRequest {
    private int accountId;
    private String fullName;
    private String phone;
    private Integer teamId;

    public AccountUpdateRequest() {}

    public AccountUpdateRequest(int accountId, String fullName, String phone, Integer teamId) {
        this.accountId = accountId;
        this.fullName = fullName;
        this.phone = phone;
        this.teamId = teamId;
    }

    public int getAccountId() { return accountId; }
    public void setAccountId(int accountId) { this.accountId = accountId; }

    public String getFullName() { return fullName; }
    public void setFullName(String fullName) { this.fullName = fullName; }

    public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone; }

    public Integer getTeamId() { return teamId; }
    public void setTeamId(Integer teamId) { this.teamId = teamId; }
}

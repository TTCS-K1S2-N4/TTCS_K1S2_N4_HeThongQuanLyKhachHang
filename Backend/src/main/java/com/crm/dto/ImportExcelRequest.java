package com.crm.dto;

public class ImportExcelRequest {
    private String fullName;
    private String email;
    private String phone;
    private Integer teamId;
    
    // For storing validation errors
    private String error;

    public ImportExcelRequest() {}

    public String getFullName() {
        return fullName;
    }

    public void setFullName(String fullName) {
        this.fullName = fullName;
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

    public Integer getTeamId() {
        return teamId;
    }

    public void setTeamId(Integer teamId) {
        this.teamId = teamId;
    }

    public String getError() {
        return error;
    }

    public void setError(String error) {
        this.error = error;
    }
    
    public boolean isValid() {
        return error == null || error.isEmpty();
    }
}

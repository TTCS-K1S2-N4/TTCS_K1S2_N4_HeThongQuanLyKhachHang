package com.crm.dto;

/**
 * LeadConversionRequest - DTO chứa thông tin yêu cầu chuyển đổi Lead thành Customer, Contact, Opportunity (S4-08).
 */
public class LeadConversionRequest {
    private Integer leadId;
    private String opportunityName;
    private Double expectedRevenue;
    private Integer accountId; // Tái sử dụng Customer có sẵn (nếu có)

    public LeadConversionRequest() {}

    public LeadConversionRequest(Integer leadId, String opportunityName) {
        this.leadId = leadId;
        this.opportunityName = opportunityName;
    }

    public LeadConversionRequest(Integer leadId, String opportunityName, Integer accountId) {
        this.leadId = leadId;
        this.opportunityName = opportunityName;
        this.accountId = accountId;
    }

    public LeadConversionRequest(Integer leadId, String opportunityName, Double expectedRevenue, Integer accountId) {
        this.leadId = leadId;
        this.opportunityName = opportunityName;
        this.expectedRevenue = expectedRevenue;
        this.accountId = accountId;
    }

    public Integer getLeadId() { return leadId; }
    public void setLeadId(Integer leadId) { this.leadId = leadId; }

    public String getOpportunityName() { return opportunityName; }
    public void setOpportunityName(String opportunityName) { this.opportunityName = opportunityName; }

    public Double getExpectedRevenue() { return expectedRevenue; }
    public void setExpectedRevenue(Double expectedRevenue) { this.expectedRevenue = expectedRevenue; }

    public Integer getAccountId() { return accountId; }
    public void setAccountId(Integer accountId) { this.accountId = accountId; }

    public boolean isValid() {
        return leadId != null && leadId > 0;
    }
}

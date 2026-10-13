package com.crm.dto;

public class LeadConversionRequest {
    private Integer leadId;
    private String opportunityName;
    private Double expectedRevenue;
    private Integer accountId; // If associating with existing Customer
    
    // Default constructor
    public LeadConversionRequest() {}

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

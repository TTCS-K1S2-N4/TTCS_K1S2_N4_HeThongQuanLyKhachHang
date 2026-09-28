package com.crm.model;

import java.sql.Timestamp;

public class Opportunity {
    private int opportunityId;
    private String title;
    private Double amount;
    private int ownerId;
    private Timestamp createdAt;

    public int getOpportunityid() { return opportunityId; }
    public void setOpportunityid(int opportunityId) { this.opportunityId = opportunityId; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public Double getAmount() { return amount; }
    public void setAmount(Double amount) { this.amount = amount; }

    public int getOwnerId() { return ownerId; }
    public void setOwnerId(int ownerId) { this.ownerId = ownerId; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }
}

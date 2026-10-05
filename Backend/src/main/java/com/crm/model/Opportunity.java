package com.crm.model;

import java.sql.Timestamp;

public class Opportunity {
    private int opportunityId;
    private String title;
    private Double amount;
    private String stage;
    private String status;
    private int customerId;
    private int ownerId;
    private Timestamp createdAt;
    private Timestamp updatedAt;

    public int getOpportunityid() { return opportunityId; }
    public void setOpportunityid(int opportunityId) { this.opportunityId = opportunityId; }
    public int getOpportunityId() { return opportunityId; }
    public void setOpportunityId(int opportunityId) { this.opportunityId = opportunityId; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public Double getAmount() { return amount; }
    public void setAmount(Double amount) { this.amount = amount; }

    public String getStage() { return stage; }
    public void setStage(String stage) { this.stage = stage; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public int getCustomerId() { return customerId; }
    public void setCustomerId(int customerId) { this.customerId = customerId; }

    public int getOwnerId() { return ownerId; }
    public void setOwnerId(int ownerId) { this.ownerId = ownerId; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public Timestamp getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Timestamp updatedAt) { this.updatedAt = updatedAt; }

    public boolean isOpen() {
        String currentStage = stage != null ? stage.toUpperCase() : (status != null ? status.toUpperCase() : "");
        if (currentStage.contains("WON") || currentStage.contains("LOST") || currentStage.contains("CLOSED")) {
            return false;
        }
        return true;
    }
}


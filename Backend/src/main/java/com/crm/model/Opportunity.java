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
    private Integer pipelineStageId;
    private String stageName;
    private Double probability;
    private Integer winLossReasonId;
    private String reasonName;
    private Integer competitorId;
    private String competitorName;
    private Timestamp closeDate;
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

    public Integer getPipelineStageId() { return pipelineStageId; }
    public void setPipelineStageId(Integer pipelineStageId) { this.pipelineStageId = pipelineStageId; }

    public String getStageName() { return stageName; }
    public void setStageName(String stageName) { this.stageName = stageName; }

    public Double getProbability() { return probability; }
    public void setProbability(Double probability) { this.probability = probability; }

    public Integer getWinLossReasonId() { return winLossReasonId; }
    public void setWinLossReasonId(Integer winLossReasonId) { this.winLossReasonId = winLossReasonId; }

    public String getReasonName() { return reasonName; }
    public void setReasonName(String reasonName) { this.reasonName = reasonName; }

    public Integer getCompetitorId() { return competitorId; }
    public void setCompetitorId(Integer competitorId) { this.competitorId = competitorId; }

    public String getCompetitorName() { return competitorName; }
    public void setCompetitorName(String competitorName) { this.competitorName = competitorName; }

    public Timestamp getCloseDate() { return closeDate; }
    public void setCloseDate(Timestamp closeDate) { this.closeDate = closeDate; }

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


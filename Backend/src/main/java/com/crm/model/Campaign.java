package com.crm.model;

import java.math.BigDecimal;
import java.sql.Date;
import java.sql.Timestamp;

/**
 * Model biểu diễn thông tin Chiến dịch tiếp thị (Campaign).
 * Phục vụ cho Story S4-03: Campaign Tracking.
 */
public class Campaign {
    private int campaignId;
    private String campaignName;
    private BigDecimal budget;
    private Date startDate;
    private Date endDate;
    private String channel;
    private String description;
    private String status;
    private Integer createdBy;
    private String creatorName;
    private Timestamp createdAt;
    private Timestamp updatedAt;

    // Các trường thống kê hiệu quả chiến dịch (S4-03-AC-03)
    private int leadCount;
    private int opportunityCount;
    private BigDecimal closedValue;

    public Campaign() {
        this.budget = BigDecimal.ZERO;
        this.status = "PLANNING";
        this.closedValue = BigDecimal.ZERO;
    }

    public Campaign(int campaignId, String campaignName, BigDecimal budget, Date startDate, Date endDate, String channel) {
        this.campaignId = campaignId;
        this.campaignName = campaignName;
        this.budget = budget != null ? budget : BigDecimal.ZERO;
        this.startDate = startDate;
        this.endDate = endDate;
        this.channel = channel;
        this.status = "PLANNING";
        this.closedValue = BigDecimal.ZERO;
    }

    public int getCampaignId() {
        return campaignId;
    }

    public void setCampaignId(int campaignId) {
        this.campaignId = campaignId;
    }

    // Alias cho name để linh hoạt tương thích FE/contract
    public String getName() {
        return campaignName;
    }

    public void setName(String name) {
        this.campaignName = name;
    }

    public String getCampaignName() {
        return campaignName;
    }

    public void setCampaignName(String campaignName) {
        this.campaignName = campaignName;
    }

    public BigDecimal getBudget() {
        return budget;
    }

    public void setBudget(BigDecimal budget) {
        this.budget = budget != null ? budget : BigDecimal.ZERO;
    }

    public Date getStartDate() {
        return startDate;
    }

    public void setStartDate(Date startDate) {
        this.startDate = startDate;
    }

    public Date getEndDate() {
        return endDate;
    }

    public void setEndDate(Date endDate) {
        this.endDate = endDate;
    }

    public String getChannel() {
        return channel;
    }

    public void setChannel(String channel) {
        this.channel = channel;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public Integer getCreatedBy() {
        return createdBy;
    }

    public void setCreatedBy(Integer createdBy) {
        this.createdBy = createdBy;
    }

    public String getCreatorName() {
        return creatorName;
    }

    public void setCreatorName(String creatorName) {
        this.creatorName = creatorName;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    public Timestamp getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(Timestamp updatedAt) {
        this.updatedAt = updatedAt;
    }

    public int getLeadCount() {
        return leadCount;
    }

    public void setLeadCount(int leadCount) {
        this.leadCount = leadCount;
    }

    public int getOpportunityCount() {
        return opportunityCount;
    }

    public void setOpportunityCount(int opportunityCount) {
        this.opportunityCount = opportunityCount;
    }

    public BigDecimal getClosedValue() {
        return closedValue;
    }

    public void setClosedValue(BigDecimal closedValue) {
        this.closedValue = closedValue != null ? closedValue : BigDecimal.ZERO;
    }
}

package com.crm.model;

import java.sql.Timestamp;

public class Activity {
    private int activityId;
    private String title;
    private String description;
    private String activityType;
    private int customerId;
    private int ownerId;
    private Timestamp createdAt;
    private Timestamp updatedAt;

    public int getActivityid() { return activityId; }
    public void setActivityid(int activityId) { this.activityId = activityId; }
    public int getActivityId() { return activityId; }
    public void setActivityId(int activityId) { this.activityId = activityId; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public String getActivityType() { return activityType; }
    public void setActivityType(String activityType) { this.activityType = activityType; }
    public String getType() { return activityType; }
    public void setType(String type) { this.activityType = type; }

    public int getCustomerId() { return customerId; }
    public void setCustomerId(int customerId) { this.customerId = customerId; }

    public int getOwnerId() { return ownerId; }
    public void setOwnerId(int ownerId) { this.ownerId = ownerId; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public Timestamp getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Timestamp updatedAt) { this.updatedAt = updatedAt; }
}


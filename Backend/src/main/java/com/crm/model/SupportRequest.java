package com.crm.model;

import java.sql.Timestamp;

/**
 * Model đại diện cho Yêu cầu hỗ trợ sau bán (Support Request).
 * Task S30-09 / S3-08.
 */
public class SupportRequest {
    private int requestId;
    private int customerId;
    private String title;
    private String description;
    private String priority; // LOW, MEDIUM, HIGH, URGENT
    private String status;   // OPEN, IN_PROGRESS, RESOLVED, CLOSED
    private Integer assigneeId;
    private String assigneeName;
    private Integer createdBy;
    private Timestamp createdAt;
    private Timestamp updatedAt;

    public SupportRequest() {
    }

    public SupportRequest(int requestId, int customerId, String title, String description,
                          String priority, String status, Integer assigneeId) {
        this.requestId = requestId;
        this.customerId = customerId;
        this.title = title;
        this.description = description;
        this.priority = priority;
        this.status = status;
        this.assigneeId = assigneeId;
    }

    public int getRequestId() {
        return requestId;
    }

    public void setRequestId(int requestId) {
        this.requestId = requestId;
    }

    public int getCustomerId() {
        return customerId;
    }

    public void setCustomerId(int customerId) {
        this.customerId = customerId;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getPriority() {
        return priority;
    }

    public void setPriority(String priority) {
        this.priority = priority;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public Integer getAssigneeId() {
        return assigneeId;
    }

    public void setAssigneeId(Integer assigneeId) {
        this.assigneeId = assigneeId;
    }

    public String getAssigneeName() {
        return assigneeName;
    }

    public void setAssigneeName(String assigneeName) {
        this.assigneeName = assigneeName;
    }

    public Integer getCreatedBy() {
        return createdBy;
    }

    public void setCreatedBy(Integer createdBy) {
        this.createdBy = createdBy;
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
}

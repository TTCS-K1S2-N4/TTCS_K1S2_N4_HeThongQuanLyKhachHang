package com.crm.dto;

import java.sql.Timestamp;

/**
 * DTO đại diện cho Yêu cầu hỗ trợ sau bán (Support Request).
 * Task S30-09 / S3-08.
 */
public class SupportRequestDto {
    private Integer requestId;
    private Integer customerId;
    private String title;
    private String description;
    private String priority; // LOW, MEDIUM, HIGH, URGENT
    private Integer assigneeId;
    private String assigneeName;
    private String status;   // OPEN, IN_PROGRESS, RESOLVED, CLOSED
    private Timestamp createdAt;

    public SupportRequestDto() {
    }

    public SupportRequestDto(Integer customerId, String title, String description, String priority, Integer assigneeId, String status) {
        this.customerId = customerId;
        this.title = title;
        this.description = description;
        this.priority = priority;
        this.assigneeId = assigneeId;
        this.status = status;
    }

    public Integer getRequestId() {
        return requestId;
    }

    public void setRequestId(Integer requestId) {
        this.requestId = requestId;
    }

    public Integer getCustomerId() {
        return customerId;
    }

    public void setCustomerId(Integer customerId) {
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

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }
}

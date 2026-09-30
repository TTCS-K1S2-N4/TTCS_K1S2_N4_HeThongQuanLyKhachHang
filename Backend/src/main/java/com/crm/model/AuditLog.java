package com.crm.model;

import java.sql.Timestamp;

public class AuditLog {
    private int logId;
    private int userId; // performed_by
    private String performedByName;
    private int targetUserId; // entity_id
    private String action; // action_type
    private String entityType;
    private String details; // description
    private String oldValue;
    private String newValue;
    private Timestamp createdAt;

    public AuditLog() {}

    public AuditLog(int userId, int targetUserId, String action, String details) {
        this.userId = userId;
        this.targetUserId = targetUserId;
        this.action = action;
        this.details = details;
    }

    public int getLogId() { return logId; }
    public void setLogId(int logId) { this.logId = logId; }

    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }

    public String getPerformedByName() { return performedByName; }
    public void setPerformedByName(String performedByName) { this.performedByName = performedByName; }

    public int getTargetUserId() { return targetUserId; }
    public void setTargetUserId(int targetUserId) { this.targetUserId = targetUserId; }

    public int getEntityId() { return targetUserId; }
    public void setEntityId(int entityId) { this.targetUserId = entityId; }

    public String getAction() { return action; }
    public void setAction(String action) { this.action = action; }

    public String getEntityType() { 
        if (entityType != null && !entityType.trim().isEmpty()) return entityType;
        if (action != null) {
            String upper = action.toUpperCase();
            if (upper.contains("DISCOUNT")) return "DISCOUNT";
            if (upper.contains("KPI") || upper.contains("TARGET")) return "KPI";
            if (upper.contains("OWNER") || upper.contains("TRANSFER")) return "DATA_OWNERSHIP";
            if (upper.contains("ROLE") || upper.contains("ASSIGN")) return "USER_ROLE";
        }
        return "SYSTEM";
    }
    public void setEntityType(String entityType) { this.entityType = entityType; }

    public String getDetails() { return details; }
    public void setDetails(String details) { this.details = details; }

    public String getOldValue() { return oldValue; }
    public void setOldValue(String oldValue) { this.oldValue = oldValue; }

    public String getNewValue() { return newValue; }
    public void setNewValue(String newValue) { this.newValue = newValue; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }
}


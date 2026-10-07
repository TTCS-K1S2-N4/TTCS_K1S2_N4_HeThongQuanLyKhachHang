package com.crm.model;

import java.sql.Timestamp;

public class AuditLog {
    private int logId;
    private int userId; // performed_by
    private String performedByName;
    private int targetUserId; // entity_id
    private String targetEntityName;
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

    public String getTargetEntityName() { return targetEntityName; }
    public void setTargetEntityName(String targetEntityName) { this.targetEntityName = targetEntityName; }

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

    public String getEntityTypeDisplay() {
        String type = getEntityType();
        if (type == null) return "-";
        switch (type.toUpperCase()) {
            case "DISCOUNT": return "Chiết khấu";
            case "KPI": return "KPI/Mục tiêu";
            case "DATA_OWNERSHIP": return "Sở hữu dữ liệu";
            case "USER_ROLE": return "Vai trò người dùng";
            case "SYSTEM": return "Hệ thống";
            default: return type;
        }
    }

    public String getActionDisplay() {
        if (action == null) return "-";
        switch (action.toUpperCase()) {
            case "DISCOUNT_CREATE": return "Tạo mới chiết khấu";
            case "DISCOUNT_UPDATE": return "Cập nhật chiết khấu";
            case "DISCOUNT_STATUS_CHANGE": return "Đổi trạng thái chiết khấu";
            case "TARGET_UPDATE": return "Cập nhật KPI/Mục tiêu";
            case "USER_ROLE_UPDATE": return "Cập nhật vai trò";
            case "ASSIGN_ROLE": return "Gán vai trò";
            case "DATA_OWNERSHIP_TRANSFER": return "Bàn giao dữ liệu";
            case "LOGIN_TEMP_LOCK": return "Khóa đăng nhập tạm thời";
            case "ACCOUNT_LOCK": return "Khóa tài khoản";
            case "ACCOUNT_UNLOCK": return "Mở khóa tài khoản";
            default: return action;
        }
    }
    public String getDetails() { return details; }
    public void setDetails(String details) { this.details = details; }

    public String getOldValue() { return oldValue; }
    public void setOldValue(String oldValue) { this.oldValue = oldValue; }

    public String getNewValue() { return newValue; }
    public void setNewValue(String newValue) { this.newValue = newValue; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public String getFormattedCreatedAt() {
        if (createdAt == null) return "-";
        java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
        sdf.setTimeZone(java.util.TimeZone.getTimeZone("Asia/Ho_Chi_Minh"));
        return sdf.format(createdAt);
    }
}


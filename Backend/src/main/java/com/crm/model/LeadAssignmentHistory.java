package com.crm.model;

import java.sql.Timestamp;

public class LeadAssignmentHistory {
    private int historyId;
    private int leadId;
    private Integer ruleId;
    private Integer assignedTo;
    private String status;
    private Timestamp assignedAt;
    private String rejectReason;

    public int getHistoryId() { return historyId; }
    public void setHistoryId(int historyId) { this.historyId = historyId; }

    public int getLeadId() { return leadId; }
    public void setLeadId(int leadId) { this.leadId = leadId; }

    public Integer getRuleId() { return ruleId; }
    public void setRuleId(Integer ruleId) { this.ruleId = ruleId; }

    public Integer getAssignedTo() { return assignedTo; }
    public void setAssignedTo(Integer assignedTo) { this.assignedTo = assignedTo; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public Timestamp getAssignedAt() { return assignedAt; }
    public void setAssignedAt(Timestamp assignedAt) { this.assignedAt = assignedAt; }

    public String getRejectReason() { return rejectReason; }
    public void setRejectReason(String rejectReason) { this.rejectReason = rejectReason; }
}

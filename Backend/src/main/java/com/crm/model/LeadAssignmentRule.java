package com.crm.model;

import java.sql.Timestamp;

public class LeadAssignmentRule {
    private int ruleId;
    private int priority;
    private String criterion;
    private String criterionValue;
    private Integer teamId;
    private Integer assigneeId;
    private boolean isActive;
    private Timestamp createdAt;
    private Timestamp updatedAt;

    public int getRuleId() { return ruleId; }
    public void setRuleId(int ruleId) { this.ruleId = ruleId; }

    public int getPriority() { return priority; }
    public void setPriority(int priority) { this.priority = priority; }

    public String getCriterion() { return criterion; }
    public void setCriterion(String criterion) { this.criterion = criterion; }

    public String getCriterionValue() { return criterionValue; }
    public void setCriterionValue(String criterionValue) { this.criterionValue = criterionValue; }

    public Integer getTeamId() { return teamId; }
    public void setTeamId(Integer teamId) { this.teamId = teamId; }

    public Integer getAssigneeId() { return assigneeId; }
    public void setAssigneeId(Integer assigneeId) { this.assigneeId = assigneeId; }

    public boolean isActive() { return isActive; }
    public void setActive(boolean active) { isActive = active; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public Timestamp getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Timestamp updatedAt) { this.updatedAt = updatedAt; }
}

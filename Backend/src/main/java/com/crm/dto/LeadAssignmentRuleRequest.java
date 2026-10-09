package com.crm.dto;

public class LeadAssignmentRuleRequest {
    private int priority;
    private String criterion;
    private String criterionValue;
    private Integer teamId;
    private Integer assigneeId;

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
}

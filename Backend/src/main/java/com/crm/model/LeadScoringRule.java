package com.crm.model;

import java.sql.Timestamp;

/**
 * Model đại diện cho Quy tắc Chấm điểm Lead (Lead Scoring Rule).
 * Đáp ứng nghiệp vụ S4-05: Khai báo tiêu chí ngành nghề, quy mô, nguồn, mức độ quan tâm.
 */
public class LeadScoringRule {

    private int ruleId;
    private String criterion;      // INDUSTRY, COMPANY_SIZE, SOURCE, INTEREST
    private String operator;       // EQUALS, CONTAINS
    private String conditionValue; // Giá trị điều kiện so khớp
    private int score;             // Điểm cộng hoặc trừ
    private boolean isActive = true;
    private Timestamp createdAt;
    private Timestamp updatedAt;

    public LeadScoringRule() {
    }

    public LeadScoringRule(String criterion, String operator, String conditionValue, int score) {
        this.criterion = criterion;
        this.operator = operator;
        this.conditionValue = conditionValue;
        this.score = score;
        this.isActive = true;
    }

    public int getRuleId() {
        return ruleId;
    }

    public void setRuleId(int ruleId) {
        this.ruleId = ruleId;
    }

    public String getCriterion() {
        return criterion;
    }

    public void setCriterion(String criterion) {
        this.criterion = criterion;
    }

    public String getOperator() {
        return operator != null ? operator : "EQUALS";
    }

    public void setOperator(String operator) {
        this.operator = operator;
    }

    public String getConditionValue() {
        return conditionValue;
    }

    public void setConditionValue(String conditionValue) {
        this.conditionValue = conditionValue;
    }

    public int getScore() {
        return score;
    }

    public void setScore(int score) {
        this.score = score;
    }

    public boolean isActive() {
        return isActive;
    }

    public void setActive(boolean active) {
        isActive = active;
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

    @Override
    public String toString() {
        return "LeadScoringRule{" +
                "ruleId=" + ruleId +
                ", criterion='" + criterion + '\'' +
                ", operator='" + operator + '\'' +
                ", conditionValue='" + conditionValue + '\'' +
                ", score=" + score +
                ", isActive=" + isActive +
                '}';
    }
}

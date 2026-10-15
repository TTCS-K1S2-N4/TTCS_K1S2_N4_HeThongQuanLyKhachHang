package com.crm.dto;

/**
 * DTO nhận dữ liệu yêu cầu thêm/sửa quy tắc chấm điểm Lead (S4-05).
 */
public class LeadScoringRuleRequest {

    private Integer ruleId;
    private String criterion;
    private String operator;
    private String conditionValue;
    private Integer score;
    private Boolean isActive;

    public LeadScoringRuleRequest() {
    }

    public LeadScoringRuleRequest(String criterion, String operator, String conditionValue, Integer score) {
        this.criterion = criterion;
        this.operator = operator;
        this.conditionValue = conditionValue;
        this.score = score;
    }

    public Integer getRuleId() {
        return ruleId;
    }

    public void setRuleId(Integer ruleId) {
        this.ruleId = ruleId;
    }

    public String getCriterion() {
        return criterion;
    }

    public void setCriterion(String criterion) {
        this.criterion = criterion;
    }

    public String getOperator() {
        return operator != null && !operator.trim().isEmpty() ? operator.trim() : "EQUALS";
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

    public Integer getScore() {
        return score;
    }

    public void setScore(Integer score) {
        this.score = score;
    }

    public Boolean getIsActive() {
        return isActive;
    }

    public void setIsActive(Boolean active) {
        isActive = active;
    }

    public boolean isValid() {
        return criterion != null && !criterion.trim().isEmpty()
                && conditionValue != null && !conditionValue.trim().isEmpty()
                && score != null;
    }

    public String getValidationErrorMessage() {
        if (criterion == null || criterion.trim().isEmpty()) {
            return "Vui lòng chọn tiêu chí chấm điểm (Ngành nghề, Quy mô, Nguồn, Mức độ quan tâm).";
        }
        if (conditionValue == null || conditionValue.trim().isEmpty()) {
            return "Giá trị điều kiện so khớp không được để trống.";
        }
        if (score == null) {
            return "Số điểm cộng/trừ phải là số nguyên hợp lệ.";
        }
        return null;
    }
}

package com.crm.dto;

import java.util.ArrayList;
import java.util.List;

/**
 * DTO trả về kết quả chấm điểm và phân loại Lead (S4-05).
 */
public class LeadScoreResponse {

    private int leadId;
    private String fullName;
    private String company;
    private int score;
    private String classification; // HOT, WARM, COLD
    private List<String> matchedRuleDescriptions = new ArrayList<>();

    public LeadScoreResponse() {
    }

    public LeadScoreResponse(int leadId, String fullName, String company, int score, String classification) {
        this.leadId = leadId;
        this.fullName = fullName;
        this.company = company;
        this.score = score;
        this.classification = classification;
    }

    public int getLeadId() {
        return leadId;
    }

    public void setLeadId(int leadId) {
        this.leadId = leadId;
    }

    public String getFullName() {
        return fullName;
    }

    public void setFullName(String fullName) {
        this.fullName = fullName;
    }

    public String getCompany() {
        return company;
    }

    public void setCompany(String company) {
        this.company = company;
    }

    public int getScore() {
        return score;
    }

    public void setScore(int score) {
        this.score = score;
    }

    public String getClassification() {
        return classification;
    }

    public void setClassification(String classification) {
        this.classification = classification;
    }

    public List<String> getMatchedRuleDescriptions() {
        return matchedRuleDescriptions;
    }

    public void setMatchedRuleDescriptions(List<String> matchedRuleDescriptions) {
        this.matchedRuleDescriptions = matchedRuleDescriptions;
    }

    public void addMatchedRule(String description) {
        if (this.matchedRuleDescriptions == null) {
            this.matchedRuleDescriptions = new ArrayList<>();
        }
        this.matchedRuleDescriptions.add(description);
    }
}

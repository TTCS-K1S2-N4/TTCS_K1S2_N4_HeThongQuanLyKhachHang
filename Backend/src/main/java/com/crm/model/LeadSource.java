package com.crm.model;

import java.sql.Timestamp;

public class LeadSource {
    private int sourceId;
    private String sourceCode;
    private String sourceName;
    private String description;
    private boolean active;
    private Timestamp createdAt;

    public LeadSource() {}

    public LeadSource(int sourceId, String sourceCode, String sourceName, String description, boolean active) {
        this.sourceId = sourceId;
        this.sourceCode = sourceCode;
        this.sourceName = sourceName;
        this.description = description;
        this.active = active;
    }

    public int getSourceId() {
        return sourceId;
    }

    public void setSourceId(int sourceId) {
        this.sourceId = sourceId;
    }

    public String getSourceCode() {
        return sourceCode;
    }

    public void setSourceCode(String sourceCode) {
        this.sourceCode = sourceCode;
    }

    public String getSourceName() {
        return sourceName;
    }

    public void setSourceName(String sourceName) {
        this.sourceName = sourceName;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public boolean isActive() {
        return active;
    }

    public void setActive(boolean active) {
        this.active = active;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }
}

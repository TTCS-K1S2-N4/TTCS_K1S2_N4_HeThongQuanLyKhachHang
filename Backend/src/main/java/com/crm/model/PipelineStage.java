package com.crm.model;

import java.sql.Timestamp;

public class PipelineStage {
    private int pipelineStageId;
    private String stageName;
    private int displayOrder;
    private double defaultProbability;
    private String exitCondition;
    private String status;
    private Timestamp createdAt;
    private Timestamp updatedAt;

    public PipelineStage() {
    }

    public int getPipelineStageId() {
        return pipelineStageId;
    }

    public void setPipelineStageId(int pipelineStageId) {
        this.pipelineStageId = pipelineStageId;
    }

    public String getStageName() {
        return stageName;
    }

    public void setStageName(String stageName) {
        this.stageName = stageName;
    }

    public int getDisplayOrder() {
        return displayOrder;
    }

    public void setDisplayOrder(int displayOrder) {
        this.displayOrder = displayOrder;
    }

    public double getDefaultProbability() {
        return defaultProbability;
    }

    public void setDefaultProbability(double defaultProbability) {
        this.defaultProbability = defaultProbability;
    }

    public String getExitCondition() {
        return exitCondition;
    }

    public void setExitCondition(String exitCondition) {
        this.exitCondition = exitCondition;
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

    public Timestamp getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(Timestamp updatedAt) {
        this.updatedAt = updatedAt;
    }
}

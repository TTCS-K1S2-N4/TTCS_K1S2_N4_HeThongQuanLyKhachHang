package com.crm.model;

/**
 * Model đại diện cho Rủi ro rời bỏ của Khách hàng (Churn Risk).
 * Task S30-09 / S3-08.
 */
public class CustomerRisk {
    private int customerId;
    private boolean riskFlag;
    private String riskReason;
    private int pendingTicketCount;
    private int threshold;

    public CustomerRisk() {
    }

    public CustomerRisk(int customerId, boolean riskFlag, String riskReason, int pendingTicketCount, int threshold) {
        this.customerId = customerId;
        this.riskFlag = riskFlag;
        this.riskReason = riskReason;
        this.pendingTicketCount = pendingTicketCount;
        this.threshold = threshold;
    }

    public int getCustomerId() {
        return customerId;
    }

    public void setCustomerId(int customerId) {
        this.customerId = customerId;
    }

    public boolean isRiskFlag() {
        return riskFlag;
    }

    public void setRiskFlag(boolean riskFlag) {
        this.riskFlag = riskFlag;
    }

    public String getRiskReason() {
        return riskReason;
    }

    public void setRiskReason(String riskReason) {
        this.riskReason = riskReason;
    }

    public int getPendingTicketCount() {
        return pendingTicketCount;
    }

    public void setPendingTicketCount(int pendingTicketCount) {
        this.pendingTicketCount = pendingTicketCount;
    }

    public int getThreshold() {
        return threshold;
    }

    public void setThreshold(int threshold) {
        this.threshold = threshold;
    }
}

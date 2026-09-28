package com.crm.model;

import java.sql.Timestamp;

public class Quote {
    private int quoteId;
    private String quoteNumber;
    private int ownerId;
    private Timestamp createdAt;

    public int getQuoteid() { return quoteId; }
    public void setQuoteid(int quoteId) { this.quoteId = quoteId; }

    public String getQuotenumber() { return quoteNumber; }
    public void setQuotenumber(String quoteNumber) { this.quoteNumber = quoteNumber; }

    public int getOwnerId() { return ownerId; }
    public void setOwnerId(int ownerId) { this.ownerId = ownerId; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }
}

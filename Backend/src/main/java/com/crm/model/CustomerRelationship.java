package com.crm.model;

import java.sql.Timestamp;

public class CustomerRelationship {
    private int relationshipId;
    private int parentCustomerId;
    private int childCustomerId;
    private String relationshipType;
    private Timestamp createdAt;

    // For JOIN results
    private Customer parentCustomer;
    private Customer childCustomer;

    public int getRelationshipId() { return relationshipId; }
    public void setRelationshipId(int relationshipId) { this.relationshipId = relationshipId; }

    public int getParentCustomerId() { return parentCustomerId; }
    public void setParentCustomerId(int parentCustomerId) { this.parentCustomerId = parentCustomerId; }

    public int getChildCustomerId() { return childCustomerId; }
    public void setChildCustomerId(int childCustomerId) { this.childCustomerId = childCustomerId; }

    public String getRelationshipType() { return relationshipType; }
    public void setRelationshipType(String relationshipType) { this.relationshipType = relationshipType; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public Customer getParentCustomer() { return parentCustomer; }
    public void setParentCustomer(Customer parentCustomer) { this.parentCustomer = parentCustomer; }

    public Customer getChildCustomer() { return childCustomer; }
    public void setChildCustomer(Customer childCustomer) { this.childCustomer = childCustomer; }
}

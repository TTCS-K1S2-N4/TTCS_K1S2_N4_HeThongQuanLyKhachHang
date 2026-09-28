package com.crm.model;

import java.sql.Timestamp;

public class Customer {
    private int customerId;
    private String customerName;
    private String phone;
    private int ownerId;
    private Timestamp createdAt;

    public int getCustomerid() { return customerId; }
    public void setCustomerid(int customerId) { this.customerId = customerId; }

    public String getCustomername() { return customerName; }
    public void setCustomername(String customerName) { this.customerName = customerName; }

    public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone; }

    public int getOwnerId() { return ownerId; }
    public void setOwnerId(int ownerId) { this.ownerId = ownerId; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }
}

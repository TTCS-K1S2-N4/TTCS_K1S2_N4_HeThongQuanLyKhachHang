package com.crm.dto;

import java.sql.Timestamp;

/**
 * DTO trả về thông tin danh sách chăm sóc khách hàng định kỳ N ngày.
 * Task S30-10 / S3-09.
 */
public class CustomerCareResponse {
    private int customerId;
    private String customerName;
    private String phone;
    private int ownerId;
    private String ownerName;
    private Timestamp lastContactedAt;
    private long daysInactive;
    private Double contractValue;
    private String careStatus;

    public CustomerCareResponse() {
    }

    public CustomerCareResponse(int customerId, String customerName, String phone, int ownerId, String ownerName,
                                Timestamp lastContactedAt, long daysInactive, Double contractValue, String careStatus) {
        this.customerId = customerId;
        this.customerName = customerName;
        this.phone = phone;
        this.ownerId = ownerId;
        this.ownerName = ownerName;
        this.lastContactedAt = lastContactedAt;
        this.daysInactive = daysInactive;
        this.contractValue = contractValue;
        this.careStatus = careStatus;
    }

    public int getCustomerId() {
        return customerId;
    }

    public void setCustomerId(int customerId) {
        this.customerId = customerId;
    }

    public String getCustomerName() {
        return customerName;
    }

    public void setCustomerName(String customerName) {
        this.customerName = customerName;
    }

    public String getPhone() {
        return phone;
    }

    public void setPhone(String phone) {
        this.phone = phone;
    }

    public int getOwnerId() {
        return ownerId;
    }

    public void setOwnerId(int ownerId) {
        this.ownerId = ownerId;
    }

    public String getOwnerName() {
        return ownerName;
    }

    public void setOwnerName(String ownerName) {
        this.ownerName = ownerName;
    }

    public Timestamp getLastContactedAt() {
        return lastContactedAt;
    }

    public void setLastContactedAt(Timestamp lastContactedAt) {
        this.lastContactedAt = lastContactedAt;
    }

    public long getDaysInactive() {
        return daysInactive;
    }

    public void setDaysInactive(long daysInactive) {
        this.daysInactive = daysInactive;
    }

    public Double getContractValue() {
        return contractValue;
    }

    public void setContractValue(Double contractValue) {
        this.contractValue = contractValue;
    }

    public String getCareStatus() {
        return careStatus;
    }

    public void setCareStatus(String careStatus) {
        this.careStatus = careStatus;
    }
}

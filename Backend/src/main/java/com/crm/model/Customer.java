package com.crm.model;

import java.sql.Timestamp;

public class Customer {
    private int customerId;
    private String customerName;
    private String taxCode;
    private String phone;
    private String email;
    private String status;
    private String industry;
    private String companySize;
    private String website;
    private String address;
    private String region;
    private int ownerId;
    private Timestamp createdAt;
    private Timestamp updatedAt;

    public int getCustomerid() { return customerId; }
    public void setCustomerid(int customerId) { this.customerId = customerId; }
    public int getCustomerId() { return customerId; }
    public void setCustomerId(int customerId) { this.customerId = customerId; }

    public String getCustomername() { return customerName; }
    public void setCustomername(String customerName) { this.customerName = customerName; }
    public String getCustomerName() { return customerName; }
    public void setCustomerName(String customerName) { this.customerName = customerName; }

    public String getTaxCode() { return taxCode; }
    public void setTaxCode(String taxCode) { this.taxCode = taxCode; }
    public String getTaxcode() { return taxCode; }
    public void setTaxcode(String taxCode) { this.taxCode = taxCode; }

    public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public String getIndustry() { return industry; }
    public void setIndustry(String industry) { this.industry = industry; }

    public String getCompanySize() { return companySize; }
    public void setCompanySize(String companySize) { this.companySize = companySize; }
    public String getSize() { return companySize; }
    public void setSize(String size) { this.companySize = size; }

    public String getWebsite() { return website; }
    public void setWebsite(String website) { this.website = website; }

    public String getAddress() { return address; }
    public void setAddress(String address) { this.address = address; }

    public String getRegion() { return region; }
    public void setRegion(String region) { this.region = region; }

    public int getOwnerId() { return ownerId; }
    public void setOwnerId(int ownerId) { this.ownerId = ownerId; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public Timestamp getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Timestamp updatedAt) { this.updatedAt = updatedAt; }
}

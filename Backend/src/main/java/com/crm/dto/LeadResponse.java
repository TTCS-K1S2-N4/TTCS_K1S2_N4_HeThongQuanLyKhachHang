package com.crm.dto;

import com.crm.model.Lead;

import java.sql.Timestamp;

public class LeadResponse {
    private int leadId;
    private String fullName;
    private String firstName;
    private String lastName;
    private String title;
    private String company;
    private String email;
    private String phone;
    private Integer leadSourceId;
    private String sourceName;
    private Integer webFormId;
    private String webFormName;
    private String status;
    private String rating;
    private int score;
    private String industry;
    private String address;
    private String city;
    private String state;
    private String country;
    private String zipCode;
    private Integer ownerId;
    private String ownerName;
    private String notes;
    private Timestamp createdAt;
    private Timestamp updatedAt;

    public LeadResponse() {}

    public static LeadResponse fromModel(Lead lead) {
        if (lead == null) return null;
        LeadResponse res = new LeadResponse();
        res.setLeadId(lead.getLeadId());
        res.setFullName(lead.getFullName());
        res.setFirstName(lead.getFirstName());
        res.setLastName(lead.getLastName());
        res.setTitle(lead.getTitle());
        res.setCompany(lead.getCompany());
        res.setEmail(lead.getEmail());
        res.setPhone(lead.getPhone());
        res.setLeadSourceId(lead.getLeadSourceId());
        res.setSourceName(lead.getSourceName());
        res.setWebFormId(lead.getWebFormId());
        res.setWebFormName(lead.getWebFormName());
        res.setStatus(lead.getStatus());
        res.setRating(lead.getRating());
        res.setScore(lead.getScore());
        res.setIndustry(lead.getIndustry());
        res.setAddress(lead.getAddress());
        res.setCity(lead.getCity());
        res.setState(lead.getState());
        res.setCountry(lead.getCountry());
        res.setZipCode(lead.getZipCode());
        res.setOwnerId(lead.getOwnerId());
        res.setOwnerName(lead.getOwnerName());
        res.setNotes(lead.getNotes());
        res.setCreatedAt(lead.getCreatedAt());
        res.setUpdatedAt(lead.getUpdatedAt());
        return res;
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

    public String getFirstName() {
        return firstName;
    }

    public void setFirstName(String firstName) {
        this.firstName = firstName;
    }

    public String getLastName() {
        return lastName;
    }

    public void setLastName(String lastName) {
        this.lastName = lastName;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getCompany() {
        return company;
    }

    public void setCompany(String company) {
        this.company = company;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getPhone() {
        return phone;
    }

    public void setPhone(String phone) {
        this.phone = phone;
    }

    public Integer getLeadSourceId() {
        return leadSourceId;
    }

    public void setLeadSourceId(Integer leadSourceId) {
        this.leadSourceId = leadSourceId;
    }

    public String getSourceName() {
        return sourceName;
    }

    public void setSourceName(String sourceName) {
        this.sourceName = sourceName;
    }

    public Integer getWebFormId() {
        return webFormId;
    }

    public void setWebFormId(Integer webFormId) {
        this.webFormId = webFormId;
    }

    public String getWebFormName() {
        return webFormName;
    }

    public void setWebFormName(String webFormName) {
        this.webFormName = webFormName;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getRating() {
        return rating;
    }

    public void setRating(String rating) {
        this.rating = rating;
    }

    public int getScore() {
        return score;
    }

    public void setScore(int score) {
        this.score = score;
    }

    public String getIndustry() {
        return industry;
    }

    public void setIndustry(String industry) {
        this.industry = industry;
    }

    public String getAddress() {
        return address;
    }

    public void setAddress(String address) {
        this.address = address;
    }

    public String getCity() {
        return city;
    }

    public void setCity(String city) {
        this.city = city;
    }

    public String getState() {
        return state;
    }

    public void setState(String state) {
        this.state = state;
    }

    public String getCountry() {
        return country;
    }

    public void setCountry(String country) {
        this.country = country;
    }

    public String getZipCode() {
        return zipCode;
    }

    public void setZipCode(String zipCode) {
        this.zipCode = zipCode;
    }

    public Integer getOwnerId() {
        return ownerId;
    }

    public void setOwnerId(Integer ownerId) {
        this.ownerId = ownerId;
    }

    public String getOwnerName() {
        return ownerName;
    }

    public void setOwnerName(String ownerName) {
        this.ownerName = ownerName;
    }

    public String getNotes() {
        return notes;
    }

    public void setNotes(String notes) {
        this.notes = notes;
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

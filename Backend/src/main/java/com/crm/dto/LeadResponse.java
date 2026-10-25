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
    private Integer campaignId;
    private String campaignName;
    private Timestamp assignedAt;
    private Timestamp slaDueDate;
    private String slaStatus;
    private Timestamp createdAt;
    private Timestamp updatedAt;
    private Integer convertedCustomerId;
    private Integer convertedContactId;
    private Integer convertedOpportunityId;

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
        res.setCampaignId(lead.getCampaignId());
        res.setCampaignName(lead.getCampaignName());
        res.setAssignedAt(lead.getAssignedAt());
        res.setSlaDueDate(lead.getSlaDueDate());
        res.setSlaStatus(lead.getSlaStatus());
        res.setSlaOverdue(lead.isOverdue() || "OVERDUE".equalsIgnoreCase(lead.getStatus()) || "OVERDUE".equalsIgnoreCase(lead.getSlaStatus()));
        res.setCreatedAt(lead.getCreatedAt());
        res.setUpdatedAt(lead.getUpdatedAt());
        res.setConvertedCustomerId(lead.getConvertedCustomerId());
        res.setConvertedContactId(lead.getConvertedContactId());
        res.setConvertedOpportunityId(lead.getConvertedOpportunityId());
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

    // JSP / DTO Compatibility Aliases
    public int getId() {
        return leadId;
    }

    public String getInterest() {
        return notes;
    }

    public Object getSource() {
        return new LeadSourceValue(leadSourceId, sourceName);
    }

    public static class LeadSourceValue extends Number implements Comparable<Object> {
        private final Integer id;
        private final String name;

        public LeadSourceValue(Integer id, String name) {
            this.id = id;
            this.name = name;
        }

        public Integer getId() { return id; }
        public String getName() { return name; }

        @Override
        public int intValue() { return id != null ? id : 0; }
        @Override
        public long longValue() { return id != null ? id.longValue() : 0L; }
        @Override
        public float floatValue() { return id != null ? id.floatValue() : 0.0f; }
        @Override
        public double doubleValue() { return id != null ? id.doubleValue() : 0.0; }

        @Override
        public String toString() {
            return name != null && !name.trim().isEmpty() ? name : (id != null ? id.toString() : "");
        }

        @Override
        public boolean equals(Object o) {
            if (this == o) return true;
            if (o == null) return false;
            if (o instanceof Number) {
                return id != null && id.equals(((Number) o).intValue());
            }
            if (o instanceof String) {
                String str = (String) o;
                return (name != null && name.equalsIgnoreCase(str)) || (id != null && id.toString().equals(str));
            }
            if (o instanceof LeadSourceValue) {
                LeadSourceValue other = (LeadSourceValue) o;
                return (id != null && id.equals(other.id)) || (name != null && name.equalsIgnoreCase(other.name));
            }
            return false;
        }

        @Override
        public int hashCode() {
            return id != null ? id.hashCode() : (name != null ? name.hashCode() : 0);
        }

        @Override
        public int compareTo(Object o) {
            if (o instanceof Number) {
                return Integer.compare(this.intValue(), ((Number) o).intValue());
            }
            return this.toString().compareTo(String.valueOf(o));
        }
    }

    private boolean slaOverdue;
    private String classification;

    public boolean isSlaOverdue() {
        return slaOverdue;
    }

    public void setSlaOverdue(boolean slaOverdue) {
        this.slaOverdue = slaOverdue;
    }

    public String getClassification() {
        if (classification != null && !classification.trim().isEmpty()) {
            return classification.trim();
        }
        if (rating != null && !rating.trim().isEmpty()) {
            return rating.trim();
        }
        return score >= 70 ? "HOT" : (score >= 40 ? "WARM" : "COLD");
    }

    public void setClassification(String classification) {
        this.classification = classification;
    }

    public String getCompanyName() {
        return company;
    }

    public Integer getCampaignId() {
        return campaignId;
    }

    public void setCampaignId(Integer campaignId) {
        this.campaignId = campaignId;
    }

    public String getCampaignName() {
        return campaignName;
    }

    public void setCampaignName(String campaignName) {
        this.campaignName = campaignName;
    }

    public Timestamp getAssignedAt() {
        return assignedAt;
    }

    public void setAssignedAt(Timestamp assignedAt) {
        this.assignedAt = assignedAt;
    }

    public Timestamp getSlaDueDate() {
        return slaDueDate;
    }

    public void setSlaDueDate(Timestamp slaDueDate) {
        this.slaDueDate = slaDueDate;
    }

    public String getSlaStatus() {
        return slaStatus;
    }

    public void setSlaStatus(String slaStatus) {
        this.slaStatus = slaStatus;
    }

    public Integer getConvertedCustomerId() {
        return convertedCustomerId;
    }

    public void setConvertedCustomerId(Integer convertedCustomerId) {
        this.convertedCustomerId = convertedCustomerId;
    }

    public Integer getConvertedContactId() {
        return convertedContactId;
    }

    public void setConvertedContactId(Integer convertedContactId) {
        this.convertedContactId = convertedContactId;
    }

    public Integer getConvertedOpportunityId() {
        return convertedOpportunityId;
    }

    public void setConvertedOpportunityId(Integer convertedOpportunityId) {
        this.convertedOpportunityId = convertedOpportunityId;
    }
}



package com.crm.model;

import java.sql.Timestamp;

public class SavedFilter {
    private int filterId;
    private int userId;
    private String filterName;
    private String module = "CUSTOMER";
    private String keyword;
    private String status;
    private String industry;
    private String companySize;
    private String region;
    private Integer ownerId;
    private String filterQuery;
    private boolean isDefault;
    private Timestamp createdAt;
    private Timestamp updatedAt;

    public int getFilterId() { return filterId; }
    public void setFilterId(int filterId) { this.filterId = filterId; }

    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }

    public String getFilterName() { return filterName; }
    public void setFilterName(String filterName) { this.filterName = filterName; }

    public String getModule() { return module; }
    public void setModule(String module) { this.module = module; }

    public String getKeyword() { return keyword; }
    public void setKeyword(String keyword) { this.keyword = keyword; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public String getIndustry() { return industry; }
    public void setIndustry(String industry) { this.industry = industry; }

    public String getCompanySize() { return companySize; }
    public void setCompanySize(String companySize) { this.companySize = companySize; }

    public String getRegion() { return region; }
    public void setRegion(String region) { this.region = region; }

    public Integer getOwnerId() { return ownerId; }
    public void setOwnerId(Integer ownerId) { this.ownerId = ownerId; }

    public String getFilterQuery() { return filterQuery; }
    public void setFilterQuery(String filterQuery) { this.filterQuery = filterQuery; }

    public boolean isDefault() { return isDefault; }
    public void setDefault(boolean isDefault) { this.isDefault = isDefault; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public Timestamp getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Timestamp updatedAt) { this.updatedAt = updatedAt; }
}

package com.crm.model;

import java.sql.Timestamp;

/**
 * Model đại diện cho Bộ lọc Lead được lưu trữ (S4-09-AC-03).
 * Lưu trữ các tiêu chí lọc cá nhân của Nhân viên kinh doanh để áp dụng nhanh.
 */
public class LeadSavedFilter {

    private int filterId;
    private int userId;
    private String filterName;
    private String module = "LEAD";
    private String keyword;
    private String status;
    private String source;
    private String classification;
    private Integer ownerId;
    private String fromDate;
    private String toDate;
    private Boolean overdue;
    private String filterQuery;
    private boolean isDefault;
    private Timestamp createdAt;
    private Timestamp updatedAt;

    public LeadSavedFilter() {
    }

    public LeadSavedFilter(int userId, String filterName, String filterQuery) {
        this.userId = userId;
        this.filterName = filterName;
        this.filterQuery = filterQuery;
        this.module = "LEAD";
    }

    public int getFilterId() {
        return filterId;
    }

    public void setFilterId(int filterId) {
        this.filterId = filterId;
    }

    // Alias cho JSP tương thích cả filter.id lẫn filter.filterId
    public int getId() {
        return filterId;
    }

    public int getUserId() {
        return userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }

    public String getFilterName() {
        return filterName;
    }

    public void setFilterName(String filterName) {
        this.filterName = filterName;
    }

    // Alias cho JSP tương thích cả filter.name lẫn filter.filterName
    public String getName() {
        return filterName;
    }

    public String getModule() {
        return module;
    }

    public void setModule(String module) {
        this.module = module;
    }

    public String getKeyword() {
        return keyword;
    }

    public void setKeyword(String keyword) {
        this.keyword = keyword;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getSource() {
        return source;
    }

    public void setSource(String source) {
        this.source = source;
    }

    public String getClassification() {
        return classification;
    }

    public void setClassification(String classification) {
        this.classification = classification;
    }

    public Integer getOwnerId() {
        return ownerId;
    }

    public void setOwnerId(Integer ownerId) {
        this.ownerId = ownerId;
    }

    public String getFromDate() {
        return fromDate;
    }

    public void setFromDate(String fromDate) {
        this.fromDate = fromDate;
    }

    public String getToDate() {
        return toDate;
    }

    public void setToDate(String toDate) {
        this.toDate = toDate;
    }

    public Boolean getOverdue() {
        return overdue;
    }

    public void setOverdue(Boolean overdue) {
        this.overdue = overdue;
    }

    public String getFilterQuery() {
        return filterQuery;
    }

    public void setFilterQuery(String filterQuery) {
        this.filterQuery = filterQuery;
    }

    // Alias cho JSP tương thích criteria
    public String getCriteria() {
        return filterQuery;
    }

    public boolean isDefault() {
        return isDefault;
    }

    public void setDefault(boolean isDefault) {
        this.isDefault = isDefault;
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

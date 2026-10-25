package com.crm.dto;

/**
 * DTO chứa các tham số lọc danh sách Lead (S4-09).
 * Hỗ trợ lọc theo trạng thái, nguồn, phân loại nóng/ấm/lạnh, người phụ trách, thời gian, và SLA quá hạn.
 */
public class LeadFilterRequest {

    private String keyword;
    private String status;
    private String source;
    private String classification; // HOT, WARM, COLD
    private String rating;         // Alias cho classification
    private Integer ownerId;
    private String ownerScope;     // MY, TEAM, ALL
    private String fromDate;       // YYYY-MM-DD
    private String toDate;         // YYYY-MM-DD
    private Boolean overdue;       // S4-09-AC-02: chỉ hiển thị lead quá SLA
    private int page = 1;
    private int pageSize = 10;
    private String sortBy = "score";
    private String sortOrder = "DESC";

    public LeadFilterRequest() {
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
        if (classification != null && !classification.trim().isEmpty()) {
            return classification.trim();
        }
        return rating != null ? rating.trim() : null;
    }

    public void setClassification(String classification) {
        this.classification = classification;
    }

    public String getRating() {
        return getClassification();
    }

    public void setRating(String rating) {
        this.rating = rating;
        if (this.classification == null) {
            this.classification = rating;
        }
    }

    public Integer getOwnerId() {
        return ownerId;
    }

    public void setOwnerId(Integer ownerId) {
        this.ownerId = ownerId;
    }

    public String getOwnerScope() {
        return ownerScope;
    }

    public void setOwnerScope(String ownerScope) {
        this.ownerScope = ownerScope;
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

    public boolean isOverdue() {
        return Boolean.TRUE.equals(overdue);
    }

    public void setOverdue(Boolean overdue) {
        this.overdue = overdue;
    }

    public int getPage() {
        return page <= 0 ? 1 : page;
    }

    public void setPage(int page) {
        this.page = page;
    }

    public int getPageSize() {
        return pageSize <= 0 ? 10 : pageSize;
    }

    public void setPageSize(int pageSize) {
        this.pageSize = pageSize;
    }

    public int getOffset() {
        return (getPage() - 1) * getPageSize();
    }

    public String getSortBy() {
        return sortBy != null ? sortBy : "score";
    }

    public void setSortBy(String sortBy) {
        this.sortBy = sortBy;
    }

    public String getSortOrder() {
        return sortOrder != null ? sortOrder : "DESC";
    }

    public void setSortOrder(String sortOrder) {
        this.sortOrder = sortOrder;
    }

    /**
     * Chuyển các tham số lọc thành Query String URL để lưu trữ và tái sử dụng bộ lọc (S4-09-AC-03).
     */
    public String toQueryString() {
        StringBuilder sb = new StringBuilder();
        if (keyword != null && !keyword.trim().isEmpty()) {
            sb.append("keyword=").append(urlEncode(keyword.trim())).append("&");
        }
        if (status != null && !status.trim().isEmpty()) {
            sb.append("status=").append(urlEncode(status.trim())).append("&");
        }
        if (source != null && !source.trim().isEmpty()) {
            sb.append("source=").append(urlEncode(source.trim())).append("&");
        }
        String cls = getClassification();
        if (cls != null && !cls.isEmpty()) {
            sb.append("classification=").append(urlEncode(cls)).append("&");
        }
        if (ownerId != null) {
            sb.append("ownerId=").append(ownerId).append("&");
        }
        if (ownerScope != null && !ownerScope.trim().isEmpty()) {
            sb.append("ownerScope=").append(urlEncode(ownerScope.trim())).append("&");
        }
        if (fromDate != null && !fromDate.trim().isEmpty()) {
            sb.append("fromDate=").append(urlEncode(fromDate.trim())).append("&");
        }
        if (toDate != null && !toDate.trim().isEmpty()) {
            sb.append("toDate=").append(urlEncode(toDate.trim())).append("&");
        }
        if (isOverdue()) {
            sb.append("overdue=true&");
        }

        if (sb.length() > 0 && sb.charAt(sb.length() - 1) == '&') {
            sb.setLength(sb.length() - 1);
        }
        return sb.toString();
    }

    private String urlEncode(String s) {
        try {
            return java.net.URLEncoder.encode(s, java.nio.charset.StandardCharsets.UTF_8.name());
        } catch (Exception e) {
            return s;
        }
    }
}

package com.crm.dto;

public class CustomerFilterRequest {
    private String keyword;
    private String status;
    private String industry;
    private String companySize;
    private String region;
    private Integer ownerId;
    private int page = 1;
    private int pageSize = 20;

    public String getKeyword() { return keyword; }
    public void setKeyword(String keyword) { this.keyword = keyword; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public String getIndustry() { return industry; }
    public void setIndustry(String industry) { this.industry = industry; }

    public String getCompanySize() { return companySize; }
    public void setCompanySize(String companySize) { this.companySize = companySize; }
    public String getSize() { return companySize; }
    public void setSize(String size) { this.companySize = size; }

    public String getRegion() { return region; }
    public void setRegion(String region) { this.region = region; }

    public Integer getOwnerId() { return ownerId; }
    public void setOwnerId(Integer ownerId) { this.ownerId = ownerId; }

    public int getPage() { return page <= 0 ? 1 : page; }
    public void setPage(int page) { this.page = page; }

    public int getPageSize() { return pageSize <= 0 ? 20 : pageSize; }
    public void setPageSize(int pageSize) { this.pageSize = pageSize; }
}

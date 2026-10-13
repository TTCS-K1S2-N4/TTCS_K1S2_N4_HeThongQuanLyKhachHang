package com.crm.dto;

import java.math.BigDecimal;
import java.sql.Date;
import java.util.ArrayList;
import java.util.List;

/**
 * DTO tiếp nhận dữ liệu yêu cầu tạo mới hoặc cập nhật Chiến dịch.
 * Phục vụ cho API C03 và C06 (S4-03).
 */
public class CampaignRequest {
    private Integer id;
    private String name;
    private BigDecimal budget;
    private Date startDate;
    private Date endDate;
    private String channel;
    private String description;
    private String status;

    public CampaignRequest() {
        this.budget = BigDecimal.ZERO;
        this.status = "PLANNING";
    }

    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public Integer getCampaignId() {
        return id;
    }

    public void setCampaignId(Integer campaignId) {
        this.id = campaignId;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public BigDecimal getBudget() {
        return budget;
    }

    public void setBudget(BigDecimal budget) {
        this.budget = budget != null ? budget : BigDecimal.ZERO;
    }

    public void setBudget(Double budgetDouble) {
        this.budget = budgetDouble != null ? BigDecimal.valueOf(budgetDouble) : BigDecimal.ZERO;
    }

    public void setBudget(String budgetStr) {
        if (budgetStr == null || budgetStr.trim().isEmpty()) {
            this.budget = BigDecimal.ZERO;
            return;
        }
        try {
            // Loại bỏ dấu phẩy hoặc khoảng trắng nếu người dùng nhập định dạng tiền tệ
            String clean = budgetStr.replaceAll("[,\\s]", "");
            this.budget = new BigDecimal(clean);
        } catch (NumberFormatException e) {
            this.budget = null; // Đánh dấu không hợp lệ để validate bắt
        }
    }

    public Date getStartDate() {
        return startDate;
    }

    public void setStartDate(Date startDate) {
        this.startDate = startDate;
    }

    public void setStartDate(String dateStr) {
        if (dateStr == null || dateStr.trim().isEmpty()) {
            this.startDate = null;
            return;
        }
        try {
            this.startDate = Date.valueOf(dateStr.trim());
        } catch (IllegalArgumentException e) {
            this.startDate = null;
        }
    }

    public Date getEndDate() {
        return endDate;
    }

    public void setEndDate(Date endDate) {
        this.endDate = endDate;
    }

    public void setEndDate(String dateStr) {
        if (dateStr == null || dateStr.trim().isEmpty()) {
            this.endDate = null;
            return;
        }
        try {
            this.endDate = Date.valueOf(dateStr.trim());
        } catch (IllegalArgumentException e) {
            this.endDate = null;
        }
    }

    public String getChannel() {
        return channel;
    }

    public void setChannel(String channel) {
        this.channel = channel;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    /**
     * Kiểm tra tính hợp lệ của dữ liệu đầu vào.
     * @return Danh sách lỗi (trống nếu hợp lệ)
     */
    public List<String> validate() {
        List<String> errors = new ArrayList<>();

        if (name == null || name.trim().isEmpty()) {
            errors.add("Tên chiến dịch không được để trống.");
        } else if (name.trim().length() > 200) {
            errors.add("Tên chiến dịch không được vượt quá 200 ký tự.");
        }

        if (budget == null) {
            errors.add("Ngân sách không đúng định dạng số hợp lệ.");
        } else if (budget.compareTo(BigDecimal.ZERO) < 0) {
            errors.add("Ngân sách không được là số âm.");
        }

        if (startDate != null && endDate != null && startDate.after(endDate)) {
            errors.add("Ngày bắt đầu không được lớn hơn ngày kết thúc.");
        }

        if (channel != null && channel.trim().length() > 100) {
            errors.add("Kênh tiếp thị không được vượt quá 100 ký tự.");
        }

        return errors;
    }
}

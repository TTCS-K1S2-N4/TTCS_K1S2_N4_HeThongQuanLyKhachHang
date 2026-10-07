package com.crm.model;

import java.sql.Timestamp;

public class Category {

    public enum Action {
        CREATE,
        UPDATE,
        DEACTIVATE,
        DELETE;

        public static Action fromString(String value) {
            if (value == null || value.trim().isEmpty()) {
                return null;
            }
            for (Action action : Action.values()) {
                if (action.name().equalsIgnoreCase(value.trim())) {
                    return action;
                }
            }
            return null;
        }
    }

    private int categoryId;
    private String categoryType;
    private String categoryName;
    private int displayOrder;
    private String status;
    private Timestamp createdAt;
    private Timestamp updatedAt;

    public Category() {
        this.status = "ACTIVE";
        this.displayOrder = 0;
    }

    public Category(int categoryId, String categoryType, String categoryName, int displayOrder, String status) {
        this.categoryId = categoryId;
        this.categoryType = categoryType;
        this.categoryName = categoryName;
        this.displayOrder = displayOrder;
        this.status = status != null ? status : "ACTIVE";
    }

    public int getCategoryId() {
        return categoryId;
    }

    public void setCategoryId(int categoryId) {
        this.categoryId = categoryId;
    }

    public String getCategoryType() {
        return categoryType;
    }

    public void setCategoryType(String categoryType) {
        this.categoryType = categoryType;
    }

    public String getCategoryName() {
        return categoryName;
    }

    public void setCategoryName(String categoryName) {
        this.categoryName = categoryName;
    }

    public int getDisplayOrder() {
        return displayOrder;
    }

    public void setDisplayOrder(int displayOrder) {
        this.displayOrder = displayOrder;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
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

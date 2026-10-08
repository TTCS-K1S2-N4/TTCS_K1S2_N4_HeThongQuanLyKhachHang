package com.crm.dto;

import com.crm.model.Customer;

public class DuplicateCandidate {
    private Customer left;
    private Customer right;
    private String reason;

    public DuplicateCandidate() {}

    public DuplicateCandidate(Customer left, Customer right, String reason) {
        this.left = left;
        this.right = right;
        this.reason = reason;
    }

    public Customer getLeft() {
        return left;
    }

    public void setLeft(Customer left) {
        this.left = left;
    }

    public Customer getRight() {
        return right;
    }

    public void setRight(Customer right) {
        this.right = right;
    }

    public String getReason() {
        return reason;
    }

    public void setReason(String reason) {
        this.reason = reason;
    }

    // Convenience getters for EL expressions in JSP
    public int getCustomerId() {
        return left != null ? left.getCustomerId() : 0;
    }

    public String getCustomerName() {
        return left != null ? left.getCustomerName() : "";
    }

    public String getPhone() {
        return left != null ? left.getPhone() : "";
    }
}

package com.crm.dto;

import java.util.HashMap;
import java.util.Map;

public class ContactTransferRequest {
    private Integer contactId;
    private Integer newCustomerId;
    private Integer transferredBy;

    public ContactTransferRequest() {
    }

    public ContactTransferRequest(Integer contactId, Integer newCustomerId, Integer transferredBy) {
        this.contactId = contactId;
        this.newCustomerId = newCustomerId;
        this.transferredBy = transferredBy;
    }

    public Integer getContactId() {
        return contactId;
    }

    public void setContactId(Integer contactId) {
        this.contactId = contactId;
    }

    public Integer getNewCustomerId() {
        return newCustomerId;
    }

    public void setNewCustomerId(Integer newCustomerId) {
        this.newCustomerId = newCustomerId;
    }

    public Integer getTransferredBy() {
        return transferredBy;
    }

    public void setTransferredBy(Integer transferredBy) {
        this.transferredBy = transferredBy;
    }

    public Map<String, String> validate() {
        Map<String, String> errors = new HashMap<>();

        if (contactId == null || contactId <= 0) {
            errors.put("contactId", "ID người liên hệ không hợp lệ.");
        }

        if (newCustomerId == null || newCustomerId <= 0) {
            errors.put("newCustomerId", "Vui lòng chọn công ty/khách hàng mới hợp lệ.");
        }

        return errors;
    }
}

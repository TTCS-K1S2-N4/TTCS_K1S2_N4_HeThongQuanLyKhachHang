package com.crm.dto;

import com.crm.util.ValidationUtil;
import java.util.HashMap;
import java.util.Map;
import java.util.Set;

public class ContactRequest {
    private Integer contactId;
    private Integer customerId;
    private String fullName;
    private String title;
    private String email;
    private String phone;
    private String buyingRole;
    private boolean isPrimary;

    private static final Set<String> VALID_BUYING_ROLES = Set.of(
            "DECISION_MAKER",
            "INFLUENCER",
            "END_USER",
            "BLOCKER"
    );

    public ContactRequest() {
    }

    public Integer getContactId() {
        return contactId;
    }

    public void setContactId(Integer contactId) {
        this.contactId = contactId;
    }

    public Integer getCustomerId() {
        return customerId;
    }

    public void setCustomerId(Integer customerId) {
        this.customerId = customerId;
    }

    public String getFullName() {
        return fullName;
    }

    public void setFullName(String fullName) {
        this.fullName = fullName;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
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

    public String getBuyingRole() {
        return buyingRole;
    }

    public void setBuyingRole(String buyingRole) {
        this.buyingRole = buyingRole;
    }

    public boolean isPrimary() {
        return isPrimary;
    }

    public void setPrimary(boolean primary) {
        isPrimary = primary;
    }

    public Map<String, String> validate() {
        Map<String, String> errors = new HashMap<>();

        if (!ValidationUtil.isNotEmpty(fullName)) {
            errors.put("fullName", "Họ và tên người liên hệ không được để trống.");
        } else if (fullName.trim().length() > 200) {
            errors.put("fullName", "Họ và tên không được vượt quá 200 ký tự.");
        }

        if (ValidationUtil.isNotEmpty(email) && !ValidationUtil.isValidEmail(email)) {
            errors.put("email", "Email không đúng định dạng hợp lệ.");
        }

        if (ValidationUtil.isNotEmpty(phone) && !ValidationUtil.isValidPhone(phone)) {
            errors.put("phone", "Số điện thoại không đúng định dạng.");
        }

        if (!ValidationUtil.isNotEmpty(buyingRole)) {
            errors.put("buyingRole", "Vai trò trong quyết định mua là bắt buộc.");
        } else if (!VALID_BUYING_ROLES.contains(buyingRole.trim().toUpperCase())) {
            errors.put("buyingRole", "Vai trò mua hàng phải thuộc một trong 4 loại: Người quyết định, Người ảnh hưởng, Người dùng cuối, Người cản trở.");
        }

        return errors;
    }
}

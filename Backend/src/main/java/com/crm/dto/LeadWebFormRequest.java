package com.crm.dto;

public class LeadWebFormRequest {
    private String formName;
    private String description;
    private String allowedDomains;
    private String successRedirectUrl;
    private boolean active = true;
    private boolean spamProtectionEnabled = true;
    private String fieldsJson;

    public LeadWebFormRequest() {}

    public String getFormName() {
        return formName;
    }

    public void setFormName(String formName) {
        this.formName = formName;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getAllowedDomains() {
        return allowedDomains;
    }

    public void setAllowedDomains(String allowedDomains) {
        this.allowedDomains = allowedDomains;
    }

    public String getSuccessRedirectUrl() {
        return successRedirectUrl;
    }

    public void setSuccessRedirectUrl(String successRedirectUrl) {
        this.successRedirectUrl = successRedirectUrl;
    }

    public boolean isActive() {
        return active;
    }

    public void setActive(boolean active) {
        this.active = active;
    }

    public boolean isSpamProtectionEnabled() {
        return spamProtectionEnabled;
    }

    public void setSpamProtectionEnabled(boolean spamProtectionEnabled) {
        this.spamProtectionEnabled = spamProtectionEnabled;
    }

    public String getFieldsJson() {
        return fieldsJson;
    }

    public void setFieldsJson(String fieldsJson) {
        this.fieldsJson = fieldsJson;
    }
}

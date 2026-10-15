package com.crm.service;

import com.crm.dao.LeadDAO;
import com.crm.dao.LeadSourceDAO;
import com.crm.dao.LeadWebFormDAO;
import com.crm.dto.LeadWebFormRequest;
import com.crm.model.Lead;
import com.crm.model.LeadSource;
import com.crm.model.LeadWebForm;
import com.crm.util.LeadSpamProtectionUtil;

import java.util.List;

public class LeadWebFormService {

    private LeadWebFormDAO webFormDAO = new LeadWebFormDAO();
    private LeadDAO leadDAO = new LeadDAO();
    private LeadSourceDAO sourceDAO = new LeadSourceDAO();

    public List<LeadWebForm> getAllWebForms() {
        return webFormDAO.getAllWebForms();
    }

    public LeadWebForm getWebFormById(int formId) {
        return webFormDAO.getById(formId);
    }

    public LeadWebForm createWebForm(LeadWebFormRequest request, Integer createdBy, String baseUrl) {
        if (request == null || request.getFormName() == null || request.getFormName().trim().isEmpty()) {
            throw new IllegalArgumentException("Tên biểu mẫu nhúng không được để trống.");
        }

        LeadWebForm form = new LeadWebForm();
        form.setFormName(request.getFormName().trim());
        form.setDescription(request.getDescription());
        form.setAllowedDomains(request.getAllowedDomains());
        form.setSuccessRedirectUrl(request.getSuccessRedirectUrl());
        form.setActive(request.isActive());
        form.setSpamProtectionEnabled(request.isSpamProtectionEnabled());
        form.setFieldsJson(request.getFieldsJson());
        form.setLeadSourceId(request.getLeadSourceId());
        form.setCreatedBy(createdBy);

        boolean created = webFormDAO.createWebForm(form);
        if (created) {
            String embedCode = generateEmbedCode(form.getFormId(), baseUrl);
            form.setEmbedCode(embedCode);
            webFormDAO.updateWebForm(form);
            return form;
        }
        return null;
    }

    public boolean updateWebForm(int formId, LeadWebFormRequest request, String baseUrl) {
        LeadWebForm existing = webFormDAO.getById(formId);
        if (existing == null) {
            return false;
        }

        if (request.getFormName() != null && !request.getFormName().trim().isEmpty()) {
            existing.setFormName(request.getFormName().trim());
        }
        existing.setDescription(request.getDescription());
        existing.setAllowedDomains(request.getAllowedDomains());
        existing.setSuccessRedirectUrl(request.getSuccessRedirectUrl());
        existing.setActive(request.isActive());
        existing.setSpamProtectionEnabled(request.isSpamProtectionEnabled());
        existing.setFieldsJson(request.getFieldsJson());
        if (request.getLeadSourceId() != null) {
            existing.setLeadSourceId(request.getLeadSourceId());
        }

        if (existing.getEmbedCode() == null || existing.getEmbedCode().trim().isEmpty()) {
            existing.setEmbedCode(generateEmbedCode(formId, baseUrl));
        }

        return webFormDAO.updateWebForm(existing);
    }

    public boolean deleteWebForm(int formId) {
        return webFormDAO.deleteWebForm(formId);
    }

    public String generateEmbedCode(int formId, String baseUrl) {
        String url = (baseUrl != null ? baseUrl : "") + "/leads/public-form?formId=" + formId;
        return "<iframe src=\"" + url + "\" width=\"100%\" height=\"600\" frameborder=\"0\" marginheight=\"0\" marginwidth=\"0\">Đang tải biểu mẫu...</iframe>";
    }

    public boolean submitPublicForm(int formId, String fullName, String email, String phone, String company,
                                   String notes, String refererHeader, String clientIp, String honeypot) {
        LeadWebForm form = webFormDAO.getById(formId);
        if (form == null || !form.isActive()) {
            throw new IllegalStateException("Biểu mẫu thu thập không tồn tại hoặc đã bị ngừng kích hoạt.");
        }

        if (form.isSpamProtectionEnabled()) {
            if (LeadSpamProtectionUtil.isHoneypotTriggered(honeypot)) {
                throw new SecurityException("Phát hiện hoạt động tự động (Spam bot).");
            }
            if (LeadSpamProtectionUtil.isRateLimited(clientIp)) {
                throw new SecurityException("Yêu cầu quá dồn dập. Vui lòng thử lại sau giây lát.");
            }
            if (!LeadSpamProtectionUtil.isDomainAllowed(refererHeader, form.getAllowedDomains())) {
                throw new SecurityException("Domain gửi biểu mẫu không được phép.");
            }
            if (LeadSpamProtectionUtil.containsSpamKeywords(notes) || 
                LeadSpamProtectionUtil.containsSpamKeywords(fullName) ||
                LeadSpamProtectionUtil.containsSpamKeywords(company)) {
                throw new SecurityException("Nội dung chứa từ khóa bị cấm hoặc liên kết spam.");
            }
            if (LeadSpamProtectionUtil.isSuspiciousEmail(email)) {
                throw new SecurityException("Địa chỉ email không hợp lệ hoặc bị nghi ngờ spam.");
            }
        }

        if (fullName == null || fullName.trim().isEmpty()) {
            throw new IllegalArgumentException("Họ và tên không được để trống.");
        }

        // Validate format email (backend — không phụ thuộc HTML5, chống bypass)
        if (email != null && !email.trim().isEmpty()) {
            if (!email.trim().matches("^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$")) {
                throw new IllegalArgumentException("Địa chỉ email không đúng định dạng.");
            }
        }

        // Validate format số điện thoại Việt Nam
        if (phone != null && !phone.trim().isEmpty()) {
            String cleanedPhone = phone.trim().replaceAll("[\\s\\-\\.]", "");
            if (!cleanedPhone.matches("^(0|\\+?84)[35789][0-9]{8}$")) {
                throw new IllegalArgumentException("Số điện thoại không đúng định dạng Việt Nam.");
            }
        }


        Lead lead = new Lead();
        lead.setFullName(fullName.trim());
        lead.setEmail(email != null ? email.trim() : null);
        lead.setPhone(phone != null ? phone.trim() : null);
        lead.setCompany(company != null ? company.trim() : null);
        lead.setNotes(notes != null ? notes.trim() : null);
        lead.setWebFormId(formId);
        lead.setStatus("NEW");
        lead.setRating("WARM");

        // Gán Lead Source từ cấu hình của biểu mẫu (nếu có); nếu không, gán nguồn mặc định WEB_FORM
        if (form.getLeadSourceId() != null && form.getLeadSourceId() > 0) {
            lead.setLeadSourceId(form.getLeadSourceId());
        } else {
            LeadSource webSource = sourceDAO.getByCode("WEB_FORM");
            if (webSource != null) {
                lead.setLeadSourceId(webSource.getSourceId());
            } else {
                // Log cảnh báo để dễ debug khi DB seed thiếu source WEB_FORM
                System.err.println("[WARN] LeadWebFormService: Không tìm thấy source_code='WEB_FORM' trong bảng lead_sources. " +
                        "Lead sẽ được tạo không có source. Kiểm tra dữ liệu seed DB.");
            }
        }

        return leadDAO.createLead(lead);
    }
}


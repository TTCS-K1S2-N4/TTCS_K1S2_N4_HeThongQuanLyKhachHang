package com.crm.service;

import com.crm.dao.LeadDAO;
import com.crm.dto.LeadRequest;
import com.crm.dto.LeadResponse;
import com.crm.model.Lead;

import java.util.ArrayList;
import java.util.List;

public class LeadService {

    private LeadDAO leadDAO = new LeadDAO();

    public List<LeadResponse> getLeads(int page, int pageSize, String search, String status, String rating, Integer ownerId) {
        int offset = (page - 1) * pageSize;
        List<Lead> leads = leadDAO.getLeads(offset, pageSize, search, status, rating, ownerId);
        List<LeadResponse> responses = new ArrayList<>();
        for (Lead lead : leads) {
            responses.add(LeadResponse.fromModel(lead));
        }
        return responses;
    }

    public int countLeads(String search, String status, String rating, Integer ownerId) {
        return leadDAO.countLeads(search, status, rating, ownerId);
    }

    public LeadResponse getLeadById(int leadId) {
        Lead lead = leadDAO.getById(leadId);
        return LeadResponse.fromModel(lead);
    }

    public LeadResponse createLead(LeadRequest request, Integer ownerId) {
        if (request == null || request.getFullName() == null || request.getFullName().trim().isEmpty()) {
            throw new IllegalArgumentException("Họ và tên Lead không được để trống.");
        }

        if (request.getEmail() != null && !request.getEmail().trim().isEmpty()) {
            Lead existing = leadDAO.getByEmail(request.getEmail().trim());
            if (existing != null) {
                throw new IllegalStateException("Email này đã tồn tại trong hệ thống (Lead #" + existing.getLeadId() + ").");
            }
        }

        if (request.getPhone() != null && !request.getPhone().trim().isEmpty()) {
            Lead existing = leadDAO.getByPhone(request.getPhone().trim());
            if (existing != null) {
                throw new IllegalStateException("Số điện thoại này đã tồn tại trong hệ thống (Lead #" + existing.getLeadId() + ").");
            }
        }

        if (request.getLeadSourceId() == null || request.getLeadSourceId() <= 0) {
            throw new IllegalArgumentException("Nguồn Lead là bắt buộc và không được để trống.");
        }


        Lead lead = new Lead();
        lead.setFullName(request.getFullName().trim());
        lead.setFirstName(request.getFirstName());
        lead.setLastName(request.getLastName());
        lead.setTitle(request.getTitle());
        lead.setCompany(request.getCompany());
        lead.setEmail(request.getEmail() != null ? request.getEmail().trim() : null);
        lead.setPhone(request.getPhone() != null ? request.getPhone().trim() : null);
        lead.setLeadSourceId(request.getLeadSourceId());
        lead.setWebFormId(request.getWebFormId());
        lead.setStatus(request.getStatus() != null ? request.getStatus() : "NEW");
        lead.setRating(request.getRating() != null ? request.getRating() : "WARM");
        lead.setScore(request.getScore());
        lead.setIndustry(request.getIndustry());
        lead.setAddress(request.getAddress());
        lead.setCity(request.getCity());
        lead.setState(request.getState());
        lead.setCountry(request.getCountry());
        lead.setZipCode(request.getZipCode());
        lead.setOwnerId(request.getOwnerId() != null ? request.getOwnerId() : ownerId);
        lead.setNotes(request.getNotes());

        boolean created = leadDAO.createLead(lead);
        if (created) {
            return getLeadById(lead.getLeadId());
        }
        return null;
    }

    public boolean updateLead(int leadId, LeadRequest request) {
        Lead existing = leadDAO.getById(leadId);
        if (existing == null) {
            return false;
        }

        if (request.getFullName() != null && !request.getFullName().trim().isEmpty()) {
            existing.setFullName(request.getFullName().trim());
        }
        existing.setFirstName(request.getFirstName());
        existing.setLastName(request.getLastName());
        existing.setTitle(request.getTitle());
        existing.setCompany(request.getCompany());
        existing.setEmail(request.getEmail() != null ? request.getEmail().trim() : null);
        existing.setPhone(request.getPhone() != null ? request.getPhone().trim() : null);
        if (request.getLeadSourceId() != null) existing.setLeadSourceId(request.getLeadSourceId());
        if (request.getWebFormId() != null) existing.setWebFormId(request.getWebFormId());
        if (request.getStatus() != null) existing.setStatus(request.getStatus());
        if (request.getRating() != null) existing.setRating(request.getRating());
        existing.setScore(request.getScore());
        existing.setIndustry(request.getIndustry());
        existing.setAddress(request.getAddress());
        existing.setCity(request.getCity());
        existing.setState(request.getState());
        existing.setCountry(request.getCountry());
        existing.setZipCode(request.getZipCode());
        if (request.getOwnerId() != null) existing.setOwnerId(request.getOwnerId());
        existing.setNotes(request.getNotes());

        return leadDAO.updateLead(existing);
    }

    public boolean deleteLead(int leadId) {
        return leadDAO.deleteLead(leadId);
    }
}

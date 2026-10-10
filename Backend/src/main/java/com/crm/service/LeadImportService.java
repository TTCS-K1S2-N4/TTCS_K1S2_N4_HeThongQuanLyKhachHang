package com.crm.service;

import com.crm.dao.LeadDAO;
import com.crm.dao.LeadSourceDAO;
import com.crm.dto.LeadImportRequest;
import com.crm.model.Lead;
import com.crm.model.LeadSource;
import com.crm.util.ExcelImportUtil;

import java.io.InputStream;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class LeadImportService {

    private LeadDAO leadDAO = new LeadDAO();
    private LeadSourceDAO sourceDAO = new LeadSourceDAO();

    public static class ImportResult {
        private int totalRows;
        private int validRows;
        private int duplicateRows;
        private int failedRows;
        private int importedCount;
        private List<LeadImportRequest> details = new ArrayList<>();

        public int getTotalRows() { return totalRows; }
        public void setTotalRows(int totalRows) { this.totalRows = totalRows; }
        public int getValidRows() { return validRows; }
        public void setValidRows(int validRows) { this.validRows = validRows; }
        public int getDuplicateRows() { return duplicateRows; }
        public void setDuplicateRows(int duplicateRows) { this.duplicateRows = duplicateRows; }
        public int getFailedRows() { return failedRows; }
        public void setFailedRows(int failedRows) { this.failedRows = failedRows; }
        public int getImportedCount() { return importedCount; }
        public void setImportedCount(int importedCount) { this.importedCount = importedCount; }
        public List<LeadImportRequest> getDetails() { return details; }
        public void setDetails(List<LeadImportRequest> details) { this.details = details; }
    }

    public ImportResult parseAndValidateExcel(InputStream inputStream, Integer ownerId) throws Exception {
        List<LeadImportRequest> requests = ExcelImportUtil.parseLeadImport(inputStream);
        ImportResult result = new ImportResult();
        result.setTotalRows(requests.size());

        List<LeadSource> activeSources = sourceDAO.getActiveSources();
        Map<String, Integer> sourceMap = new HashMap<>();
        for (LeadSource src : activeSources) {
            sourceMap.put(src.getSourceName().trim().toLowerCase(), src.getSourceId());
            sourceMap.put(src.getSourceCode().trim().toLowerCase(), src.getSourceId());
        }

        int valid = 0;
        int dup = 0;
        int fail = 0;

        for (LeadImportRequest req : requests) {
            req.setOwnerId(ownerId);

            // Map Lead Source Name to ID & enforce mandatory source requirement
            if (req.getSourceName() != null && !req.getSourceName().trim().isEmpty()) {
                Integer srcId = sourceMap.get(req.getSourceName().trim().toLowerCase());
                if (srcId != null) {
                    req.setLeadSourceId(srcId);
                } else {
                    req.addFieldError("Nguồn Lead '" + req.getSourceName() + "' không tồn tại trong hệ thống");
                }
            } else {
                Integer defaultSrc = sourceMap.get("import_excel");
                if (defaultSrc != null) {
                    req.setLeadSourceId(defaultSrc);
                } else {
                    req.addFieldError("Nguồn Lead là bắt buộc và không được để trống");
                }
            }

            if (!req.isValid()) {
                fail++;
                continue;
            }

            // Check Duplicate by Email or Phone
            Lead existingByEmail = req.getEmail() != null ? leadDAO.getByEmail(req.getEmail()) : null;
            Lead existingByPhone = req.getPhone() != null ? leadDAO.getByPhone(req.getPhone()) : null;

            if (existingByEmail != null) {
                req.setDuplicate(true);
                req.setExistingLeadId(existingByEmail.getLeadId());
                req.setDuplicateReason("Trùng email với Lead #" + existingByEmail.getLeadId());
                dup++;
            } else if (existingByPhone != null) {
                req.setDuplicate(true);
                req.setExistingLeadId(existingByPhone.getLeadId());
                req.setDuplicateReason("Trùng SĐT với Lead #" + existingByPhone.getLeadId());
                dup++;
            } else {
                valid++;
            }
        }

        result.setValidRows(valid);
        result.setDuplicateRows(dup);
        result.setFailedRows(fail);
        result.setDetails(requests);

        return result;
    }

    public int executeImport(List<LeadImportRequest> importRequests, boolean skipDuplicates) {
        if (importRequests == null || importRequests.isEmpty()) {
            return 0;
        }

        List<Lead> leadsToInsert = new ArrayList<>();

        for (LeadImportRequest req : importRequests) {
            if (!req.isValid()) continue;
            if (skipDuplicates && req.isDuplicate()) continue;

            Lead lead = new Lead();
            lead.setFullName(req.getFullName());
            lead.setTitle(req.getTitle());
            lead.setCompany(req.getCompany());
            lead.setEmail(req.getEmail());
            lead.setPhone(req.getPhone());
            lead.setLeadSourceId(req.getLeadSourceId());
            lead.setStatus(req.getStatus() != null ? req.getStatus() : "NEW");
            lead.setRating(req.getRating() != null ? req.getRating() : "WARM");
            lead.setIndustry(req.getIndustry());
            lead.setAddress(req.getAddress());
            lead.setCity(req.getCity());
            lead.setState(req.getState());
            lead.setCountry(req.getCountry());
            lead.setZipCode(req.getZipCode());
            lead.setOwnerId(req.getOwnerId());
            lead.setNotes(req.getNotes());

            leadsToInsert.add(lead);
        }

        return leadDAO.batchCreateLeads(leadsToInsert);
    }
}

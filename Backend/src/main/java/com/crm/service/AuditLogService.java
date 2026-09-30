package com.crm.service;

import com.crm.dao.AuditLogDAO;
import com.crm.dao.AuditLogDetailDAO;
import com.crm.model.AuditLog;

import java.util.List;

public class AuditLogService {

    private final AuditLogDAO auditLogDAO;
    private final AuditLogDetailDAO auditLogDetailDAO;

    public AuditLogService() {
        this.auditLogDAO = new AuditLogDAO();
        this.auditLogDetailDAO = new AuditLogDetailDAO();
    }

    public List<AuditLog> getAuditLogs(Integer userId, String entityType, String fromDate, String toDate, int page, int pageSize) {
        int validPage = Math.max(1, page);
        int validPageSize = (pageSize > 0 && pageSize <= 100) ? pageSize : 10;
        int offset = (validPage - 1) * validPageSize;

        return auditLogDAO.findAuditLogs(userId, entityType, fromDate, toDate, offset, validPageSize);
    }

    public int getTotalAuditLogs(Integer userId, String entityType, String fromDate, String toDate) {
        return auditLogDAO.countAuditLogs(userId, entityType, fromDate, toDate);
    }

    public AuditLog getAuditLogById(int auditLogId) {
        if (auditLogId <= 0) {
            return null;
        }
        return auditLogDetailDAO.getAuditLogById(auditLogId);
    }
}
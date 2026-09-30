package com.crm.dao;

import com.crm.model.AuditLog;
import com.crm.util.DBConnection;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class AuditLogDetailDAO {
    public AuditLog getAuditLogById(int auditLogId) {
        String sql = "SELECT a.log_id, a.action_type, a.performed_by, a.target_user_id, a.description, " +
                     "a.old_value, a.new_value, a.created_at, u.full_name as performed_by_name " +
                     "FROM audit_logs a LEFT JOIN users u ON a.performed_by = u.user_id " +
                     "WHERE a.log_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, auditLogId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    AuditLog log = new AuditLog();
                    log.setLogId(rs.getInt("log_id"));
                    log.setAction(rs.getString("action_type"));
                    log.setUserId(rs.getInt("performed_by"));
                    log.setPerformedByName(rs.getString("performed_by_name"));
                    log.setTargetUserId(rs.getInt("target_user_id"));
                    log.setDetails(rs.getString("description"));
                    try { log.setOldValue(rs.getString("old_value")); } catch (SQLException ignored) {}
                    try { log.setNewValue(rs.getString("new_value")); } catch (SQLException ignored) {}
                    log.setCreatedAt(rs.getTimestamp("created_at"));
                    return log;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }
}
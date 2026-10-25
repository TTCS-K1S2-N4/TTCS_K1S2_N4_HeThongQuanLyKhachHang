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
                     "a.old_value, a.new_value, a.created_at, u.full_name as performed_by_name, " +
                     "COALESCE(p.product_name, o.title, tu.full_name) as target_entity_name " +
                     "FROM audit_logs a " +
                     "LEFT JOIN users u ON a.performed_by = u.user_id " +
                     "LEFT JOIN products p ON a.target_user_id = p.product_id AND a.action_type IN ('DISCOUNT_CREATE', 'DISCOUNT_UPDATE', 'DISCOUNT_STATUS_CHANGE') " +
                     "LEFT JOIN opportunities o ON a.target_user_id = o.opportunity_id AND a.action_type = 'TARGET_UPDATE' " +
                     "LEFT JOIN users tu ON a.target_user_id = tu.user_id AND a.action_type NOT IN ('DISCOUNT_CREATE', 'DISCOUNT_UPDATE', 'DISCOUNT_STATUS_CHANGE', 'TARGET_UPDATE') " +
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
                    log.setTargetEntityName(rs.getString("target_entity_name"));
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
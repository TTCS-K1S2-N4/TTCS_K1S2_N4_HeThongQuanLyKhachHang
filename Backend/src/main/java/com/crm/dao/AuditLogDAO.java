package com.crm.dao;

import com.crm.model.AuditLog;
import com.crm.util.DBConnection;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;

public class AuditLogDAO {
    public boolean insertLog(AuditLog log) {
        String sql = "INSERT INTO audit_logs (action_type, performed_by, target_user_id, description) VALUES (?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, log.getAction());
            ps.setInt(2, log.getUserId());
            ps.setInt(3, log.getTargetUserId());
            ps.setString(4, log.getDetails());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public AuditLog getLatestLockEvent(int targetUserId) {
        String sql = "SELECT log_id, action_type, performed_by, target_user_id, description, created_at " +
                     "FROM audit_logs " +
                     "WHERE target_user_id = ? AND action_type IN ('LOGIN_TEMP_LOCK', 'ACCOUNT_LOCK', 'ACCOUNT_UNLOCK') " +
                     "ORDER BY created_at DESC LIMIT 1";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, targetUserId);
            try (java.sql.ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    AuditLog log = new AuditLog();
                    log.setLogId(rs.getInt("log_id"));
                    log.setAction(rs.getString("action_type"));
                    log.setUserId(rs.getInt("performed_by"));
                    log.setTargetUserId(rs.getInt("target_user_id"));
                    log.setDetails(rs.getString("description"));
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

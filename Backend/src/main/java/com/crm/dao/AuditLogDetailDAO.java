package com.crm.dao;

import com.crm.model.AuditLog;
import com.crm.util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

public class AuditLogDetailDAO {

    private static final Logger LOGGER = Logger.getLogger(AuditLogDetailDAO.class.getName());

    public AuditLog getLogById(int logId) {
        String sql = "SELECT log_id, action_type, performed_by, target_user_id, description, created_at FROM audit_logs WHERE log_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, logId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToAuditLog(rs);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Lỗi lấy chi tiết audit log ID: " + logId, e);
        }
        return null;
    }

    public List<AuditLog> getLogs(int performedBy, int targetUserId, String actionType, int page, int pageSize) {
        List<AuditLog> logs = new ArrayList<>();
        StringBuilder sql = new StringBuilder("SELECT log_id, action_type, performed_by, target_user_id, description, created_at FROM audit_logs WHERE 1=1 ");
        List<Object> params = new ArrayList<>();

        if (performedBy > 0) {
            sql.append("AND performed_by = ? ");
            params.add(performedBy);
        }
        if (targetUserId > 0) {
            sql.append("AND target_user_id = ? ");
            params.add(targetUserId);
        }
        if (actionType != null && !actionType.trim().isEmpty()) {
            sql.append("AND action_type = ? ");
            params.add(actionType.trim());
        }

        sql.append("ORDER BY created_at DESC LIMIT ? OFFSET ?");
        int offset = Math.max(0, (page - 1) * pageSize);
        params.add(pageSize > 0 ? pageSize : 20);
        params.add(offset);

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    logs.add(mapResultSetToAuditLog(rs));
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Lỗi truy vấn danh sách audit log", e);
        }
        return logs;
    }

    public int countLogs(int performedBy, int targetUserId, String actionType) {
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM audit_logs WHERE 1=1 ");
        List<Object> params = new ArrayList<>();

        if (performedBy > 0) {
            sql.append("AND performed_by = ? ");
            params.add(performedBy);
        }
        if (targetUserId > 0) {
            sql.append("AND target_user_id = ? ");
            params.add(targetUserId);
        }
        if (actionType != null && !actionType.trim().isEmpty()) {
            sql.append("AND action_type = ? ");
            params.add(actionType.trim());
        }

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Lỗi đếm danh sách audit log", e);
        }
        return 0;
    }

    private AuditLog mapResultSetToAuditLog(ResultSet rs) throws SQLException {
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

package com.crm.dao;

import com.crm.model.AuditLog;
import com.crm.util.DBConnection;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class AuditLogDAO {
    public boolean insertLog(AuditLog log) {
        String sql = "INSERT INTO audit_logs (action_type, performed_by, target_user_id, description, old_value, new_value) VALUES (?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, log.getAction());
            ps.setInt(2, log.getUserId());
            ps.setInt(3, log.getTargetUserId());
            ps.setString(4, log.getDetails());
            ps.setString(5, log.getOldValue());
            ps.setString(6, log.getNewValue());
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

    public List<AuditLog> findAuditLogs(Integer userId, String entityType, String fromDate, String toDate, int offset, int limit) {
        List<AuditLog> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
            "SELECT a.log_id, a.action_type, a.performed_by, a.target_user_id, a.description, " +
            "a.old_value, a.new_value, a.created_at, u.full_name as performed_by_name " +
            "FROM audit_logs a LEFT JOIN users u ON a.performed_by = u.user_id WHERE 1=1 "
        );
        List<Object> params = new ArrayList<>();

        if (userId != null && userId > 0) {
            sql.append(" AND a.performed_by = ?");
            params.add(userId);
        }
        if (entityType != null && !entityType.trim().isEmpty()) {
            appendEntityTypeFilter(sql, params, entityType);
        }
        if (fromDate != null && !fromDate.trim().isEmpty()) {
            sql.append(" AND a.created_at >= ?");
            params.add(fromDate.trim().contains(" ") ? fromDate.trim() : fromDate.trim() + " 00:00:00");
        }
        if (toDate != null && !toDate.trim().isEmpty()) {
            sql.append(" AND a.created_at <= ?");
            params.add(toDate.trim().contains(" ") ? toDate.trim() : toDate.trim() + " 23:59:59");
        }

        sql.append(" ORDER BY a.created_at DESC LIMIT ? OFFSET ?");
        params.add(limit);
        params.add(offset);

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    AuditLog log = mapResultSetToAuditLog(rs);
                    list.add(log);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public int countAuditLogs(Integer userId, String entityType, String fromDate, String toDate) {
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM audit_logs a WHERE 1=1 ");
        List<Object> params = new ArrayList<>();

        if (userId != null && userId > 0) {
            sql.append(" AND a.performed_by = ?");
            params.add(userId);
        }
        if (entityType != null && !entityType.trim().isEmpty()) {
            appendEntityTypeFilter(sql, params, entityType);
        }
        if (fromDate != null && !fromDate.trim().isEmpty()) {
            sql.append(" AND a.created_at >= ?");
            params.add(fromDate.trim().contains(" ") ? fromDate.trim() : fromDate.trim() + " 00:00:00");
        }
        if (toDate != null && !toDate.trim().isEmpty()) {
            sql.append(" AND a.created_at <= ?");
            params.add(toDate.trim().contains(" ") ? toDate.trim() : toDate.trim() + " 23:59:59");
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
            e.printStackTrace();
        }
        return 0;
    }

    private void appendEntityTypeFilter(StringBuilder sql, List<Object> params, String entityType) {
        if (entityType == null || entityType.trim().isEmpty()) {
            return;
        }
        String type = entityType.trim().toUpperCase();
        if ("SYSTEM".equals(type)) {
            sql.append(" AND (a.action_type LIKE '%LOCK%' OR a.action_type LIKE '%UNLOCK%' OR a.action_type LIKE '%LOGIN%' OR a.action_type LIKE '%SYSTEM%' OR (a.action_type NOT LIKE '%DISCOUNT%' AND a.action_type NOT LIKE '%KPI%' AND a.action_type NOT LIKE '%TARGET%' AND a.action_type NOT LIKE '%OWNER%' AND a.action_type NOT LIKE '%TRANSFER%' AND a.action_type NOT LIKE '%ROLE%' AND a.action_type NOT LIKE '%ASSIGN%'))");
        } else if ("DISCOUNT".equals(type)) {
            sql.append(" AND a.action_type LIKE '%DISCOUNT%'");
        } else if ("KPI".equals(type) || "TARGET".equals(type)) {
            sql.append(" AND (a.action_type LIKE '%KPI%' OR a.action_type LIKE '%TARGET%')");
        } else if ("DATA_OWNERSHIP".equals(type) || "OWNER".equals(type) || "TRANSFER".equals(type)) {
            sql.append(" AND (a.action_type LIKE '%OWNER%' OR a.action_type LIKE '%TRANSFER%')");
        } else if ("USER_ROLE".equals(type) || "ROLE".equals(type) || "ASSIGN".equals(type)) {
            sql.append(" AND (a.action_type LIKE '%ROLE%' OR a.action_type LIKE '%ASSIGN%')");
        } else {
            sql.append(" AND a.action_type LIKE ?");
            params.add("%" + entityType.trim() + "%");
        }
    }

    private AuditLog mapResultSetToAuditLog(ResultSet rs) throws SQLException {
        AuditLog log = new AuditLog();
        log.setLogId(rs.getInt("log_id"));
        log.setAction(rs.getString("action_type"));
        log.setUserId(rs.getInt("performed_by"));
        try { log.setPerformedByName(rs.getString("performed_by_name")); } catch (SQLException ignored) {}
        log.setTargetUserId(rs.getInt("target_user_id"));
        log.setDetails(rs.getString("description"));
        try { log.setOldValue(rs.getString("old_value")); } catch (SQLException ignored) {}
        try { log.setNewValue(rs.getString("new_value")); } catch (SQLException ignored) {}
        log.setCreatedAt(rs.getTimestamp("created_at"));
        return log;
    }
}

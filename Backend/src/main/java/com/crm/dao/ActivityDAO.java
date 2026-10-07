package com.crm.dao;

import com.crm.model.Activity;
import com.crm.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ActivityDAO {

    public ActivityDAO() {
        ensureSchema();
    }

    private void ensureSchema() {
        String alterSql = "ALTER TABLE activities " +
                "ADD COLUMN IF NOT EXISTS customer_id INT NULL, " +
                "ADD COLUMN IF NOT EXISTS activity_type VARCHAR(50) DEFAULT 'NOTE', " +
                "ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP;";
        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement()) {
            try { stmt.executeUpdate(alterSql); } catch (SQLException ignored) {}
        } catch (SQLException e) {
            // connection might be unavailable in static context
        }
    }

    private Activity mapResultSetToActivity(ResultSet rs) throws SQLException {
        Activity obj = new Activity();
        obj.setActivityid(rs.getInt("activity_id"));
        obj.setTitle(rs.getString("title"));
        obj.setDescription(rs.getString("description"));
        obj.setOwnerId(rs.getInt("owner_id"));
        obj.setCreatedAt(rs.getTimestamp("created_at"));

        try {
            int cid = rs.getInt("customer_id");
            if (!rs.wasNull()) obj.setCustomerId(cid);
        } catch (SQLException ignored) {}

        try { obj.setActivityType(rs.getString("activity_type")); } catch (SQLException ignored) {}
        try { obj.setUpdatedAt(rs.getTimestamp("updated_at")); } catch (SQLException ignored) {}

        return obj;
    }

    public List<Activity> getList(String keyword, List<Integer> ownerIds, int page, int pageSize) {
        if (ownerIds != null && ownerIds.isEmpty()) return new ArrayList<>();
        
        List<Activity> list = new ArrayList<>();
        String sql = "SELECT * FROM activities WHERE 1=1";
        if (keyword != null && !keyword.trim().isEmpty()) {
            sql += " AND title LIKE ?";
        }
        
        if (ownerIds != null) {
            String inClause = String.join(",", java.util.Collections.nCopies(ownerIds.size(), "?"));
            sql += " AND owner_id IN (" + inClause + ")";
        }
        
        sql += " ORDER BY activity_id DESC LIMIT ? OFFSET ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            int idx = 1;
            if (keyword != null && !keyword.trim().isEmpty()) {
                ps.setString(idx++, "%" + keyword.trim() + "%");
            }
            if (ownerIds != null) {
                for (Integer oid : ownerIds) {
                    ps.setInt(idx++, oid);
                }
            }
            ps.setInt(idx++, pageSize);
            ps.setInt(idx++, (page - 1) * pageSize);

            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                list.add(mapResultSetToActivity(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public int count(String keyword, List<Integer> ownerIds) {
        if (ownerIds != null && ownerIds.isEmpty()) return 0;
        
        String sql = "SELECT COUNT(*) FROM activities WHERE 1=1";
        if (keyword != null && !keyword.trim().isEmpty()) {
            sql += " AND title LIKE ?";
        }
        if (ownerIds != null) {
            String inClause = String.join(",", java.util.Collections.nCopies(ownerIds.size(), "?"));
            sql += " AND owner_id IN (" + inClause + ")";
        }

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            int idx = 1;
            if (keyword != null && !keyword.trim().isEmpty()) {
                ps.setString(idx++, "%" + keyword.trim() + "%");
            }
            if (ownerIds != null) {
                for (Integer oid : ownerIds) {
                    ps.setInt(idx++, oid);
                }
            }
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    public Activity findById(int id) {
        String sql = "SELECT * FROM activities WHERE activity_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return mapResultSetToActivity(rs);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public List<Activity> getActivitiesByCustomerId(int customerId, int page, int pageSize) {
        List<Activity> list = new ArrayList<>();
        int p = page <= 0 ? 1 : page;
        int psz = pageSize <= 0 ? 20 : pageSize;
        int offset = (p - 1) * psz;

        String sql = "SELECT * FROM activities WHERE customer_id = ? ORDER BY created_at DESC, activity_id DESC LIMIT ? OFFSET ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, customerId);
            ps.setInt(2, psz);
            ps.setInt(3, offset);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                list.add(mapResultSetToActivity(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public int countByCustomerId(int customerId) {
        String sql = "SELECT COUNT(*) FROM activities WHERE customer_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, customerId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }
}

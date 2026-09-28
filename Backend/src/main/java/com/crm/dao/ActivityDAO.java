package com.crm.dao;

import com.crm.model.Activity;
import com.crm.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ActivityDAO {

    private Activity mapResultSetToActivity(ResultSet rs) throws SQLException {
        Activity obj = new Activity();
        obj.setActivityid(rs.getInt("activity_id"));
        obj.setTitle(rs.getString("title"));
        obj.setDescription(rs.getString("description"));
        obj.setOwnerId(rs.getInt("owner_id"));
        obj.setCreatedAt(rs.getTimestamp("created_at"));
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
}

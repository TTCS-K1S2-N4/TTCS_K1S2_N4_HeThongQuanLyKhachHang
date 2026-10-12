package com.crm.dao;

import com.crm.model.LeadSource;
import com.crm.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class LeadSourceDAO {

    public List<LeadSource> getAllSources() {
        List<LeadSource> list = new ArrayList<>();
        String sql = "SELECT * FROM lead_sources ORDER BY source_name ASC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapResultSet(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<LeadSource> getActiveSources() {
        List<LeadSource> list = new ArrayList<>();
        String sql = "SELECT * FROM lead_sources WHERE is_active = 1 ORDER BY source_name ASC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapResultSet(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public LeadSource getById(int sourceId) {
        String sql = "SELECT * FROM lead_sources WHERE source_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, sourceId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSet(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public LeadSource getByCode(String code) {
        if (code == null) return null;
        String sql = "SELECT * FROM lead_sources WHERE source_code = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, code.trim());
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSet(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public LeadSource getByName(String name) {
        if (name == null) return null;
        String sql = "SELECT * FROM lead_sources WHERE source_name = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, name.trim());
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSet(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public boolean createSource(LeadSource source) {
        String sql = "INSERT INTO lead_sources (source_code, source_name, description, is_active) VALUES (?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, source.getSourceCode());
            ps.setString(2, source.getSourceName());
            ps.setString(3, source.getDescription());
            ps.setBoolean(4, source.isActive());
            int rows = ps.executeUpdate();
            if (rows > 0) {
                try (ResultSet keys = ps.getGeneratedKeys()) {
                    if (keys.next()) {
                        source.setSourceId(keys.getInt(1));
                    }
                }
                return true;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    private LeadSource mapResultSet(ResultSet rs) throws SQLException {
        LeadSource source = new LeadSource();
        source.setSourceId(rs.getInt("source_id"));
        source.setSourceCode(rs.getString("source_code"));
        source.setSourceName(rs.getString("source_name"));
        source.setDescription(rs.getString("description"));
        source.setActive(rs.getBoolean("is_active"));
        source.setCreatedAt(rs.getTimestamp("created_at"));
        return source;
    }
}

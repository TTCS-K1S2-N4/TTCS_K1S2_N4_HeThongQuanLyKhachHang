package com.crm.dao;

import com.crm.model.SavedFilter;
import com.crm.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class SavedFilterDAO {

    public SavedFilterDAO() {
        ensureTableExists();
    }

    private void ensureTableExists() {
        String sql = "CREATE TABLE IF NOT EXISTS saved_filters (" +
                "filter_id INT AUTO_INCREMENT PRIMARY KEY, " +
                "user_id INT NOT NULL, " +
                "filter_name VARCHAR(100) NOT NULL, " +
                "module VARCHAR(50) DEFAULT 'CUSTOMER', " +
                "keyword VARCHAR(200), " +
                "status VARCHAR(50), " +
                "industry VARCHAR(100), " +
                "company_size VARCHAR(50), " +
                "region VARCHAR(100), " +
                "owner_id INT, " +
                "filter_query TEXT, " +
                "is_default TINYINT(1) DEFAULT 0, " +
                "created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, " +
                "updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP" +
                ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;";
        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement()) {
            stmt.executeUpdate(sql);
        } catch (SQLException e) {
            // Log or ignore if already existing
        }
    }

    private SavedFilter mapResultSetToSavedFilter(ResultSet rs) throws SQLException {
        SavedFilter obj = new SavedFilter();
        obj.setFilterId(rs.getInt("filter_id"));
        obj.setUserId(rs.getInt("user_id"));
        obj.setFilterName(rs.getString("filter_name"));
        obj.setModule(rs.getString("module"));
        obj.setKeyword(rs.getString("keyword"));
        obj.setStatus(rs.getString("status"));
        obj.setIndustry(rs.getString("industry"));
        obj.setCompanySize(rs.getString("company_size"));
        obj.setRegion(rs.getString("region"));
        int oid = rs.getInt("owner_id");
        if (!rs.wasNull()) {
            obj.setOwnerId(oid);
        }
        obj.setFilterQuery(rs.getString("filter_query"));
        obj.setDefault(rs.getBoolean("is_default"));
        obj.setCreatedAt(rs.getTimestamp("created_at"));
        obj.setUpdatedAt(rs.getTimestamp("updated_at"));
        return obj;
    }

    public boolean createSavedFilter(SavedFilter filter) {
        String sql = "INSERT INTO saved_filters (user_id, filter_name, module, keyword, status, industry, company_size, region, owner_id, filter_query, is_default) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, filter.getUserId());
            ps.setString(2, filter.getFilterName());
            ps.setString(3, filter.getModule() != null ? filter.getModule() : "CUSTOMER");
            ps.setString(4, filter.getKeyword());
            ps.setString(5, filter.getStatus());
            ps.setString(6, filter.getIndustry());
            ps.setString(7, filter.getCompanySize());
            ps.setString(8, filter.getRegion());
            if (filter.getOwnerId() != null) {
                ps.setInt(9, filter.getOwnerId());
            } else {
                ps.setNull(9, Types.INTEGER);
            }
            ps.setString(10, filter.getFilterQuery());
            ps.setBoolean(11, filter.isDefault());

            int rows = ps.executeUpdate();
            if (rows > 0) {
                ResultSet rs = ps.getGeneratedKeys();
                if (rs.next()) {
                    filter.setFilterId(rs.getInt(1));
                }
                return true;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public List<SavedFilter> getSavedFiltersByUserId(int userId) {
        List<SavedFilter> list = new ArrayList<>();
        String sql = "SELECT * FROM saved_filters WHERE user_id = ? ORDER BY is_default DESC, filter_id DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                list.add(mapResultSetToSavedFilter(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public SavedFilter findById(int filterId, int userId) {
        String sql = "SELECT * FROM saved_filters WHERE filter_id = ? AND user_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, filterId);
            ps.setInt(2, userId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return mapResultSetToSavedFilter(rs);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public boolean deleteSavedFilter(int filterId, int userId) {
        String sql = "DELETE FROM saved_filters WHERE filter_id = ? AND user_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, filterId);
            ps.setInt(2, userId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
}

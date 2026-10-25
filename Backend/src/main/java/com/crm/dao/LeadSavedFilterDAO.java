package com.crm.dao;

import com.crm.model.LeadSavedFilter;
import com.crm.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * DAO xử lý lưu trữ và truy vấn Bộ lọc Lead của người dùng (S4-09-AC-03).
 * Tái sử dụng bảng saved_filters dùng chung với module = 'LEAD'.
 */
public class LeadSavedFilterDAO {

    private static final Logger LOGGER = Logger.getLogger(LeadSavedFilterDAO.class.getName());

    public LeadSavedFilterDAO() {
        // Constructor nhẹ không chạy lệnh DDL runtime
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
            LOGGER.log(Level.WARNING, "Bỏ qua lỗi kiểm tra bảng saved_filters: " + e.getMessage());
        }
    }

    public boolean createSavedFilter(LeadSavedFilter filter) {
        String sql = "INSERT INTO saved_filters (user_id, filter_name, module, keyword, status, owner_id, filter_query, is_default) " +
                     "VALUES (?, ?, 'LEAD', ?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, filter.getUserId());
            ps.setString(2, filter.getFilterName());
            ps.setString(3, filter.getKeyword());
            ps.setString(4, filter.getStatus());
            if (filter.getOwnerId() != null) {
                ps.setInt(5, filter.getOwnerId());
            } else {
                ps.setNull(5, Types.INTEGER);
            }
            ps.setString(6, filter.getFilterQuery());
            ps.setBoolean(7, filter.isDefault());

            int affected = ps.executeUpdate();
            if (affected > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        filter.setFilterId(rs.getInt(1));
                    }
                }
                return true;
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Lỗi tạo saved filter cho Lead: " + e.getMessage(), e);
        }
        return false;
    }

    public List<LeadSavedFilter> getSavedFiltersByUserId(int userId) {
        List<LeadSavedFilter> list = new ArrayList<>();
        String sql = "SELECT * FROM saved_filters WHERE user_id = ? AND module = 'LEAD' ORDER BY is_default DESC, filter_id DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSet(rs));
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Lỗi lấy danh sách saved filters của userId=" + userId + ": " + e.getMessage(), e);
        }
        return list;
    }

    public LeadSavedFilter findById(int filterId, int userId) {
        String sql = "SELECT * FROM saved_filters WHERE filter_id = ? AND user_id = ? AND module = 'LEAD'";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, filterId);
            ps.setInt(2, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSet(rs);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Lỗi tìm saved filter #" + filterId + ": " + e.getMessage(), e);
        }
        return null;
    }

    public boolean deleteSavedFilter(int filterId, int userId) {
        String sql = "DELETE FROM saved_filters WHERE filter_id = ? AND user_id = ? AND module = 'LEAD'";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, filterId);
            ps.setInt(2, userId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Lỗi xóa saved filter #" + filterId + ": " + e.getMessage(), e);
        }
        return false;
    }

    public boolean existsByName(int userId, String filterName) {
        if (filterName == null || filterName.trim().isEmpty()) return false;
        String sql = "SELECT 1 FROM saved_filters WHERE user_id = ? AND filter_name = ? AND module = 'LEAD' LIMIT 1";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setString(2, filterName.trim());
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Lỗi kiểm tra trùng tên saved filter: " + e.getMessage(), e);
        }
        return false;
    }

    private LeadSavedFilter mapResultSet(ResultSet rs) throws SQLException {
        LeadSavedFilter filter = new LeadSavedFilter();
        filter.setFilterId(rs.getInt("filter_id"));
        filter.setUserId(rs.getInt("user_id"));
        filter.setFilterName(rs.getString("filter_name"));
        filter.setModule(rs.getString("module"));
        String fq = rs.getString("filter_query");
        filter.setFilterQuery(fq);

        String kw = rs.getString("keyword");
        if ((kw == null || kw.isEmpty()) && fq != null) {
            kw = extractQueryParam(fq, "keyword");
            if (kw == null) kw = extractQueryParam(fq, "search");
        }
        filter.setKeyword(kw);

        String st = rs.getString("status");
        if ((st == null || st.isEmpty()) && fq != null) {
            st = extractQueryParam(fq, "status");
        }
        filter.setStatus(st);

        int oid = rs.getInt("owner_id");
        if (!rs.wasNull()) {
            filter.setOwnerId(oid);
        } else if (fq != null) {
            String oidStr = extractQueryParam(fq, "ownerId");
            if (oidStr != null && !"MY".equalsIgnoreCase(oidStr)) {
                try { filter.setOwnerId(Integer.parseInt(oidStr)); } catch (NumberFormatException ignore) {}
            }
        }

        if (fq != null && !fq.isEmpty()) {
            filter.setSource(extractQueryParam(fq, "source"));
            String cls = extractQueryParam(fq, "classification");
            if (cls == null) {
                cls = extractQueryParam(fq, "rating");
            }
            filter.setClassification(cls);
            filter.setFromDate(extractQueryParam(fq, "fromDate"));
            filter.setToDate(extractQueryParam(fq, "toDate"));
            String ov = extractQueryParam(fq, "overdue");
            if (ov != null) {
                filter.setOverdue("true".equalsIgnoreCase(ov) || "1".equals(ov));
            }
        }
        filter.setDefault(rs.getBoolean("is_default"));
        filter.setCreatedAt(rs.getTimestamp("created_at"));
        filter.setUpdatedAt(rs.getTimestamp("updated_at"));
        return filter;
    }

    private String extractQueryParam(String query, String key) {
        if (query == null || key == null) return null;
        for (String param : query.split("&")) {
            String[] pair = param.split("=", 2);
            if (pair.length == 2 && key.equalsIgnoreCase(pair[0])) {
                try {
                    return java.net.URLDecoder.decode(pair[1], java.nio.charset.StandardCharsets.UTF_8.name());
                } catch (Exception e) {
                    return pair[1];
                }
            }
        }
        return null;
    }
}

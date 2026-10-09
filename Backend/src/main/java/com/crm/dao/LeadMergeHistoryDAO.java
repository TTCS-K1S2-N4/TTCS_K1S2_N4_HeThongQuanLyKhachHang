package com.crm.dao;

import com.crm.model.LeadMergeHistory;
import com.crm.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * DAO xử lý truy vấn lưu và đọc lịch sử gộp Lead (Lead Merge History).
 * Hỗ trợ tham gia transaction chung thông qua Connection truyền từ Service.
 */
public class LeadMergeHistoryDAO {

    private static final Logger LOGGER = Logger.getLogger(LeadMergeHistoryDAO.class.getName());

    public LeadMergeHistoryDAO() {
        ensureSchema();
    }

    /**
     * Tự động khởi tạo schema bảng lead_merge_history và bảng leads nếu chưa có.
     */
    public void ensureSchema() {
        try (Connection conn = DBConnection.getConnection()) {
            if (conn == null) return;

            String createHistoryTableSql = "CREATE TABLE IF NOT EXISTS lead_merge_history (" +
                    "merge_id INT AUTO_INCREMENT PRIMARY KEY, " +
                    "primary_lead_id INT NOT NULL, " +
                    "duplicate_lead_id INT NOT NULL, " +
                    "merged_by INT NULL, " +
                    "merged_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, " +
                    "retained_fields TEXT NULL, " +
                    "note TEXT NULL" +
                    ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;";

            String createLeadsTableSql = "CREATE TABLE IF NOT EXISTS leads (" +
                    "lead_id INT AUTO_INCREMENT PRIMARY KEY, " +
                    "full_name VARCHAR(150), " +
                    "company_name VARCHAR(200), " +
                    "email VARCHAR(150), " +
                    "phone VARCHAR(50), " +
                    "status VARCHAR(50) DEFAULT 'NEW', " +
                    "owner_id INT NULL, " +
                    "campaign_id INT NULL, " +
                    "customer_id INT NULL, " +
                    "source VARCHAR(100) NULL, " +
                    "created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, " +
                    "updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP" +
                    ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;";

            try (Statement stmt = conn.createStatement()) {
                stmt.executeUpdate(createHistoryTableSql);
                stmt.executeUpdate(createLeadsTableSql);
            } catch (SQLException e) {
                LOGGER.log(Level.FINE, "Ghi nhận khởi tạo bảng: " + e.getMessage());
            }
        } catch (SQLException e) {
            LOGGER.log(Level.WARNING, "Không thể kết nối DB trong ensureSchema của LeadMergeHistoryDAO: " + e.getMessage());
        }
    }

    /**
     * Lưu nhật ký gộp Lead bằng Connection độc lập.
     */
    public int save(LeadMergeHistory history) {
        try (Connection conn = DBConnection.getConnection()) {
            return save(history, conn);
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Lỗi khi lưu LeadMergeHistory", e);
            return -1;
        }
    }

    /**
     * Lưu nhật ký gộp Lead trong cùng một Transaction Connection.
     * Đảm bảo tính atomic: nếu lưu log thất bại thì toàn bộ thao tác gộp sẽ rollback.
     */
    public int save(LeadMergeHistory history, Connection conn) throws SQLException {
        if (history == null || conn == null) {
            throw new IllegalArgumentException("History hoặc Connection không được để null");
        }

        String sql = "INSERT INTO lead_merge_history (primary_lead_id, duplicate_lead_id, merged_by, merged_at, retained_fields, note) " +
                "VALUES (?, ?, ?, ?, ?, ?)";

        try (PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, history.getPrimaryLeadId());
            ps.setInt(2, history.getDuplicateLeadId());
            if (history.getMergedBy() != null) {
                ps.setInt(3, history.getMergedBy());
            } else {
                ps.setNull(3, Types.INTEGER);
            }
            ps.setTimestamp(4, history.getMergedAt() != null ? history.getMergedAt() : new Timestamp(System.currentTimeMillis()));
            ps.setString(5, history.getRetainedFields());
            ps.setString(6, history.getNote());

            int affected = ps.executeUpdate();
            if (affected > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        int genId = rs.getInt(1);
                        history.setMergeId(genId);
                        return genId;
                    }
                }
            }
        }
        return -1;
    }

    /**
     * Lấy danh sách lịch sử gộp của một Lead (với tư cách là bản ghi chính hoặc bản ghi bị gộp).
     */
    public List<LeadMergeHistory> findByLeadId(int leadId) {
        List<LeadMergeHistory> list = new ArrayList<>();
        String sql = "SELECT h.*, u.full_name AS merged_by_name FROM lead_merge_history h " +
                "LEFT JOIN users u ON h.merged_by = u.user_id " +
                "WHERE h.primary_lead_id = ? OR h.duplicate_lead_id = ? " +
                "ORDER BY h.merge_id DESC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, leadId);
            ps.setInt(2, leadId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRow(rs));
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Lỗi khi tìm LeadMergeHistory theo leadId=" + leadId, e);
        }
        return list;
    }

    /**
     * Tìm chi tiết lịch sử gộp theo mergeId.
     */
    public LeadMergeHistory findById(int mergeId) {
        String sql = "SELECT h.*, u.full_name AS merged_by_name FROM lead_merge_history h " +
                "LEFT JOIN users u ON h.merged_by = u.user_id " +
                "WHERE h.merge_id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, mergeId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Lỗi khi tìm LeadMergeHistory theo id=" + mergeId, e);
        }
        return null;
    }

    private LeadMergeHistory mapRow(ResultSet rs) throws SQLException {
        LeadMergeHistory h = new LeadMergeHistory();
        h.setMergeId(rs.getInt("merge_id"));
        h.setPrimaryLeadId(rs.getInt("primary_lead_id"));
        h.setDuplicateLeadId(rs.getInt("duplicate_lead_id"));
        h.setMergedBy(rs.getObject("merged_by") != null ? rs.getInt("merged_by") : null);
        try {
            h.setMergedByName(rs.getString("merged_by_name"));
        } catch (SQLException ignored) {}
        h.setMergedAt(rs.getTimestamp("merged_at"));
        h.setRetainedFields(rs.getString("retained_fields"));
        h.setNote(rs.getString("note"));
        return h;
    }
}

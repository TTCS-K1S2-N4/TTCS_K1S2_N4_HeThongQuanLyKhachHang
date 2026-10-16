package com.crm.dao;

import com.crm.model.LeadAssignmentHistory;
import com.crm.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * LeadAssignmentHistoryDAO - Ghi nhận và truy vấn lịch sử phân bổ Lead trong MySQL crm_db.
 * Hỗ trợ tham gia vào Transaction bằng Connection truyền vào.
 */
public class LeadAssignmentHistoryDAO {

    private static final Logger LOGGER = Logger.getLogger(LeadAssignmentHistoryDAO.class.getName());

    /**
     * Ghi nhận lịch sử phân bổ trong cùng Transaction Connection.
     */
    public boolean saveHistory(Connection conn, LeadAssignmentHistory history) throws SQLException {
        String sql = "INSERT INTO lead_assignment_history " +
                     "(lead_id, rule_id, assigned_to, performed_by, status, assigned_at, reject_reason) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?)";
        try (PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            stmt.setInt(1, history.getLeadId());

            if (history.getRuleId() != null) {
                stmt.setInt(2, history.getRuleId());
            } else {
                stmt.setNull(2, Types.INTEGER);
            }

            if (history.getAssignedTo() != null) {
                stmt.setInt(3, history.getAssignedTo());
            } else {
                stmt.setNull(3, Types.INTEGER);
            }

            if (history.getPerformedBy() != null) {
                stmt.setInt(4, history.getPerformedBy());
            } else {
                stmt.setNull(4, Types.INTEGER);
            }

            stmt.setString(5, history.getStatus() != null ? history.getStatus() : "ASSIGNED");

            Timestamp assignedAt = history.getAssignedAt() != null
                    ? history.getAssignedAt()
                    : new Timestamp(System.currentTimeMillis());
            stmt.setTimestamp(6, assignedAt);

            if (history.getRejectReason() != null) {
                stmt.setString(7, history.getRejectReason());
            } else {
                stmt.setNull(7, Types.VARCHAR);
            }

            int affected = stmt.executeUpdate();
            if (affected > 0) {
                try (ResultSet keys = stmt.getGeneratedKeys()) {
                    if (keys.next()) {
                        history.setHistoryId(keys.getInt(1));
                    }
                }
                return true;
            }
        }
        return false;
    }

    /**
     * Ghi nhận lịch sử với kết nối độc lập.
     */
    public boolean saveHistory(LeadAssignmentHistory history) {
        try (Connection conn = DBConnection.getConnection()) {
            return saveHistory(conn, history);
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Lỗi lưu lịch sử phân bổ Lead", e);
            return false;
        }
    }

    /**
     * Truy vấn timeline lịch sử phân bổ của một Lead.
     */
    public List<LeadAssignmentHistory> getHistoryByLeadId(int leadId) {
        List<LeadAssignmentHistory> list = new ArrayList<>();
        String sql = "SELECT history_id, lead_id, rule_id, assigned_to, performed_by, status, assigned_at, reject_reason " +
                     "FROM lead_assignment_history " +
                     "WHERE lead_id = ? " +
                     "ORDER BY assigned_at DESC, history_id DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, leadId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    LeadAssignmentHistory h = new LeadAssignmentHistory();
                    h.setHistoryId(rs.getInt("history_id"));
                    h.setLeadId(rs.getInt("lead_id"));

                    int rId = rs.getInt("rule_id");
                    if (!rs.wasNull()) h.setRuleId(rId);

                    int aTo = rs.getInt("assigned_to");
                    if (!rs.wasNull()) h.setAssignedTo(aTo);

                    int pBy = rs.getInt("performed_by");
                    if (!rs.wasNull()) h.setPerformedBy(pBy);

                    h.setStatus(rs.getString("status"));
                    h.setAssignedAt(rs.getTimestamp("assigned_at"));
                    h.setRejectReason(rs.getString("reject_reason"));
                    list.add(h);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Lỗi truy vấn lịch sử phân bổ Lead #" + leadId, e);
        }
        return list;
    }
}

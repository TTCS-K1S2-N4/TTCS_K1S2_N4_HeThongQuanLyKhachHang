package com.crm.dao;

import com.crm.model.ContactCompanyHistory;
import com.crm.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

public class ContactCompanyHistoryDAO {
    private static final Logger LOGGER = Logger.getLogger(ContactCompanyHistoryDAO.class.getName());

    private ContactCompanyHistory mapResultSetToHistory(ResultSet rs) throws SQLException {
        ContactCompanyHistory history = new ContactCompanyHistory();
        history.setHistoryId(rs.getInt("history_id"));
        history.setContactId(rs.getInt("contact_id"));
        history.setOldCustomerId(rs.getInt("old_customer_id"));
        history.setNewCustomerId(rs.getInt("new_customer_id"));

        int tb = rs.getInt("transferred_by");
        history.setTransferredBy(rs.wasNull() ? null : tb);
        history.setTransferredAt(rs.getTimestamp("transferred_at"));

        try {
            history.setOldCustomerName(rs.getString("old_customer_name"));
        } catch (SQLException ignored) {}

        try {
            history.setNewCustomerName(rs.getString("new_customer_name"));
        } catch (SQLException ignored) {}

        try {
            history.setTransferredByName(rs.getString("transferred_by_name"));
        } catch (SQLException ignored) {}

        return history;
    }

    public boolean insert(ContactCompanyHistory history, Connection externalConn) throws SQLException {
        String sql = "INSERT INTO contact_company_history (contact_id, old_customer_id, new_customer_id, transferred_by) " +
                     "VALUES (?, ?, ?, ?)";

        Connection conn = externalConn != null ? externalConn : DBConnection.getConnection();
        boolean autoClose = externalConn == null;

        try (PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, history.getContactId());
            ps.setInt(2, history.getOldCustomerId());
            ps.setInt(3, history.getNewCustomerId());
            if (history.getTransferredBy() != null) {
                ps.setInt(4, history.getTransferredBy());
            } else {
                ps.setNull(4, Types.INTEGER);
            }

            int affectedRows = ps.executeUpdate();
            if (affectedRows > 0) {
                try (ResultSet keys = ps.getGeneratedKeys()) {
                    if (keys.next()) {
                        history.setHistoryId(keys.getInt(1));
                    }
                }
                return true;
            }
            return false;
        } finally {
            if (autoClose && conn != null) {
                conn.close();
            }
        }
    }

    public List<ContactCompanyHistory> getByContactId(int contactId) {
        List<ContactCompanyHistory> list = new ArrayList<>();
        String sql = "SELECT h.*, " +
                     "c_old.customer_name AS old_customer_name, " +
                     "c_new.customer_name AS new_customer_name, " +
                     "u.full_name AS transferred_by_name " +
                     "FROM contact_company_history h " +
                     "LEFT JOIN customers c_old ON h.old_customer_id = c_old.customer_id " +
                     "LEFT JOIN customers c_new ON h.new_customer_id = c_new.customer_id " +
                     "LEFT JOIN users u ON h.transferred_by = u.user_id " +
                     "WHERE h.contact_id = ? " +
                     "ORDER BY h.transferred_at DESC, h.history_id DESC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, contactId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSetToHistory(rs));
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Lỗi khi truy vấn lịch sử chuyển công ty cho contactId=" + contactId, e);
        }
        return list;
    }
}

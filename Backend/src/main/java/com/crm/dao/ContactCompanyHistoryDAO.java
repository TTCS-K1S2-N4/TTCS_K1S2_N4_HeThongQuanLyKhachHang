package com.crm.dao;

import com.crm.model.ContactCompanyHistory;
import com.crm.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * DAO lưu vết lịch sử chuyển đổi công ty của Người liên hệ.
 * Task S30-03 / S3-02.
 */
public class ContactCompanyHistoryDAO {

    private static final Logger LOGGER = Logger.getLogger(ContactCompanyHistoryDAO.class.getName());

    private ContactCompanyHistory mapResultSet(ResultSet rs) throws SQLException {
        ContactCompanyHistory h = new ContactCompanyHistory();
        h.setHistoryId(rs.getInt("history_id"));
        h.setContactId(rs.getInt("contact_id"));
        h.setFromCustomerId(rs.getInt("from_customer_id"));
        h.setToCustomerId(rs.getInt("to_customer_id"));
        h.setTransferredAt(rs.getTimestamp("transferred_at"));
        h.setReason(rs.getString("reason"));
        int transferredBy = rs.getInt("transferred_by");
        if (!rs.wasNull()) {
            h.setTransferredBy(transferredBy);
        }

        try {
            h.setFromCustomerName(rs.getString("from_customer_name"));
        } catch (SQLException ignored) {}
        try {
            h.setToCustomerName(rs.getString("to_customer_name"));
        } catch (SQLException ignored) {}
        try {
            h.setTransferredByName(rs.getString("transferred_by_name"));
        } catch (SQLException ignored) {}

        return h;
    }

    public boolean insert(ContactCompanyHistory history) {
        try (Connection conn = DBConnection.getConnection()) {
            return insert(history, conn);
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Lỗi kết nối khi insert ContactCompanyHistory", e);
            return false;
        }
    }

    public boolean insert(ContactCompanyHistory history, Connection conn) throws SQLException {
        String sql = "INSERT INTO contact_company_history (contact_id, from_customer_id, to_customer_id, reason, transferred_by) " +
                     "VALUES (?, ?, ?, ?, ?)";
        try (PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, history.getContactId());
            ps.setInt(2, history.getFromCustomerId());
            ps.setInt(3, history.getToCustomerId());
            ps.setString(4, history.getReason());
            if (history.getTransferredBy() != null) {
                ps.setInt(5, history.getTransferredBy());
            } else {
                ps.setNull(5, Types.INTEGER);
            }

            int affected = ps.executeUpdate();
            if (affected > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        history.setHistoryId(rs.getInt(1));
                    }
                }
                return true;
            }
        }
        return false;
    }

    public List<ContactCompanyHistory> findByContactId(int contactId) {
        List<ContactCompanyHistory> list = new ArrayList<>();
        String sql = "SELECT h.*, " +
                     "       fc.customer_name AS from_customer_name, " +
                     "       tc.customer_name AS to_customer_name, " +
                     "       u.full_name AS transferred_by_name " +
                     "FROM contact_company_history h " +
                     "LEFT JOIN customers fc ON h.from_customer_id = fc.customer_id " +
                     "LEFT JOIN customers tc ON h.to_customer_id = tc.customer_id " +
                     "LEFT JOIN users u ON h.transferred_by = u.user_id " +
                     "WHERE h.contact_id = ? " +
                     "ORDER BY h.transferred_at DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, contactId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSet(rs));
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Lỗi truy vấn lịch sử Contact theo contactId: " + contactId, e);
        }
        return list;
    }

    public List<ContactCompanyHistory> findByCustomerId(int customerId) {
        List<ContactCompanyHistory> list = new ArrayList<>();
        String sql = "SELECT h.*, " +
                     "       fc.customer_name AS from_customer_name, " +
                     "       tc.customer_name AS to_customer_name, " +
                     "       u.full_name AS transferred_by_name " +
                     "FROM contact_company_history h " +
                     "LEFT JOIN customers fc ON h.from_customer_id = fc.customer_id " +
                     "LEFT JOIN customers tc ON h.to_customer_id = tc.customer_id " +
                     "LEFT JOIN users u ON h.transferred_by = u.user_id " +
                     "WHERE h.from_customer_id = ? OR h.to_customer_id = ? " +
                     "ORDER BY h.transferred_at DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, customerId);
            ps.setInt(2, customerId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSet(rs));
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Lỗi truy vấn lịch sử Contact theo customerId: " + customerId, e);
        }
        return list;
    }
}

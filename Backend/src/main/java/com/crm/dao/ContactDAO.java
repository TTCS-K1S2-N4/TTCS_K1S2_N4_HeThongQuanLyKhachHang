package com.crm.dao;

import com.crm.model.Contact;
import com.crm.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

public class ContactDAO {
    private static final Logger LOGGER = Logger.getLogger(ContactDAO.class.getName());

    private Contact mapResultSetToContact(ResultSet rs) throws SQLException {
        Contact contact = new Contact();
        contact.setContactId(rs.getInt("contact_id"));
        contact.setCustomerId(rs.getInt("customer_id"));
        contact.setFullName(rs.getString("full_name"));
        contact.setTitle(rs.getString("title"));
        contact.setEmail(rs.getString("email"));
        contact.setPhone(rs.getString("phone"));
        contact.setBuyingRole(rs.getString("buying_role"));
        contact.setPrimary(rs.getBoolean("is_primary"));
        contact.setCreatedAt(rs.getTimestamp("created_at"));
        contact.setUpdatedAt(rs.getTimestamp("updated_at"));

        try {
            contact.setCustomerName(rs.getString("customer_name"));
        } catch (SQLException ignored) {
            // Field customer_name may not be present in basic query
        }

        return contact;
    }

    public List<Contact> getByCustomerId(int customerId) {
        List<Contact> list = new ArrayList<>();
        String sql = "SELECT c.*, cust.customer_name FROM contacts c " +
                     "LEFT JOIN customers cust ON c.customer_id = cust.customer_id " +
                     "WHERE c.customer_id = ? " +
                     "ORDER BY c.is_primary DESC, c.contact_id DESC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, customerId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSetToContact(rs));
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Lỗi khi lấy danh sách người liên hệ cho customerId=" + customerId, e);
        }
        return list;
    }

    public Contact findById(int contactId) {
        String sql = "SELECT c.*, cust.customer_name FROM contacts c " +
                     "LEFT JOIN customers cust ON c.customer_id = cust.customer_id " +
                     "WHERE c.contact_id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, contactId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToContact(rs);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Lỗi khi tìm người liên hệ theo contactId=" + contactId, e);
        }
        return null;
    }

    public int insert(Contact contact, Connection externalConn) throws SQLException {
        String sql = "INSERT INTO contacts (customer_id, full_name, title, email, phone, buying_role, is_primary) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?)";
        
        Connection conn = externalConn != null ? externalConn : DBConnection.getConnection();
        boolean autoClose = externalConn == null;

        try (PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, contact.getCustomerId());
            ps.setString(2, contact.getFullName());
            ps.setString(3, contact.getTitle());
            ps.setString(4, contact.getEmail());
            ps.setString(5, contact.getPhone());
            ps.setString(6, contact.getBuyingRole() != null ? contact.getBuyingRole().toUpperCase() : "DECISION_MAKER");
            ps.setBoolean(7, contact.isPrimary());

            int affectedRows = ps.executeUpdate();
            if (affectedRows > 0) {
                try (ResultSet generatedKeys = ps.getGeneratedKeys()) {
                    if (generatedKeys.next()) {
                        int generatedId = generatedKeys.getInt(1);
                        contact.setContactId(generatedId);
                        return generatedId;
                    }
                }
            }
            return -1;
        } finally {
            if (autoClose && conn != null) {
                conn.close();
            }
        }
    }

    public boolean update(Contact contact, Connection externalConn) throws SQLException {
        String sql = "UPDATE contacts SET full_name = ?, title = ?, email = ?, phone = ?, " +
                     "buying_role = ?, is_primary = ? WHERE contact_id = ?";

        Connection conn = externalConn != null ? externalConn : DBConnection.getConnection();
        boolean autoClose = externalConn == null;

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, contact.getFullName());
            ps.setString(2, contact.getTitle());
            ps.setString(3, contact.getEmail());
            ps.setString(4, contact.getPhone());
            ps.setString(5, contact.getBuyingRole() != null ? contact.getBuyingRole().toUpperCase() : "DECISION_MAKER");
            ps.setBoolean(6, contact.isPrimary());
            ps.setInt(7, contact.getContactId());

            return ps.executeUpdate() > 0;
        } finally {
            if (autoClose && conn != null) {
                conn.close();
            }
        }
    }

    public boolean resetPrimaryForCustomer(int customerId, Connection externalConn) throws SQLException {
        String sql = "UPDATE contacts SET is_primary = 0 WHERE customer_id = ?";

        Connection conn = externalConn != null ? externalConn : DBConnection.getConnection();
        boolean autoClose = externalConn == null;

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, customerId);
            ps.executeUpdate();
            return true;
        } finally {
            if (autoClose && conn != null) {
                conn.close();
            }
        }
    }

    public boolean setPrimary(int contactId, int customerId, Connection externalConn) throws SQLException {
        String sql = "UPDATE contacts SET is_primary = 1 WHERE contact_id = ? AND customer_id = ?";

        Connection conn = externalConn != null ? externalConn : DBConnection.getConnection();
        boolean autoClose = externalConn == null;

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, contactId);
            ps.setInt(2, customerId);
            return ps.executeUpdate() > 0;
        } finally {
            if (autoClose && conn != null) {
                conn.close();
            }
        }
    }

    public boolean updateCustomerId(int contactId, int newCustomerId, boolean isPrimary, Connection externalConn) throws SQLException {
        String sql = "UPDATE contacts SET customer_id = ?, is_primary = ? WHERE contact_id = ?";

        Connection conn = externalConn != null ? externalConn : DBConnection.getConnection();
        boolean autoClose = externalConn == null;

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, newCustomerId);
            ps.setBoolean(2, isPrimary);
            ps.setInt(3, contactId);

            return ps.executeUpdate() > 0;
        } finally {
            if (autoClose && conn != null) {
                conn.close();
            }
        }
    }
}

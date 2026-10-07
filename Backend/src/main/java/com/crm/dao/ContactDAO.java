package com.crm.dao;

import com.crm.model.Contact;
import com.crm.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * DAO quản lý dữ liệu Người liên hệ (Contact).
 * Sử dụng 100% JDBC PreparedStatement, hỗ trợ tham số Connection cho Transaction.
 * Task S30-03 / S3-02.
 */
public class ContactDAO {

    private static final Logger LOGGER = Logger.getLogger(ContactDAO.class.getName());

    private Contact mapResultSetToContact(ResultSet rs) throws SQLException {
        Contact c = new Contact();
        c.setContactId(rs.getInt("contact_id"));
        c.setCustomerId(rs.getInt("customer_id"));
        c.setFullName(rs.getString("full_name"));
        c.setTitle(rs.getString("title"));
        c.setEmail(rs.getString("email"));
        c.setPhone(rs.getString("phone"));
        c.setBuyingRole(rs.getString("buying_role"));
        c.setPrimary(rs.getBoolean("is_primary"));
        c.setCreatedAt(rs.getTimestamp("created_at"));
        c.setUpdatedAt(rs.getTimestamp("updated_at"));
        return c;
    }

    public List<Contact> findByCustomerId(int customerId) {
        List<Contact> list = new ArrayList<>();
        String sql = "SELECT * FROM contacts WHERE customer_id = ? ORDER BY is_primary DESC, contact_id ASC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, customerId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSetToContact(rs));
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Lỗi truy vấn danh sách Contact theo customerId: " + customerId, e);
        }
        return list;
    }

    public Contact findById(int contactId) {
        String sql = "SELECT * FROM contacts WHERE contact_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, contactId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToContact(rs);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Lỗi tìm Contact theo ID: " + contactId, e);
        }
        return null;
    }

    public Contact findPrimaryByCustomerId(int customerId) {
        String sql = "SELECT * FROM contacts WHERE customer_id = ? AND is_primary = 1 LIMIT 1";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, customerId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToContact(rs);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Lỗi tìm Primary Contact cho customerId: " + customerId, e);
        }
        return null;
    }

    public int insert(Contact contact) {
        try (Connection conn = DBConnection.getConnection()) {
            return insert(contact, conn);
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Lỗi kết nối khi insert Contact", e);
            return 0;
        }
    }

    public int insert(Contact contact, Connection conn) throws SQLException {
        String sql = "INSERT INTO contacts (customer_id, full_name, title, email, phone, buying_role, is_primary) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?)";
        try (PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, contact.getCustomerId());
            ps.setString(2, contact.getFullName());
            ps.setString(3, contact.getTitle());
            ps.setString(4, contact.getEmail());
            ps.setString(5, contact.getPhone());
            ps.setString(6, contact.getBuyingRole());
            ps.setBoolean(7, contact.isPrimary());

            int affected = ps.executeUpdate();
            if (affected > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        int id = rs.getInt(1);
                        contact.setContactId(id);
                        return id;
                    }
                }
            }
        }
        return 0;
    }

    public boolean update(Contact contact) {
        try (Connection conn = DBConnection.getConnection()) {
            return update(contact, conn);
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Lỗi kết nối khi update Contact", e);
            return false;
        }
    }

    public boolean update(Contact contact, Connection conn) throws SQLException {
        String sql = "UPDATE contacts SET full_name = ?, title = ?, email = ?, phone = ?, " +
                     "buying_role = ?, is_primary = ? WHERE contact_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, contact.getFullName());
            ps.setString(2, contact.getTitle());
            ps.setString(3, contact.getEmail());
            ps.setString(4, contact.getPhone());
            ps.setString(5, contact.getBuyingRole());
            ps.setBoolean(6, contact.isPrimary());
            ps.setInt(7, contact.getContactId());

            return ps.executeUpdate() > 0;
        }
    }

    public boolean resetPrimaryForCustomer(int customerId, Connection conn) throws SQLException {
        String sql = "UPDATE contacts SET is_primary = 0 WHERE customer_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, customerId);
            ps.executeUpdate();
            return true;
        }
    }

    public boolean setPrimary(int contactId, int customerId, Connection conn) throws SQLException {
        String sql = "UPDATE contacts SET is_primary = 1 WHERE contact_id = ? AND customer_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, contactId);
            ps.setInt(2, customerId);
            return ps.executeUpdate() > 0;
        }
    }

    public boolean updateCustomerId(int contactId, int newCustomerId, Connection conn) throws SQLException {
        String sql = "UPDATE contacts SET customer_id = ?, is_primary = 0 WHERE contact_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, newCustomerId);
            ps.setInt(2, contactId);
            return ps.executeUpdate() > 0;
        }
    }

    public boolean delete(int contactId) {
        String sql = "DELETE FROM contacts WHERE contact_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, contactId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Lỗi xóa Contact ID: " + contactId, e);
            return false;
        }
    }
}

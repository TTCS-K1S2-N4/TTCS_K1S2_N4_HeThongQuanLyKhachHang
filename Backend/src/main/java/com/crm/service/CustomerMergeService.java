package com.crm.service;
import com.crm.model.Customer;
import com.crm.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class CustomerMergeService {

    public List<Customer> findDuplicates() {
        List<Customer> duplicates = new ArrayList<>();
        String sql = "SELECT * FROM customers WHERE phone IN " +
                     "(SELECT phone FROM customers WHERE phone IS NOT NULL AND phone != '' GROUP BY phone HAVING COUNT(*) > 1) " +
                     "OR LOWER(TRIM(customer_name)) IN " +
                     "(SELECT LOWER(TRIM(customer_name)) FROM customers GROUP BY LOWER(TRIM(customer_name)) HAVING COUNT(*) > 1) " +
                     "OR customer_id IN " +
                     "(SELECT v1.entity_id FROM custom_field_values v1 " +
                     " JOIN custom_field_definitions d1 ON v1.field_id = d1.field_id " +
                     " WHERE d1.entity_type = 'CUSTOMER' AND d1.field_key IN ('tax_code', 'website') " +
                     "   AND v1.field_value IS NOT NULL AND v1.field_value != '' " +
                     "   AND EXISTS (SELECT 1 FROM custom_field_values v2 WHERE v2.field_id = v1.field_id " +
                     "               AND v2.entity_id != v1.entity_id " +
                     "               AND LOWER(TRIM(v2.field_value)) = LOWER(TRIM(v1.field_value))) " +
                     ") ORDER BY customer_name, phone";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Customer c = new Customer();
                c.setCustomerId(rs.getInt("customer_id"));
                c.setCustomerName(rs.getString("customer_name"));
                c.setPhone(rs.getString("phone"));
                c.setOwnerId(rs.getInt("owner_id"));
                c.setCreatedAt(rs.getTimestamp("created_at"));
                duplicates.add(c);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return duplicates;
    }

    public boolean mergeCustomers(int primaryId, int secondaryId, int mergedBy) {
        if (primaryId == secondaryId) return false;

        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            // 1. Reassign custom_field_values (ignore duplicates)
            String updateCf = "UPDATE IGNORE custom_field_values SET entity_id = ? WHERE entity_type = 'CUSTOMER' AND entity_id = ?";
            try (PreparedStatement ps = conn.prepareStatement(updateCf)) {
                ps.setInt(1, primaryId);
                ps.setInt(2, secondaryId);
                ps.executeUpdate();
            }

            // 2. Reassign customer_relationships (as parent)
            String updateRelParent = "UPDATE IGNORE customer_relationships SET parent_customer_id = ? WHERE parent_customer_id = ?";
            try (PreparedStatement ps = conn.prepareStatement(updateRelParent)) {
                ps.setInt(1, primaryId);
                ps.setInt(2, secondaryId);
                ps.executeUpdate();
            }

            // 3. Reassign customer_relationships (as child)
            String updateRelChild = "UPDATE IGNORE customer_relationships SET child_customer_id = ? WHERE child_customer_id = ?";
            try (PreparedStatement ps = conn.prepareStatement(updateRelChild)) {
                ps.setInt(1, primaryId);
                ps.setInt(2, secondaryId);
                ps.executeUpdate();
            }

            // 4. Log merge
            String logSql = "INSERT INTO customer_merges(primary_customer_id, secondary_customer_id, merged_data, merged_by) VALUES (?, ?, ?, ?)";
            try (PreparedStatement ps = conn.prepareStatement(logSql)) {
                ps.setInt(1, primaryId);
                ps.setInt(2, secondaryId);
                ps.setString(3, "{\"note\":\"Merged via system\"}");
                ps.setInt(4, mergedBy);
                ps.executeUpdate();
            }

            // 5. Delete secondary customer
            String deleteSql = "DELETE FROM customers WHERE customer_id = ?";
            try (PreparedStatement ps = conn.prepareStatement(deleteSql)) {
                ps.setInt(1, secondaryId);
                ps.executeUpdate();
            }

            conn.commit();
            return true;
        } catch (SQLException e) {
            e.printStackTrace();
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
            }
            return false;
        } finally {
            if (conn != null) {
                try {
                    conn.setAutoCommit(true);
                    conn.close();
                } catch (SQLException ex) { ex.printStackTrace(); }
            }
        }
    }
}

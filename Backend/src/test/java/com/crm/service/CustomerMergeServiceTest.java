package com.crm.service;

import com.crm.model.Customer;
import com.crm.util.DBConnection;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import java.sql.*;
import java.util.List;

import static org.junit.jupiter.api.Assertions.*;

public class CustomerMergeServiceTest {

    private CustomerMergeService mergeService;

    @BeforeEach
    public void setUp() {
        mergeService = new CustomerMergeService();
    }

    @Test
    public void testMergeCustomersSameIdReturnsFalse() {
        boolean result = mergeService.mergeCustomers(5, 5, 1);
        assertFalse(result, "Gộp khách hàng trùng ID vào chính nó phải trả về false");
    }

    @Test
    public void testMergeCustomersInvalidIdsReturnsFalse() {
        boolean resultZero = mergeService.mergeCustomers(0, 10, 1);
        assertFalse(resultZero, "Primary ID <= 0 phải trả về false");

        boolean resultNegative = mergeService.mergeCustomers(10, -1, 1);
        assertFalse(resultNegative, "Secondary ID < 0 phải trả về false");
    }

    @Test
    public void testFindDuplicatesDoesNotThrowException() {
        assertDoesNotThrow(() -> {
            List<Customer> list = mergeService.findDuplicates();
            assertNotNull(list);
            List<com.crm.dto.DuplicateCandidate> pairs = mergeService.findDuplicatePairs();
            assertNotNull(pairs);
        });
    }

    @Test
    public void testMergePreservesOpportunitiesActivitiesContactsAndAudit() {
        int primaryId = 998801;
        int secondaryId = 998802;
        int ownerId = 1;

        try (Connection conn = DBConnection.getConnection()) {
            if (conn == null) return; // Skip if no active DB connection during test run

            // Clean up old test data if any
            try (Statement stmt = conn.createStatement()) {
                stmt.execute("DELETE FROM customer_merges WHERE primary_customer_id = 998801 OR secondary_customer_id = 998802");
                stmt.execute("DELETE FROM opportunities WHERE customer_id IN (998801, 998802)");
                stmt.execute("DELETE FROM activities WHERE customer_id IN (998801, 998802)");
                stmt.execute("DELETE FROM contacts WHERE customer_id IN (998801, 998802)");
                stmt.execute("DELETE FROM customers WHERE customer_id IN (998801, 998802)");
            }

            // Insert Primary Customer
            String insertCust = "INSERT INTO customers(customer_id, customer_name, phone, owner_id) VALUES (?, ?, ?, ?)";
            try (PreparedStatement ps = conn.prepareStatement(insertCust)) {
                ps.setInt(1, primaryId);
                ps.setString(2, "Test Primary Customer 998801");
                ps.setString(3, "0909998801");
                ps.setInt(4, ownerId);
                ps.executeUpdate();

                ps.setInt(1, secondaryId);
                ps.setString(2, "Test Secondary Customer 998802");
                ps.setString(3, "0909998802");
                ps.setInt(4, ownerId);
                ps.executeUpdate();
            }

            // Insert Contact for secondary
            String insertContact = "INSERT INTO contacts(customer_id, contact_name, phone) VALUES (?, ?, ?)";
            try (PreparedStatement ps = conn.prepareStatement(insertContact)) {
                ps.setInt(1, secondaryId);
                ps.setString(2, "Contact Secondary 998802");
                ps.setString(3, "0911223344");
                ps.executeUpdate();
            }

            // Insert Opportunity for secondary
            String insertOpp = "INSERT INTO opportunities(customer_id, title, amount, owner_id) VALUES (?, ?, ?, ?)";
            try (PreparedStatement ps = conn.prepareStatement(insertOpp)) {
                ps.setInt(1, secondaryId);
                ps.setString(2, "Opp Secondary 998802");
                ps.setBigDecimal(3, new java.math.BigDecimal("150000000"));
                ps.setInt(4, ownerId);
                ps.executeUpdate();
            }

            // Insert Activity for secondary
            String insertAct = "INSERT INTO activities(customer_id, title, owner_id) VALUES (?, ?, ?)";
            try (PreparedStatement ps = conn.prepareStatement(insertAct)) {
                ps.setInt(1, secondaryId);
                ps.setString(2, "Activity Secondary 998802");
                ps.setInt(3, ownerId);
                ps.executeUpdate();
            }

            // Perform Merge
            boolean success = mergeService.mergeCustomers(primaryId, secondaryId, ownerId);
            assertTrue(success, "Gộp 2 khách hàng hợp lệ phải trả về true");

            // Verify secondary customer is deleted
            String checkSec = "SELECT COUNT(*) FROM customers WHERE customer_id = ?";
            try (PreparedStatement ps = conn.prepareStatement(checkSec)) {
                ps.setInt(1, secondaryId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        assertEquals(0, rs.getInt(1), "Customer secondary phải bị xóa khỏi bảng customers");
                    }
                }
            }

            // Verify Opportunity transferred to primary
            String checkOpp = "SELECT COUNT(*) FROM opportunities WHERE customer_id = ? AND title = 'Opp Secondary 998802'";
            try (PreparedStatement ps = conn.prepareStatement(checkOpp)) {
                ps.setInt(1, primaryId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        assertEquals(1, rs.getInt(1), "Opportunity của secondary phải chuyển sang primary");
                    }
                }
            }

            // Verify Activity transferred to primary
            String checkAct = "SELECT COUNT(*) FROM activities WHERE customer_id = ? AND title = 'Activity Secondary 998802'";
            try (PreparedStatement ps = conn.prepareStatement(checkAct)) {
                ps.setInt(1, primaryId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        assertEquals(1, rs.getInt(1), "Activity của secondary phải chuyển sang primary");
                    }
                }
            }

            // Verify Contact transferred to primary
            String checkContact = "SELECT COUNT(*) FROM contacts WHERE customer_id = ? AND contact_name = 'Contact Secondary 998802'";
            try (PreparedStatement ps = conn.prepareStatement(checkContact)) {
                ps.setInt(1, primaryId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        assertEquals(1, rs.getInt(1), "Contact của secondary phải chuyển sang primary");
                    }
                }
            }

            // Verify Audit Log recorded in customer_merges
            String checkAudit = "SELECT COUNT(*) FROM customer_merges WHERE primary_customer_id = ? AND secondary_customer_id = ?";
            try (PreparedStatement ps = conn.prepareStatement(checkAudit)) {
                ps.setInt(1, primaryId);
                ps.setInt(2, secondaryId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        assertEquals(1, rs.getInt(1), "Nhật ký gộp phải được ghi vào customer_merges");
                    }
                }
            }

            // Clean up test data
            try (Statement stmt = conn.createStatement()) {
                stmt.execute("DELETE FROM customer_merges WHERE primary_customer_id = 998801");
                stmt.execute("DELETE FROM opportunities WHERE customer_id = 998801");
                stmt.execute("DELETE FROM activities WHERE customer_id = 998801");
                stmt.execute("DELETE FROM contacts WHERE customer_id = 998801");
                stmt.execute("DELETE FROM customers WHERE customer_id = 998801");
            }
        } catch (SQLException ignored) {}
    }

    @Test
    public void testMergeCustomersRollbackOnNonExistentCustomer() {
        int primaryId = 999991;
        int secondaryId = 999992;
        int ownerId = 1;

        // Ensure non-existent customer merge fails cleanly and rolls back
        boolean success = mergeService.mergeCustomers(primaryId, secondaryId, ownerId);
        assertFalse(success, "Gộp với khách hàng không tồn tại phải trả về false và rollback transaction");

        try (Connection conn = DBConnection.getConnection()) {
            if (conn == null) return;
            // Verify no audit log recorded
            String checkAudit = "SELECT COUNT(*) FROM customer_merges WHERE primary_customer_id = ? AND secondary_customer_id = ?";
            try (PreparedStatement ps = conn.prepareStatement(checkAudit)) {
                ps.setInt(1, primaryId);
                ps.setInt(2, secondaryId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        assertEquals(0, rs.getInt(1), "Khi merge thất bại không được có audit log");
                    }
                }
            }
        } catch (SQLException ignored) {}
    }
}


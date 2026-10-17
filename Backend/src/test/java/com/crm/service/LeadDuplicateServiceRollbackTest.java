package com.crm.service;

import com.crm.dao.CustomerDAO;
import com.crm.dao.LeadMergeHistoryDAO;
import com.crm.dto.LeadMergeRequest;
import com.crm.model.Lead;
import com.crm.model.LeadMergeHistory;
import com.crm.util.DBConnection;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import static org.junit.jupiter.api.Assertions.*;

public class LeadDuplicateServiceRollbackTest {

    private int primaryId;
    private int duplicateId;
    private int subActivityId;

    @BeforeEach
    public void setUp() throws SQLException {
        try (Connection conn = DBConnection.getConnection()) {
            // Create Primary Lead
            String sql1 = "INSERT INTO leads (full_name, email, phone, company, status, notes, lead_source_id) VALUES (?, ?, ?, ?, 'NEW', ?, 1)";
            try (PreparedStatement ps = conn.prepareStatement(sql1, PreparedStatement.RETURN_GENERATED_KEYS)) {
                ps.setString(1, "TEST_ROLLBACK_PRIMARY");
                ps.setString(2, "rb.primary@example.com");
                ps.setString(3, "0911550011");
                ps.setString(4, "Primary Corp");
                ps.setString(5, "Initial primary note");
                ps.executeUpdate();
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) primaryId = rs.getInt(1);
                }
            }

            // Create Duplicate Lead
            try (PreparedStatement ps = conn.prepareStatement(sql1, PreparedStatement.RETURN_GENERATED_KEYS)) {
                ps.setString(1, "TEST_ROLLBACK_SUB");
                ps.setString(2, "rb.sub@example.com");
                ps.setString(3, "0911550022");
                ps.setString(4, "Sub Corp");
                ps.setString(5, "Important sub note");
                ps.executeUpdate();
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) duplicateId = rs.getInt(1);
                }
            }

            // Create Activity attached to Duplicate Lead
            String sqlAct = "INSERT INTO activities (lead_id, title, activity_type, owner_id) VALUES (?, ?, 'CALL', 1)";
            try (PreparedStatement ps = conn.prepareStatement(sqlAct, PreparedStatement.RETURN_GENERATED_KEYS)) {
                ps.setInt(1, duplicateId);
                ps.setString(2, "Rollback Test Activity");
                ps.executeUpdate();
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) subActivityId = rs.getInt(1);
                }
            }
        }
    }

    @AfterEach
    public void tearDown() throws SQLException {
        try (Connection conn = DBConnection.getConnection()) {
            try (PreparedStatement ps = conn.prepareStatement("DELETE FROM activities WHERE lead_id IN (?, ?) OR activity_id = ?")) {
                ps.setInt(1, primaryId);
                ps.setInt(2, duplicateId);
                ps.setInt(3, subActivityId);
                ps.executeUpdate();
            }
            try (PreparedStatement ps = conn.prepareStatement("DELETE FROM lead_merge_history WHERE primary_lead_id IN (?, ?) OR duplicate_lead_id IN (?, ?)")) {
                ps.setInt(1, primaryId);
                ps.setInt(2, duplicateId);
                ps.setInt(3, primaryId);
                ps.setInt(4, duplicateId);
                ps.executeUpdate();
            }
            try (PreparedStatement ps = conn.prepareStatement("DELETE FROM leads WHERE lead_id IN (?, ?)")) {
                ps.setInt(1, primaryId);
                ps.setInt(2, duplicateId);
                ps.executeUpdate();
            }
        }
    }

    @Test
    @DisplayName("Kiểm tra Rollback toàn bộ khi xảy ra lỗi giữa quá trình gộp (Audit History failure)")
    public void testMergeRollbackOnHistoryFailure() throws SQLException {
        // Mock LeadMergeHistoryDAO to throw SQLException upon save
        LeadMergeHistoryDAO failingHistoryDAO = new LeadMergeHistoryDAO() {
            @Override
            public int save(LeadMergeHistory history, Connection conn) throws SQLException {
                throw new SQLException("SIMULATED DATABASE FAILURE: Disk full or constraint error");
            }
        };

        CustomerDAO customerDAO = new CustomerDAO();
        LeadDuplicateService service = new LeadDuplicateService(failingHistoryDAO, customerDAO);

        LeadMergeRequest req = new LeadMergeRequest(primaryId, duplicateId);
        req.setRetainedFullName("SHOULD_BE_ROLLED_BACK");
        req.setNote("Rollback test note");

        // Execute merge - should return false due to exception and rollback
        boolean result = service.mergeLeads(req, 1);
        assertFalse(result, "Thao tác gộp phải trả về false khi có lỗi trong transaction");

        // Verify Database state after rollback
        try (Connection conn = DBConnection.getConnection()) {
            // 1. Primary Lead must NOT have changed name or notes
            try (PreparedStatement ps = conn.prepareStatement("SELECT full_name, notes, status FROM leads WHERE lead_id = ?")) {
                ps.setInt(1, primaryId);
                try (ResultSet rs = ps.executeQuery()) {
                    assertTrue(rs.next());
                    assertEquals("TEST_ROLLBACK_PRIMARY", rs.getString("full_name"), "Tên Lead chính phải giữ nguyên sau rollback");
                    assertEquals("Initial primary note", rs.getString("notes"), "Ghi chú Lead chính phải giữ nguyên sau rollback");
                    assertEquals("NEW", rs.getString("status"));
                }
            }

            // 2. Duplicate Lead must NOT have been marked as MERGED
            try (PreparedStatement ps = conn.prepareStatement("SELECT status FROM leads WHERE lead_id = ?")) {
                ps.setInt(1, duplicateId);
                try (ResultSet rs = ps.executeQuery()) {
                    assertTrue(rs.next());
                    assertEquals("NEW", rs.getString("status"), "Lead phụ phải giữ nguyên trạng thái NEW sau rollback");
                }
            }

            // 3. Activity must STILL belong to Duplicate Lead (not reassigned to Primary)
            try (PreparedStatement ps = conn.prepareStatement("SELECT lead_id FROM activities WHERE activity_id = ?")) {
                ps.setInt(1, subActivityId);
                try (ResultSet rs = ps.executeQuery()) {
                    assertTrue(rs.next());
                    assertEquals(duplicateId, rs.getInt("lead_id"), "Activity của Lead phụ không được chuyển sang Lead chính khi rollback");
                }
            }

            // 4. No history record must exist
            try (PreparedStatement ps = conn.prepareStatement("SELECT COUNT(*) FROM lead_merge_history WHERE primary_lead_id = ? AND duplicate_lead_id = ?")) {
                ps.setInt(1, primaryId);
                ps.setInt(2, duplicateId);
                try (ResultSet rs = ps.executeQuery()) {
                    assertTrue(rs.next());
                    assertEquals(0, rs.getInt(1), "Bảng lead_merge_history không được có bản ghi sau rollback");
                }
            }
        }
    }
}

package com.crm.integration;

import com.crm.controller.lead.LeadAcceptServlet;
import com.crm.controller.lead.LeadRejectServlet;
import com.crm.dao.LeadAssignmentHistoryDAO;
import com.crm.model.Account;
import com.crm.service.LeadSlaService;
import com.crm.util.DBConnection;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.junit.jupiter.api.*;

import java.io.PrintWriter;
import java.io.StringWriter;
import java.sql.*;
import java.util.Collections;
import java.util.concurrent.*;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

/**
 * Integration Test suite cho S4-07: Lead Acceptance, Rejection & Response SLA
 * Chạy trên database cô lập crm_s4_06_test.
 * Bao gồm đầy đủ 12 Test Cases bắt buộc (TC01 - TC12) và các bài kiểm tra bảo mật, phân quyền, concurrency.
 */
@TestMethodOrder(MethodOrderer.OrderAnnotation.class)
public class LeadSlaIntegrationTest {

    private static final String TEST_DB_URL = "jdbc:mysql://localhost:3306/crm_s4_06_test?useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true&useUnicode=true&characterEncoding=UTF-8";
    private static final String DRIVER = "com.mysql.cj.jdbc.Driver";

    private LeadSlaService slaService;
    private LeadAssignmentHistoryDAO historyDAO;

    @BeforeAll
    static void initSafetyGate() throws Exception {
        String testUser = System.getProperty("db.test.user");
        String testPass = System.getProperty("db.test.password", System.getenv("MYSQL_TEST_PWD"));

        if (testPass == null || testPass.trim().isEmpty() || testUser == null || testUser.trim().isEmpty()) {
            try (java.io.InputStream is = LeadSlaIntegrationTest.class.getClassLoader().getResourceAsStream("db.local.properties")) {
                if (is != null) {
                    java.util.Properties props = new java.util.Properties();
                    props.load(is);
                    if (testPass == null || testPass.trim().isEmpty()) {
                        testPass = props.getProperty("db.password");
                    }
                    if (testUser == null || testUser.trim().isEmpty()) {
                        testUser = props.getProperty("db.username", "root");
                    }
                }
            }
            if (testPass == null || testPass.trim().isEmpty() || testUser == null || testUser.trim().isEmpty()) {
                try (java.io.InputStream is = LeadSlaIntegrationTest.class.getClassLoader().getResourceAsStream("db.properties")) {
                    if (is != null) {
                        java.util.Properties props = new java.util.Properties();
                        props.load(is);
                        if (testPass == null || testPass.trim().isEmpty()) {
                            testPass = props.getProperty("db.password");
                        }
                        if (testUser == null || testUser.trim().isEmpty()) {
                            testUser = props.getProperty("db.username", "root");
                        }
                    }
                }
            }
        }
        if (testUser == null || testUser.trim().isEmpty()) {
            testUser = "root";
        }
        if (testPass == null) {
            testPass = "";
        }

        DBConnection.setCustomCredentials(TEST_DB_URL, testUser, testPass, DRIVER);
        try (Connection conn = DBConnection.getConnection()) {
            assertNotNull(conn);
            if (!"crm_s4_06_test".equalsIgnoreCase(conn.getCatalog())) {
                throw new IllegalStateException("CRITICAL SAFETY FAIL: Not crm_s4_06_test!");
            }
        }
    }

    @BeforeEach
    void setUp() throws SQLException {
        verifySafetyCatalog();
        historyDAO = new LeadAssignmentHistoryDAO();
        slaService = new LeadSlaService(historyDAO);
        resetFixtures();
    }

    private void verifySafetyCatalog() throws SQLException {
        try (Connection conn = DBConnection.getConnection()) {
            if (!"crm_s4_06_test".equalsIgnoreCase(conn.getCatalog())) {
                throw new IllegalStateException("CRITICAL SAFETY FAIL: Not crm_s4_06_test!");
            }
        }
    }

    private void resetFixtures() throws SQLException {
        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement()) {
            stmt.execute("SET FOREIGN_KEY_CHECKS = 0");
            stmt.execute("TRUNCATE TABLE lead_assignment_history");
            stmt.execute("TRUNCATE TABLE lead_sla_configs");
            stmt.execute("TRUNCATE TABLE lead_sla_notifications");
            stmt.execute("TRUNCATE TABLE activities");
            stmt.execute("TRUNCATE TABLE leads");
            stmt.execute("TRUNCATE TABLE users");
            stmt.execute("TRUNCATE TABLE teams");
            stmt.execute("SET FOREIGN_KEY_CHECKS = 1");

            // Teams (Team 1 có leader_id = 102, Team 2 có leader_id = 201)
            stmt.execute("INSERT INTO teams (team_id, team_name, region, leader_id) VALUES " +
                    "(1, 'Team Bac', 'North', 102), " +
                    "(2, 'Team Nam', 'South', 201)");

            // Users
            stmt.execute("INSERT INTO users (user_id, email, password_hash, full_name, team_id, is_active, lockout_until) VALUES " +
                    "(1, 'admin@test.local', 'hash', 'Admin Director', NULL, 1, NULL), " +
                    "(101, 'rep1.north@test.local', 'hash', 'Rep North 1', 1, 1, NULL), " +
                    "(102, 'leader.north@test.local', 'hash', 'Leader North', 1, 1, NULL), " +
                    "(201, 'rep1.south@test.local', 'hash', 'Rep South 1', 2, 1, NULL)");

            // Leads
            stmt.execute("INSERT INTO leads (lead_id, contact_name, status, owner_id, assigned_at, sla_due_date, is_overdue, sla_status) VALUES " +
                    "(1, 'Lead Assigned to 101', 'ASSIGNED', 101, CURRENT_TIMESTAMP, DATE_ADD(CURRENT_TIMESTAMP, INTERVAL 2 HOUR), 0, 'PENDING'), " +
                    "(2, 'Lead Overdue for 101', 'ASSIGNED', 101, DATE_SUB(CURRENT_TIMESTAMP, INTERVAL 3 HOUR), DATE_SUB(CURRENT_TIMESTAMP, INTERVAL 1 HOUR), 0, 'PENDING'), " +
                    "(3, 'Lead Queued No Owner', 'QUEUED', NULL, NULL, NULL, 0, NULL), " +
                    "(4, 'Lead Converted', 'CONVERTED', 101, CURRENT_TIMESTAMP, NULL, 0, NULL), " +
                    "(5, 'Lead Assigned to 201', 'ASSIGNED', 201, CURRENT_TIMESTAMP, NULL, 0, 'PENDING')");
        }
    }

    @AfterAll
    static void tearDownClass() {
        DBConnection.resetDefaultCredentials();
    }

    // =========================================================================
    // TC01 - TC03: LEAD ACCEPTANCE
    // =========================================================================

    @Test
    @Order(1)
    @DisplayName("TC01 - Nhận Lead hợp lệ: Lead đang phân cho User 101; 101 nhận Lead -> Chuyển sang IN_PROGRESS và dữ liệu được lưu")
    void testTC01_AcceptLead_Valid() throws SQLException {
        boolean accepted = slaService.acceptLead(1, 101, false);
        assertTrue(accepted);

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement("SELECT status, sla_status, is_overdue FROM leads WHERE lead_id = 1")) {
            try (ResultSet rs = ps.executeQuery()) {
                assertTrue(rs.next());
                assertEquals("IN_PROGRESS", rs.getString("status"));
                assertEquals("IN_PROGRESS", rs.getString("sla_status"));
                assertFalse(rs.getBoolean("is_overdue"));
            }
        }

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement("SELECT status, assigned_to, performed_by, assigned_at FROM lead_assignment_history WHERE lead_id = 1")) {
            try (ResultSet rs = ps.executeQuery()) {
                assertTrue(rs.next());
                assertEquals("IN_PROGRESS", rs.getString("status"));
                assertEquals(101, rs.getInt("assigned_to"));
                assertEquals(101, rs.getInt("performed_by"));
                assertNotNull(rs.getTimestamp("assigned_at"));
            }
        }
    }

    @Test
    @Order(2)
    @DisplayName("TC02 - Nhân viên không được phân cố nhận Lead: Backend từ chối thao tác và dữ liệu không thay đổi")
    void testTC02_AcceptLead_Unauthorized_NonOwner() {
        SecurityException ex = assertThrows(SecurityException.class, () -> {
            slaService.acceptLead(1, 102, false);
        });
        assertTrue(ex.getMessage().contains("Ownership vi phạm"));

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement("SELECT status, owner_id FROM leads WHERE lead_id = 1")) {
            try (ResultSet rs = ps.executeQuery()) {
                assertTrue(rs.next());
                assertEquals("ASSIGNED", rs.getString("status"));
                assertEquals(101, rs.getInt("owner_id"));
            }
        } catch (SQLException e) {
            fail("Query DB thất bại: " + e.getMessage());
        }
    }

    @Test
    @Order(3)
    @DisplayName("TC03 - Nhận Lead hai lần: Không tạo trạng thái hoặc assignment sai; idempotent thành công")
    void testTC03_AcceptLead_Duplicate_Idempotent() throws SQLException {
        slaService.acceptLead(1, 101, false);
        // Gọi nhận lần 2
        boolean secondCall = slaService.acceptLead(1, 101, false);
        assertTrue(secondCall);

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement("SELECT COUNT(*) FROM lead_assignment_history WHERE lead_id = 1 AND status = 'IN_PROGRESS'")) {
            try (ResultSet rs = ps.executeQuery()) {
                assertTrue(rs.next());
                assertEquals(1, rs.getInt(1), "Không được ghi lịch sử IN_PROGRESS trùng lặp");
            }
        }
    }

    // =========================================================================
    // TC04 - TC06: LEAD REJECTION
    // =========================================================================

    @Test
    @Order(4)
    @DisplayName("TC04 - Từ chối không có lý do: Backend trả lỗi validation; Lead không bị thay đổi")
    void testTC04_RejectLead_EmptyReason_ValidationFailed() {
        IllegalArgumentException ex = assertThrows(IllegalArgumentException.class, () -> {
            slaService.rejectLead(1, 101, "   ");
        });
        assertTrue(ex.getMessage().contains("bắt buộc"));

        assertThrows(IllegalArgumentException.class, () -> {
            slaService.rejectLead(1, 101, null);
        });

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement("SELECT status, owner_id FROM leads WHERE lead_id = 1")) {
            try (ResultSet rs = ps.executeQuery()) {
                assertTrue(rs.next());
                assertEquals("ASSIGNED", rs.getString("status"));
                assertEquals(101, rs.getInt("owner_id"));
            }
        } catch (SQLException e) {
            fail("Query DB thất bại: " + e.getMessage());
        }
    }

    @Test
    @Order(5)
    @DisplayName("TC05 - Từ chối có lý do: Lead trở lại hàng chờ phân bổ (QUEUED); assignment cũ kết thúc; lý do được lưu")
    void testTC05_RejectLead_WithReason_Success() throws SQLException {
        boolean rejected = slaService.rejectLead(1, 101, "Khách hàng sai số điện thoại, không liên lạc được");
        assertTrue(rejected);

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement("SELECT status, owner_id, sla_status, assigned_at, sla_due_date FROM leads WHERE lead_id = 1")) {
            try (ResultSet rs = ps.executeQuery()) {
                assertTrue(rs.next());
                assertEquals("QUEUED", rs.getString("status"));
                assertNull(rs.getObject("owner_id"), "owner_id phải được reset về NULL để không còn thuộc nhân viên từ chối");
                assertNull(rs.getObject("assigned_at"));
                assertNull(rs.getObject("sla_due_date"));
                assertEquals("REJECTED", rs.getString("sla_status"));
            }
        }

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement("SELECT status, reject_reason, assigned_to, performed_by FROM lead_assignment_history WHERE lead_id = 1 AND status = 'REJECTED'")) {
            try (ResultSet rs = ps.executeQuery()) {
                assertTrue(rs.next());
                assertEquals("REJECTED", rs.getString("status"));
                assertEquals("Khách hàng sai số điện thoại, không liên lạc được", rs.getString("reject_reason"));
                assertEquals(101, rs.getInt("assigned_to"));
                assertEquals(101, rs.getInt("performed_by"));
            }
        }
    }

    @Test
    @Order(6)
    @DisplayName("TC06 - Nhân viên khác từ chối Lead: Không được phép nếu không có quyền phù hợp")
    void testTC06_RejectLead_Unauthorized_NonOwner() {
        SecurityException ex = assertThrows(SecurityException.class, () -> {
            slaService.rejectLead(1, 102, "Không thích nhận");
        });
        assertTrue(ex.getMessage().contains("Ownership vi phạm"));

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement("SELECT status, owner_id FROM leads WHERE lead_id = 1")) {
            try (ResultSet rs = ps.executeQuery()) {
                assertTrue(rs.next());
                assertEquals("ASSIGNED", rs.getString("status"));
                assertEquals(101, rs.getInt("owner_id"));
            }
        } catch (SQLException e) {
            fail("Query DB thất bại: " + e.getMessage());
        }
    }

    // =========================================================================
    // TC07 - TC10: SLA RESPONSE & NOTIFICATION
    // =========================================================================

    @Test
    @Order(7)
    @DisplayName("TC07 - Lead chưa quá SLA: Không gắn cờ quá hạn và không tạo cảnh báo quá hạn")
    void testTC07_Sla_LeadNotOverdue_NoWarning() throws SQLException {
        int flagged = slaService.checkAndFlagOverdueLeads();

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement("SELECT is_overdue, sla_status FROM leads WHERE lead_id = 1")) {
            try (ResultSet rs = ps.executeQuery()) {
                assertTrue(rs.next());
                assertFalse(rs.getBoolean("is_overdue"), "Lead chưa tới hạn không được bị gắn cờ quá hạn");
                assertEquals("PENDING", rs.getString("sla_status"));
            }
        }

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement("SELECT COUNT(*) FROM lead_sla_notifications WHERE lead_id = 1")) {
            try (ResultSet rs = ps.executeQuery()) {
                assertTrue(rs.next());
                assertEquals(0, rs.getInt(1), "Tuyệt đối không tạo thông báo cảnh báo cho Lead chưa quá hạn");
            }
        }
    }

    @Test
    @Order(8)
    @DisplayName("TC08 - Lead quá SLA và chưa liên hệ: Job phát hiện quá hạn, gắn cờ và tạo thông báo cho trưởng nhóm đúng một lần")
    void testTC08_Sla_LeadOverdue_Uncontacted_FlagAndNotifyLeader() throws SQLException {
        int flagged = slaService.checkAndFlagOverdueLeads();
        assertTrue(flagged >= 1, "Phải phát hiện và gắn cờ cho Lead #2");

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement("SELECT is_overdue, sla_status, status FROM leads WHERE lead_id = 2")) {
            try (ResultSet rs = ps.executeQuery()) {
                assertTrue(rs.next());
                assertTrue(rs.getBoolean("is_overdue"), "is_overdue phải chuyển sang 1 (true)");
                assertEquals("OVERDUE", rs.getString("sla_status"));
                assertEquals("ASSIGNED", rs.getString("status"));
            }
        }

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement("SELECT lead_id, sales_rep_id, leader_id, message FROM lead_sla_notifications WHERE lead_id = 2")) {
            try (ResultSet rs = ps.executeQuery()) {
                assertTrue(rs.next());
                assertEquals(2, rs.getInt("lead_id"));
                assertEquals(101, rs.getInt("sales_rep_id"));
                assertEquals(102, rs.getInt("leader_id"), "Thông báo phải gửi đúng cho Trưởng nhóm (leader_id = 102) của Team 1");
                assertTrue(rs.getString("message").contains("CẢNH BÁO QUÁ HẠN SLA"));
            }
        }
    }

    @Test
    @Order(9)
    @DisplayName("TC09 - Lead đã được liên hệ: Không bị cảnh báo là chưa phản hồi nếu sự kiện liên hệ đáp ứng đúng định nghĩa SLA")
    void testTC09_Sla_LeadContacted_NotOverdue() throws SQLException {
        boolean contacted = slaService.recordLeadContact(2, 101, "Đã gọi điện trao đổi nhu cầu và báo giá giải pháp");
        assertTrue(contacted);

        int flagged = slaService.checkAndFlagOverdueLeads();

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement("SELECT is_overdue, sla_status, status FROM leads WHERE lead_id = 2")) {
            try (ResultSet rs = ps.executeQuery()) {
                assertTrue(rs.next());
                assertFalse(rs.getBoolean("is_overdue"), "Lead đã liên hệ không được bị gắn cờ quá hạn");
                assertEquals("RESPONDED", rs.getString("sla_status"));
                assertEquals("CONTACTED", rs.getString("status"));
            }
        }

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement("SELECT COUNT(*) FROM activities WHERE lead_id = 2")) {
            try (ResultSet rs = ps.executeQuery()) {
                assertTrue(rs.next());
                assertEquals(1, rs.getInt(1), "Phải có bản ghi tương tác trong bảng activities");
            }
        }
    }

    @Test
    @Order(10)
    @DisplayName("TC10 - Job chạy lại: Không tạo nhiều cảnh báo trùng cho cùng một sự kiện quá hạn")
    void testTC10_Sla_JobReRun_NoDuplicateNotification() throws SQLException {
        int flagged1 = slaService.checkAndFlagOverdueLeads();
        assertTrue(flagged1 >= 1);

        int flagged2 = slaService.checkAndFlagOverdueLeads();
        assertEquals(0, flagged2, "Lần chạy thứ hai không được gắn cờ lại cho Lead đã xử lý");

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement("SELECT COUNT(*) FROM lead_sla_notifications WHERE lead_id = 2")) {
            try (ResultSet rs = ps.executeQuery()) {
                assertTrue(rs.next());
                assertEquals(1, rs.getInt(1), "Ràng buộc UNIQUE và logic kiểm tra phải đảm bảo chỉ có duy nhất 1 thông báo");
            }
        }
    }

    // =========================================================================
    // TC11 - TC12: TRANSACTION ROLLBACK & FULL INTEGRATION
    // =========================================================================

    @Test
    @Order(11)
    @DisplayName("TC11 - Lỗi database: Transaction được xử lý an toàn (Rollback), không tạo dữ liệu dở dang")
    void testTC11_DatabaseError_TransactionRollback() throws SQLException {
        LeadAssignmentHistoryDAO failingHistoryDAO = mock(LeadAssignmentHistoryDAO.class);
        when(failingHistoryDAO.saveHistory(any(Connection.class), any())).thenReturn(false);
        LeadSlaService serviceWithFailingDAO = new LeadSlaService(failingHistoryDAO);

        SQLException exAccept = assertThrows(SQLException.class, () -> {
            serviceWithFailingDAO.acceptLead(1, 101, false);
        });
        assertTrue(exAccept.getMessage().contains("thất bại"));

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement("SELECT status, owner_id FROM leads WHERE lead_id = 1")) {
            try (ResultSet rs = ps.executeQuery()) {
                assertTrue(rs.next());
                assertEquals("ASSIGNED", rs.getString("status"), "Rollback accept phải giữ nguyên trạng thái ASSIGNED");
                assertEquals(101, rs.getInt("owner_id"));
            }
        }

        SQLException exReject = assertThrows(SQLException.class, () -> {
            serviceWithFailingDAO.rejectLead(1, 101, "Lý do kiểm thử rollback", false);
        });
        assertTrue(exReject.getMessage().contains("thất bại"));

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement("SELECT status, owner_id FROM leads WHERE lead_id = 1")) {
            try (ResultSet rs = ps.executeQuery()) {
                assertTrue(rs.next());
                assertEquals("ASSIGNED", rs.getString("status"), "Rollback reject phải giữ nguyên trạng thái ASSIGNED");
                assertEquals(101, rs.getInt("owner_id"));
            }
        }
    }

    @Test
    @Order(12)
    @DisplayName("TC12 - Kiểm thử tích hợp Servlet: Xác minh thao tác từ HTTP đi đến Backend và dữ liệu Database thay đổi thật")
    void testTC12_FullIntegration_HttpToDatabase() throws Exception {
        // 1. Gửi request Accept qua LeadAcceptServlet
        LeadAcceptServlet acceptServlet = new LeadAcceptServlet();
        acceptServlet.setSlaService(slaService);

        HttpServletRequest reqAccept = mock(HttpServletRequest.class);
        HttpServletResponse respAccept = mock(HttpServletResponse.class);
        HttpSession sessionAccept = mock(HttpSession.class);
        StringWriter swAccept = new StringWriter();
        PrintWriter pwAccept = new PrintWriter(swAccept);

        when(reqAccept.getSession(false)).thenReturn(sessionAccept);
        when(sessionAccept.getAttribute("userId")).thenReturn(101);
        when(sessionAccept.getAttribute("roleId")).thenReturn(2);
        Account acc = new Account();
        acc.setRoleCodes(Collections.singletonList("SALES_REP"));
        when(sessionAccept.getAttribute("currentUser")).thenReturn(acc);

        when(reqAccept.getParameter("leadId")).thenReturn("1");
        when(respAccept.getWriter()).thenReturn(pwAccept);

        acceptServlet.doPost(reqAccept, respAccept);

        verify(respAccept).setStatus(HttpServletResponse.SC_OK);
        assertTrue(swAccept.toString().contains("\"status\": \"success\""));

        // Kiểm tra Database sau khi Accept qua Servlet
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement("SELECT status, sla_status FROM leads WHERE lead_id = 1")) {
            try (ResultSet rs = ps.executeQuery()) {
                assertTrue(rs.next());
                assertEquals("IN_PROGRESS", rs.getString("status"), "Database phải đổi sang IN_PROGRESS thật");
                assertEquals("IN_PROGRESS", rs.getString("sla_status"));
            }
        }

        // 2. Chuyển Lead về ASSIGNED để test Reject qua Servlet
        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement()) {
            stmt.execute("UPDATE leads SET status = 'ASSIGNED', owner_id = 101 WHERE lead_id = 1");
        }

        LeadRejectServlet rejectServlet = new LeadRejectServlet();
        rejectServlet.setSlaService(slaService);

        HttpServletRequest reqReject = mock(HttpServletRequest.class);
        HttpServletResponse respReject = mock(HttpServletResponse.class);
        HttpSession sessionReject = mock(HttpSession.class);
        StringWriter swReject = new StringWriter();
        PrintWriter pwReject = new PrintWriter(swReject);

        when(reqReject.getSession(false)).thenReturn(sessionReject);
        when(sessionReject.getAttribute("userId")).thenReturn(101);
        when(sessionReject.getAttribute("roleId")).thenReturn(2);
        when(sessionReject.getAttribute("currentUser")).thenReturn(acc);

        when(reqReject.getParameter("leadId")).thenReturn("1");
        when(reqReject.getParameter("rejectReason")).thenReturn("Khách hàng không phản hồi cuộc gọi qua Servlet");
        when(respReject.getWriter()).thenReturn(pwReject);

        rejectServlet.doPost(reqReject, respReject);

        verify(respReject).setStatus(HttpServletResponse.SC_OK);
        assertTrue(swReject.toString().contains("\"status\": \"success\""));

        // Kiểm tra Database sau khi Reject qua Servlet
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement("SELECT status, owner_id, sla_status FROM leads WHERE lead_id = 1")) {
            try (ResultSet rs = ps.executeQuery()) {
                assertTrue(rs.next());
                assertEquals("QUEUED", rs.getString("status"), "Database phải đổi sang QUEUED thật");
                assertNull(rs.getObject("owner_id"), "owner_id phải bị unassign thật trong Database");
                assertEquals("REJECTED", rs.getString("sla_status"));
            }
        }
    }

    // =========================================================================
    // ADDITIONAL SECURITY, CONCURRENCY & CONFIG TESTS
    // =========================================================================

    @Test
    @Order(13)
    @DisplayName("IT-13: Quản trị viên (Admin) có quyền tiếp nhận thay cho nhân viên -> Thành công")
    void testAcceptLead_AdminElevated_Success() throws SQLException {
        boolean accepted = slaService.acceptLead(1, 1, true);
        assertTrue(accepted);

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement("SELECT status FROM leads WHERE lead_id = 1")) {
            try (ResultSet rs = ps.executeQuery()) {
                assertTrue(rs.next());
                assertEquals("IN_PROGRESS", rs.getString("status"));
            }
        }
    }

    @Test
    @Order(14)
    @DisplayName("IT-14: Từ chối tiếp nhận Lead đã CONVERTED -> Ném IllegalStateException (409)")
    void testAcceptLead_Converted_Blocked() {
        IllegalStateException ex = assertThrows(IllegalStateException.class, () -> {
            slaService.acceptLead(4, 101, false);
        });
        assertTrue(ex.getMessage().contains("đã được chuyển đổi"));
    }

    @Test
    @Order(15)
    @DisplayName("IT-15: Hai request tiếp nhận đồng thời cùng một Lead -> Không tạo duplicate history")
    void testConcurrency_ConcurrentAccept() throws Exception {
        int threads = 2;
        ExecutorService executor = Executors.newFixedThreadPool(threads);
        CountDownLatch startGate = new CountDownLatch(1);
        CountDownLatch endGate = new CountDownLatch(threads);

        for (int i = 0; i < threads; i++) {
            executor.submit(() -> {
                try {
                    startGate.await();
                    slaService.acceptLead(1, 101, false);
                } catch (Exception ignored) {
                } finally {
                    endGate.countDown();
                }
            });
        }

        startGate.countDown();
        assertTrue(endGate.await(5, TimeUnit.SECONDS));
        executor.shutdown();

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement("SELECT COUNT(*) FROM lead_assignment_history WHERE lead_id = 1 AND status = 'IN_PROGRESS'")) {
            try (ResultSet rs = ps.executeQuery()) {
                assertTrue(rs.next());
                assertEquals(1, rs.getInt(1), "Chỉ được tạo duy nhất 1 bản ghi IN_PROGRESS");
            }
        }
    }

    @Test
    @Order(16)
    @DisplayName("IT-16: Accept và Reject chạy đồng thời trên cùng Lead -> Pessimistic locking đảm bảo tính nhất quán")
    void testConcurrency_AcceptAndRejectConcurrent() throws Exception {
        ExecutorService executor = Executors.newFixedThreadPool(2);
        CountDownLatch startGate = new CountDownLatch(1);
        CountDownLatch endGate = new CountDownLatch(2);

        executor.submit(() -> {
            try {
                startGate.await();
                slaService.acceptLead(1, 101, false);
            } catch (Exception ignored) {
            } finally {
                endGate.countDown();
            }
        });

        executor.submit(() -> {
            try {
                startGate.await();
                slaService.rejectLead(1, 101, "Từ chối trong tranh chấp", false);
            } catch (Exception ignored) {
            } finally {
                endGate.countDown();
            }
        });

        startGate.countDown();
        assertTrue(endGate.await(5, TimeUnit.SECONDS));
        executor.shutdown();

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement("SELECT status, owner_id FROM leads WHERE lead_id = 1")) {
            try (ResultSet rs = ps.executeQuery()) {
                assertTrue(rs.next());
                String status = rs.getString("status");
                assertTrue("IN_PROGRESS".equals(status) || "QUEUED".equals(status), "Trạng thái cuối cùng phải là IN_PROGRESS hoặc QUEUED");
            }
        }
    }

    @Test
    @Order(17)
    @DisplayName("IT-17: Đọc cấu hình SLA từ CSDL (Không tự ý hardcode 24h nếu bảng rỗng)")
    void testSla_ConfigFromDatabase() throws SQLException {
        try (Connection conn = DBConnection.getConnection()) {
            Integer minutes = slaService.getSlaResponseTimeMinutes(conn, "HIGH");
            assertNull(minutes, "Nếu bảng lead_sla_configs rỗng, phải trả về null, tuyệt đối không hardcode");
        }

        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement()) {
            stmt.execute("INSERT INTO lead_sla_configs (priority_level, response_time_minutes, is_active) VALUES ('HIGH', 60, 1)");
        }

        try (Connection conn = DBConnection.getConnection()) {
            Integer minutes = slaService.getSlaResponseTimeMinutes(conn, "HIGH");
            assertNotNull(minutes);
            assertEquals(60, minutes, "Phải đọc đúng cấu hình 60 phút từ bảng lead_sla_configs");
        }
    }

    @Test
    @Order(18)
    @DisplayName("IT-18: Cấu hình SLA có is_active = 0 bị bỏ qua -> Trả về null")
    void testSla_InactiveConfigIgnored() throws SQLException {
        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement()) {
            stmt.execute("INSERT INTO lead_sla_configs (priority_level, response_time_minutes, is_active) VALUES ('INACTIVE_TIER', 30, 0)");
        }

        try (Connection conn = DBConnection.getConnection()) {
            Integer minutes = slaService.getSlaResponseTimeMinutes(conn, "INACTIVE_TIER");
            assertNull(minutes, "Cấu hình SLA bị vô hiệu hóa (is_active = 0) không được áp dụng");
        }
    }

    @Test
    @Order(19)
    @DisplayName("IT-19: Lead có sla_due_date = NULL không bị gắn cờ quá hạn")
    void testSla_LeadWithNullDueDate_NotFlagged() throws SQLException {
        slaService.checkAndFlagOverdueLeads();

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement("SELECT is_overdue FROM leads WHERE lead_id = 5")) {
            try (ResultSet rs = ps.executeQuery()) {
                assertTrue(rs.next());
                assertFalse(rs.getBoolean("is_overdue"), "Lead không có deadline không được bị gắn cờ quá hạn");
            }
        }
    }

    @Test
    @Order(20)
    @DisplayName("IT-20: LeadAcceptServlet từ chối chưa đăng nhập (Session null) -> HTTP 401")
    void testServlet_Accept_Unauthenticated() throws Exception {
        LeadAcceptServlet servlet = new LeadAcceptServlet();
        servlet.setSlaService(slaService);

        HttpServletRequest req = mock(HttpServletRequest.class);
        HttpServletResponse resp = mock(HttpServletResponse.class);
        StringWriter sw = new StringWriter();
        PrintWriter pw = new PrintWriter(sw);

        when(req.getSession(false)).thenReturn(null);
        when(resp.getWriter()).thenReturn(pw);

        servlet.doPost(req, resp);

        verify(resp).setStatus(HttpServletResponse.SC_UNAUTHORIZED);
        assertTrue(sw.toString().contains("Yêu cầu đăng nhập"));
    }

    @Test
    @Order(21)
    @DisplayName("IT-21: LeadRejectServlet từ chối chưa đăng nhập -> HTTP 401")
    void testSecurity_RejectLead_Unauthenticated() throws Exception {
        LeadRejectServlet servlet = new LeadRejectServlet();
        servlet.setSlaService(slaService);

        HttpServletRequest req = mock(HttpServletRequest.class);
        HttpServletResponse resp = mock(HttpServletResponse.class);
        StringWriter sw = new StringWriter();
        PrintWriter pw = new PrintWriter(sw);

        when(req.getSession(false)).thenReturn(null);
        when(resp.getWriter()).thenReturn(pw);

        servlet.doPost(req, resp);

        verify(resp).setStatus(HttpServletResponse.SC_UNAUTHORIZED);
        assertTrue(sw.toString().contains("Yêu cầu đăng nhập"));
    }
}

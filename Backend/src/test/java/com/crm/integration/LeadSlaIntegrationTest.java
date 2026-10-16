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
            stmt.execute("TRUNCATE TABLE leads");
            stmt.execute("TRUNCATE TABLE users");
            stmt.execute("TRUNCATE TABLE teams");
            stmt.execute("SET FOREIGN_KEY_CHECKS = 1");

            // Teams
            stmt.execute("INSERT INTO teams (team_id, team_name, region) VALUES (1, 'Team Bac', 'North'), (2, 'Team Nam', 'South')");

            // Users
            stmt.execute("INSERT INTO users (user_id, email, password_hash, full_name, team_id, is_active, lockout_until) VALUES " +
                    "(1, 'admin@test.local', 'hash', 'Admin Director', NULL, 1, NULL), " +
                    "(101, 'rep1.north@test.local', 'hash', 'Rep North 1', 1, 1, NULL), " +
                    "(102, 'rep2.north@test.local', 'hash', 'Rep North 2', 1, 1, NULL), " +
                    "(201, 'rep1.south@test.local', 'hash', 'Rep South 1', 2, 1, NULL)");

            // Leads
            stmt.execute("INSERT INTO leads (lead_id, contact_name, status, owner_id, assigned_at, sla_due_date, is_overdue) VALUES " +
                    "(1, 'Lead Assigned to 101', 'ASSIGNED', 101, CURRENT_TIMESTAMP, DATE_ADD(CURRENT_TIMESTAMP, INTERVAL 2 HOUR), 0), " +
                    "(2, 'Lead Overdue for 101', 'ASSIGNED', 101, DATE_SUB(CURRENT_TIMESTAMP, INTERVAL 3 HOUR), DATE_SUB(CURRENT_TIMESTAMP, INTERVAL 1 HOUR), 0), " +
                    "(3, 'Lead Queued No Owner', 'QUEUED', NULL, NULL, NULL, 0), " +
                    "(4, 'Lead Converted', 'CONVERTED', 101, CURRENT_TIMESTAMP, NULL, 0), " +
                    "(5, 'Lead Assigned to 201', 'ASSIGNED', 201, CURRENT_TIMESTAMP, NULL, 0)");
        }
    }

    // =========================================================================
    // 1. LEAD ACCEPTANCE TESTS
    // =========================================================================

    @Test
    @Order(1)
    @DisplayName("S4-07 IT-01: Nhân viên nhận Lead hợp lệ (Lead #1 -> User 101) -> Chuyển sang IN_PROGRESS")
    void testAcceptLead_Success() throws SQLException {
        boolean accepted = slaService.acceptLead(1, 101, false);
        assertTrue(accepted);

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement("SELECT status, sla_status, is_overdue FROM leads WHERE lead_id = 1")) {
            try (ResultSet rs = ps.executeQuery()) {
                assertTrue(rs.next());
                assertEquals("IN_PROGRESS", rs.getString("status"));
                assertEquals("RESPONDED", rs.getString("sla_status"));
                assertFalse(rs.getBoolean("is_overdue"));
            }
        }

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement("SELECT status, assigned_to, performed_by FROM lead_assignment_history WHERE lead_id = 1")) {
            try (ResultSet rs = ps.executeQuery()) {
                assertTrue(rs.next());
                assertEquals("IN_PROGRESS", rs.getString("status"));
                assertEquals(101, rs.getInt("assigned_to"));
                assertEquals(101, rs.getInt("performed_by"));
            }
        }
    }

    @Test
    @Order(2)
    @DisplayName("S4-07 IT-02: Nhân viên không sở hữu Lead cố tình nhận Lead -> Bị chặn (SecurityException / 403)")
    void testAcceptLead_NonOwner_Blocked() {
        // User 102 cố nhận Lead 1 (đang giao cho User 101)
        SecurityException ex = assertThrows(SecurityException.class, () -> {
            slaService.acceptLead(1, 102, false);
        });
        assertTrue(ex.getMessage().contains("Ownership vi phạm"));
    }

    @Test
    @Order(3)
    @DisplayName("S4-07 IT-03: Quản trị viên (Admin) có quyền tiếp nhận thay cho nhân viên -> Thành công")
    void testAcceptLead_AdminElevated_Success() throws SQLException {
        // Admin (User 1) có quyền đặc quyền isElevatedRole = true
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
    @Order(4)
    @DisplayName("S4-07 IT-04: Từ chối tiếp nhận Lead đã CONVERTED -> Ném IllegalStateException (409)")
    void testAcceptLead_Converted_Blocked() {
        IllegalStateException ex = assertThrows(IllegalStateException.class, () -> {
            slaService.acceptLead(4, 101, false);
        });
        assertTrue(ex.getMessage().contains("đã được chuyển đổi"));
    }

    @Test
    @Order(5)
    @DisplayName("S4-07 IT-05: Tiếp nhận lặp lại Lead đã IN_PROGRESS -> Idempotent thành công không ghi trùng")
    void testAcceptLead_Idempotent() throws SQLException {
        slaService.acceptLead(1, 101, false);
        // Gọi lần 2
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
    // 2. LEAD REJECTION TESTS
    // =========================================================================

    @Test
    @Order(6)
    @DisplayName("S4-07 IT-06: Nhân viên từ chối Lead kèm lý do hợp lệ -> Trả về QUEUED, ghi reject_reason")
    void testRejectLead_Success() throws SQLException {
        boolean rejected = slaService.rejectLead(1, 101, "Khách hàng sai số điện thoại, không liên lạc được");
        assertTrue(rejected);

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement("SELECT status, owner_id, sla_status FROM leads WHERE lead_id = 1")) {
            try (ResultSet rs = ps.executeQuery()) {
                assertTrue(rs.next());
                assertEquals("QUEUED", rs.getString("status"));
                assertNull(rs.getObject("owner_id"));
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
    @Order(7)
    @DisplayName("S4-07 IT-07: Từ chối Lead không có lý do -> Bị từ chối (IllegalArgumentException / 400)")
    void testRejectLead_MissingReason_Blocked() {
        IllegalArgumentException ex = assertThrows(IllegalArgumentException.class, () -> {
            slaService.rejectLead(1, 101, "   ");
        });
        assertTrue(ex.getMessage().contains("bắt buộc"));
    }

    @Test
    @Order(8)
    @DisplayName("S4-07 IT-08: Người không sở hữu cố tình từ chối Lead -> Bị chặn (SecurityException / 403)")
    void testRejectLead_NonOwner_Blocked() {
        SecurityException ex = assertThrows(SecurityException.class, () -> {
            slaService.rejectLead(1, 102, "Không thích nhận");
        });
        assertTrue(ex.getMessage().contains("Ownership vi phạm"));
    }

    // =========================================================================
    // 3. RESPONSE SLA TESTS
    // =========================================================================

    @Test
    @Order(9)
    @DisplayName("S4-07 IT-09: Quét và gắn cờ is_overdue = 1 cho các Lead quá hạn phản hồi (Lead #2)")
    void testSla_FlagOverdueLeads() throws SQLException {
        // Lead #2 có sla_due_date trong quá khứ (-1 hour), is_overdue = 0
        int flagged = slaService.checkAndFlagOverdueLeads();
        assertTrue(flagged >= 1, "Phải gắn cờ quá hạn cho ít nhất 1 Lead");

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement("SELECT is_overdue, sla_status, status FROM leads WHERE lead_id = 2")) {
            try (ResultSet rs = ps.executeQuery()) {
                assertTrue(rs.next());
                assertTrue(rs.getBoolean("is_overdue"), "is_overdue phải chuyển sang 1 (true)");
                assertEquals("OVERDUE", rs.getString("sla_status"));
                assertEquals("ASSIGNED", rs.getString("status"), "Trạng thái Lead phải giữ nguyên ASSIGNED");
            }
        }
    }

    @Test
    @Order(10)
    @DisplayName("S4-07 IT-10: Đọc cấu hình SLA từ CSDL (Không tự ý hardcode 24h nếu bảng rỗng)")
    void testSla_ConfigFromDatabase() throws SQLException {
        // Khi lead_sla_configs rỗng
        try (Connection conn = DBConnection.getConnection()) {
            Integer minutes = slaService.getSlaResponseTimeMinutes(conn, "HIGH");
            assertNull(minutes, "Nếu bảng lead_sla_configs rỗng, phải trả về null, tuyệt đối không hardcode");
        }

        // Khi có cấu hình
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

    // =========================================================================
    // 4. CONCURRENCY TESTS
    // =========================================================================

    @Test
    @Order(11)
    @DisplayName("S4-07 IT-11: Hai request tiếp nhận đồng thời cùng một Lead -> Không tạo duplicate history")
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

    // =========================================================================
    // 5. API CONTRACT TESTS (LEAD ACCEPT & REJECT SERVLETS)
    // =========================================================================

    @Test
    @Order(12)
    @DisplayName("S4-07 IT-12: LeadAcceptServlet từ chối chưa đăng nhập (Session null) -> HTTP 401")
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
    @Order(13)
    @DisplayName("S4-07 IT-13: LeadAcceptServlet tiếp nhận thành công -> HTTP 200 JSON")
    void testServlet_Accept_Success() throws Exception {
        LeadAcceptServlet servlet = new LeadAcceptServlet();
        servlet.setSlaService(slaService);

        HttpServletRequest req = mock(HttpServletRequest.class);
        HttpServletResponse resp = mock(HttpServletResponse.class);
        HttpSession session = mock(HttpSession.class);
        StringWriter sw = new StringWriter();
        PrintWriter pw = new PrintWriter(sw);

        when(req.getSession(false)).thenReturn(session);
        when(session.getAttribute("userId")).thenReturn(101);
        when(session.getAttribute("roleId")).thenReturn(2);
        Account acc = new Account();
        acc.setRoleCodes(Collections.singletonList("SALES_REP"));
        when(session.getAttribute("currentUser")).thenReturn(acc);

        when(req.getParameter("leadId")).thenReturn("1");
        when(resp.getWriter()).thenReturn(pw);

        servlet.doPost(req, resp);

        verify(resp).setStatus(HttpServletResponse.SC_OK);
        assertTrue(sw.toString().contains("\"status\": \"success\""));
        assertTrue(sw.toString().contains("IN_PROGRESS"));
    }

    @Test
    @Order(14)
    @DisplayName("S4-07 IT-14: LeadRejectServlet từ chối thành công -> HTTP 200 JSON")
    void testServlet_Reject_Success() throws Exception {
        LeadRejectServlet servlet = new LeadRejectServlet();
        servlet.setSlaService(slaService);

        HttpServletRequest req = mock(HttpServletRequest.class);
        HttpServletResponse resp = mock(HttpServletResponse.class);
        HttpSession session = mock(HttpSession.class);
        StringWriter sw = new StringWriter();
        PrintWriter pw = new PrintWriter(sw);

        when(req.getSession(false)).thenReturn(session);
        when(session.getAttribute("userId")).thenReturn(101);
        when(session.getAttribute("roleId")).thenReturn(2);
        Account acc = new Account();
        acc.setRoleCodes(Collections.singletonList("SALES_REP"));
        when(session.getAttribute("currentUser")).thenReturn(acc);

        when(req.getParameter("leadId")).thenReturn("1");
        when(req.getParameter("rejectReason")).thenReturn("Sai nhu cầu sản phẩm");
        when(resp.getWriter()).thenReturn(pw);

        servlet.doPost(req, resp);

        verify(resp).setStatus(HttpServletResponse.SC_OK);
        assertTrue(sw.toString().contains("\"status\": \"success\""));
    }

    // =========================================================================
    // 6. TARGETED HARDENING TESTS (TRANSACTION, CONCURRENCY, SLA EDGE CASES)
    // =========================================================================

    @Test
    @Order(15)
    @DisplayName("S4-07 IT-15: Transaction Rollback khi INSERT History thất bại trong acceptLead -> Lead giữ nguyên trạng thái ASSIGNED")
    void testTransaction_RollbackOnHistoryFailure_Accept() throws SQLException {
        LeadAssignmentHistoryDAO failingHistoryDAO = mock(LeadAssignmentHistoryDAO.class);
        when(failingHistoryDAO.saveHistory(any(Connection.class), any())).thenReturn(false);
        LeadSlaService serviceWithFailingDAO = new LeadSlaService(failingHistoryDAO);

        SQLException ex = assertThrows(SQLException.class, () -> {
            serviceWithFailingDAO.acceptLead(1, 101, false);
        });
        assertTrue(ex.getMessage().contains("thất bại"));

        // Verify database state: Lead #1 must still be ASSIGNED with owner 101
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement("SELECT status, owner_id FROM leads WHERE lead_id = 1")) {
            try (ResultSet rs = ps.executeQuery()) {
                assertTrue(rs.next());
                assertEquals("ASSIGNED", rs.getString("status"), "Rollback phải giữ nguyên trạng thái ASSIGNED");
                assertEquals(101, rs.getInt("owner_id"), "Rollback phải giữ nguyên owner_id 101");
            }
        }
    }

    @Test
    @Order(16)
    @DisplayName("S4-07 IT-16: Transaction Rollback khi INSERT History thất bại trong rejectLead -> Lead giữ nguyên trạng thái ASSIGNED")
    void testTransaction_RollbackOnHistoryFailure_Reject() throws SQLException {
        LeadAssignmentHistoryDAO failingHistoryDAO = mock(LeadAssignmentHistoryDAO.class);
        when(failingHistoryDAO.saveHistory(any(Connection.class), any())).thenReturn(false);
        LeadSlaService serviceWithFailingDAO = new LeadSlaService(failingHistoryDAO);

        SQLException ex = assertThrows(SQLException.class, () -> {
            serviceWithFailingDAO.rejectLead(1, 101, "Lý do từ chối kiểm thử rollback", false);
        });
        assertTrue(ex.getMessage().contains("thất bại"));

        // Verify database state: Lead #1 must still be ASSIGNED with owner 101, not QUEUED
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement("SELECT status, owner_id FROM leads WHERE lead_id = 1")) {
            try (ResultSet rs = ps.executeQuery()) {
                assertTrue(rs.next());
                assertEquals("ASSIGNED", rs.getString("status"), "Rollback phải giữ nguyên trạng thái ASSIGNED");
                assertEquals(101, rs.getInt("owner_id"), "Rollback phải giữ nguyên owner_id 101");
            }
        }
    }

    @Test
    @Order(17)
    @DisplayName("S4-07 IT-17: Accept và Reject chạy đồng thời trên cùng Lead -> Pessimistic locking đảm bảo tính nhất quán")
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

        // One of the two must succeed, and the final state must be either IN_PROGRESS or QUEUED
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
    @Order(18)
    @DisplayName("S4-07 IT-18: Cấu hình SLA có is_active = 0 bị bỏ qua -> Trả về null")
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
    @DisplayName("S4-07 IT-19: Lead đã phản hồi (IN_PROGRESS) không bị gắn cờ quá hạn dù sla_due_date đã qua")
    void testSla_NotOverdueIfAlreadyResponded() throws SQLException {
        // Cập nhật Lead #2 có sla_due_date trong quá khứ sang IN_PROGRESS
        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement()) {
            stmt.execute("UPDATE leads SET status = 'IN_PROGRESS', is_overdue = 0 WHERE lead_id = 2");
        }

        slaService.checkAndFlagOverdueLeads();
        // Lead #2 không được bị gắn cờ quá hạn vì trạng thái không còn là ASSIGNED
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement("SELECT is_overdue, status FROM leads WHERE lead_id = 2")) {
            try (ResultSet rs = ps.executeQuery()) {
                assertTrue(rs.next());
                assertFalse(rs.getBoolean("is_overdue"), "Lead IN_PROGRESS không được bị gắn cờ quá hạn");
            }
        }
    }

    @Test
    @Order(20)
    @DisplayName("S4-07 IT-20: Lead có sla_due_date = NULL không bị gắn cờ quá hạn")
    void testSla_LeadWithNullDueDate_NotFlagged() throws SQLException {
        // Lead #5 có sla_due_date = NULL, status = 'ASSIGNED'
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
    @Order(21)
    @DisplayName("S4-07 IT-21: LeadRejectServlet từ chối chưa đăng nhập -> HTTP 401")
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

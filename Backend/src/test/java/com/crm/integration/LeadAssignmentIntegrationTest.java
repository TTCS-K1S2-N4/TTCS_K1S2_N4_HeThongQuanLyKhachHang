package com.crm.integration;

import com.crm.controller.lead.LeadAssignServlet;
import com.crm.dao.LeadAssignmentHistoryDAO;
import com.crm.dao.LeadAssignmentRuleDAO;
import com.crm.model.Account;
import com.crm.model.LeadAssignmentHistory;
import com.crm.model.LeadAssignmentRule;
import com.crm.service.LeadAssignmentService;
import com.crm.util.DBConnection;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.junit.jupiter.api.*;
import org.mockito.Mockito;

import java.io.PrintWriter;
import java.io.StringWriter;
import java.sql.*;
import java.util.*;
import java.util.concurrent.*;
import java.util.concurrent.atomic.AtomicInteger;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

/**
 * Suite kiểm thử tích hợp thực tế (Integration Test) cho S4-06 trên MySQL database cô lập: crm_s4_06_test.
 * Tuyệt đối không chạy trên crm_db. Fail-fast nếu catalog không đúng.
 */
@TestMethodOrder(MethodOrderer.OrderAnnotation.class)
public class LeadAssignmentIntegrationTest {

    private static final String TEST_DB_URL = "jdbc:mysql://localhost:3306/crm_s4_06_test?useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true&useUnicode=true&characterEncoding=UTF-8";
    private static final String DRIVER = "com.mysql.cj.jdbc.Driver";

    private LeadAssignmentService assignmentService;
    private LeadAssignmentRuleDAO ruleDAO;
    private LeadAssignmentHistoryDAO historyDAO;

    @BeforeAll
    static void initSafetyGate() throws Exception {
        String testUser = System.getProperty("db.test.user");
        String testPass = System.getProperty("db.test.password", System.getenv("MYSQL_TEST_PWD"));

        if (testPass == null || testPass.trim().isEmpty() || testUser == null || testUser.trim().isEmpty()) {
            try (java.io.InputStream is = LeadAssignmentIntegrationTest.class.getClassLoader().getResourceAsStream("db.local.properties")) {
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
                try (java.io.InputStream is = LeadAssignmentIntegrationTest.class.getClassLoader().getResourceAsStream("db.properties")) {
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

        // SAFETY GATE FAIL-FAST: Kiểm tra catalog kết nối
        try (Connection conn = DBConnection.getConnection()) {
            assertNotNull(conn, "Không thể kết nối đến MySQL test database");
            String catalog = conn.getCatalog();
            if (!"crm_s4_06_test".equalsIgnoreCase(catalog)) {
                throw new IllegalStateException("CRITICAL SAFETY ABORT: Database catalog is '" + catalog + "', NOT 'crm_s4_06_test'!");
            }
        }
    }

    @AfterAll
    static void tearDownClass() {
        DBConnection.resetDefaultCredentials();
    }

    @BeforeEach
    void setUp() throws SQLException {
        verifySafetyCatalog();
        ruleDAO = new LeadAssignmentRuleDAO();
        historyDAO = new LeadAssignmentHistoryDAO();
        assignmentService = new LeadAssignmentService(ruleDAO, historyDAO);

        // Reset dữ liệu mẫu (Fixtures) cho mỗi bài kiểm thử
        resetTestFixtures();
    }

    private void verifySafetyCatalog() throws SQLException {
        try (Connection conn = DBConnection.getConnection()) {
            if (!"crm_s4_06_test".equalsIgnoreCase(conn.getCatalog())) {
                throw new IllegalStateException("CRITICAL SAFETY ABORT: Not connected to crm_s4_06_test!");
            }
        }
    }

    private void resetTestFixtures() throws SQLException {
        try (Connection conn = DBConnection.getConnection()) {
            try (Statement stmt = conn.createStatement()) {
                stmt.execute("SET FOREIGN_KEY_CHECKS = 0");
                stmt.execute("TRUNCATE TABLE lead_assignment_history");
                stmt.execute("TRUNCATE TABLE lead_assignment_rules");
                stmt.execute("TRUNCATE TABLE leads");
                stmt.execute("TRUNCATE TABLE users");
                stmt.execute("TRUNCATE TABLE teams");
                stmt.execute("SET FOREIGN_KEY_CHECKS = 1");

                // 1. Teams
                stmt.execute("INSERT INTO teams (team_id, team_name, region) VALUES " +
                        "(1, 'Team Bac Test', 'North'), " +
                        "(2, 'Team Nam Test', 'South')");

                stmt.execute("INSERT INTO users (user_id, email, password_hash, full_name, team_id, is_active, lockout_until) VALUES " +
                        "(1, 'admin@test.local', 'hash', 'Admin Director', NULL, 1, NULL), " +
                        "(101, 'rep1.north@test.local', 'hash', 'Rep North 1', 1, 1, NULL), " +
                        "(102, 'rep2.north@test.local', 'hash', 'Rep North 2', 1, 1, NULL), " +
                        "(103, 'lead.north@test.local', 'hash', 'TeamLead North', 1, 1, NULL), " +
                        "(201, 'rep1.south@test.local', 'hash', 'Rep South 1', 2, 1, NULL), " +
                        "(104, 'inactive.north@test.local', 'hash', 'Inactive Rep', 1, 0, NULL), " +
                        "(105, 'locked.north@test.local', 'hash', 'Locked Rep', 1, 1, DATE_ADD(CURRENT_TIMESTAMP, INTERVAL 1 DAY))");

                // 3. Rules
                // Rule 1: Priority 1, Region South -> Assignee 201
                // Rule 2: Priority 2, Industry Technology -> Assignee 102
                // Rule 3: Priority 3, Round-Robin -> Team 1
                stmt.execute("INSERT INTO lead_assignment_rules (rule_id, rule_name, priority, criterion, criterion_value, team_id, assignee_id, last_assigned_user_id, is_active) VALUES " +
                        "(1, 'Rule Region South', 1, 'REGION', 'South', NULL, 201, NULL, 1), " +
                        "(2, 'Rule Industry Tech', 2, 'INDUSTRY', 'Technology', NULL, 102, NULL, 1), " +
                        "(3, 'Rule Round Robin Team 1', 3, 'ROUND_ROBIN', NULL, 1, NULL, NULL, 1)");

                // 4. Leads
                stmt.execute("INSERT INTO leads (lead_id, contact_name, company_name, region, industry, status, owner_id) VALUES " +
                        "(1, 'Lead Region South', 'Cong ty Nam', 'South', 'Retail', 'NEW', NULL), " +
                        "(2, 'Lead Industry Tech', 'Cong ty CNTT', 'North', 'Technology', 'NEW', NULL), " +
                        "(3, 'Lead RR 1', 'Cong ty RR1', 'North', 'Agriculture', 'NEW', NULL), " +
                        "(4, 'Lead RR 2', 'Cong ty RR2', 'North', 'Agriculture', 'NEW', NULL), " +
                        "(5, 'Lead No Match', 'Cong ty NoMatch', 'West', 'Aerospace', 'NEW', NULL), " +
                        "(6, 'Lead Converted', 'Cong ty Chuyen Doi', 'North', 'Finance', 'CONVERTED', 101), " +
                        "(7, 'Lead Team 2 Owned', 'Cong ty Team 2', 'South', 'Retail', 'ASSIGNED', 201)");
            }
        }
    }

    // =========================================================================
    // NHÓM 1: DATABASE INTEGRATION TESTS (PHÂN BỔ THẬT TRÊN MYSQL)
    // =========================================================================

    @Test
    @Order(1)
    @DisplayName("IT-01: Phân bổ Lead theo Tiêu chí Region khớp CSDL (Lead #1 -> Rule #1 -> User #201)")
    void testAssignLead_ByRegion() throws SQLException {
        Integer assignedUser = assignmentService.assignLead(1, "South", "Retail", 1);

        assertNotNull(assignedUser);
        assertEquals(201, assignedUser, "Lead #1 phải được phân bổ cho User 201 (Team Nam)");

        // Kiểm tra trực tiếp bảng leads
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement("SELECT status, owner_id, assigned_at FROM leads WHERE lead_id = 1");
             ResultSet rs = ps.executeQuery()) {
            assertTrue(rs.next());
            assertEquals("ASSIGNED", rs.getString("status"));
            assertEquals(201, rs.getInt("owner_id"));
            assertNotNull(rs.getTimestamp("assigned_at"));
        }

        // Kiểm tra trực tiếp bảng lead_assignment_history
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement("SELECT rule_id, assigned_to, performed_by, status FROM lead_assignment_history WHERE lead_id = 1");
             ResultSet rs = ps.executeQuery()) {
            assertTrue(rs.next());
            assertEquals(1, rs.getInt("rule_id"));
            assertEquals(201, rs.getInt("assigned_to"));
            assertEquals(1, rs.getInt("performed_by"));
            assertEquals("ASSIGNED", rs.getString("status"));
        }
    }

    @Test
    @Order(2)
    @DisplayName("IT-02: Phân bổ Lead theo Tiêu chí Industry (Lead #2 -> Rule #2 -> User #102)")
    void testAssignLead_ByIndustry() throws SQLException {
        Integer assignedUser = assignmentService.assignLead(2, "North", "Technology", 1);

        assertNotNull(assignedUser);
        assertEquals(102, assignedUser, "Lead #2 phải được phân bổ cho User 102");

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement("SELECT status, owner_id FROM leads WHERE lead_id = 2");
             ResultSet rs = ps.executeQuery()) {
            assertTrue(rs.next());
            assertEquals("ASSIGNED", rs.getString("status"));
            assertEquals(102, rs.getInt("owner_id"));
        }
    }

    @Test
    @Order(3)
    @DisplayName("IT-03: Kiểm tra thứ tự ưu tiên Rule Priority (Priority 1 Region South thắng Priority 2 Tech)")
    void testAssignLead_RulePriorityOrder() throws SQLException {
        // Lead có cả Region=South và Industry=Technology -> Rule 1 (Priority 1) phải thắng Rule 2 (Priority 2)
        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement()) {
            stmt.execute("INSERT INTO leads (lead_id, contact_name, region, industry, status) VALUES (10, 'Lead Both Match', 'South', 'Technology', 'NEW')");
        }

        Integer assignedUser = assignmentService.assignLead(10, "South", "Technology", 1);
        assertEquals(201, assignedUser, "Rule có Priority 1 (South) phải được ưu tiên trước");
    }

    @Test
    @Order(4)
    @DisplayName("IT-04: Kiểm chứng Round-Robin bền vững trong CSDL (Lưu pointer & xoay vòng qua 101, 102, 103)")
    void testAssignLead_PersistentRoundRobinRotation() throws SQLException {
        // Lead 3 phân bổ lần 1 -> User 101 (đầu tiên)
        Integer user1 = assignmentService.assignLead(3, "North", "Agriculture", 1);
        assertEquals(101, user1);
        assertPointerInDb(3, 101);

        // Lead 4 phân bổ lần 2 -> User 102
        Integer user2 = assignmentService.assignLead(4, "North", "Agriculture", 1);
        assertEquals(102, user2);
        assertPointerInDb(3, 102);

        // Thêm Lead mới phân bổ lần 3 -> User 103
        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement()) {
            stmt.execute("INSERT INTO leads (lead_id, contact_name, region, industry, status) VALUES (11, 'Lead RR 3', 'North', 'Agriculture', 'NEW')");
            stmt.execute("INSERT INTO leads (lead_id, contact_name, region, industry, status) VALUES (12, 'Lead RR 4', 'North', 'Agriculture', 'NEW')");
        }

        Integer user3 = assignmentService.assignLead(11, "North", "Agriculture", 1);
        assertEquals(103, user3);
        assertPointerInDb(3, 103);

        // Lần 4: Quay vòng lại người đầu tiên (101)
        Integer user4 = assignmentService.assignLead(12, "North", "Agriculture", 1);
        assertEquals(101, user4, "Phải quay vòng lại 101");
        assertPointerInDb(3, 101);
    }

    private void assertPointerInDb(int ruleId, int expectedPointer) throws SQLException {
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement("SELECT last_assigned_user_id FROM lead_assignment_rules WHERE rule_id = ?")) {
            ps.setInt(1, ruleId);
            try (ResultSet rs = ps.executeQuery()) {
                assertTrue(rs.next());
                assertEquals(expectedPointer, rs.getInt("last_assigned_user_id"));
            }
        }
    }

    @Test
    @Order(5)
    @DisplayName("IT-05: Lead không khớp Rule nào được đưa vào hàng chờ QUEUED và ghi history")
    void testAssignLead_NoMatchingRule_FallbackToQueued() throws SQLException {
        // Tắt Rule 3 (Round Robin catch-all) để tạo điều kiện không có Rule nào khớp với Lead 5 (West / Aerospace)
        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement()) {
            stmt.execute("UPDATE lead_assignment_rules SET is_active = 0 WHERE rule_id = 3");
        }

        Integer assignedUser = assignmentService.assignLead(5, "West", "Aerospace", 1);
        assertNull(assignedUser, "Không khớp rule nào phải trả về null");

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement("SELECT status, owner_id FROM leads WHERE lead_id = 5");
             ResultSet rs = ps.executeQuery()) {
            assertTrue(rs.next());
            assertEquals("QUEUED", rs.getString("status"));
            assertNull(rs.getObject("owner_id"));
        }

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement("SELECT status, assigned_to FROM lead_assignment_history WHERE lead_id = 5");
             ResultSet rs = ps.executeQuery()) {
            assertTrue(rs.next());
            assertEquals("QUEUED", rs.getString("status"));
            assertNull(rs.getObject("assigned_to"));
        }
    }

    // =========================================================================
    // NHÓM 2: TRANSACTION & ROLLBACK TESTS
    // =========================================================================

    @Test
    @Order(6)
    @DisplayName("IT-06: Rollback toàn phần khi cập nhật Lead lỗi hoặc vi phạm ràng buộc")
    void testTransaction_RollbackOnFailure() throws SQLException {
        // Cố tình tạo điều kiện lỗi bằng cách gán Lead không tồn tại
        assertThrows(IllegalArgumentException.class, () -> {
            assignmentService.assignLead(99999, "North", "IT", 999);
        });

        // Kiểm tra không có history rác được tạo
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement("SELECT COUNT(*) FROM lead_assignment_history WHERE lead_id = 99999");
             ResultSet rs = ps.executeQuery()) {
            assertTrue(rs.next());
            assertEquals(0, rs.getInt(1), "Rollback phải đảm bảo không tạo history rác");
        }
    }

    @Test
    @Order(7)
    @DisplayName("IT-07: Từ chối phân bổ Lead đã CONVERTED (Không ghi đè dữ liệu)")
    void testTransaction_BlockConvertedLead() {
        IllegalStateException ex = assertThrows(IllegalStateException.class, () -> {
            assignmentService.assignLead(6, "North", "Finance", 999);
        });
        assertTrue(ex.getMessage().contains("đã được chuyển đổi"));

        // Kiểm tra Lead 6 vẫn giữ nguyên owner_id 101 và status CONVERTED
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement("SELECT status, owner_id FROM leads WHERE lead_id = 6");
             ResultSet rs = ps.executeQuery()) {
            assertTrue(rs.next());
            assertEquals("CONVERTED", rs.getString("status"));
            assertEquals(101, rs.getInt("owner_id"));
        } catch (SQLException e) {
            fail(e);
        }
    }

    // =========================================================================
    // NHÓM 3: CONCURRENCY TESTS (ĐA LUỒNG & KHÓA BI QUAN)
    // =========================================================================

    @Test
    @Order(8)
    @DisplayName("IT-08: Hai request đồng thời phân bổ cùng một Lead -> Không phân bổ trùng lặp")
    void testConcurrency_SameLeadTwoThreads() throws Exception {
        int threads = 2;
        ExecutorService executor = Executors.newFixedThreadPool(threads);
        CountDownLatch startGate = new CountDownLatch(1);
        CountDownLatch endGate = new CountDownLatch(threads);

        List<Integer> results = Collections.synchronizedList(new ArrayList<>());
        AtomicInteger successCount = new AtomicInteger(0);

        for (int i = 0; i < threads; i++) {
            executor.submit(() -> {
                try {
                    startGate.await();
                    Integer assignee = assignmentService.assignLead(1, "South", "Retail", 1);
                    results.add(assignee);
                    successCount.incrementAndGet();
                } catch (Exception e) {
                    // Xử lý lỗi nếu có
                } finally {
                    endGate.countDown();
                }
            });
        }

        startGate.countDown();
        assertTrue(endGate.await(10, TimeUnit.SECONDS), "Timeout concurrency test");
        executor.shutdown();

        assertEquals(2, results.size());
        assertEquals(results.get(0), results.get(1), "Cả hai luồng phải thống nhất cùng một người nhận");

        // Kiểm tra trong CSDL chỉ có DUY NHẤT 1 lịch sử phân bổ ASSIGNED
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement("SELECT COUNT(*) FROM lead_assignment_history WHERE lead_id = 1 AND status = 'ASSIGNED'");
             ResultSet rs = ps.executeQuery()) {
            assertTrue(rs.next());
            assertEquals(1, rs.getInt(1), "Không được ghi history trùng lặp khi chạy đồng thời");
        }
    }

    @Test
    @Order(9)
    @DisplayName("IT-09: Hai request đồng thời phân bổ 2 Lead khác nhau qua cùng Rule Round-Robin -> Không nhảy bước")
    void testConcurrency_DifferentLeadsSameRule() throws Exception {
        int threads = 2;
        ExecutorService executor = Executors.newFixedThreadPool(threads);
        CountDownLatch startGate = new CountDownLatch(1);
        CountDownLatch endGate = new CountDownLatch(threads);

        List<Integer> assignedUsers = Collections.synchronizedList(new ArrayList<>());

        executor.submit(() -> {
            try {
                startGate.await();
                assignedUsers.add(assignmentService.assignLead(3, "North", "Agriculture", 1));
            } catch (Exception ignored) {} finally { endGate.countDown(); }
        });

        executor.submit(() -> {
            try {
                startGate.await();
                assignedUsers.add(assignmentService.assignLead(4, "North", "Agriculture", 1));
            } catch (Exception ignored) {} finally { endGate.countDown(); }
        });

        startGate.countDown();
        assertTrue(endGate.await(10, TimeUnit.SECONDS));
        executor.shutdown();

        assertEquals(2, assignedUsers.size());
        assertNotEquals(assignedUsers.get(0), assignedUsers.get(1), "2 Lead phải được phân bổ cho 2 người khác nhau qua Round-Robin");
        assertTrue(assignedUsers.contains(101) && assignedUsers.contains(102), "Phải phân bổ cho 101 và 102");
    }

    // =========================================================================
    // NHÓM 4: SECURITY & DATA SCOPE TESTS
    // =========================================================================

    @Test
    @Order(10)
    @DisplayName("IT-10: Team Lead phân bổ thủ công Lead hợp lệ trong Team của mình -> THÀNH CÔNG")
    void testSecurity_TeamLead_AssignWithinTeam_Success() throws SQLException {
        // Team Lead North (team_id = 1) gán Lead 3 cho Rep North 2 (User 102, team_id = 1)
        boolean success = assignmentService.assignLeadManually(3, 102, 103, 1);
        assertTrue(success);

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement("SELECT owner_id, status FROM leads WHERE lead_id = 3");
             ResultSet rs = ps.executeQuery()) {
            assertTrue(rs.next());
            assertEquals(102, rs.getInt("owner_id"));
            assertEquals("ASSIGNED", rs.getString("status"));
        }
    }

    @Test
    @Order(11)
    @DisplayName("IT-11: Team Lead cố tình phân bổ cho nhân viên ngoài Team (Team 1 -> User 201) -> BỊ CHẶN (HTTP 403 / SecurityException)")
    void testSecurity_TeamLead_AssignOutsideTeam_Blocked() {
        // Team Lead North (team_id = 1) cố gán Lead cho User 201 (thuộc Team 2)
        SecurityException ex = assertThrows(SecurityException.class, () -> {
            assignmentService.assignLeadManually(3, 201, 103, 1);
        });
        assertTrue(ex.getMessage().contains("Data Scope vi phạm"));
    }

    @Test
    @Order(12)
    @DisplayName("IT-12: Team Lead cố tình can thiệp Lead đang thuộc quản lý của Team khác (Lead 7 thuộc Team 2) -> BỊ CHẶN")
    void testSecurity_TeamLead_InterfereOtherTeamLead_Blocked() {
        // Team Lead North (team_id = 1) cố gán Lead 7 (đang do User 201 Team 2 sở hữu)
        SecurityException ex = assertThrows(SecurityException.class, () -> {
            assignmentService.assignLeadManually(7, 101, 103, 1);
        });
        assertTrue(ex.getMessage().contains("Data Scope của Lead vi phạm"));
    }

    @Test
    @Order(13)
    @DisplayName("IT-13: Phân bổ cho nhân viên bị VÔ HIỆU HÓA (User 104 is_active=0) -> BỊ TỪ CHỐI")
    void testSecurity_AssignToInactiveUser_Blocked() {
        IllegalArgumentException ex = assertThrows(IllegalArgumentException.class, () -> {
            assignmentService.assignLeadManually(3, 104, 103, 1);
        });
        assertTrue(ex.getMessage().contains("vô hiệu hóa hoặc đang bị khóa"));
    }

    @Test
    @Order(14)
    @DisplayName("IT-14: Phân bổ cho nhân viên đang BỊ KHÓA TÀI KHOẢN (User 105 lockout_until) -> BỊ TỪ CHỐI")
    void testSecurity_AssignToLockedUser_Blocked() {
        IllegalArgumentException ex = assertThrows(IllegalArgumentException.class, () -> {
            assignmentService.assignLeadManually(3, 105, 103, 1);
        });
        assertTrue(ex.getMessage().contains("vô hiệu hóa hoặc đang bị khóa"));
    }

    // =========================================================================
    // NHÓM 5: API CONTRACT INTEGRATION TESTS (LEAD ASSIGN SERVLET)
    // =========================================================================

    @Test
    @Order(15)
    @DisplayName("IT-15: Servlet chặn người dùng chưa đăng nhập (Session null) -> Trả về HTTP 401")
    void testServlet_Unauthenticated_Returns401() throws Exception {
        LeadAssignServlet servlet = new LeadAssignServlet();
        servlet.setAssignmentService(assignmentService);

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
    @Order(16)
    @DisplayName("IT-16: Servlet chặn vai trò SALES_REP (Role 2) -> Trả về HTTP 403")
    void testServlet_SalesRole_Returns403() throws Exception {
        LeadAssignServlet servlet = new LeadAssignServlet();
        servlet.setAssignmentService(assignmentService);

        HttpServletRequest req = mock(HttpServletRequest.class);
        HttpServletResponse resp = mock(HttpServletResponse.class);
        HttpSession session = mock(HttpSession.class);
        StringWriter sw = new StringWriter();
        PrintWriter pw = new PrintWriter(sw);

        when(req.getSession(false)).thenReturn(session);
        when(session.getAttribute("userId")).thenReturn(101);
        when(session.getAttribute("roleId")).thenReturn(2); // SALES_REP
        Account salesAcc = new Account();
        salesAcc.setRoleCodes(Collections.singletonList("SALES_REP"));
        when(session.getAttribute("currentUser")).thenReturn(salesAcc);

        when(resp.getWriter()).thenReturn(pw);

        servlet.doPost(req, resp);

        verify(resp).setStatus(HttpServletResponse.SC_FORBIDDEN);
        assertTrue(sw.toString().contains("Chỉ Trưởng nhóm hoặc Quản trị viên"));
    }

    @Test
    @Order(17)
    @DisplayName("IT-17: Servlet hỗ trợ tham số userId theo Master API Contract (FE05 compatibility) -> 200 OK")
    void testServlet_UserIdParameterSupport_Returns200() throws Exception {
        LeadAssignServlet servlet = new LeadAssignServlet();
        servlet.setAssignmentService(assignmentService);

        HttpServletRequest req = mock(HttpServletRequest.class);
        HttpServletResponse resp = mock(HttpServletResponse.class);
        HttpSession session = mock(HttpSession.class);
        StringWriter sw = new StringWriter();
        PrintWriter pw = new PrintWriter(sw);

        when(req.getSession(false)).thenReturn(session);
        when(session.getAttribute("userId")).thenReturn(1);
        when(session.getAttribute("roleId")).thenReturn(1); // ADMIN
        Account adminAcc = new Account();
        adminAcc.setRoleCodes(Collections.singletonList("ADMIN"));
        when(session.getAttribute("currentUser")).thenReturn(adminAcc);

        // FE gửi leadId và userId (thay vì assigneeId)
        when(req.getParameter("leadId")).thenReturn("3");
        when(req.getParameter("assigneeId")).thenReturn(null);
        when(req.getParameter("userId")).thenReturn("102");

        when(resp.getWriter()).thenReturn(pw);

        servlet.doPost(req, resp);

        verify(resp).setStatus(HttpServletResponse.SC_OK);
        assertTrue(sw.toString().contains("\"status\": \"success\""));
        assertTrue(sw.toString().contains("\"assigneeId\": 102"));
    }
}

package com.crm.integration;

import com.crm.controller.lead.LeadFilterServlet;
import com.crm.controller.lead.LeadListServlet;
import com.crm.controller.lead.LeadSavedFilterServlet;
import com.crm.dao.AccountDAO;
import com.crm.dao.LeadDAO;
import com.crm.dao.LeadSavedFilterDAO;
import com.crm.dto.LeadFilterRequest;
import com.crm.dto.LeadResponse;
import com.crm.model.Lead;
import com.crm.model.LeadSavedFilter;
import com.crm.service.LeadFilterService;
import com.crm.service.LeadScoringService;
import com.crm.service.PermissionService;
import com.crm.util.DBConnection;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.junit.jupiter.api.*;

import java.io.PrintWriter;
import java.io.StringWriter;
import java.sql.*;
import java.util.Collections;
import java.util.List;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

/**
 * Integration Test Suite cho S4-09: Lead List, Filters & Saved Filters.
 * Bao phủ đầy đủ 17 Test Cases (LF01 - LF17).
 * Chạy trên database kiểm thử cô lập crm_s4_06_test.
 */
@TestMethodOrder(MethodOrderer.OrderAnnotation.class)
public class LeadFilterIntegrationTest {

    private static final String TEST_DB_URL = "jdbc:mysql://localhost:3306/crm_s4_06_test?useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true&useUnicode=true&characterEncoding=UTF-8";
    private static final String DRIVER = "com.mysql.cj.jdbc.Driver";

    private LeadFilterService filterService;
    private LeadSavedFilterDAO savedFilterDAO;
    private LeadDAO leadDAO;

    private static int userSalesA = 201;
    private static int userSalesB = 202;
    private static int sourceWebsiteId;
    private static int sourceFacebookId;

    @BeforeAll
    static void initSafetyGate() throws Exception {
        String testUser = System.getProperty("db.test.user");
        String testPass = System.getProperty("db.test.password", System.getenv("MYSQL_TEST_PWD"));

        if (testPass == null || testPass.trim().isEmpty() || testUser == null || testUser.trim().isEmpty()) {
            try (java.io.InputStream is = LeadFilterIntegrationTest.class.getClassLoader().getResourceAsStream("db.local.properties")) {
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
                try (java.io.InputStream is = LeadFilterIntegrationTest.class.getClassLoader().getResourceAsStream("db.properties")) {
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

            try (Statement stmt = conn.createStatement()) {
                // Đảm bảo có bảng lead_sources với các nguồn mẫu
                stmt.execute("CREATE TABLE IF NOT EXISTS lead_sources (" +
                        "source_id INT AUTO_INCREMENT PRIMARY KEY, " +
                        "source_name VARCHAR(100) NOT NULL UNIQUE" +
                        ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");

                try {
                    stmt.execute("REPLACE INTO lead_sources (source_id, source_code, source_name) VALUES (1, 'WEB', 'Website'), (2, 'FB', 'Facebook'), (3, 'ADS', 'Google Ads')");
                } catch (SQLException ignore) {
                    try {
                        stmt.execute("REPLACE INTO lead_sources (source_id, source_name) VALUES (1, 'Website'), (2, 'Facebook'), (3, 'Google Ads')");
                    } catch (SQLException ignored) {}
                }

                // Đảm bảo có bảng permissions và role_permissions để phân quyền data_scope = ALL cho roleId = 1
                stmt.execute("CREATE TABLE IF NOT EXISTS permissions (" +
                        "permission_id INT AUTO_INCREMENT PRIMARY KEY, " +
                        "permission_code VARCHAR(100), " +
                        "permission_name VARCHAR(150), " +
                        "module VARCHAR(50)" +
                        ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");

                stmt.execute("CREATE TABLE IF NOT EXISTS role_permissions (" +
                        "role_id INT NOT NULL, " +
                        "permission_id INT NOT NULL, " +
                        "data_scope VARCHAR(20) DEFAULT 'ALL', " +
                        "PRIMARY KEY (role_id, permission_id)" +
                        ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");

                // Đảm bảo có bảng roles
                stmt.execute("CREATE TABLE IF NOT EXISTS roles (" +
                        "role_id INT AUTO_INCREMENT PRIMARY KEY, " +
                        "role_name VARCHAR(50) NOT NULL" +
                        ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");

                stmt.execute("INSERT IGNORE INTO roles (role_id, role_name) VALUES (1, 'ADMIN')");

                try {
                    stmt.execute("INSERT IGNORE INTO permissions (permission_id, permission_code, permission_name, module) " +
                                 "VALUES (999, 'LEAD_VIEW_ALL', 'View All Leads', 'LEAD'), (998, 'ACCOUNT_VIEW_ALL', 'View All Accounts', 'ACCOUNT')");
                    stmt.execute("REPLACE INTO role_permissions (role_id, permission_id, data_scope) VALUES (1, 999, 'ALL'), (1, 998, 'ALL')");
                } catch (SQLException ignore) {}

                // Đảm bảo có bảng saved_filters
                stmt.execute("CREATE TABLE IF NOT EXISTS saved_filters (" +
                        "filter_id INT AUTO_INCREMENT PRIMARY KEY, " +
                        "user_id INT NOT NULL, " +
                        "filter_name VARCHAR(100) NOT NULL, " +
                        "module VARCHAR(50) DEFAULT 'CUSTOMER', " +
                        "keyword VARCHAR(200), " +
                        "status VARCHAR(50), " +
                        "industry VARCHAR(100), " +
                        "company_size VARCHAR(50), " +
                        "region VARCHAR(100), " +
                        "owner_id INT, " +
                        "filter_query TEXT, " +
                        "is_default TINYINT(1) DEFAULT 0, " +
                        "created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, " +
                        "updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP" +
                        ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");

                // Đảm bảo bảng leads có đầy đủ các cột phục vụ test
                stmt.execute("CREATE TABLE IF NOT EXISTS leads (" +
                        "lead_id INT AUTO_INCREMENT PRIMARY KEY, " +
                        "full_name VARCHAR(150) NOT NULL, " +
                        "first_name VARCHAR(100), " +
                        "last_name VARCHAR(100), " +
                        "title VARCHAR(100), " +
                        "company VARCHAR(200), " +
                        "company_name VARCHAR(200), " +
                        "email VARCHAR(150), " +
                        "phone VARCHAR(50), " +
                        "lead_source_id INT, " +
                        "source VARCHAR(100), " +
                        "web_form_id INT, " +
                        "status VARCHAR(50) DEFAULT 'NEW', " +
                        "rating VARCHAR(20) DEFAULT 'COLD', " +
                        "score INT DEFAULT 0, " +
                        "industry VARCHAR(100), " +
                        "address VARCHAR(255), " +
                        "city VARCHAR(100), " +
                        "region VARCHAR(100), " +
                        "state VARCHAR(100), " +
                        "country VARCHAR(100), " +
                        "zip_code VARCHAR(20), " +
                        "owner_id INT, " +
                        "notes TEXT, " +
                        "assigned_at TIMESTAMP NULL, " +
                        "sla_due_date TIMESTAMP NULL, " +
                        "is_overdue TINYINT(1) DEFAULT 0, " +
                        "sla_status VARCHAR(50) DEFAULT 'IN_PROGRESS', " +
                        "contact_name VARCHAR(150), " +
                        "created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, " +
                        "updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP" +
                        ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");

                // Thêm các cột nếu thiếu
                String[] cols = {
                    "ALTER TABLE leads ADD COLUMN assigned_at TIMESTAMP NULL",
                    "ALTER TABLE leads ADD COLUMN sla_due_date TIMESTAMP NULL",
                    "ALTER TABLE leads ADD COLUMN is_overdue TINYINT(1) DEFAULT 0",
                    "ALTER TABLE leads ADD COLUMN sla_status VARCHAR(50) DEFAULT 'IN_PROGRESS'",
                    "ALTER TABLE leads ADD COLUMN lead_source_id INT NULL",
                    "ALTER TABLE leads ADD COLUMN source VARCHAR(100) NULL",
                    "ALTER TABLE leads ADD COLUMN score INT DEFAULT 0",
                    "ALTER TABLE leads ADD COLUMN rating VARCHAR(20) DEFAULT 'COLD'",
                    "ALTER TABLE leads ADD COLUMN owner_id INT NULL"
                };
                for (String sql : cols) {
                    try { stmt.execute(sql); } catch (SQLException ignore) {}
                }

                // Xóa dữ liệu cũ của test
                stmt.execute("DELETE FROM saved_filters WHERE module = 'LEAD'");
                stmt.execute("DELETE FROM leads WHERE email LIKE '%@filtertest.com'");
            }
        }
    }

    @AfterAll
    static void tearDownClass() {
        DBConnection.resetDefaultCredentials();
    }

    @BeforeEach
    void setUp() {
        this.filterService = new LeadFilterService();
        this.savedFilterDAO = new LeadSavedFilterDAO();
        this.leadDAO = new LeadDAO();
    }

    private int createTestLead(String name, String email, String status, String rating, int score,
                               Integer sourceId, Integer ownerId, Timestamp createdAt,
                               Timestamp slaDueDate, boolean isOverdue, String slaStatus) throws SQLException {
        String srcName = (sourceId != null && sourceId == 1) ? "Website" : ((sourceId != null && sourceId == 2) ? "Facebook" : (sourceId != null ? "Google Ads" : null));
        String sql = "INSERT INTO leads (full_name, contact_name, company, email, phone, status, rating, score, " +
                     "lead_source_id, source, owner_id, created_at, sla_due_date, is_overdue, sla_status) " +
                     "VALUES (?, ?, 'Filter Test Corp', ?, '0988776655', ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, name);
            ps.setString(2, name);
            ps.setString(3, email);
            ps.setString(4, status);
            ps.setString(5, rating);
            ps.setInt(6, score);
            if (sourceId != null) ps.setInt(7, sourceId); else ps.setNull(7, Types.INTEGER);
            ps.setString(8, srcName);
            if (ownerId != null) ps.setInt(9, ownerId); else ps.setNull(9, Types.INTEGER);
            ps.setTimestamp(10, createdAt != null ? createdAt : new Timestamp(System.currentTimeMillis()));
            ps.setTimestamp(11, slaDueDate);
            ps.setBoolean(12, isOverdue);
            ps.setString(13, slaStatus);

            ps.executeUpdate();
            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) return rs.getInt(1);
            }
        }
        return 0;
    }

    // =========================================================================
    // LF01: Lọc theo trạng thái
    // =========================================================================
    @Test
    @Order(1)
    @DisplayName("LF01: Lọc Lead theo trạng thái (status = QUALIFIED)")
    void testLF01_FilterByStatus() throws SQLException {
        createTestLead("LF01 Lead New", "lf01_new@filtertest.com", "NEW", "COLD", 20, 1, userSalesA, null, null, false, null);
        int leadQualified = createTestLead("LF01 Lead Qual", "lf01_qual@filtertest.com", "QUALIFIED", "HOT", 80, 1, userSalesA, null, null, false, null);

        LeadFilterRequest req = new LeadFilterRequest();
        req.setStatus("QUALIFIED");

        List<LeadResponse> list = filterService.filterLeads(req, userSalesA, Collections.singletonList(1));
        assertNotNull(list);
        assertFalse(list.isEmpty());
        for (LeadResponse l : list) {
            assertEquals("QUALIFIED", l.getStatus(), "Chỉ trả về Lead có status = QUALIFIED");
        }
        assertTrue(list.stream().anyMatch(l -> l.getLeadId() == leadQualified));
    }

    // =========================================================================
    // LF02: Lọc theo nguồn Lead
    // =========================================================================
    @Test
    @Order(2)
    @DisplayName("LF02: Lọc Lead theo nguồn (source = Website)")
    void testLF02_FilterBySource() throws SQLException {
        int leadWeb = createTestLead("LF02 Web Lead", "lf02_web@filtertest.com", "NEW", "WARM", 50, 1, userSalesA, null, null, false, null);
        createTestLead("LF02 FB Lead", "lf02_fb@filtertest.com", "NEW", "WARM", 50, 2, userSalesA, null, null, false, null);

        LeadFilterRequest req = new LeadFilterRequest();
        req.setSource("Website");

        List<LeadResponse> list = filterService.filterLeads(req, userSalesA, Collections.singletonList(1));
        assertNotNull(list);
        assertFalse(list.isEmpty());
        for (LeadResponse l : list) {
            assertTrue("Website".equalsIgnoreCase(l.getSourceName()) || (l.getLeadSourceId() != null && l.getLeadSourceId() == 1),
                    "Chỉ trả về Lead có nguồn Website");
        }
        assertTrue(list.stream().anyMatch(l -> l.getLeadId() == leadWeb));
    }

    // =========================================================================
    // LF03: Lọc phân loại HOT / WARM / COLD
    // =========================================================================
    @Test
    @Order(3)
    @DisplayName("LF03: Lọc Lead theo phân loại HOT / WARM / COLD")
    void testLF03_FilterByClassification() throws SQLException {
        int hotLead = createTestLead("LF03 Hot Lead", "lf03_hot@filtertest.com", "NEW", "HOT", 85, 1, userSalesA, null, null, false, null);
        createTestLead("LF03 Cold Lead", "lf03_cold@filtertest.com", "NEW", "COLD", 15, 1, userSalesA, null, null, false, null);

        LeadFilterRequest req = new LeadFilterRequest();
        req.setClassification("HOT");

        List<LeadResponse> list = filterService.filterLeads(req, userSalesA, Collections.singletonList(1));
        assertNotNull(list);
        assertFalse(list.isEmpty());
        for (LeadResponse l : list) {
            assertEquals("HOT", l.getClassification(), "Chỉ trả về Lead phân loại HOT");
        }
        assertTrue(list.stream().anyMatch(l -> l.getLeadId() == hotLead));
    }

    // =========================================================================
    // LF04: Lọc theo người phụ trách
    // =========================================================================
    @Test
    @Order(4)
    @DisplayName("LF04: Lọc Lead theo người phụ trách (ownerId)")
    void testLF04_FilterByOwner() throws SQLException {
        int leadA = createTestLead("LF04 Lead A", "lf04_a@filtertest.com", "NEW", "HOT", 75, 1, userSalesA, null, null, false, null);
        int leadB = createTestLead("LF04 Lead B", "lf04_b@filtertest.com", "NEW", "HOT", 75, 1, userSalesB, null, null, false, null);

        // Giám đốc (Role ID = 1, quyền ALL) lọc theo userSalesA
        LeadFilterRequest req = new LeadFilterRequest();
        req.setOwnerId(userSalesA);

        List<LeadResponse> list = filterService.filterLeads(req, 1, Collections.singletonList(1));
        assertNotNull(list);
        assertTrue(list.stream().anyMatch(l -> l.getLeadId() == leadA));
        assertFalse(list.stream().anyMatch(l -> l.getLeadId() == leadB), "Không được chứa Lead của user B");
    }

    // =========================================================================
    // LF05: Lọc khoảng thời gian
    // =========================================================================
    @Test
    @Order(5)
    @DisplayName("LF05: Lọc Lead theo khoảng thời gian tạo (fromDate - toDate)")
    void testLF05_FilterByDateRange() throws SQLException {
        Timestamp pastDate = Timestamp.valueOf("2026-10-05 10:00:00");
        Timestamp outsideDate = Timestamp.valueOf("2026-09-01 10:00:00");

        int inRangeLead = createTestLead("LF05 InRange", "lf05_in@filtertest.com", "NEW", "WARM", 50, 1, userSalesA, pastDate, null, false, null);
        int outRangeLead = createTestLead("LF05 OutRange", "lf05_out@filtertest.com", "NEW", "WARM", 50, 1, userSalesA, outsideDate, null, false, null);

        LeadFilterRequest req = new LeadFilterRequest();
        req.setFromDate("2026-10-01");
        req.setToDate("2026-10-10");

        List<LeadResponse> list = filterService.filterLeads(req, userSalesA, Collections.singletonList(1));
        assertNotNull(list);
        assertTrue(list.stream().anyMatch(l -> l.getLeadId() == inRangeLead));
        assertFalse(list.stream().anyMatch(l -> l.getLeadId() == outRangeLead), "Lead ngoài khoảng ngày không được trả về");
    }

    // =========================================================================
    // LF06: Kết hợp nhiều điều kiện lọc
    // =========================================================================
    @Test
    @Order(6)
    @DisplayName("LF06: Kết hợp đồng thời nhiều điều kiện lọc (status + source + rating + owner)")
    void testLF06_MultiCriteriaFilter() throws SQLException {
        int matchLead = createTestLead("LF06 Match", "lf06_match@filtertest.com", "QUALIFIED", "HOT", 90, 1, userSalesA, null, null, false, null);
        createTestLead("LF06 NoMatch", "lf06_diff@filtertest.com", "NEW", "HOT", 90, 1, userSalesA, null, null, false, null);

        LeadFilterRequest req = new LeadFilterRequest();
        req.setStatus("QUALIFIED");
        req.setClassification("HOT");
        req.setSource("Website");
        req.setOwnerId(userSalesA);

        List<LeadResponse> list = filterService.filterLeads(req, 1, Collections.singletonList(1));
        assertNotNull(list);
        assertTrue(list.stream().anyMatch(l -> l.getLeadId() == matchLead));
        for (LeadResponse r : list) {
            assertEquals("QUALIFIED", r.getStatus());
            assertEquals("HOT", r.getClassification());
        }
    }

    // =========================================================================
    // LF07: Tham số không hợp lệ (fromDate > toDate, ngày sai cú pháp)
    // =========================================================================
    @Test
    @Order(7)
    @DisplayName("LF07: Xử lý an toàn khi tham số không hợp lệ hoặc fromDate > toDate")
    void testLF07_InvalidParametersSafeHandling() {
        LeadFilterRequest req = new LeadFilterRequest();
        req.setFromDate("2026-10-25");
        req.setToDate("2026-10-05"); // fromDate lớn hơn toDate

        assertDoesNotThrow(() -> {
            List<LeadResponse> list = filterService.filterLeads(req, userSalesA, Collections.singletonList(1));
            assertNotNull(list);
        });

        req.setFromDate("invalid-date-format");
        assertDoesNotThrow(() -> {
            List<LeadResponse> list = filterService.filterLeads(req, userSalesA, Collections.singletonList(1));
            assertNotNull(list);
        });
    }

    // =========================================================================
    // LF08: Lead quá SLA hiển thị nổi bật
    // =========================================================================
    @Test
    @Order(8)
    @DisplayName("LF08: Lead quá hạn SLA được nhận biết và đánh dấu nổi bật")
    void testLF08_SlaOverdueHighlight() throws SQLException {
        Timestamp pastDue = new Timestamp(System.currentTimeMillis() - 3600 * 1000L); // Quá hạn 1 tiếng
        int overdueLead = createTestLead("LF08 Overdue Lead", "lf08_overdue@filtertest.com", "ASSIGNED", "HOT", 75, 1, userSalesA, null, pastDue, true, "OVERDUE");

        LeadFilterRequest req = new LeadFilterRequest();
        req.setKeyword("LF08 Overdue");

        List<LeadResponse> list = filterService.filterLeads(req, userSalesA, Collections.singletonList(1));
        assertNotNull(list);
        assertFalse(list.isEmpty());

        LeadResponse target = list.stream().filter(l -> l.getLeadId() == overdueLead).findFirst().orElse(null);
        assertNotNull(target, "Phải tìm thấy Lead kiểm thử");
        assertTrue(target.isSlaOverdue(), "Lead quá hạn SLA phải có cờ slaOverdue = true");

        // Kiểm tra lọc chuyên biệt quá SLA
        LeadFilterRequest overdueOnlyReq = new LeadFilterRequest();
        overdueOnlyReq.setOverdue(true);
        List<LeadResponse> overdueOnlyList = filterService.filterLeads(overdueOnlyReq, userSalesA, Collections.singletonList(1));
        assertTrue(overdueOnlyList.stream().anyMatch(l -> l.getLeadId() == overdueLead), "Bộ lọc chỉ quá SLA phải trả về Lead này");
    }

    // =========================================================================
    // LF09: Lead đã phản hồi (RESPONDED) không bị cảnh báo quá hạn sai
    // =========================================================================
    @Test
    @Order(9)
    @DisplayName("LF09: Lead đã phản hồi (RESPONDED/CONTACTED) không bị cảnh báo quá hạn sai")
    void testLF09_RespondedLeadNotOverdue() throws SQLException {
        Timestamp oldCreated = Timestamp.valueOf("2026-10-01 08:00:00");
        Timestamp pastDue = Timestamp.valueOf("2026-10-02 08:00:00");

        // Lead tạo từ nhiều ngày trước nhưng đã liên hệ / phản hồi
        int contactedLead = createTestLead("LF09 Contacted Lead", "lf09_resp@filtertest.com", "CONTACTED", "HOT", 80, 1, userSalesA, oldCreated, pastDue, false, "RESPONDED");

        LeadFilterRequest req = new LeadFilterRequest();
        req.setKeyword("LF09 Contacted");

        List<LeadResponse> list = filterService.filterLeads(req, userSalesA, Collections.singletonList(1));
        assertNotNull(list);
        assertFalse(list.isEmpty());

        LeadResponse target = list.stream().filter(l -> l.getLeadId() == contactedLead).findFirst().orElse(null);
        assertNotNull(target);
        assertFalse(target.isSlaOverdue(), "Lead đã RESPONDED tuyệt đối không được đánh dấu quá hạn!");

        // Khi bật toggle lọc overdue=true, lead này không được xuất hiện
        LeadFilterRequest ovReq = new LeadFilterRequest();
        ovReq.setKeyword("LF09 Contacted");
        ovReq.setOverdue(true);
        List<LeadResponse> ovList = filterService.filterLeads(ovReq, userSalesA, Collections.singletonList(1));
        assertTrue(ovList.isEmpty(), "Lead đã phản hồi không được xuất hiện trong danh sách quá hạn");
    }

    // =========================================================================
    // LF10: Lưu bộ lọc có đặt tên
    // =========================================================================
    @Test
    @Order(10)
    @DisplayName("LF10: Lưu bộ lọc cá nhân có đặt tên thành công")
    void testLF10_SaveFilterWithName() {
        LeadSavedFilter filter = new LeadSavedFilter();
        filter.setUserId(userSalesA);
        filter.setFilterName("Lead Nóng Gọi Sáng");
        filter.setFilterQuery("classification=HOT&status=NEW&source=Website");
        filter.setStatus("NEW");

        boolean saved = filterService.saveFilter(filter, userSalesA);
        assertTrue(saved, "Lưu bộ lọc phải thành công");
        assertTrue(filter.getFilterId() > 0, "filterId phải được tự động sinh");

        // Kiểm tra tên trùng lặp
        assertTrue(filterService.existsSavedFilterName(userSalesA, "Lead Nóng Gọi Sáng"), "Hệ thống phải nhận diện được tên đã tồn tại");
    }

    // =========================================================================
    // LF11: Mở lại bộ lọc đã lưu và nhận đúng kết quả lọc
    // =========================================================================
    @Test
    @Order(11)
    @DisplayName("LF11: Mở lại bộ lọc đã lưu, khôi phục tiêu chí và kết quả lọc chính xác")
    void testLF11_ReloadSavedFilter() throws SQLException {
        createTestLead("LF11 Lead Hot New", "lf11_target@filtertest.com", "NEW", "HOT", 85, 1, userSalesA, null, null, false, null);

        LeadSavedFilter filter = new LeadSavedFilter();
        filter.setUserId(userSalesA);
        filter.setFilterName("Bộ lọc kiểm tra mở lại");
        filter.setFilterQuery("keyword=LF11&classification=HOT&status=NEW&fromDate=2026-10-01&toDate=2026-10-31&overdue=false");
        filterService.saveFilter(filter, userSalesA);

        LeadSavedFilter loaded = savedFilterDAO.findById(filter.getFilterId(), userSalesA);
        assertNotNull(loaded, "Phải tìm thấy bộ lọc đã lưu");
        assertEquals("LF11", loaded.getKeyword());
        assertEquals("HOT", loaded.getClassification());
        assertEquals("NEW", loaded.getStatus());
        assertEquals("2026-10-01", loaded.getFromDate());
        assertEquals("2026-10-31", loaded.getToDate());

        // Áp dụng lại query từ bộ lọc
        LeadFilterRequest req = new LeadFilterRequest();
        req.setKeyword(loaded.getKeyword());
        req.setClassification(loaded.getClassification());
        req.setStatus(loaded.getStatus());

        List<LeadResponse> results = filterService.filterLeads(req, userSalesA, Collections.singletonList(1));
        assertNotNull(results);
        assertFalse(results.isEmpty());
        assertTrue(results.stream().anyMatch(l -> l.getEmail().equals("lf11_target@filtertest.com")));
    }

    // =========================================================================
    // LF12: Bộ lọc tồn tại bền vững sau khi đăng xuất / đăng nhập lại
    // =========================================================================
    @Test
    @Order(12)
    @DisplayName("LF12: Đăng xuất và đăng nhập lại, bộ lọc vẫn tồn tại nguyên vẹn trong CSDL")
    void testLF12_PersistenceAcrossSessions() {
        LeadSavedFilter f = new LeadSavedFilter();
        f.setUserId(userSalesA);
        f.setFilterName("Bộ lọc phiên làm việc mới");
        f.setFilterQuery("classification=WARM");
        filterService.saveFilter(f, userSalesA);

        // Giả lập phiên mới hoàn toàn bằng DAO instance mới
        LeadSavedFilterDAO newSessionDAO = new LeadSavedFilterDAO();
        List<LeadSavedFilter> list = newSessionDAO.getSavedFiltersByUserId(userSalesA);
        assertNotNull(list);
        assertTrue(list.stream().anyMatch(sf -> "Bộ lọc phiên làm việc mới".equals(sf.getFilterName())),
                "Bộ lọc phải được lưu bền vững trong CSDL MySQL");
    }

    // =========================================================================
    // LF13: Phân quyền - Người dùng không xem/xóa được bộ lọc của người khác
    // =========================================================================
    @Test
    @Order(13)
    @DisplayName("LF13: Người dùng bị từ chối truy cập hoặc xóa bộ lọc riêng tư của người khác")
    void testLF13_PrivateFilterIsolation() {
        LeadSavedFilter filterA = new LeadSavedFilter();
        filterA.setUserId(userSalesA);
        filterA.setFilterName("Bộ lọc bí mật của Sales A");
        filterA.setFilterQuery("status=NEW");
        filterService.saveFilter(filterA, userSalesA);

        // Sales B cố gắng đọc bộ lọc của Sales A
        LeadSavedFilter readByB = savedFilterDAO.findById(filterA.getFilterId(), userSalesB);
        assertNull(readByB, "Sales B không được phép đọc bộ lọc của Sales A");

        // Sales B cố gắng xóa bộ lọc của Sales A
        boolean deleteByB = filterService.deleteSavedFilter(filterA.getFilterId(), userSalesB);
        assertFalse(deleteByB, "Sales B không được phép xóa bộ lọc của Sales A");

        // Xác nhận bộ lọc của Sales A vẫn còn nguyên
        LeadSavedFilter stillExists = savedFilterDAO.findById(filterA.getFilterId(), userSalesA);
        assertNotNull(stillExists, "Bộ lọc của Sales A phải còn nguyên");
    }

    // =========================================================================
    // LF14: Bộ lọc không có kết quả phù hợp
    // =========================================================================
    @Test
    @Order(14)
    @DisplayName("LF14: Bộ lọc không có kết quả trả về danh sách rỗng an toàn")
    void testLF14_EmptyResults() {
        LeadFilterRequest req = new LeadFilterRequest();
        req.setKeyword("NONEXISTENT_KEYWORD_XYZ_999999");

        List<LeadResponse> list = filterService.filterLeads(req, userSalesA, Collections.singletonList(1));
        assertNotNull(list);
        assertTrue(list.isEmpty());

        int count = filterService.countFilteredLeads(req, userSalesA, Collections.singletonList(1));
        assertEquals(0, count);
    }

    // =========================================================================
    // LF15: Phân trang bảo lưu điều kiện lọc
    // =========================================================================
    @Test
    @Order(15)
    @DisplayName("LF15: Phân trang sau khi lọc, số lượng và offset tính toán chính xác")
    void testLF15_PaginationPreserved() throws SQLException {
        // Tạo 5 lead cùng tiêu chí
        for (int i = 1; i <= 5; i++) {
            createTestLead("LF15 Paging " + i, "lf15_" + i + "@filtertest.com", "NEW", "WARM", 50, 1, userSalesA, null, null, false, null);
        }

        LeadFilterRequest req = new LeadFilterRequest();
        req.setKeyword("LF15 Paging");
        req.setPage(1);
        req.setPageSize(2);

        List<LeadResponse> page1 = filterService.filterLeads(req, userSalesA, Collections.singletonList(1));
        assertEquals(2, page1.size(), "Trang 1 phải có đúng 2 bản ghi");

        req.setPage(2);
        List<LeadResponse> page2 = filterService.filterLeads(req, userSalesA, Collections.singletonList(1));
        assertEquals(2, page2.size(), "Trang 2 phải có đúng 2 bản ghi");
        assertNotEquals(page1.get(0).getLeadId(), page2.get(0).getLeadId(), "Hai trang không được trùng lặp dữ liệu");

        int total = filterService.countFilteredLeads(req, userSalesA, Collections.singletonList(1));
        assertTrue(total >= 5, "Tổng số bản ghi phải >= 5");
    }

    // =========================================================================
    // LF16: Kiểm soát Data Scope
    // =========================================================================
    @Test
    @Order(16)
    @DisplayName("LF16: Kiểm soát phạm vi dữ liệu - Nhân viên không thể xem Lead ngoài quyền hạn")
    void testLF16_DataScopeEnforcement() throws SQLException {
        int leadB = createTestLead("LF16 Lead of B", "lf16_b@filtertest.com", "NEW", "HOT", 80, 1, userSalesB, null, null, false, null);

        LeadFilterRequest req = new LeadFilterRequest();
        req.setOwnerScope("MY"); // Nhân viên chỉ xem lead của mình

        List<LeadResponse> list = filterService.filterLeads(req, userSalesA, Collections.singletonList(0));
        assertNotNull(list);
        assertFalse(list.stream().anyMatch(l -> l.getLeadId() == leadB),
                "Nhân viên Sales A không được thấy Lead do Sales B phụ trách khi ở phạm vi MY");
    }

    // =========================================================================
    // LF17: Kiểm tra toàn luồng Servlet → Service → DAO → Database
    // =========================================================================
    @Test
    @Order(17)
    @DisplayName("LF17: Luồng API Servlet (LeadSavedFilterServlet và LeadFilterServlet) tích hợp hoàn chỉnh")
    void testLF17_FullApiServletIntegration() throws Exception {
        // 1. Kiểm tra LeadSavedFilterServlet: Lưu bộ lọc mới kèm validate trùng tên
        LeadSavedFilterServlet savedServlet = new LeadSavedFilterServlet();
        savedServlet.setFilterService(filterService);

        HttpServletRequest req = mock(HttpServletRequest.class);
        HttpServletResponse resp = mock(HttpServletResponse.class);
        HttpSession session = mock(HttpSession.class);

        when(req.getSession(false)).thenReturn(session);
        when(session.getAttribute("userId")).thenReturn(userSalesA);
        when(req.getServletPath()).thenReturn("/leads/filters");
        when(req.getParameter("filterName")).thenReturn("Bộ lọc E2E Test");
        when(req.getParameter("status")).thenReturn("NEW");
        when(req.getParameter("classification")).thenReturn("HOT");

        StringWriter sw = new StringWriter();
        PrintWriter pw = new PrintWriter(sw);
        when(resp.getWriter()).thenReturn(pw);

        savedServlet.doPost(req, resp);
        pw.flush();
        String jsonResult = sw.toString();
        assertTrue(jsonResult.contains("\"success\":true"), "Lưu bộ lọc qua Servlet API phải thành công");

        // Cố tình lưu trùng tên lần 2 -> phải trả về lỗi 400
        StringWriter sw2 = new StringWriter();
        PrintWriter pw2 = new PrintWriter(sw2);
        when(resp.getWriter()).thenReturn(pw2);

        savedServlet.doPost(req, resp);
        pw2.flush();
        verify(resp).setStatus(HttpServletResponse.SC_BAD_REQUEST);

        // 2. Kiểm tra LeadFilterServlet: Lọc Lead trả JSON
        LeadFilterServlet filterServlet = new LeadFilterServlet();
        filterServlet.setFilterService(filterService);

        HttpServletRequest filterReq = mock(HttpServletRequest.class);
        HttpServletResponse filterResp = mock(HttpServletResponse.class);
        when(filterReq.getSession(false)).thenReturn(session);
        when(filterReq.getParameter("status")).thenReturn("NEW");

        StringWriter sw3 = new StringWriter();
        PrintWriter pw3 = new PrintWriter(sw3);
        when(filterResp.getWriter()).thenReturn(pw3);

        filterServlet.doGet(filterReq, filterResp);
        pw3.flush();
        String filterJson = sw3.toString();
        assertTrue(filterJson.contains("\"success\":true"), "API /leads/filter phải trả về JSON thành công");
        assertTrue(filterJson.contains("\"data\":["), "API phải có mảng data");
    }
}

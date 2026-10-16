package com.crm.integration;

import com.crm.controller.lead.LeadConvertServlet;
import com.crm.dto.LeadConversionRequest;
import com.crm.model.Account;
import com.crm.service.LeadConversionService;
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
 * Integration Test suite cho S4-08: Lead Conversion.
 * Chạy trên database kiểm thử cô lập crm_s4_06_test.
 */
@TestMethodOrder(MethodOrderer.OrderAnnotation.class)
public class LeadConversionIntegrationTest {

    private static final String TEST_DB_URL = "jdbc:mysql://localhost:3306/crm_s4_06_test?useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true&useUnicode=true&characterEncoding=UTF-8";
    private static final String DRIVER = "com.mysql.cj.jdbc.Driver";

    private LeadConversionService conversionService;

    @BeforeAll
    static void initSafetyGate() throws Exception {
        String testUser = System.getProperty("db.test.user");
        String testPass = System.getProperty("db.test.password", System.getenv("MYSQL_TEST_PWD"));

        if (testPass == null || testPass.trim().isEmpty() || testUser == null || testUser.trim().isEmpty()) {
            try (java.io.InputStream is = LeadConversionIntegrationTest.class.getClassLoader().getResourceAsStream("db.properties")) {
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

            // Đảm bảo các bảng liên kết chuyển đổi có mặt trong test database
            try (Statement stmt = conn.createStatement()) {
                stmt.execute("CREATE TABLE IF NOT EXISTS customers (" +
                        "customer_id INT AUTO_INCREMENT PRIMARY KEY, " +
                        "customer_name VARCHAR(200) NOT NULL, " +
                        "phone VARCHAR(20), " +
                        "owner_id INT NOT NULL, " +
                        "created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, " +
                        "tax_code VARCHAR(50), " +
                        "email VARCHAR(150), " +
                        "status VARCHAR(50) DEFAULT 'Tiềm năng', " +
                        "industry VARCHAR(100), " +
                        "company_size VARCHAR(50), " +
                        "size VARCHAR(50), " +
                        "website VARCHAR(255), " +
                        "address TEXT, " +
                        "region VARCHAR(100), " +
                        "updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP" +
                        ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");

                stmt.execute("CREATE TABLE IF NOT EXISTS contacts (" +
                        "contact_id INT AUTO_INCREMENT PRIMARY KEY, " +
                        "customer_id INT NOT NULL, " +
                        "full_name VARCHAR(150) NOT NULL, " +
                        "title VARCHAR(100), " +
                        "email VARCHAR(150), " +
                        "phone VARCHAR(20), " +
                        "buying_role ENUM('DECIDER','INFLUENCER','END_USER','BLOCKER') NOT NULL DEFAULT 'END_USER', " +
                        "is_primary TINYINT(1) NOT NULL DEFAULT 0, " +
                        "created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, " +
                        "updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP" +
                        ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");

                stmt.execute("CREATE TABLE IF NOT EXISTS opportunities (" +
                        "opportunity_id INT AUTO_INCREMENT PRIMARY KEY, " +
                        "title VARCHAR(200) NOT NULL, " +
                        "amount DECIMAL(15,2) DEFAULT 0.00, " +
                        "owner_id INT NOT NULL, " +
                        "customer_id INT NULL, " +
                        "pipeline_stage_id INT NULL, " +
                        "probability DECIMAL(5,2), " +
                        "stage VARCHAR(100), " +
                        "status VARCHAR(50), " +
                        "created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP" +
                        ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");

                stmt.execute("CREATE TABLE IF NOT EXISTS activities (" +
                        "activity_id INT AUTO_INCREMENT PRIMARY KEY, " +
                        "title VARCHAR(200) NOT NULL, " +
                        "description TEXT, " +
                        "owner_id INT NOT NULL, " +
                        "lead_id INT NULL, " +
                        "customer_id INT NULL, " +
                        "created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP" +
                        ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");
            }
        }
    }

    @BeforeEach
    void setUp() throws SQLException {
        conversionService = new LeadConversionService();
        resetFixtures();
    }

    private void resetFixtures() throws SQLException {
        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement()) {
            stmt.execute("SET FOREIGN_KEY_CHECKS = 0");
            stmt.execute("TRUNCATE TABLE activities");
            stmt.execute("TRUNCATE TABLE opportunities");
            stmt.execute("TRUNCATE TABLE contacts");
            stmt.execute("TRUNCATE TABLE customers");
            stmt.execute("TRUNCATE TABLE leads");
            stmt.execute("TRUNCATE TABLE users");
            stmt.execute("SET FOREIGN_KEY_CHECKS = 1");

            // Users
            stmt.execute("INSERT INTO users (user_id, email, password_hash, full_name, is_active) VALUES " +
                    "(1, 'admin@test.local', 'hash', 'Admin Director', 1), " +
                    "(101, 'rep1@test.local', 'hash', 'Sales Rep 1', 1), " +
                    "(102, 'rep2@test.local', 'hash', 'Sales Rep 2', 1)");

            // Leads
            stmt.execute("INSERT INTO leads (lead_id, company_name, contact_name, email, phone, status, owner_id) VALUES " +
                    "(1, 'Vinamilk', 'Nguyen Van A', 'a@vinamilk.com', '0901234567', 'IN_PROGRESS', 101), " +
                    "(2, 'FPT Corporation', 'Tran Thi B', 'b@fpt.com', '0907654321', 'ASSIGNED', 101), " +
                    "(3, 'Viettel', 'Le Van C', 'c@viettel.com', '0988888888', 'CONVERTED', 101), " +
                    "(4, 'Vingroup', 'Pham Van D', 'd@vingroup.com', '0911111111', 'IN_PROGRESS', 102)");

            // Activities for Lead #1
            stmt.execute("INSERT INTO activities (activity_id, title, owner_id, lead_id, customer_id) VALUES " +
                    "(1, 'Cuộc gọi tư vấn ban đầu', 101, 1, NULL), " +
                    "(2, 'Gửi báo giá sơ bộ', 101, 1, NULL)");
        }
    }

    @Test
    @Order(1)
    @DisplayName("S4-08 IT-01: Chuyển đổi Lead thành công tạo mới Customer, Contact, Opportunity và liên kết Activities")
    void testConvertLead_Success_NewEntities() throws Exception {
        LeadConversionRequest req = new LeadConversionRequest(1, "Hợp đồng Sữa Học Đường", 150000000.0, null);
        LeadConversionService.ConversionResult result = conversionService.convertLead(req, 101, false);

        assertNotNull(result);
        assertTrue(result.getCustomerId() > 0);
        assertTrue(result.getContactId() > 0);
        assertNotNull(result.getOpportunityId());
        assertTrue(result.getOpportunityId() > 0);
        assertEquals(2, result.getActivityCount(), "Phải cập nhật đúng 2 activities của Lead #1");

        try (Connection conn = DBConnection.getConnection()) {
            // Kiểm tra Customer
            try (PreparedStatement ps = conn.prepareStatement("SELECT customer_name, owner_id, email, phone FROM customers WHERE customer_id = ?")) {
                ps.setInt(1, result.getCustomerId());
                try (ResultSet rs = ps.executeQuery()) {
                    assertTrue(rs.next());
                    assertEquals("Vinamilk", rs.getString("customer_name"));
                    assertEquals(101, rs.getInt("owner_id"));
                    assertEquals("a@vinamilk.com", rs.getString("email"));
                    assertEquals("0901234567", rs.getString("phone"));
                }
            }

            // Kiểm tra Contact
            try (PreparedStatement ps = conn.prepareStatement("SELECT full_name, email, phone, customer_id, is_primary FROM contacts WHERE contact_id = ?")) {
                ps.setInt(1, result.getContactId());
                try (ResultSet rs = ps.executeQuery()) {
                    assertTrue(rs.next());
                    assertEquals("Nguyen Van A", rs.getString("full_name"));
                    assertEquals(result.getCustomerId(), rs.getInt("customer_id"));
                    assertTrue(rs.getBoolean("is_primary"));
                }
            }

            // Kiểm tra Opportunity
            try (PreparedStatement ps = conn.prepareStatement("SELECT title, amount, customer_id, owner_id FROM opportunities WHERE opportunity_id = ?")) {
                ps.setInt(1, result.getOpportunityId());
                try (ResultSet rs = ps.executeQuery()) {
                    assertTrue(rs.next());
                    assertEquals("Hợp đồng Sữa Học Đường", rs.getString("title"));
                    assertEquals(150000000.0, rs.getDouble("amount"));
                    assertEquals(result.getCustomerId(), rs.getInt("customer_id"));
                }
            }

            // Kiểm tra Activities: lead_id vẫn được bảo toàn (KHÔNG bị xóa), và customer_id được cập nhật!
            try (PreparedStatement ps = conn.prepareStatement("SELECT lead_id, customer_id FROM activities WHERE activity_id IN (1, 2)")) {
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        assertEquals(1, rs.getInt("lead_id"), "lead_id phải được bảo toàn lịch sử!");
                        assertEquals(result.getCustomerId(), rs.getInt("customer_id"), "customer_id phải được liên kết sang Customer mới!");
                    }
                }
            }

            // Kiểm tra Lead trạng thái CONVERTED và các FK
            try (PreparedStatement ps = conn.prepareStatement("SELECT status, converted_customer_id, converted_contact_id, converted_opportunity_id FROM leads WHERE lead_id = 1")) {
                try (ResultSet rs = ps.executeQuery()) {
                    assertTrue(rs.next());
                    assertEquals("CONVERTED", rs.getString("status"));
                    assertEquals(result.getCustomerId(), rs.getInt("converted_customer_id"));
                    assertEquals(result.getContactId(), rs.getInt("converted_contact_id"));
                    assertEquals(result.getOpportunityId(), (Integer) rs.getInt("converted_opportunity_id"));
                }
            }
        }
    }

    @Test
    @Order(2)
    @DisplayName("S4-08 IT-02: Chuyển đổi Lead tái sử dụng Customer có sẵn (accountId)")
    void testConvertLead_ExistingCustomer() throws Exception {
        int existingCustId;
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement("INSERT INTO customers (customer_name, owner_id) VALUES ('Tập đoàn FPT', 101)", Statement.RETURN_GENERATED_KEYS)) {
            ps.executeUpdate();
            try (ResultSet rs = ps.getGeneratedKeys()) {
                assertTrue(rs.next());
                existingCustId = rs.getInt(1);
            }
        }

        LeadConversionRequest req = new LeadConversionRequest(2, "Cơ hội Phần mềm", 200000000.0, existingCustId);
        LeadConversionService.ConversionResult result = conversionService.convertLead(req, 101, false);

        assertEquals(existingCustId, result.getCustomerId(), "Phải sử dụng đúng ID của Customer có sẵn");

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement("SELECT customer_id FROM contacts WHERE contact_id = ?")) {
            ps.setInt(1, result.getContactId());
            try (ResultSet rs = ps.executeQuery()) {
                assertTrue(rs.next());
                assertEquals(existingCustId, rs.getInt("customer_id"), "Contact phải liên kết vào Customer có sẵn");
            }
        }
    }

    @Test
    @Order(3)
    @DisplayName("S4-08 IT-03: Chuyển đổi Lead không tạo Opportunity khi không truyền opportunityName")
    void testConvertLead_WithoutOpportunity() throws Exception {
        LeadConversionRequest req = new LeadConversionRequest(2, null, null, null);
        LeadConversionService.ConversionResult result = conversionService.convertLead(req, 101, false);

        assertNotNull(result);
        assertNull(result.getOpportunityId(), "Không tạo Opportunity nếu không có tên cơ hội");

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement("SELECT converted_opportunity_id FROM leads WHERE lead_id = 2")) {
            try (ResultSet rs = ps.executeQuery()) {
                assertTrue(rs.next());
                assertNull(rs.getObject("converted_opportunity_id"), "converted_opportunity_id trên Lead phải là null");
            }
        }
    }

    @Test
    @Order(4)
    @DisplayName("S4-08 IT-04: Chặn người không sở hữu Lead chuyển đổi -> SecurityException / HTTP 403")
    void testConvertLead_OwnershipViolation() {
        // User 102 cố tình chuyển đổi Lead #1 (thuộc sở hữu của User 101)
        LeadConversionRequest req = new LeadConversionRequest(1, "Xâm phạm");
        SecurityException ex = assertThrows(SecurityException.class, () -> {
            conversionService.convertLead(req, 102, false);
        });
        assertTrue(ex.getMessage().contains("Ownership vi phạm"));
    }

    @Test
    @Order(5)
    @DisplayName("S4-08 IT-05: Quản trị viên (Elevated Role) có quyền chuyển đổi Lead thay nhân viên")
    void testConvertLead_AdminElevated_Success() throws Exception {
        // Admin (User 1, isElevatedRole = true) chuyển đổi Lead #4 (thuộc User 102)
        LeadConversionRequest req = new LeadConversionRequest(4, "Dự án Vingroup");
        LeadConversionService.ConversionResult result = conversionService.convertLead(req, 1, true);

        assertNotNull(result);
        assertTrue(result.getCustomerId() > 0);
    }

    @Test
    @Order(6)
    @DisplayName("S4-08 IT-06: Chặn chuyển đổi Lead đã ở trạng thái CONVERTED -> IllegalStateException / 409")
    void testConvertLead_AlreadyConverted() {
        LeadConversionRequest req = new LeadConversionRequest(3, "Cơ hội Viettel");
        IllegalStateException ex = assertThrows(IllegalStateException.class, () -> {
            conversionService.convertLead(req, 101, false);
        });
        assertTrue(ex.getMessage().contains("đã được chuyển đổi trước đó"));
    }

    @Test
    @Order(7)
    @DisplayName("S4-08 IT-07: Chặn chuyển đổi Lead không tồn tại -> IllegalArgumentException / 404")
    void testConvertLead_NotFound() {
        LeadConversionRequest req = new LeadConversionRequest(99999, "Cơ hội ảo");
        IllegalArgumentException ex = assertThrows(IllegalArgumentException.class, () -> {
            conversionService.convertLead(req, 101, false);
        });
        assertTrue(ex.getMessage().contains("không tồn tại"));
    }

    @Test
    @Order(8)
    @DisplayName("S4-08 IT-08: Xử lý đồng thời (Concurrency) trên cùng một Lead bằng SELECT ... FOR UPDATE")
    void testConvertLead_ConcurrentCalls() throws Exception {
        int threads = 2;
        ExecutorService executor = Executors.newFixedThreadPool(threads);
        CountDownLatch startGate = new CountDownLatch(1);
        CountDownLatch endGate = new CountDownLatch(threads);

        for (int i = 0; i < threads; i++) {
            executor.submit(() -> {
                try {
                    startGate.await();
                    LeadConversionRequest req = new LeadConversionRequest(1, "Tranh chấp cơ hội");
                    conversionService.convertLead(req, 101, false);
                } catch (Exception ignored) {
                } finally {
                    endGate.countDown();
                }
            });
        }

        startGate.countDown();
        assertTrue(endGate.await(5, TimeUnit.SECONDS));
        executor.shutdown();

        // Kiểm tra tính toàn vẹn: Chỉ có đúng 1 Customer được tạo ra từ Lead #1
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement("SELECT COUNT(*) FROM customers WHERE customer_name = 'Vinamilk'")) {
            try (ResultSet rs = ps.executeQuery()) {
                assertTrue(rs.next());
                assertEquals(1, rs.getInt(1), "Chỉ được tạo duy nhất 1 Customer, không bị trùng do concurrency");
            }
        }
    }

    @Test
    @Order(9)
    @DisplayName("S4-08 IT-09: LeadConvertServlet thực thi thành công trả về HTTP 200 JSON đầy đủ các trường FE04")
    void testServlet_Convert_SuccessJson() throws Exception {
        LeadConvertServlet servlet = new LeadConvertServlet();
        servlet.setConversionService(conversionService);

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
        when(req.getParameter("opportunityName")).thenReturn("Hợp đồng Test Servlet");
        when(resp.getWriter()).thenReturn(pw);

        servlet.doPost(req, resp);

        verify(resp).setStatus(HttpServletResponse.SC_OK);
        String json = sw.toString();
        assertTrue(json.contains("\"status\": \"success\""));
        assertTrue(json.contains("customerId"));
        assertTrue(json.contains("contactId"));
        assertTrue(json.contains("opportunityId"));
        assertTrue(json.contains("activityCount"));
    }
}

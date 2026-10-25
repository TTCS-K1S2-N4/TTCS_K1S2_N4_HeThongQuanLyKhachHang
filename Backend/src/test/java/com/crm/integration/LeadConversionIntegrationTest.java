package com.crm.integration;

import com.crm.controller.lead.LeadConvertServlet;
import com.crm.controller.lead.LeadUpdateServlet;
import com.crm.dto.LeadConversionRequest;
import com.crm.dto.LeadRequest;
import com.crm.model.Account;
import com.crm.service.LeadConversionService;
import com.crm.service.LeadService;
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
 * Integration Test suite cho S4-08: Lead Conversion (Bao phủ toàn bộ kịch bản LC01 - LC14).
 * Chạy trên database kiểm thử cô lập crm_s4_06_test.
 */
@TestMethodOrder(MethodOrderer.OrderAnnotation.class)
public class LeadConversionIntegrationTest {

    private static final String TEST_DB_URL = "jdbc:mysql://localhost:3306/crm_s4_06_test?useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true&useUnicode=true&characterEncoding=UTF-8";
    private static final String DRIVER = "com.mysql.cj.jdbc.Driver";

    private LeadConversionService conversionService;
    private LeadService leadService;

    @BeforeAll
    static void initSafetyGate() throws Exception {
        String testUser = System.getProperty("db.test.user");
        String testPass = System.getProperty("db.test.password", System.getenv("MYSQL_TEST_PWD"));

        if (testPass == null || testPass.trim().isEmpty() || testUser == null || testUser.trim().isEmpty()) {
            try (java.io.InputStream is = LeadConversionIntegrationTest.class.getClassLoader().getResourceAsStream("db.local.properties")) {
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
                        "contact_name VARCHAR(150), " +
                        "full_name VARCHAR(150) NOT NULL, " +
                        "title VARCHAR(100), " +
                        "position VARCHAR(100), " +
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
                        "campaign_id INT NULL, " +
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

                stmt.execute("CREATE TABLE IF NOT EXISTS campaigns (" +
                        "campaign_id INT AUTO_INCREMENT PRIMARY KEY, " +
                        "campaign_name VARCHAR(200) NOT NULL, " +
                        "status VARCHAR(50) DEFAULT 'ACTIVE'" +
                        ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");

                // Thêm các cột nếu bảng đã có sẵn nhưng thiếu cột
                try { stmt.execute("ALTER TABLE contacts ADD COLUMN contact_name VARCHAR(150)"); } catch (Exception ignore) {}
                try { stmt.execute("ALTER TABLE contacts ADD COLUMN position VARCHAR(100)"); } catch (Exception ignore) {}
                try { stmt.execute("ALTER TABLE opportunities ADD COLUMN campaign_id INT NULL"); } catch (Exception ignore) {}
                try { stmt.execute("ALTER TABLE customers ADD COLUMN industry VARCHAR(100)"); } catch (Exception ignore) {}
                try { stmt.execute("ALTER TABLE customers ADD COLUMN address TEXT"); } catch (Exception ignore) {}
                try { stmt.execute("ALTER TABLE customers ADD COLUMN region VARCHAR(100)"); } catch (Exception ignore) {}
            }
        }
    }

    @AfterAll
    static void tearDownClass() {
        DBConnection.resetDefaultCredentials();
    }

    @BeforeEach
    void setUp() throws SQLException {
        conversionService = new LeadConversionService();
        leadService = new LeadService();
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
            stmt.execute("TRUNCATE TABLE campaigns");
            stmt.execute("SET FOREIGN_KEY_CHECKS = 1");

            // Users
            stmt.execute("INSERT INTO users (user_id, email, password_hash, full_name, is_active) VALUES " +
                    "(1, 'admin@test.local', 'hash', 'Admin Director', 1), " +
                    "(101, 'rep1@test.local', 'hash', 'Sales Rep 1', 1), " +
                    "(102, 'rep2@test.local', 'hash', 'Sales Rep 2', 1)");

            // Campaigns
            stmt.execute("INSERT INTO campaigns (campaign_id, campaign_name, status) VALUES " +
                    "(10, 'Chiến dịch Q4 Doanh nghiệp', 'ACTIVE')");

            // Leads:
            // Lead 1: Đầy đủ thông tin ánh xạ, thuộc sở hữu User 101, trạng thái IN_PROGRESS
            stmt.execute("INSERT INTO leads (lead_id, company_name, contact_name, full_name, email, phone, status, owner_id, industry, address, city, region, title, campaign_id) VALUES " +
                    "(1, 'Vinamilk', 'Nguyen Van A', 'Nguyen Van A', 'a@vinamilk.com', '0901234567', 'IN_PROGRESS', 101, 'Sản xuất', '123 Đỗ Xuân Hợp', 'Hà Nội', 'Miền Bắc', 'Giám đốc Thu mua', 10), " +
                    "(2, 'FPT Corporation', 'Tran Thi B', 'Tran Thi B', 'b@fpt.com', '0907654321', 'ASSIGNED', 101, 'Công nghệ', 'Duy Tân, Cầu Giấy', 'Hà Nội', 'Miền Bắc', 'Trưởng phòng IT', 10), " +
                    "(3, 'Viettel', 'Le Van C', 'Le Van C', 'c@viettel.com', '0988888888', 'CONVERTED', 101, 'Viễn thông', 'Trần Hữu Dực', 'Hà Nội', 'Miền Bắc', 'Phó Giám đốc', 10), " +
                    "(4, 'Vingroup', 'Pham Van D', 'Pham Van D', 'd@vingroup.com', '0911111111', 'IN_PROGRESS', 102, 'Bất động sản', 'Vinhomes Riverside', 'Hà Nội', 'Miền Bắc', 'Quản lý Dự án', 10), " +
                    "(5, 'Công ty Không Tên', NULL, NULL, 'notname@test.local', '0922222222', 'IN_PROGRESS', 101, NULL, NULL, NULL, NULL, NULL, NULL)");

            // Activities cho Lead #1
            stmt.execute("INSERT INTO activities (activity_id, title, description, owner_id, lead_id, customer_id) VALUES " +
                    "(1, 'Cuộc gọi tư vấn ban đầu', 'Trao đổi về nhu cầu mua sắm thiết bị', 101, 1, NULL), " +
                    "(2, 'Gửi báo giá sơ bộ', 'Báo giá lô hàng đợt 1', 101, 1, NULL)");
        }
    }

    @Test
    @Order(1)
    @DisplayName("LC01: Chuyển đổi Lead hợp lệ sinh đồng thời Customer, Contact, Opportunity")
    void testLC01_ConvertLead_Success_CreatesAllThreeEntities() throws Exception {
        LeadConversionRequest req = new LeadConversionRequest(1, "Hợp đồng Sữa Học Đường", 150000000.0, null);
        LeadConversionService.ConversionResult result = conversionService.convertLead(req, 101, false);

        assertNotNull(result);
        assertTrue(result.getCustomerId() > 0, "Phải sinh Customer");
        assertTrue(result.getContactId() > 0, "Phải sinh Contact");
        assertNotNull(result.getOpportunityId(), "Phải sinh Opportunity");
        assertTrue(result.getOpportunityId() > 0, "Opportunity ID phải > 0");

        try (Connection conn = DBConnection.getConnection()) {
            // Kiểm tra trạng thái Lead đã là CONVERTED
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
    @DisplayName("LC02: Kiểm tra ánh xạ dữ liệu Lead sang các đối tượng mới không bắt người dùng nhập lại")
    void testLC02_FieldMapping_PreservesAllDataWithoutReentry() throws Exception {
        LeadConversionRequest req = new LeadConversionRequest(1, "Hợp đồng Sữa Học Đường", 150000000.0, null);
        LeadConversionService.ConversionResult result = conversionService.convertLead(req, 101, false);

        try (Connection conn = DBConnection.getConnection()) {
            // 1. Kiểm tra ánh xạ sang Customer: tên, điện thoại, email, ngành nghề, địa chỉ, khu vực, người phụ trách
            try (PreparedStatement ps = conn.prepareStatement("SELECT customer_name, phone, email, industry, address, region, owner_id FROM customers WHERE customer_id = ?")) {
                ps.setInt(1, result.getCustomerId());
                try (ResultSet rs = ps.executeQuery()) {
                    assertTrue(rs.next());
                    assertEquals("Vinamilk", rs.getString("customer_name"));
                    assertEquals("0901234567", rs.getString("phone"));
                    assertEquals("a@vinamilk.com", rs.getString("email"));
                    assertEquals("Sản xuất", rs.getString("industry"));
                    assertEquals("123 Đỗ Xuân Hợp", rs.getString("address"));
                    assertEquals("Miền Bắc", rs.getString("region"));
                    assertEquals(101, rs.getInt("owner_id"));
                }
            }

            // 2. Kiểm tra ánh xạ sang Contact: họ tên, email, điện thoại, chức danh, is_primary
            try (PreparedStatement ps = conn.prepareStatement("SELECT full_name, email, phone, title, is_primary, customer_id FROM contacts WHERE contact_id = ?")) {
                ps.setInt(1, result.getContactId());
                try (ResultSet rs = ps.executeQuery()) {
                    assertTrue(rs.next());
                    assertEquals("Nguyen Van A", rs.getString("full_name"));
                    assertEquals("a@vinamilk.com", rs.getString("email"));
                    assertEquals("0901234567", rs.getString("phone"));
                    assertEquals("Giám đốc Thu mua", rs.getString("title"));
                    assertTrue(rs.getBoolean("is_primary"));
                    assertEquals(result.getCustomerId(), rs.getInt("customer_id"));
                }
            }

            // 3. Kiểm tra ánh xạ sang Opportunity: tiêu đề, giá trị, chiến dịch, customer_id, owner_id
            try (PreparedStatement ps = conn.prepareStatement("SELECT title, amount, customer_id, owner_id, campaign_id FROM opportunities WHERE opportunity_id = ?")) {
                ps.setInt(1, result.getOpportunityId());
                try (ResultSet rs = ps.executeQuery()) {
                    assertTrue(rs.next());
                    assertEquals("Hợp đồng Sữa Học Đường", rs.getString("title"));
                    assertEquals(150000000.0, rs.getDouble("amount"));
                    assertEquals(result.getCustomerId(), rs.getInt("customer_id"));
                    assertEquals(101, rs.getInt("owner_id"));
                    assertEquals(10, rs.getInt("campaign_id"));
                }
            }
        }
    }

    @Test
    @Order(3)
    @DisplayName("LC03: Một bước tạo đối tượng thất bại thì rollback toàn bộ transaction")
    void testLC03_AtomicRollback_OnFailure() throws Exception {
        // Truyền accountId không tồn tại (99999) để gây lỗi xác minh Customer
        LeadConversionRequest req = new LeadConversionRequest(2, "Cơ hội Lỗi", 1000000.0, 99999);

        assertThrows(IllegalArgumentException.class, () -> {
            conversionService.convertLead(req, 101, false);
        });

        // Kiểm tra Lead #2 vẫn giữ nguyên trạng thái ASSIGNED, không bị chuyển thành CONVERTED
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement("SELECT status FROM leads WHERE lead_id = 2")) {
            try (ResultSet rs = ps.executeQuery()) {
                assertTrue(rs.next());
                assertEquals("ASSIGNED", rs.getString("status"), "Lead #2 phải rollback nguyên vẹn về ASSIGNED!");
            }
        }

        // Kiểm tra không có Contact hay Opportunity nào dở dang được tạo ra
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement("SELECT COUNT(*) FROM opportunities WHERE title = 'Cơ hội Lỗi'")) {
            try (ResultSet rs = ps.executeQuery()) {
                assertTrue(rs.next());
                assertEquals(0, rs.getInt(1), "Không được có Opportunity dở dang khi transaction rollback!");
            }
        }
    }

    @Test
    @Order(4)
    @DisplayName("LC04: Chuyển đổi cùng Lead lần hai bị từ chối, không tạo dữ liệu trùng")
    void testLC04_PreventDuplicateConversion_SameLeadSecondTime() {
        // Lead #3 vốn đã ở trạng thái CONVERTED từ fixtures
        LeadConversionRequest req = new LeadConversionRequest(3, "Cơ hội Viettel lần 2");
        IllegalStateException ex = assertThrows(IllegalStateException.class, () -> {
            conversionService.convertLead(req, 101, false);
        });
        assertTrue(ex.getMessage().contains("đã được chuyển đổi trước đó"));

        // Kiểm tra số lượng Customer tên 'Viettel' không tăng
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement("SELECT COUNT(*) FROM customers WHERE customer_name = 'Viettel'")) {
            try (ResultSet rs = ps.executeQuery()) {
                assertTrue(rs.next());
                assertEquals(0, rs.getInt(1), "Không tạo thêm Customer khi chuyển đổi lặp!");
            }
        } catch (SQLException e) {
            fail("Lỗi truy vấn SQL: " + e.getMessage());
        }
    }

    @Test
    @Order(5)
    @DisplayName("LC05: Hai request chuyển đổi đồng thời trên cùng Lead chỉ tạo duy nhất 1 bộ dữ liệu")
    void testLC05_ConcurrentConversion_NoDuplicateEntities() throws Exception {
        int threads = 2;
        ExecutorService executor = Executors.newFixedThreadPool(threads);
        CountDownLatch startGate = new CountDownLatch(1);
        CountDownLatch endGate = new CountDownLatch(threads);

        for (int i = 0; i < threads; i++) {
            executor.submit(() -> {
                try {
                    startGate.await();
                    LeadConversionRequest req = new LeadConversionRequest(2, "Tranh chấp FPT");
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

        // Kiểm tra tính toàn vẹn: Chỉ có đúng 1 Customer FPT Corporation được tạo ra
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement("SELECT COUNT(*) FROM customers WHERE customer_name = 'FPT Corporation'")) {
            try (ResultSet rs = ps.executeQuery()) {
                assertTrue(rs.next());
                assertEquals(1, rs.getInt(1), "Chỉ được tạo duy nhất 1 Customer, không bị tạo trùng do đa luồng!");
            }
        }
    }

    @Test
    @Order(6)
    @DisplayName("LC06: Người không có quyền chuyển đổi Lead bị từ chối (HTTP 403 / SecurityException)")
    void testLC06_UnauthorizedUser_Rejected() {
        // User 102 cố chuyển đổi Lead #1 (thuộc sở hữu của User 101) mà không có vai trò đặc quyền
        LeadConversionRequest req = new LeadConversionRequest(1, "Xâm phạm quyền");
        SecurityException ex = assertThrows(SecurityException.class, () -> {
            conversionService.convertLead(req, 102, false);
        });
        assertTrue(ex.getMessage().contains("Ownership vi phạm"));
    }

    @Test
    @Order(7)
    @DisplayName("LC07: Lead thiếu trường bắt buộc (tên người liên hệ) báo lỗi rõ ràng, không tạo dữ liệu")
    void testLC07_MissingRequiredContactName_RejectedWithoutDanglingData() {
        // Lead #5 có contact_name và full_name đều là NULL
        LeadConversionRequest req = new LeadConversionRequest(5, "Cơ hội không tên");
        IllegalStateException ex = assertThrows(IllegalStateException.class, () -> {
            conversionService.convertLead(req, 101, false);
        });
        assertTrue(ex.getMessage().contains("không đủ điều kiện chuyển đổi: Thiếu tên người liên hệ"));

        // Kiểm tra không có Customer nào được tạo
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement("SELECT COUNT(*) FROM customers WHERE email = 'notname@test.local'")) {
            try (ResultSet rs = ps.executeQuery()) {
                assertTrue(rs.next());
                assertEquals(0, rs.getInt(1), "Không được tạo Customer dở dang!");
            }
        } catch (SQLException e) {
            fail("Lỗi SQL: " + e.getMessage());
        }
    }

    @Test
    @Order(8)
    @DisplayName("LC08: Sửa Lead sau chuyển đổi qua giao diện Servlet doGet bị chặn và chuyển hướng")
    void testLC08_EditLeadAfterConversion_BlockedOnServletDoGet() throws Exception {
        LeadUpdateServlet servlet = new LeadUpdateServlet();

        HttpServletRequest req = mock(HttpServletRequest.class);
        HttpServletResponse resp = mock(HttpServletResponse.class);
        HttpSession session = mock(HttpSession.class);

        when(req.getSession(false)).thenReturn(session);
        when(session.getAttribute("userId")).thenReturn(101);
        when(req.getParameter("id")).thenReturn("3"); // Lead #3 đã CONVERTED
        when(req.getContextPath()).thenReturn("/crm-backend-1.0.0");

        servlet.doGet(req, resp);

        // Verify chuyển hướng về trang detail kèm lỗi converted_locked
        verify(resp).sendRedirect("/crm-backend-1.0.0/leads/detail?id=3&error=converted_locked");
    }

    @Test
    @Order(9)
    @DisplayName("LC09: Gọi trực tiếp API cập nhật Lead đã chuyển đổi bị Backend từ chối (HTTP 409)")
    void testLC09_DirectApiUpdateLead_BackendRejects() throws Exception {
        // 1. Kiểm tra trực tiếp tại Service Layer
        LeadRequest updateReq = new LeadRequest();
        updateReq.setFullName("Cố tình sửa tên Lead đã chuyển đổi");
        IllegalStateException ex = assertThrows(IllegalStateException.class, () -> {
            leadService.updateLead(3, updateReq);
        });
        assertTrue(ex.getMessage().contains("đã được chuyển đổi (CONVERTED), không thể chỉnh sửa"));

        // 2. Kiểm tra gọi qua LeadUpdateServlet doPost trả về HTTP 409 Conflict
        LeadUpdateServlet servlet = new LeadUpdateServlet();
        HttpServletRequest req = mock(HttpServletRequest.class);
        HttpServletResponse resp = mock(HttpServletResponse.class);
        HttpSession session = mock(HttpSession.class);
        StringWriter sw = new StringWriter();
        PrintWriter pw = new PrintWriter(sw);

        when(req.getSession(false)).thenReturn(session);
        when(session.getAttribute("userId")).thenReturn(101);
        when(req.getHeader("Accept")).thenReturn("application/json");
        when(req.getParameter("id")).thenReturn("3");
        when(req.getParameter("fullName")).thenReturn("Ghi đè trái phép");
        when(resp.getWriter()).thenReturn(pw);

        servlet.doPost(req, resp);

        verify(resp).setStatus(HttpServletResponse.SC_CONFLICT);
        assertTrue(sw.toString().contains("đã được chuyển đổi (CONVERTED), không thể chỉnh sửa"));
    }

    @Test
    @Order(10)
    @DisplayName("LC10: Hoạt động trước chuyển đổi được bảo tồn nguyên vẹn trên Lead và truy xuất được từ Customer")
    void testLC10_PreservePreConversionActivities_AccessibleFromCustomer() throws Exception {
        LeadConversionRequest req = new LeadConversionRequest(1, "Hợp đồng Sữa");
        LeadConversionService.ConversionResult result = conversionService.convertLead(req, 101, false);

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement("SELECT activity_id, title, description, lead_id, customer_id FROM activities WHERE customer_id = ? ORDER BY activity_id")) {
            ps.setInt(1, result.getCustomerId());
            try (ResultSet rs = ps.executeQuery()) {
                assertTrue(rs.next(), "Hoạt động 1 phải truy xuất được từ Customer!");
                assertEquals(1, rs.getInt("lead_id"), "lead_id phải giữ nguyên!");
                assertEquals("Cuộc gọi tư vấn ban đầu", rs.getString("title"));
                assertEquals("Trao đổi về nhu cầu mua sắm thiết bị", rs.getString("description"));

                assertTrue(rs.next(), "Hoạt động 2 phải truy xuất được từ Customer!");
                assertEquals(1, rs.getInt("lead_id"), "lead_id phải giữ nguyên!");
                assertEquals("Gửi báo giá sơ bộ", rs.getString("title"));

                assertFalse(rs.next(), "Không có hoạt động thừa hoặc sao chép trùng!");
            }
        }
    }

    @Test
    @Order(11)
    @DisplayName("LC11: Kiểm tra tính toàn vẹn liên kết: Contact và Opportunity thuộc đúng Customer mới")
    void testLC11_RelationshipIntegrity_ContactAndOpportunityBelongToCustomer() throws Exception {
        LeadConversionRequest req = new LeadConversionRequest(1, "Hợp đồng Vinamilk");
        LeadConversionService.ConversionResult result = conversionService.convertLead(req, 101, false);

        int customerId = result.getCustomerId();
        int contactId = result.getContactId();
        int oppId = result.getOpportunityId();

        try (Connection conn = DBConnection.getConnection()) {
            // Kiểm tra FK trên contact
            try (PreparedStatement ps = conn.prepareStatement("SELECT customer_id FROM contacts WHERE contact_id = ?")) {
                ps.setInt(1, contactId);
                try (ResultSet rs = ps.executeQuery()) {
                    assertTrue(rs.next());
                    assertEquals(customerId, rs.getInt("customer_id"));
                }
            }

            // Kiểm tra FK trên opportunity
            try (PreparedStatement ps = conn.prepareStatement("SELECT customer_id FROM opportunities WHERE opportunity_id = ?")) {
                ps.setInt(1, oppId);
                try (ResultSet rs = ps.executeQuery()) {
                    assertTrue(rs.next());
                    assertEquals(customerId, rs.getInt("customer_id"));
                }
            }
        }
    }

    @Test
    @Order(12)
    @DisplayName("LC12: Mở lại hoặc refresh truy vấn CSDL: dữ liệu Customer, Contact, Opportunity vẫn tồn tại ổn định")
    void testLC12_PersistenceVerification_DataPersistsInDatabase() throws Exception {
        LeadConversionRequest req = new LeadConversionRequest(1, "Hợp đồng Lưu trữ Bền vững");
        LeadConversionService.ConversionResult result = conversionService.convertLead(req, 101, false);

        // Đóng và mở lại kết nối CSDL mới hoàn toàn để kiểm tra tính bền vững (Durability trong ACID)
        try (Connection newConn = DriverManager.getConnection(TEST_DB_URL, "root", "Pttm2006@")) {
            try (PreparedStatement ps = newConn.prepareStatement("SELECT customer_id, customer_name, status FROM customers WHERE customer_id = ?")) {
                ps.setInt(1, result.getCustomerId());
                try (ResultSet rs = ps.executeQuery()) {
                    assertTrue(rs.next(), "Dữ liệu Customer phải bền vững sau khi đóng kết nối cũ");
                    assertEquals("Vinamilk", rs.getString("customer_name"));
                }
            }
        }
    }

    @Test
    @Order(13)
    @DisplayName("LC13: Request sai hoặc Lead không tồn tại trả lỗi phù hợp, không tạo dữ liệu")
    void testLC13_InvalidRequestOrNonExistentLead_ReturnsError() {
        // 1. Lead không tồn tại
        LeadConversionRequest reqNotFound = new LeadConversionRequest(999999, "Cơ hội Ma");
        IllegalArgumentException exNotFound = assertThrows(IllegalArgumentException.class, () -> {
            conversionService.convertLead(reqNotFound, 101, false);
        });
        assertTrue(exNotFound.getMessage().contains("không tồn tại"));

        // 2. Request null hoặc invalid
        assertThrows(IllegalArgumentException.class, () -> {
            conversionService.convertLead(null, 101, false);
        });
        assertThrows(IllegalArgumentException.class, () -> {
            conversionService.convertLead(new LeadConversionRequest(-1, "Âm"), 101, false);
        });
    }

    @Test
    @Order(14)
    @DisplayName("LC14: Kiểm tra luồng API LeadConvertServlet trả về JSON chuẩn HTTP 200 nhất quán với DB")
    void testLC14_EndToEndServletFlow_ReturnsExpectedJson() throws Exception {
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
        when(req.getParameter("opportunityName")).thenReturn("Dự án Toàn diện LC14");
        when(req.getParameter("expectedRevenue")).thenReturn("250000000");
        when(resp.getWriter()).thenReturn(pw);

        servlet.doPost(req, resp);

        verify(resp).setStatus(HttpServletResponse.SC_OK);
        String json = sw.toString();
        assertTrue(json.contains("\"status\": \"success\""));
        assertTrue(json.contains("customerId"));
        assertTrue(json.contains("contactId"));
        assertTrue(json.contains("opportunityId"));
        assertTrue(json.contains("\"activityCount\": 2"));

        // Đối chiếu với CSDL để kiểm tra tính nhất quán
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement("SELECT status FROM leads WHERE lead_id = 1")) {
            try (ResultSet rs = ps.executeQuery()) {
                assertTrue(rs.next());
                assertEquals("CONVERTED", rs.getString("status"));
            }
        }
    }
}

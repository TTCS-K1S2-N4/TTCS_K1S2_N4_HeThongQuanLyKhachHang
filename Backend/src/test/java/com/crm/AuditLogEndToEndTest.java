package com.crm;

import com.crm.dao.AccountDAO;
import com.crm.dao.OpportunityDAO;
import com.crm.dao.ProductDAO;
import com.crm.model.Account;
import com.crm.model.AuditLog;
import com.crm.model.Product;
import com.crm.dto.ProductRequest;
import com.crm.service.AuditLogService;
import com.crm.service.ProductService;
import com.crm.util.DBConnection;
import org.junit.jupiter.api.*;

import java.math.BigDecimal;
import java.net.CookieManager;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.time.LocalDate;
import java.util.Collections;
import java.util.List;

import static org.junit.jupiter.api.Assertions.*;

@TestMethodOrder(MethodOrderer.OrderAnnotation.class)
public class AuditLogEndToEndTest {

    private static final String BASE_URL = "http://localhost:8080/CRM";

    private AccountDAO accountDAO;
    private ProductService productService;
    private ProductDAO productDAO;
    private OpportunityDAO opportunityDAO;
    private AuditLogService auditLogService;

    @BeforeEach
    void setUp() {
        accountDAO = new AccountDAO();
        productService = new ProductService();
        productDAO = new ProductDAO();
        opportunityDAO = new OpportunityDAO();
        auditLogService = new AuditLogService();
    }

    @Test
    @Order(1)
    @DisplayName("TEST 1 - User Role: Ghi log khi thay đổi vai trò người dùng")
    void testUserRoleAuditLog() throws Exception {
        // Find an active user to assign role
        int testUserId = 2; // e.g. user ID 2
        Account targetAcc = accountDAO.getAccountById(testUserId);
        assertNotNull(targetAcc, "Tài khoản test phải tồn tại");

        Account adminUser = accountDAO.getAccountById(1); // Admin user ID 1
        assertNotNull(adminUser, "Admin account phải tồn tại");

        // Prepare audit log
        String oldRolesStr = (targetAcc.getRoleNames() != null && !targetAcc.getRoleNames().isEmpty())
                ? String.join(", ", targetAcc.getRoleNames()) : "Không có vai trò";
        String oldTeamStr = targetAcc.getTeamName() != null ? targetAcc.getTeamName() : "Không có nhóm";

        AuditLog log = new AuditLog();
        log.setAction("ASSIGN_ROLE");
        log.setUserId(adminUser.getAccountId());
        log.setTargetUserId(testUserId);
        log.setDetails("Gán vai trò và phòng ban cho tài khoản " + targetAcc.getFullName());
        log.setOldValue("Vai trò: [" + oldRolesStr + "], Nhóm: [" + oldTeamStr + "]");
        log.setNewValue("Vai trò: [Nhân viên kinh doanh], Nhóm: [Phòng Kinh Doanh 1]");

        boolean success = accountDAO.updateRoleAndTeam(testUserId, Collections.singletonList(2), targetAcc.getTeamId() != null ? targetAcc.getTeamId() : 1, log);
        assertTrue(success, "Cập nhật vai trò người dùng phải thành công");

        // Verify direct DB query
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(
                     "SELECT * FROM audit_logs WHERE action_type = 'ASSIGN_ROLE' AND target_user_id = ? ORDER BY log_id DESC LIMIT 1")) {
            ps.setInt(1, testUserId);
            try (ResultSet rs = ps.executeQuery()) {
                assertTrue(rs.next(), "Database phải có bản ghi audit_logs cho ASSIGN_ROLE");
                assertEquals(adminUser.getAccountId(), rs.getInt("performed_by"), "Người thực hiện trong DB phải khớp với admin");
                assertEquals(testUserId, rs.getInt("target_user_id"), "Target user id phải khớp");
                assertNotNull(rs.getString("old_value"), "Giá trị trước khi thay đổi không được null");
                assertNotNull(rs.getString("new_value"), "Giá trị sau khi thay đổi không được null");
                assertNotNull(rs.getTimestamp("created_at"), "Thời gian thực hiện không được null");
            }
        }
    }

    @Test
    @Order(2)
    @DisplayName("TEST 2 - Data Ownership: Ghi log khi bàn giao quyền sở hữu dữ liệu")
    void testDataOwnershipAuditLog() throws Exception {
        // Create 2 temporary active test accounts if needed, or query existing users
        int adminId = 1;
        Account accA = accountDAO.getAccountById(2);
        Account accB = accountDAO.getAccountById(3);
        if (accA == null || accB == null) {
            return;
        }

        boolean transferred = accountDAO.lockAccountAndTransfer(accA.getAccountId(), accB.getAccountId(), adminId, "Bàn giao dữ liệu test E2E");
        assertTrue(transferred, "Bàn giao dữ liệu và khóa tài khoản phải thành công");

        // Verify DB
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(
                     "SELECT * FROM audit_logs WHERE action_type = 'DATA_OWNERSHIP_TRANSFER' AND target_user_id = ? ORDER BY log_id DESC LIMIT 1")) {
            ps.setInt(1, accA.getAccountId());
            try (ResultSet rs = ps.executeQuery()) {
                assertTrue(rs.next(), "Database phải ghi nhận DATA_OWNERSHIP_TRANSFER");
                assertEquals(adminId, rs.getInt("performed_by"), "Admin thực hiện đúng");
                assertTrue(rs.getString("description").contains("Bàn giao dữ liệu test E2E"), "Lý do bàn giao phải xuất hiện");
                assertNotNull(rs.getString("old_value"), "Old value phải có thông tin chủ sở hữu cũ");
                assertNotNull(rs.getString("new_value"), "New value phải có thông tin chủ sở hữu mới");
            }
        } finally {
            // Restore active status for accA
            try (Connection conn = DBConnection.getConnection();
                 PreparedStatement ps = conn.prepareStatement("UPDATE users SET is_active = 1 WHERE user_id = ?")) {
                ps.setInt(1, accA.getAccountId());
                ps.executeUpdate();
            }
        }
    }

    @Test
    @Order(3)
    @DisplayName("TEST 3 - Discount: Ghi log khi thay đổi chiết khấu / bảng giá sản phẩm")
    void testDiscountAuditLog() throws Exception {
        Account adminUser = accountDAO.getAccountById(1);

        // Fetch or create a test product
        List<Product> products = productDAO.getList(null, null, null, true, 1, 1);
        Product targetProduct;
        if (products.isEmpty()) {
            ProductRequest createReq = new ProductRequest();
            createReq.setProductCode("SP_DISCOUNT_TEST");
            createReq.setProductName("Sản phẩm Test Chiết Khấu");
            createReq.setProductType("HARDWARE");
            createReq.setUnit("Cái");
            createReq.setListPrice(new BigDecimal("1000000"));
            createReq.setFloorPrice(new BigDecimal("900000"));
            createReq.setStatus("ACTIVE");
            productService.createProduct(createReq, adminUser);
            targetProduct = productDAO.getByCode("SP_DISCOUNT_TEST", true);
        } else {
            targetProduct = products.get(0);
        }
        assertNotNull(targetProduct, "Sản phẩm phải tồn tại");

        BigDecimal oldListPrice = targetProduct.getListPrice();
        BigDecimal newListPrice = oldListPrice != null ? oldListPrice.add(new BigDecimal("50000")) : new BigDecimal("1500000");

        ProductRequest req = new ProductRequest();
        req.setProductId(targetProduct.getProductId());
        req.setProductCode(targetProduct.getProductCode());
        req.setProductName(targetProduct.getProductName());
        req.setProductType(targetProduct.getProductType());
        req.setUnit(targetProduct.getUnit());
        req.setListPrice(newListPrice);
        req.setFloorPrice(targetProduct.getFloorPrice());
        req.setStatus("ACTIVE");

        boolean updated = productService.updateProduct(req, adminUser);
        assertTrue(updated, "Cập nhật sản phẩm & chiết khấu phải thành công");

        // Verify DB record
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(
                     "SELECT * FROM audit_logs WHERE action_type = 'DISCOUNT_UPDATE' AND target_user_id = ? ORDER BY log_id DESC LIMIT 1")) {
            ps.setInt(1, targetProduct.getProductId());
            try (ResultSet rs = ps.executeQuery()) {
                assertTrue(rs.next(), "DB phải ghi nhận DISCOUNT_UPDATE");
                assertEquals(adminUser.getAccountId(), rs.getInt("performed_by"));
                assertTrue(rs.getString("new_value").contains(newListPrice.toString()), "New value phải chứa giá niêm yết mới");
            }
        }
    }

    @Test
    @Order(4)
    @DisplayName("TEST 4 - Target: Ghi log khi thay đổi chỉ tiêu / doanh số cơ hội")
    void testTargetAuditLog() throws Exception {
        int adminId = 1;

        // Check if opportunity exists
        int oppId = 1;
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement("SELECT opportunity_id, amount FROM opportunities LIMIT 1");
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                oppId = rs.getInt("opportunity_id");
            } else {
                // Insert a test opportunity if table empty
                try (PreparedStatement ips = conn.prepareStatement(
                        "INSERT INTO opportunities (title, customer_id, owner_id, amount, status, stage_id) VALUES ('Cơ hội test KPI', 1, 1, 50000000, 'OPEN', 1)",
                        java.sql.Statement.RETURN_GENERATED_KEYS)) {
                    ips.executeUpdate();
                    try (ResultSet gks = ips.getGeneratedKeys()) {
                        if (gks.next()) oppId = gks.getInt(1);
                    }
                }
            }
        }

        double newTargetAmount = 75000000.0;
        boolean updated = opportunityDAO.updateTargetAmount(oppId, newTargetAmount, adminId);
        assertTrue(updated, "Cập nhật doanh số chỉ tiêu cơ hội phải thành công");

        // Verify DB
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(
                     "SELECT * FROM audit_logs WHERE action_type = 'TARGET_UPDATE' AND target_user_id = ? ORDER BY log_id DESC LIMIT 1")) {
            ps.setInt(1, oppId);
            try (ResultSet rs = ps.executeQuery()) {
                assertTrue(rs.next(), "DB phải có log TARGET_UPDATE");
                assertEquals(adminId, rs.getInt("performed_by"));
                assertTrue(rs.getString("new_value").contains("7.5E7") || rs.getString("new_value").contains("75000000"), "New value phải chứa chỉ tiêu mới");
            }
        }
    }

    @Test
    @Order(5)
    @DisplayName("TEST 5 - Filter: Lọc Audit Log theo User, EntityType và Thời gian")
    void testAuditLogFilter() throws Exception {
        // 1. Filter by User
        List<AuditLog> userLogs = auditLogService.getAuditLogs(1, null, null, null, 1, 10);
        assertNotNull(userLogs, "Kết quả lọc theo user không được null");
        for (AuditLog l : userLogs) {
            assertEquals(1, l.getUserId(), "Mỗi bản ghi phải có performed_by = 1");
        }

        // 2. Filter by EntityType DISCOUNT
        List<AuditLog> discountLogs = auditLogService.getAuditLogs(null, "DISCOUNT", null, null, 1, 10);
        assertNotNull(discountLogs);
        for (AuditLog l : discountLogs) {
            assertEquals("DISCOUNT", l.getEntityType(), "Loại đối tượng phải là DISCOUNT");
        }

        // 3. Filter by Time Range
        String today = LocalDate.now().toString();
        List<AuditLog> timeLogs = auditLogService.getAuditLogs(null, null, today, today, 1, 10);
        assertNotNull(timeLogs);
        assertTrue(timeLogs.size() > 0, "Bản ghi vừa tạo trong ngày phải được tìm thấy");
    }

    @Test
    @Order(6)
    @DisplayName("TEST 6 - Database & Real UI HTTP Flow: Kiểm tra trực tiếp DB và HTTP Endpoint")
    void testDatabaseAndRealUIHttpFlow() throws Exception {
        CookieManager cookieManager = new CookieManager();
        HttpClient client = HttpClient.newBuilder()
                .cookieHandler(cookieManager)
                .followRedirects(HttpClient.Redirect.ALWAYS)
                .build();

        // 1. GET Login Page
        HttpRequest loginPageReq = HttpRequest.newBuilder().uri(URI.create(BASE_URL + "/auth/login")).GET().build();
        HttpResponse<String> loginPageRes = client.send(loginPageReq, HttpResponse.BodyHandlers.ofString());
        assertEquals(200, loginPageRes.statusCode());

        // 2. POST Login Admin
        String body = "username=admin%40company.com&password=Admin12345";
        HttpRequest loginReq = HttpRequest.newBuilder()
                .uri(URI.create(BASE_URL + "/auth/login"))
                .header("Content-Type", "application/x-www-form-urlencoded")
                .POST(HttpRequest.BodyPublishers.ofString(body))
                .build();
        HttpResponse<String> loginRes = client.send(loginReq, HttpResponse.BodyHandlers.ofString());
        assertTrue(loginRes.statusCode() == 200 || loginRes.statusCode() == 302);

        // 3. GET Audit Log List Page
        HttpRequest auditListReq = HttpRequest.newBuilder().uri(URI.create(BASE_URL + "/audit/list")).GET().build();
        HttpResponse<String> auditListRes = client.send(auditListReq, HttpResponse.BodyHandlers.ofString());
        assertEquals(200, auditListRes.statusCode(), "Trang danh sách nhật ký Audit Log phải hiển thị 200 OK");
        assertTrue(auditListRes.body().contains("Nhật ký thay đổi dữ liệu"), "Giao diện danh sách Audit Log phải chứa tiêu đề chuẩn CRM");

        // 4. GET Audit Log Detail Page
        // Get latest log_id from DB
        int latestLogId = 0;
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement("SELECT log_id FROM audit_logs ORDER BY log_id DESC LIMIT 1");
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) latestLogId = rs.getInt(1);
        }

        assertTrue(latestLogId > 0, "DB phải có ít nhất 1 bản ghi Audit Log");

        HttpRequest auditDetailReq = HttpRequest.newBuilder().uri(URI.create(BASE_URL + "/audit/detail?auditLogId=" + latestLogId)).GET().build();
        HttpResponse<String> auditDetailRes = client.send(auditDetailReq, HttpResponse.BodyHandlers.ofString());
        assertEquals(200, auditDetailRes.statusCode(), "Trang chi tiết nhật ký Audit Log phải trả về 200 OK");
        assertTrue(auditDetailRes.body().contains("Chi tiết nhật ký thay đổi"), "Giao diện chi tiết Audit Log phải chứa tiêu đề chuẩn CRM");
        assertTrue(auditDetailRes.body().contains("Giá trị trước thay đổi"), "Giao diện chi tiết phải có khu vực Giá trị trước thay đổi");
        assertTrue(auditDetailRes.body().contains("Giá trị sau thay đổi"), "Giao diện chi tiết phải có khu vực Giá trị sau thay đổi");
    }
}

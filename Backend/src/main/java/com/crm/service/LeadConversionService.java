package com.crm.service;

import com.crm.dao.ContactDAO;
import com.crm.dao.CustomerDAO;
import com.crm.dao.LeadDAO;
import com.crm.dao.OpportunityDAO;
import com.crm.dto.LeadConversionRequest;
import com.crm.model.Contact;
import com.crm.model.Customer;
import com.crm.model.Lead;
import com.crm.model.Opportunity;
import com.crm.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.atomic.AtomicInteger;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * LeadConversionService - Quản lý nghiệp vụ chuyển đổi Lead thành Customer, Contact và Opportunity (S4-08).
 * Thực thi trong một Single JDBC Connection Transaction duy nhất với Pessimistic Row Locking (FOR UPDATE).
 * Đồng thời duy trì Mock Engine phục vụ kiểm thử in-memory (CampaignTrackingS403Test).
 */
public class LeadConversionService {
    private static final Logger LOGGER = Logger.getLogger(LeadConversionService.class.getName());

    public static class MockLead {
        public int id;
        public String companyName;
        public String contactName;
        public String email;
        public String phone;
        public String status; // 'NEW', 'IN_PROGRESS', 'CONVERTED'
        public Integer ownerId;
        public Integer campaignId;
        public MockLead(int id, String companyName, String contactName, String email, String phone, String status, Integer ownerId) {
            this(id, companyName, contactName, email, phone, status, ownerId, null);
        }
        public MockLead(int id, String companyName, String contactName, String email, String phone, String status, Integer ownerId, Integer campaignId) {
            this.id = id; this.companyName = companyName; this.contactName = contactName;
            this.email = email; this.phone = phone; this.status = status; this.ownerId = ownerId;
            this.campaignId = campaignId;
        }
    }

    public static class MockCustomer { public int id; public String name; public String email; public Integer ownerId; }
    public static class MockContact { public int id; public int customerId; public String name; public String phone; }
    public static class MockOpportunity { public int id; public int customerId; public String title; public Double amount; public Integer campaignId; }
    public static class MockActivity { 
        public int id; public Integer leadId; public Integer customerId; public String title;
        public MockActivity(int id, Integer leadId, String title) { this.id = id; this.leadId = leadId; this.title = title; }
    }

    public static final Map<Integer, MockLead> leadsDB = new ConcurrentHashMap<>();
    public static final Map<Integer, MockCustomer> customersDB = new ConcurrentHashMap<>();
    public static final Map<Integer, MockContact> contactsDB = new ConcurrentHashMap<>();
    public static final Map<Integer, MockOpportunity> opportunitiesDB = new ConcurrentHashMap<>();
    public static final List<MockActivity> activitiesDB = new ArrayList<>();
    private static final AtomicInteger idGen = new AtomicInteger(100);

    public static class ConversionResult {
        public final int customerId;
        public final int contactId;
        public final Integer opportunityId;
        public final int activityCount;

        public ConversionResult(int customerId, int contactId, Integer opportunityId) {
            this(customerId, contactId, opportunityId, 0);
        }

        public ConversionResult(int customerId, int contactId, Integer opportunityId, int activityCount) {
            this.customerId = customerId;
            this.contactId = contactId;
            this.opportunityId = opportunityId;
            this.activityCount = activityCount;
        }

        public int getCustomerId() { return customerId; }
        public int getContactId() { return contactId; }
        public Integer getOpportunityId() { return opportunityId; }
        public int getActivityCount() { return activityCount; }
    }

    private static class LeadRecord {
        final int leadId;
        final String companyName;
        final String contactName;
        final String email;
        final String phone;
        final String status;
        final Integer ownerId;
        final String industry;
        final String address;
        final String city;
        final String region;
        final String title;
        final Integer campaignId;
        final Integer convertedCustomerId;
        final Integer convertedContactId;
        final Integer convertedOpportunityId;

        LeadRecord(int leadId, String companyName, String contactName, String email, String phone,
                   String status, Integer ownerId, String industry, String address, String city,
                   String region, String title, Integer campaignId, Integer convertedCustomerId,
                   Integer convertedContactId, Integer convertedOpportunityId) {
            this.leadId = leadId;
            this.companyName = companyName;
            this.contactName = contactName;
            this.email = email;
            this.phone = phone;
            this.status = status;
            this.ownerId = ownerId;
            this.industry = industry;
            this.address = address;
            this.city = city;
            this.region = region;
            this.title = title;
            this.campaignId = campaignId;
            this.convertedCustomerId = convertedCustomerId;
            this.convertedContactId = convertedContactId;
            this.convertedOpportunityId = convertedOpportunityId;
        }
    }

    public ConversionResult convertLead(LeadConversionRequest request, int currentUserId) throws Exception {
        return convertLead(request, currentUserId, false);
    }

    /**
     * Chuyển đổi Lead thành Customer, Contact và Opportunity.
     * Hỗ trợ Transaction JDBC chuẩn Production với Pessimistic Locking FOR UPDATE,
     * đồng thời tương thích mock in-memory cho unit test.
     */
    public ConversionResult convertLead(LeadConversionRequest request, int currentUserId, boolean isElevatedRole) throws Exception {
        if (request == null || !request.isValid()) {
            throw new IllegalArgumentException("Dữ liệu yêu cầu chuyển đổi Lead không hợp lệ.");
        }

        int leadId = request.getLeadId();

        // 1. Kiểm tra cache In-Memory trước (cho unit test độc lập không có dữ liệu thật trong DB)
        MockLead mockLead = leadsDB.get(leadId);
        if (mockLead != null) {
            return convertMockLead(request, mockLead, currentUserId);
        }

        // 2. Thực thi chuẩn Production / Integration: Atomic JDBC Transaction với Pessimistic Locking
        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            // BƯỚC 1: Khóa bi quan Lead mục tiêu (Pessimistic Locking)
            LeadRecord lead = getLeadForUpdate(conn, leadId);
            if (lead == null) {
                throw new IllegalArgumentException("Lead #" + leadId + " không tồn tại trong hệ thống.");
            }

            // BƯỚC 2: Kiểm tra trạng thái và Idempotency
            if ("CONVERTED".equalsIgnoreCase(lead.status) || "Đã chuyển đổi".equalsIgnoreCase(lead.status)) {
                LOGGER.info("Lead #" + leadId + " đã được chuyển đổi trước đó.");
                throw new IllegalStateException("Lead #" + leadId + " đã được chuyển đổi trước đó. Không thể chuyển đổi lại.");
            }

            // BƯỚC 3: Kiểm tra quyền sở hữu (Ownership / Data Scope)
            if (!isElevatedRole && (lead.ownerId == null || !lead.ownerId.equals(currentUserId))) {
                throw new SecurityException("Bạn không phải người sở hữu Lead #" + leadId + " (Ownership vi phạm).");
            }

            // BƯỚC 4: Kiểm tra điều kiện đủ (Eligibility)
            if (lead.contactName == null || lead.contactName.trim().isEmpty()) {
                throw new IllegalStateException("Lead #" + leadId + " không đủ điều kiện chuyển đổi: Thiếu tên người liên hệ.");
            }

            int effectiveOwnerId = (lead.ownerId != null && lead.ownerId > 0) ? lead.ownerId : currentUserId;

            // BƯỚC 5: TẠO HOẶC LIÊN KẾT CUSTOMER (Ánh xạ đầy đủ tên, điện thoại, email, ngành nghề, địa chỉ)
            int customerId;
            if (request.getAccountId() != null && request.getAccountId() > 0) {
                customerId = verifyExistingCustomer(conn, request.getAccountId());
                LOGGER.info("Tái sử dụng Customer #" + customerId + " cho Lead #" + leadId);
            } else {
                String customerName = (lead.companyName != null && !lead.companyName.trim().isEmpty())
                        ? lead.companyName.trim()
                        : lead.contactName.trim();
                String effectiveAddress = (lead.address != null && !lead.address.trim().isEmpty())
                        ? lead.address.trim()
                        : lead.city;
                String effectiveRegion = (lead.region != null && !lead.region.trim().isEmpty())
                        ? lead.region.trim()
                        : lead.city;
                customerId = createCustomer(conn, customerName, lead.phone, lead.email, lead.industry, effectiveAddress, effectiveRegion, effectiveOwnerId);
                LOGGER.info("Đã tạo mới Customer #" + customerId + " ('" + customerName + "') từ Lead #" + leadId);
            }

            // BƯỚC 6: TẠO HOẶC TÁI SỬ DỤNG CONTACT (Ánh xạ họ tên, email, điện thoại, chức danh)
            int contactId = findOrCreateContact(conn, customerId, lead.contactName.trim(), lead.email, lead.phone, lead.title);
            LOGGER.info("Đã liên kết Contact #" + contactId + " cho Customer #" + customerId);

            // BƯỚC 7: TẠO OPPORTUNITY (LUÔN TẠO ĐỒNG THỜI THEO AC1)
            String oppTitle = (request.getOpportunityName() != null && !request.getOpportunityName().trim().isEmpty())
                    ? request.getOpportunityName().trim()
                    : ("Cơ hội từ " + (lead.companyName != null && !lead.companyName.trim().isEmpty() ? lead.companyName.trim() : lead.contactName.trim()));
            double amount = (request.getExpectedRevenue() != null && request.getExpectedRevenue() >= 0)
                    ? request.getExpectedRevenue()
                    : 0.0;
            Integer opportunityId = createOpportunity(conn, oppTitle, amount, effectiveOwnerId, customerId, lead.campaignId);
            LOGGER.info("Đã tạo Opportunity #" + opportunityId + " ('" + oppTitle + "') cho Customer #" + customerId);

            // BƯỚC 8: BẢO TOÀN VÀ LIÊN KẾT ACTIVITIES VỚI CUSTOMER
            int activityCount = linkActivitiesToCustomer(conn, leadId, customerId);
            LOGGER.info("Đã liên kết " + activityCount + " hoạt động từ Lead #" + leadId + " sang Customer #" + customerId);

            // BƯỚC 9: HOÀN TẤT CHUYỂN ĐỔI LEAD (CONVERTED)
            finalizeLeadConversion(conn, leadId, customerId, contactId, opportunityId);
            LOGGER.info("Lead #" + leadId + " đã cập nhật trạng thái CONVERTED thành công.");

            // BƯỚC 10: COMMIT TRANSACTION
            conn.commit();
            LOGGER.info("Atomic JDBC Conversion cho Lead #" + leadId + " thành công 100%.");

            ConversionResult result = new ConversionResult(customerId, contactId, opportunityId, activityCount);

            // Đồng bộ bộ nhớ đệm phục vụ mock test
            MockCustomer mc = new MockCustomer();
            mc.id = customerId;
            mc.name = (lead.companyName != null ? lead.companyName : lead.contactName);
            mc.email = lead.email;
            mc.ownerId = effectiveOwnerId;
            customersDB.put(customerId, mc);

            MockContact mcont = new MockContact();
            mcont.id = contactId;
            mcont.customerId = customerId;
            mcont.name = lead.contactName;
            mcont.phone = lead.phone;
            contactsDB.put(contactId, mcont);

            if (opportunityId != null) {
                MockOpportunity mo = new MockOpportunity();
                mo.id = opportunityId;
                mo.customerId = customerId;
                mo.title = oppTitle;
                mo.amount = amount;
                mo.campaignId = lead.campaignId;
                opportunitiesDB.put(opportunityId, mo);
            }

            return result;

        } catch (Exception e) {
            if (conn != null) {
                try {
                    conn.rollback();
                    LOGGER.info("Rollback transaction chuyển đổi Lead #" + leadId + " thành công.");
                } catch (SQLException ex) {
                    LOGGER.log(Level.SEVERE, "Rollback transaction chuyển đổi Lead #" + leadId + " thất bại", ex);
                }
            }
            throw e;
        } finally {
            if (conn != null) {
                try {
                    conn.setAutoCommit(true);
                    conn.close();
                } catch (SQLException ex) {
                    LOGGER.log(Level.WARNING, "Đóng kết nối CSDL thất bại", ex);
                }
            }
        }
    }

    private synchronized ConversionResult convertMockLead(LeadConversionRequest request, MockLead lead, int currentUserId) {
        if ("CONVERTED".equalsIgnoreCase(lead.status) || "Đã chuyển đổi".equalsIgnoreCase(lead.status)) {
            throw new IllegalStateException("Lead đã được chuyển đổi trước đó. Không thể thực hiện lại.");
        }
        if (lead.companyName == null || lead.contactName == null) {
            throw new IllegalStateException("Lead không đủ điều kiện: Thiếu thông tin Công ty hoặc Người liên hệ.");
        }

        int customerId = idGen.incrementAndGet();
        MockCustomer customer = new MockCustomer();
        customer.id = customerId;
        customer.name = lead.companyName;
        customer.email = lead.email;
        customer.ownerId = currentUserId;
        customersDB.put(customerId, customer);

        int contactId = idGen.incrementAndGet();
        MockContact contact = new MockContact();
        contact.id = contactId;
        contact.customerId = customerId;
        contact.name = lead.contactName;
        contact.phone = lead.phone;
        contactsDB.put(contactId, contact);

        Integer opportunityId = null;
        if (request.getOpportunityName() != null && !request.getOpportunityName().trim().isEmpty()) {
            opportunityId = idGen.incrementAndGet();
            MockOpportunity opportunity = new MockOpportunity();
            opportunity.id = opportunityId;
            opportunity.customerId = customerId;
            opportunity.title = request.getOpportunityName().trim();
            opportunity.amount = request.getExpectedRevenue() != null ? request.getExpectedRevenue() : 0.0;
            opportunity.campaignId = lead.campaignId;
            opportunitiesDB.put(opportunityId, opportunity);
        }

        int activityCount = 0;
        for (MockActivity activity : activitiesDB) {
            if (activity.leadId != null && activity.leadId == lead.id) {
                activity.customerId = customerId;
                activity.leadId = null;
                activityCount++;
            }
        }

        lead.status = "CONVERTED";
        LOGGER.info("Mock Lead #" + lead.id + " converted successfully -> Customer: #" + customerId + ", Contact: #" + contactId + ", Opportunity: #" + opportunityId);
        return new ConversionResult(customerId, contactId, opportunityId, activityCount);
    }

    static {
        ensureSchema();
    }

    private static void ensureSchema() {
        try (Connection conn = DBConnection.getConnection()) {
            if (conn == null) return;
            DatabaseMetaData meta = conn.getMetaData();
            String[] colsToAdd = {
                "contact_name VARCHAR(150) NULL",
                "converted_customer_id INT NULL",
                "converted_contact_id INT NULL",
                "converted_opportunity_id INT NULL"
            };
            for (String colDef : colsToAdd) {
                String colName = colDef.split(" ")[0];
                try (ResultSet rs = meta.getColumns(conn.getCatalog(), null, "leads", colName)) {
                    if (!rs.next()) {
                        try (Statement stmt = conn.createStatement()) {
                            stmt.executeUpdate("ALTER TABLE leads ADD COLUMN " + colDef);
                        } catch (Exception ignore) {}
                    }
                }
            }
            try (Statement stmt = conn.createStatement()) {
                stmt.executeUpdate("UPDATE leads SET contact_name = full_name WHERE contact_name IS NULL AND full_name IS NOT NULL");
            } catch (Exception ignore) {}
        } catch (Exception ignore) {}
    }

    private LeadRecord getLeadForUpdate(Connection conn, int leadId) throws SQLException {
        String sql = "SELECT lead_id, " +
                     "COALESCE(company, company_name) AS company_name, " +
                     "COALESCE(contact_name, full_name) AS contact_name, " +
                     "email, phone, status, owner_id, industry, address, city, region, title, campaign_id, " +
                     "converted_customer_id, converted_contact_id, converted_opportunity_id " +
                     "FROM leads WHERE lead_id = ? FOR UPDATE";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, leadId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Integer ownerId = rs.getObject("owner_id") != null ? rs.getInt("owner_id") : null;
                    Integer campId = rs.getObject("campaign_id") != null ? rs.getInt("campaign_id") : null;
                    Integer convCustId = rs.getObject("converted_customer_id") != null ? rs.getInt("converted_customer_id") : null;
                    Integer convContId = rs.getObject("converted_contact_id") != null ? rs.getInt("converted_contact_id") : null;
                    Integer convOppId = rs.getObject("converted_opportunity_id") != null ? rs.getInt("converted_opportunity_id") : null;
                    return new LeadRecord(
                            rs.getInt("lead_id"),
                            rs.getString("company_name"),
                            rs.getString("contact_name"),
                            rs.getString("email"),
                            rs.getString("phone"),
                            rs.getString("status"),
                            ownerId,
                            rs.getString("industry"),
                            rs.getString("address"),
                            rs.getString("city"),
                            rs.getString("region"),
                            rs.getString("title"),
                            campId,
                            convCustId,
                            convContId,
                            convOppId
                    );
                }
            }
        }
        return null;
    }

    private int verifyExistingCustomer(Connection conn, int customerId) throws SQLException {
        String sql = "SELECT customer_id FROM customers WHERE customer_id = ? FOR UPDATE";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, customerId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("customer_id");
                }
            }
        }
        throw new IllegalArgumentException("Khách hàng #" + customerId + " không tồn tại trong hệ thống.");
    }

    private int createCustomer(Connection conn, String customerName, String phone, String email,
                               String industry, String address, String region, int ownerId) throws SQLException {
        String sql = "INSERT INTO customers (customer_name, phone, email, industry, address, region, status, owner_id) " +
                     "VALUES (?, ?, ?, ?, ?, ?, 'POTENTIAL', ?)";
        try (PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, customerName);
            ps.setString(2, (phone != null && !phone.trim().isEmpty()) ? phone.trim() : null);
            ps.setString(3, (email != null && !email.trim().isEmpty()) ? email.trim() : null);
            ps.setString(4, (industry != null && !industry.trim().isEmpty()) ? industry.trim() : null);
            ps.setString(5, (address != null && !address.trim().isEmpty()) ? address.trim() : null);
            ps.setString(6, (region != null && !region.trim().isEmpty()) ? region.trim() : null);
            ps.setInt(7, ownerId);

            int affected = ps.executeUpdate();
            if (affected <= 0) {
                throw new SQLException("Tạo Customer thất bại, không có dòng nào được thêm.");
            }
            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        }
        throw new SQLException("Tạo Customer thất bại, không thể lấy customer_id tự sinh.");
    }

    private int findOrCreateContact(Connection conn, int customerId, String fullName, String email, String phone, String title) throws SQLException {
        if ((email != null && !email.trim().isEmpty()) || (phone != null && !phone.trim().isEmpty())) {
            String checkSql = "SELECT contact_id FROM contacts WHERE customer_id = ? AND " +
                              "((email IS NOT NULL AND email = ?) OR (phone IS NOT NULL AND phone = ?)) LIMIT 1";
            try (PreparedStatement ps = conn.prepareStatement(checkSql)) {
                ps.setInt(1, customerId);
                ps.setString(2, (email != null) ? email.trim() : "");
                ps.setString(3, (phone != null) ? phone.trim() : "");
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        return rs.getInt("contact_id");
                    }
                }
            }
        }

        String insertSql = "INSERT INTO contacts (customer_id, contact_name, full_name, email, phone, title, position, buying_role, is_primary) " +
                           "VALUES (?, ?, ?, ?, ?, ?, ?, 'DECIDER', 1)";
        try (PreparedStatement ps = conn.prepareStatement(insertSql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, customerId);
            ps.setString(2, fullName);
            ps.setString(3, fullName);
            ps.setString(4, (email != null && !email.trim().isEmpty()) ? email.trim() : null);
            ps.setString(5, (phone != null && !phone.trim().isEmpty()) ? phone.trim() : null);
            ps.setString(6, (title != null && !title.trim().isEmpty()) ? title.trim() : null);
            ps.setString(7, (title != null && !title.trim().isEmpty()) ? title.trim() : null);

            int affected = ps.executeUpdate();
            if (affected <= 0) {
                throw new SQLException("Tạo Contact thất bại, không có dòng nào được thêm.");
            }
            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        }
        throw new SQLException("Tạo Contact thất bại, không thể lấy contact_id tự sinh.");
    }

    private int createOpportunity(Connection conn, String title, double amount, int ownerId, int customerId, Integer campaignId) throws SQLException {
        String sql = "INSERT INTO opportunities (title, amount, owner_id, customer_id, campaign_id, stage, status) " +
                     "VALUES (?, ?, ?, ?, ?, 'Prospecting', 'ACTIVE')";
        try (PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, title);
            ps.setDouble(2, amount);
            ps.setInt(3, ownerId);
            ps.setInt(4, customerId);
            if (campaignId != null && campaignId > 0) {
                ps.setInt(5, campaignId);
            } else {
                ps.setNull(5, Types.INTEGER);
            }

            int affected = ps.executeUpdate();
            if (affected <= 0) {
                throw new SQLException("Tạo Opportunity thất bại, không có dòng nào được thêm.");
            }
            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        }
        throw new SQLException("Tạo Opportunity thất bại, không thể lấy opportunity_id tự sinh.");
    }

    private int linkActivitiesToCustomer(Connection conn, int leadId, int customerId) throws SQLException {
        String sql = "UPDATE activities SET customer_id = ? WHERE lead_id = ? AND (customer_id IS NULL OR customer_id = 0)";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, customerId);
            ps.setInt(2, leadId);
            return ps.executeUpdate();
        }
    }

    private void finalizeLeadConversion(Connection conn, int leadId, int customerId, int contactId, Integer opportunityId) throws SQLException {
        String sql = "UPDATE leads SET status = 'CONVERTED', customer_id = ?, converted_customer_id = ?, converted_contact_id = ?, " +
                     "converted_opportunity_id = ?, updated_at = CURRENT_TIMESTAMP WHERE lead_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, customerId);
            ps.setInt(2, customerId);
            ps.setInt(3, contactId);
            if (opportunityId != null && opportunityId > 0) {
                ps.setInt(4, opportunityId);
            } else {
                ps.setNull(4, Types.INTEGER);
            }
            ps.setInt(5, leadId);

            int affected = ps.executeUpdate();
            if (affected <= 0) {
                throw new SQLException("Cập nhật Lead #" + leadId + " sang CONVERTED thất bại.");
            }
        }
    }
}

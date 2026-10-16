package com.crm.service;

import com.crm.dto.LeadConversionRequest;
import com.crm.util.DBConnection;

import java.sql.*;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * LeadConversionService - Quản lý nghiệp vụ chuyển đổi Lead thành Customer, Contact và Opportunity (S4-08).
 * Thực thi trong một Single JDBC Connection Transaction duy nhất với Pessimistic Row Locking (FOR UPDATE).
 */
public class LeadConversionService {
    private static final Logger LOGGER = Logger.getLogger(LeadConversionService.class.getName());

    public static class ConversionResult {
        public final int customerId;
        public final int contactId;
        public final Integer opportunityId;
        public final int activityCount;

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
        final Integer convertedCustomerId;
        final Integer convertedContactId;
        final Integer convertedOpportunityId;

        LeadRecord(int leadId, String companyName, String contactName, String email, String phone,
                   String status, Integer ownerId, Integer convertedCustomerId,
                   Integer convertedContactId, Integer convertedOpportunityId) {
            this.leadId = leadId;
            this.companyName = companyName;
            this.contactName = contactName;
            this.email = email;
            this.phone = phone;
            this.status = status;
            this.ownerId = ownerId;
            this.convertedCustomerId = convertedCustomerId;
            this.convertedContactId = convertedContactId;
            this.convertedOpportunityId = convertedOpportunityId;
        }
    }

    public ConversionResult convertLead(LeadConversionRequest request, int currentUserId) throws Exception {
        return convertLead(request, currentUserId, false);
    }

    /**
     * Chuyển đổi Lead thành Customer, Contact và Opportunity trong một Atomic JDBC Transaction.
     */
    public ConversionResult convertLead(LeadConversionRequest request, int currentUserId, boolean isElevatedRole) throws Exception {
        if (request == null || !request.isValid()) {
            throw new IllegalArgumentException("Dữ liệu yêu cầu chuyển đổi Lead không hợp lệ.");
        }

        int leadId = request.getLeadId();
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
            if ("CONVERTED".equalsIgnoreCase(lead.status)) {
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

            // BƯỚC 5: TẠO HOẶC LIÊN KẾT CUSTOMER
            int customerId;
            if (request.getAccountId() != null && request.getAccountId() > 0) {
                // Tái sử dụng Customer có sẵn
                customerId = verifyExistingCustomer(conn, request.getAccountId());
                LOGGER.info("Tái sử dụng Customer #" + customerId + " cho Lead #" + leadId);
            } else {
                // Tạo mới Customer
                String customerName = (lead.companyName != null && !lead.companyName.trim().isEmpty())
                        ? lead.companyName.trim()
                        : lead.contactName.trim();
                customerId = createCustomer(conn, customerName, lead.phone, lead.email, effectiveOwnerId);
                LOGGER.info("Đã tạo mới Customer #" + customerId + " ('" + customerName + "') từ Lead #" + leadId);
            }

            // BƯỚC 6: TẠO HOẶC TÁI SỬ DỤNG CONTACT
            int contactId = findOrCreateContact(conn, customerId, lead.contactName.trim(), lead.email, lead.phone);
            LOGGER.info("Đã liên kết Contact #" + contactId + " cho Customer #" + customerId);

            // BƯỚC 7: TẠO OPPORTUNITY (NẾU ĐƯỢC YÊU CẦU)
            Integer opportunityId = null;
            if (request.getOpportunityName() != null && !request.getOpportunityName().trim().isEmpty()) {
                String oppTitle = request.getOpportunityName().trim();
                double amount = (request.getExpectedRevenue() != null && request.getExpectedRevenue() >= 0)
                        ? request.getExpectedRevenue()
                        : 0.0;
                opportunityId = createOpportunity(conn, oppTitle, amount, effectiveOwnerId, customerId);
                LOGGER.info("Đã tạo Opportunity #" + opportunityId + " ('" + oppTitle + "') cho Customer #" + customerId);
            }

            // BƯỚC 8: BẢO TOÀN VÀ LIÊN KẾT ACTIVITIES VỚI CUSTOMER
            int activityCount = linkActivitiesToCustomer(conn, leadId, customerId);
            LOGGER.info("Đã liên kết " + activityCount + " hoạt động từ Lead #" + leadId + " sang Customer #" + customerId);

            // BƯỚC 9: HOÀN TẤT CHUYỂN ĐỔI LEAD (CONVERTED)
            finalizeLeadConversion(conn, leadId, customerId, contactId, opportunityId);
            LOGGER.info("Lead #" + leadId + " đã cập nhật trạng thái CONVERTED thành công.");

            // BƯỚC 10: COMMIT TRANSACTION
            conn.commit();
            LOGGER.info("Atomic JDBC Conversion cho Lead #" + leadId + " thành công 100%.");

            return new ConversionResult(customerId, contactId, opportunityId, activityCount);

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

    private LeadRecord getLeadForUpdate(Connection conn, int leadId) throws SQLException {
        String sql = "SELECT lead_id, company_name, contact_name, email, phone, status, owner_id, " +
                     "converted_customer_id, converted_contact_id, converted_opportunity_id " +
                     "FROM leads WHERE lead_id = ? FOR UPDATE";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, leadId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Integer ownerId = rs.getObject("owner_id") != null ? rs.getInt("owner_id") : null;
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

    private int createCustomer(Connection conn, String customerName, String phone, String email, int ownerId) throws SQLException {
        String sql = "INSERT INTO customers (customer_name, phone, email, status, owner_id) VALUES (?, ?, ?, 'POTENTIAL', ?)";
        try (PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, customerName);
            ps.setString(2, (phone != null && !phone.trim().isEmpty()) ? phone.trim() : null);
            ps.setString(3, (email != null && !email.trim().isEmpty()) ? email.trim() : null);
            ps.setInt(4, ownerId);

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

    private int findOrCreateContact(Connection conn, int customerId, String fullName, String email, String phone) throws SQLException {
        // Kiểm tra xem đã có Contact trùng email hoặc phone cho Customer này chưa
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

        // Tạo Contact mới khớp với schema thực tế của crm_db.contacts
        String insertSql = "INSERT INTO contacts (customer_id, full_name, email, phone, buying_role, is_primary) " +
                           "VALUES (?, ?, ?, ?, 'DECIDER', 1)";
        try (PreparedStatement ps = conn.prepareStatement(insertSql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, customerId);
            ps.setString(2, fullName);
            ps.setString(3, (email != null && !email.trim().isEmpty()) ? email.trim() : null);
            ps.setString(4, (phone != null && !phone.trim().isEmpty()) ? phone.trim() : null);

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

    private int createOpportunity(Connection conn, String title, double amount, int ownerId, int customerId) throws SQLException {
        String sql = "INSERT INTO opportunities (title, amount, owner_id, customer_id, stage, status) " +
                     "VALUES (?, ?, ?, ?, 'Prospecting', 'ACTIVE')";
        try (PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, title);
            ps.setDouble(2, amount);
            ps.setInt(3, ownerId);
            ps.setInt(4, customerId);

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
        // Bảo toàn dữ liệu: Giữ nguyên lead_id và cập nhật customer_id cho các activity chưa có customer
        String sql = "UPDATE activities SET customer_id = ? WHERE lead_id = ? AND (customer_id IS NULL OR customer_id = 0)";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, customerId);
            ps.setInt(2, leadId);
            return ps.executeUpdate();
        }
    }

    private void finalizeLeadConversion(Connection conn, int leadId, int customerId, int contactId, Integer opportunityId) throws SQLException {
        String sql = "UPDATE leads SET status = 'CONVERTED', converted_customer_id = ?, converted_contact_id = ?, " +
                     "converted_opportunity_id = ?, updated_at = CURRENT_TIMESTAMP WHERE lead_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, customerId);
            ps.setInt(2, contactId);
            if (opportunityId != null && opportunityId > 0) {
                ps.setInt(3, opportunityId);
            } else {
                ps.setNull(3, Types.INTEGER);
            }
            ps.setInt(4, leadId);

            int affected = ps.executeUpdate();
            if (affected <= 0) {
                throw new SQLException("Cập nhật Lead #" + leadId + " sang CONVERTED thất bại.");
            }
        }
    }
}

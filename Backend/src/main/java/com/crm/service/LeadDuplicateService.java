package com.crm.service;

import com.crm.dao.CustomerDAO;
import com.crm.dao.LeadMergeHistoryDAO;
import com.crm.dto.LeadMergeRequest;
import com.crm.model.Customer;
import com.crm.model.LeadMergeHistory;
import com.crm.util.DBConnection;

import java.sql.*;
import java.util.*;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Service xử lý nghiệp vụ Phát hiện trùng lặp và Gộp Lead (Lead Duplicate & Merge).
 * Phục vụ cho User Story S4-04 (AC-01, AC-02, AC-03).
 */
public class LeadDuplicateService {

    private static final Logger LOGGER = Logger.getLogger(LeadDuplicateService.class.getName());

    private final LeadMergeHistoryDAO historyDAO;
    private final CustomerDAO customerDAO;

    public LeadDuplicateService() {
        this.historyDAO = new LeadMergeHistoryDAO();
        this.customerDAO = new CustomerDAO();
    }

    public LeadDuplicateService(LeadMergeHistoryDAO historyDAO, CustomerDAO customerDAO) {
        this.historyDAO = historyDAO != null ? historyDAO : new LeadMergeHistoryDAO();
        this.customerDAO = customerDAO != null ? customerDAO : new CustomerDAO();
    }

    // =========================================================================
    // 1. DATA MODELS DÀNH CHO NGHIỆP VỤ DUPLICATE & MERGE
    // =========================================================================

    public static class LeadRecord {
        private int leadId;
        private String fullName;
        private String companyName;
        private String email;
        private String phone;
        private String status;
        private Integer ownerId;
        private String ownerName;
        private Integer campaignId;
        private String campaignName;
        private Integer customerId;
        private String source;
        private Timestamp createdAt;
        private Timestamp updatedAt;

        public LeadRecord() {}

        public LeadRecord(int leadId, String fullName, String companyName, String email, String phone, String status) {
            this.leadId = leadId;
            this.fullName = fullName;
            this.companyName = companyName;
            this.email = email;
            this.phone = phone;
            this.status = status;
        }

        public int getLeadId() { return leadId; }
        public void setLeadId(int leadId) { this.leadId = leadId; }
        public String getFullName() { return fullName; }
        public void setFullName(String fullName) { this.fullName = fullName; }
        public String getCompanyName() { return companyName; }
        public void setCompanyName(String companyName) { this.companyName = companyName; }
        public String getEmail() { return email; }
        public void setEmail(String email) { this.email = email; }
        public String getPhone() { return phone; }
        public void setPhone(String phone) { this.phone = phone; }
        public String getStatus() { return status; }
        public void setStatus(String status) { this.status = status; }
        public Integer getOwnerId() { return ownerId; }
        public void setOwnerId(Integer ownerId) { this.ownerId = ownerId; }
        public String getOwnerName() { return ownerName; }
        public void setOwnerName(String ownerName) { this.ownerName = ownerName; }
        public Integer getCampaignId() { return campaignId; }
        public void setCampaignId(Integer campaignId) { this.campaignId = campaignId; }
        public String getCampaignName() { return campaignName; }
        public void setCampaignName(String campaignName) { this.campaignName = campaignName; }
        public Integer getCustomerId() { return customerId; }
        public void setCustomerId(Integer customerId) { this.customerId = customerId; }
        public String getSource() { return source; }
        public void setSource(String source) { this.source = source; }
        public Timestamp getCreatedAt() { return createdAt; }
        public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }
        public Timestamp getUpdatedAt() { return updatedAt; }
        public void setUpdatedAt(Timestamp updatedAt) { this.updatedAt = updatedAt; }
    }

    public static class LeadDuplicateCandidate {
        private LeadRecord left;
        private LeadRecord right;
        private List<String> reasons;

        public LeadDuplicateCandidate() {
            this.reasons = new ArrayList<>();
        }

        public LeadDuplicateCandidate(LeadRecord left, LeadRecord right, List<String> reasons) {
            this.left = left;
            this.right = right;
            this.reasons = reasons != null ? reasons : new ArrayList<>();
        }

        public LeadRecord getLeft() { return left; }
        public void setLeft(LeadRecord left) { this.left = left; }
        public LeadRecord getRight() { return right; }
        public void setRight(LeadRecord right) { this.right = right; }
        public List<String> getReasons() { return reasons; }
        public void setReasons(List<String> reasons) { this.reasons = reasons; }
        public String getReasonString() {
            return reasons != null ? String.join(", ", reasons) : "";
        }
    }

    public static class CustomerCandidate {
        private Customer customer;
        private List<String> reasons;

        public CustomerCandidate() {
            this.reasons = new ArrayList<>();
        }

        public CustomerCandidate(Customer customer, List<String> reasons) {
            this.customer = customer;
            this.reasons = reasons != null ? reasons : new ArrayList<>();
        }

        public Customer getCustomer() { return customer; }
        public void setCustomer(Customer customer) { this.customer = customer; }
        public List<String> getReasons() { return reasons; }
        public void setReasons(List<String> reasons) { this.reasons = reasons; }
        public String getReasonString() {
            return reasons != null ? String.join(", ", reasons) : "";
        }
    }

    // =========================================================================
    // 2. PHÁT HIỆN TRÙNG LẶP LEAD (S4-04-AC-01)
    // =========================================================================

    /**
     * Tìm tất cả các Lead trùng lặp với một Lead cụ thể theo Email, Số điện thoại và Tên công ty.
     */
    public List<LeadDuplicateCandidate> findDuplicatesForLead(int leadId) {
        LeadRecord target = findLeadById(leadId);
        if (target == null) return Collections.emptyList();

        List<LeadRecord> allLeads = getAllActiveLeads();
        List<LeadDuplicateCandidate> result = new ArrayList<>();

        for (LeadRecord other : allLeads) {
            if (other.getLeadId() == target.getLeadId()) continue;

            List<String> reasons = evaluateDuplicateReasons(target, other);
            if (!reasons.isEmpty()) {
                result.add(new LeadDuplicateCandidate(target, other, reasons));
            }
        }
        return result;
    }

    /**
     * Quét toàn bộ danh sách Lead và tìm tất cả các cặp trùng lặp.
     */
    public List<LeadDuplicateCandidate> findAllDuplicatePairs() {
        List<LeadRecord> allLeads = getAllActiveLeads();
        List<LeadDuplicateCandidate> pairs = new ArrayList<>();

        for (int i = 0; i < allLeads.size(); i++) {
            LeadRecord l1 = allLeads.get(i);
            for (int j = i + 1; j < allLeads.size(); j++) {
                LeadRecord l2 = allLeads.get(j);

                List<String> reasons = evaluateDuplicateReasons(l1, l2);
                if (!reasons.isEmpty()) {
                    pairs.add(new LeadDuplicateCandidate(l1, l2, reasons));
                }
            }
        }
        return pairs;
    }

    /**
     * Kiểm tra các tiêu chí trùng: Email, Số điện thoại và Tên công ty (S4-04-AC-01).
     */
    public List<String> evaluateDuplicateReasons(LeadRecord a, LeadRecord b) {
        List<String> reasons = new ArrayList<>();
        if (a == null || b == null) return reasons;

        // 1. Kiểm tra Email
        if (isSameEmail(a.getEmail(), b.getEmail())) {
            reasons.add("Trùng Email");
        }

        // 2. Kiểm tra Số điện thoại
        if (isSamePhone(a.getPhone(), b.getPhone())) {
            reasons.add("Trùng Số điện thoại");
        }

        // 3. Kiểm tra Tên công ty
        if (isSameCompany(a.getCompanyName(), b.getCompanyName())) {
            reasons.add("Trùng Tên công ty");
        }

        return reasons;
    }

    // =========================================================================
    // 3. GỢI Ý GẮN LEAD VÀO KHÁCH HÀNG ĐÃ CÓ (S4-04-AC-02)
    // =========================================================================

    /**
     * Tìm các Khách hàng hiện có trong hệ thống trùng với Lead theo Email, Phone, Company Name.
     */
    public List<CustomerCandidate> findMatchingCustomersForLead(int leadId) {
        LeadRecord lead = findLeadById(leadId);
        if (lead == null) return Collections.emptyList();

        List<CustomerCandidate> matches = new ArrayList<>();
        List<Customer> allCustomers = getAllCustomers();

        for (Customer c : allCustomers) {
            List<String> reasons = new ArrayList<>();

            if (isSameEmail(lead.getEmail(), c.getEmail())) {
                reasons.add("Trùng Email");
            }
            if (isSamePhone(lead.getPhone(), c.getPhone())) {
                reasons.add("Trùng Số điện thoại");
            }
            if (isSameCompany(lead.getCompanyName(), c.getCustomerName())) {
                reasons.add("Trùng Tên công ty");
            }

            if (!reasons.isEmpty()) {
                matches.add(new CustomerCandidate(c, reasons));
            }
        }
        return matches;
    }

    /**
     * Gắn thẳng Lead vào Khách hàng đã có theo S4-04-AC-02.
     */
    public boolean linkLeadToCustomer(int leadId, int customerId, int userId) {
        if (leadId <= 0 || customerId <= 0) {
            throw new IllegalArgumentException("leadId và customerId phải là số nguyên dương.");
        }

        Customer customer = customerDAO.findById(customerId);
        if (customer == null) {
            throw new IllegalArgumentException("Khách hàng không tồn tại với ID: " + customerId);
        }

        String sql = "UPDATE leads SET customer_id = ?, updated_at = CURRENT_TIMESTAMP WHERE lead_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, customerId);
            ps.setInt(2, leadId);

            int updated = ps.executeUpdate();
            if (updated > 0) {
                LOGGER.info("Gắn thành công Lead id=" + leadId + " vào Khách hàng id=" + customerId + " bởi userId=" + userId);
                return true;
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Lỗi khi gắn Lead vào Khách hàng", e);
        }
        return false;
    }

    // =========================================================================
    // 4. GỘP LEAD BẢO TOÀN LỊCH SỬ (S4-04-AC-03)
    // =========================================================================

    /**
     * Thực hiện gộp 2 Lead trong một Transaction Connection duy nhất (Atomic & Rollback an toàn).
     * Bảo toàn toàn bộ lịch sử thao tác, hoạt động và nhật ký của cả hai bản ghi.
     */
    public boolean mergeLeads(LeadMergeRequest req, int userId) {
        if (req == null) {
            throw new IllegalArgumentException("Dữ liệu yêu cầu gộp Lead không được null.");
        }
        List<String> errs = req.validate();
        if (!errs.isEmpty()) {
            throw new IllegalArgumentException(String.join("; ", errs));
        }

        int primaryId = req.getPrimaryLeadId();
        int duplicateId = req.getDuplicateLeadId();

        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            // 0. Xác minh cả 2 Lead cùng tồn tại và đang hoạt động (không bị gộp trước đó)
            LeadRecord primaryLead = findLeadByIdForUpdate(primaryId, conn);
            LeadRecord duplicateLead = findLeadByIdForUpdate(duplicateId, conn);

            if (primaryLead == null || duplicateLead == null) {
                LOGGER.warning("Không tìm thấy đủ 2 Lead để gộp: primary=" + primaryId + ", duplicate=" + duplicateId);
                conn.rollback();
                return false;
            }

            if ("MERGED".equalsIgnoreCase(primaryLead.getStatus()) || "MERGED".equalsIgnoreCase(duplicateLead.getStatus())) {
                LOGGER.warning("Một trong hai Lead đã ở trạng thái MERGED, không thể gộp lại.");
                conn.rollback();
                throw new IllegalStateException("Một trong hai Lead đã được gộp trước đó.");
            }

            // 1. Chuyển giao các hoạt động (activities) từ Lead trùng sang Lead chính để bảo toàn lịch sử
            reassignActivities(primaryId, duplicateId, conn);

            // 2. Chuyển giao chiến dịch hoặc thông tin bổ sung nếu Lead chính bị trống
            String finalName = req.getRetainedFullName() != null && !req.getRetainedFullName().trim().isEmpty()
                    ? req.getRetainedFullName().trim() : (primaryLead.getFullName() != null ? primaryLead.getFullName() : duplicateLead.getFullName());
            String finalCompany = req.getRetainedCompany() != null && !req.getRetainedCompany().trim().isEmpty()
                    ? req.getRetainedCompany().trim() : (primaryLead.getCompanyName() != null ? primaryLead.getCompanyName() : duplicateLead.getCompanyName());
            String finalEmail = req.getRetainedEmail() != null && !req.getRetainedEmail().trim().isEmpty()
                    ? req.getRetainedEmail().trim() : (primaryLead.getEmail() != null ? primaryLead.getEmail() : duplicateLead.getEmail());
            String finalPhone = req.getRetainedPhone() != null && !req.getRetainedPhone().trim().isEmpty()
                    ? req.getRetainedPhone().trim() : (primaryLead.getPhone() != null ? primaryLead.getPhone() : duplicateLead.getPhone());
            Integer finalCampaign = primaryLead.getCampaignId() != null ? primaryLead.getCampaignId() : duplicateLead.getCampaignId();
            Integer finalCustomer = primaryLead.getCustomerId() != null ? primaryLead.getCustomerId() : duplicateLead.getCustomerId();

            String updatePrimarySql = "UPDATE leads SET full_name = ?, company_name = ?, email = ?, phone = ?, " +
                    "campaign_id = ?, customer_id = ?, updated_at = CURRENT_TIMESTAMP WHERE lead_id = ?";
            try (PreparedStatement ps = conn.prepareStatement(updatePrimarySql)) {
                ps.setString(1, finalName);
                ps.setString(2, finalCompany);
                ps.setString(3, finalEmail);
                ps.setString(4, finalPhone);
                if (finalCampaign != null) ps.setInt(5, finalCampaign); else ps.setNull(5, Types.INTEGER);
                if (finalCustomer != null) ps.setInt(6, finalCustomer); else ps.setNull(6, Types.INTEGER);
                ps.setInt(7, primaryId);
                ps.executeUpdate();
            }

            // 3. Đánh dấu Lead trùng chuyển sang trạng thái 'MERGED' (giữ nguyên bản ghi trong DB để truy vết)
            String updateDuplicateSql = "UPDATE leads SET status = 'MERGED', updated_at = CURRENT_TIMESTAMP WHERE lead_id = ?";
            try (PreparedStatement ps = conn.prepareStatement(updateDuplicateSql)) {
                ps.setInt(1, duplicateId);
                ps.executeUpdate();
            }

            // 4. Ghi nhận lịch sử gộp vào lead_merge_history (S4-04-AC-03)
            String retainedSummary = String.format("{\"mergedLeadId\":%d,\"retainedName\":\"%s\",\"retainedEmail\":\"%s\",\"retainedPhone\":\"%s\"}",
                    duplicateId, escapeJson(finalName), escapeJson(finalEmail), escapeJson(finalPhone));

            LeadMergeHistory history = new LeadMergeHistory();
            history.setPrimaryLeadId(primaryId);
            history.setDuplicateLeadId(duplicateId);
            history.setMergedBy(userId);
            history.setRetainedFields(retainedSummary);
            history.setNote(req.getNote() != null ? req.getNote().trim() : "Gộp tự động qua chức năng CRM S4-04");

            int historyId = historyDAO.save(history, conn);
            if (historyId <= 0) {
                throw new SQLException("Không thể lưu lịch sử gộp Lead vào bảng lead_merge_history.");
            }

            conn.commit();
            LOGGER.info("Gộp Lead thành công: primary=" + primaryId + ", duplicate=" + duplicateId + " bởi userId=" + userId);
            return true;

        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Lỗi trong quá trình gộp Lead, đang rollback: " + e.getMessage(), e);
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException ex) {
                    LOGGER.log(Level.SEVERE, "Lỗi rollback transaction", ex);
                }
            }
            if (e instanceof IllegalStateException) {
                throw (IllegalStateException) e;
            }
            return false;
        } finally {
            if (conn != null) {
                try {
                    conn.setAutoCommit(true);
                    conn.close();
                } catch (SQLException ex) {
                    LOGGER.log(Level.SEVERE, "Lỗi đóng connection", ex);
                }
            }
        }
    }

    private void reassignActivities(int primaryId, int duplicateId, Connection conn) {
        String updateActivitiesSql = "UPDATE activities SET owner_id = owner_id WHERE 1=0"; // fallback
        try {
            // Kiểm tra xem bảng activities có cột lead_id không
            DatabaseMetaData meta = conn.getMetaData();
            try (ResultSet rs = meta.getColumns(null, null, "activities", "lead_id")) {
                if (rs.next()) {
                    updateActivitiesSql = "UPDATE activities SET lead_id = ? WHERE lead_id = ?";
                    try (PreparedStatement ps = conn.prepareStatement(updateActivitiesSql)) {
                        ps.setInt(1, primaryId);
                        ps.setInt(2, duplicateId);
                        ps.executeUpdate();
                    }
                }
            }
        } catch (SQLException ignored) {}
    }

    // =========================================================================
    // 5. HELPER DATABASE & NORMALIZATION
    // =========================================================================

    public LeadRecord findLeadById(int leadId) {
        String sql = "SELECT l.*, u.full_name AS owner_name, c.campaign_name FROM leads l " +
                "LEFT JOIN users u ON l.owner_id = u.user_id " +
                "LEFT JOIN campaigns c ON l.campaign_id = c.campaign_id " +
                "WHERE l.lead_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, leadId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapLeadRow(rs);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Lỗi tìm Lead id=" + leadId, e);
        }
        return null;
    }

    private LeadRecord findLeadByIdForUpdate(int leadId, Connection conn) throws SQLException {
        String sql = "SELECT l.*, u.full_name AS owner_name, c.campaign_name FROM leads l " +
                "LEFT JOIN users u ON l.owner_id = u.user_id " +
                "LEFT JOIN campaigns c ON l.campaign_id = c.campaign_id " +
                "WHERE l.lead_id = ? FOR UPDATE";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, leadId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapLeadRow(rs);
            }
        }
        return null;
    }

    private List<LeadRecord> getAllActiveLeads() {
        List<LeadRecord> list = new ArrayList<>();
        String sql = "SELECT l.*, u.full_name AS owner_name, c.campaign_name FROM leads l " +
                "LEFT JOIN users u ON l.owner_id = u.user_id " +
                "LEFT JOIN campaigns c ON l.campaign_id = c.campaign_id " +
                "WHERE l.status IS NULL OR l.status != 'MERGED' " +
                "ORDER BY l.lead_id ASC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapLeadRow(rs));
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Lỗi lấy danh sách Lead", e);
        }
        return list;
    }

    private List<Customer> getAllCustomers() {
        List<Customer> list = new ArrayList<>();
        String sql = "SELECT customer_id, customer_name, phone, email, owner_id FROM customers ORDER BY customer_id ASC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Customer c = new Customer();
                c.setCustomerId(rs.getInt("customer_id"));
                c.setCustomerName(rs.getString("customer_name"));
                c.setPhone(rs.getString("phone"));
                c.setEmail(rs.getString("email"));
                c.setOwnerId(rs.getInt("owner_id"));
                list.add(c);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Lỗi lấy danh sách Khách hàng", e);
        }
        return list;
    }

    private LeadRecord mapLeadRow(ResultSet rs) throws SQLException {
        LeadRecord l = new LeadRecord();
        l.setLeadId(rs.getInt("lead_id"));
        l.setFullName(rs.getString("full_name"));
        l.setCompanyName(rs.getString("company_name"));
        l.setEmail(rs.getString("email"));
        l.setPhone(rs.getString("phone"));
        l.setStatus(rs.getString("status"));
        l.setOwnerId(rs.getObject("owner_id") != null ? rs.getInt("owner_id") : null);
        try { l.setOwnerName(rs.getString("owner_name")); } catch (SQLException ignored) {}
        l.setCampaignId(rs.getObject("campaign_id") != null ? rs.getInt("campaign_id") : null);
        try { l.setCampaignName(rs.getString("campaign_name")); } catch (SQLException ignored) {}
        l.setCustomerId(rs.getObject("customer_id") != null ? rs.getInt("customer_id") : null);
        try { l.setSource(rs.getString("source")); } catch (SQLException ignored) {}
        l.setCreatedAt(rs.getTimestamp("created_at"));
        l.setUpdatedAt(rs.getTimestamp("updated_at"));
        return l;
    }

    // =========================================================================
    // 6. THUẬT TOÁN CHUẨN HÓA VÀ SO KHỚP CHUỖI
    // =========================================================================

    public boolean isSameEmail(String e1, String e2) {
        if (e1 == null || e2 == null) return false;
        String s1 = e1.trim().toLowerCase();
        String s2 = e2.trim().toLowerCase();
        return !s1.isEmpty() && !s2.isEmpty() && s1.equals(s2);
    }

    public boolean isSamePhone(String p1, String p2) {
        if (p1 == null || p2 == null) return false;
        String norm1 = normalizePhone(p1);
        String norm2 = normalizePhone(p2);
        return !norm1.isEmpty() && !norm2.isEmpty() && norm1.equals(norm2);
    }

    public String normalizePhone(String phone) {
        if (phone == null) return "";
        String p = phone.replaceAll("[^0-9]", "");
        if (p.startsWith("84") && p.length() > 9) {
            p = "0" + p.substring(2);
        }
        return p;
    }

    public boolean isSameCompany(String c1, String c2) {
        if (c1 == null || c2 == null) return false;
        String raw1 = c1.trim();
        String raw2 = c2.trim();
        if (raw1.isEmpty() || raw2.isEmpty()) return false;
        if (raw1.equalsIgnoreCase(raw2)) return true;

        String norm1 = normalizeCompanyName(raw1);
        String norm2 = normalizeCompanyName(raw2);
        if (norm1.isEmpty() || norm2.isEmpty()) return false;
        if (norm1.equals(norm2)) return true;

        if (norm1.length() >= 4 && norm2.length() >= 4) {
            if (norm1.contains(norm2) || norm2.contains(norm1)) return true;
        }
        return false;
    }

    public String normalizeCompanyName(String name) {
        if (name == null) return "";
        String s = name.trim().toLowerCase();
        s = s.replaceAll("[.,\\-()\\[\\]\\\"\\']", " ");

        String[] stopWords = {
                "công ty tnhh tm dv", "công ty tnhh tm", "công ty tnhh", "công ty cổ phần", "công ty cp", "công ty", "cty tnhh", "cty cp", "cty",
                "tnhh tm dv", "tnhh tm", "tnhh", "cổ phần", "cp",
                "co., ltd", "co. ltd", "co ltd", "ltd", "inc", "corp", "corporation", "gmbh", "pvt ltd"
        };
        for (String sw : stopWords) {
            s = s.replace(sw, " ");
        }
        return s.replaceAll("\\s+", " ").trim();
    }

    private String escapeJson(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", "\\n").replace("\r", "\\r");
    }
}

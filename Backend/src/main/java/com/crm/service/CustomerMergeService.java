package com.crm.service;
import com.crm.model.Customer;
import com.crm.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

public class CustomerMergeService {

    private static final Logger LOGGER = Logger.getLogger(CustomerMergeService.class.getName());

    public List<Customer> findDuplicates() {
        List<com.crm.dto.DuplicateCandidate> pairs = findDuplicatePairs();
        List<Customer> list = new ArrayList<>();
        java.util.Set<Integer> addedIds = new java.util.HashSet<>();
        for (com.crm.dto.DuplicateCandidate pair : pairs) {
            if (pair.getLeft() != null && addedIds.add(pair.getLeft().getCustomerId())) {
                list.add(pair.getLeft());
            }
            if (pair.getRight() != null && addedIds.add(pair.getRight().getCustomerId())) {
                list.add(pair.getRight());
            }
        }
        return list;
    }

    public List<com.crm.dto.DuplicateCandidate> findDuplicatePairs() {
        List<Customer> allCustomers = getAllCustomersForDuplicateCheck();
        List<com.crm.dto.DuplicateCandidate> candidates = new ArrayList<>();

        for (int i = 0; i < allCustomers.size(); i++) {
            Customer c1 = allCustomers.get(i);
            for (int j = i + 1; j < allCustomers.size(); j++) {
                Customer c2 = allCustomers.get(j);

                if (c1.getCustomerId() == c2.getCustomerId()) continue;

                List<String> reasons = new ArrayList<>();

                // A. Check Tax Code
                if (isSameTaxCode(c1.getTaxCode(), c2.getTaxCode())) {
                    reasons.add("Mã số thuế");
                }

                // B. Check Website
                if (isSameWebsite(c1.getWebsite(), c2.getWebsite())) {
                    reasons.add("Website");
                }

                // C. Check Name Similarity
                if (isSimilarName(c1.getCustomerName(), c2.getCustomerName())) {
                    reasons.add("Tên gần giống");
                }

                if (!reasons.isEmpty()) {
                    String reasonStr = String.join(", ", reasons);
                    candidates.add(new com.crm.dto.DuplicateCandidate(c1, c2, reasonStr));
                }
            }
        }
        return candidates;
    }

    private List<Customer> getAllCustomersForDuplicateCheck() {
        List<Customer> list = new ArrayList<>();
        String sql = "SELECT c.*, u.full_name AS owner_name FROM customers c LEFT JOIN users u ON c.owner_id = u.user_id ORDER BY c.customer_id ASC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Customer c = new Customer();
                c.setCustomerId(rs.getInt("customer_id"));
                c.setCustomerName(rs.getString("customer_name"));
                c.setPhone(rs.getString("phone"));
                c.setOwnerId(rs.getInt("owner_id"));
                try { c.setOwnerName(rs.getString("owner_name")); } catch (SQLException ignored) {}
                try { c.setEmail(rs.getString("email")); } catch (SQLException ignored) {}
                try { c.setTaxCode(rs.getString("tax_code")); } catch (SQLException ignored) {}
                try { c.setWebsite(rs.getString("website")); } catch (SQLException ignored) {}
                try { c.setStatus(rs.getString("status")); } catch (SQLException ignored) {}
                c.setCreatedAt(rs.getTimestamp("created_at"));
                list.add(c);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Lỗi lấy danh sách khách hàng để tìm trùng lặp", e);
        }
        return list;
    }

    private boolean isSameTaxCode(String tax1, String tax2) {
        if (tax1 == null || tax2 == null) return false;
        String t1 = tax1.trim();
        String t2 = tax2.trim();
        if (t1.isEmpty() || t2.isEmpty()) return false;
        return t1.equalsIgnoreCase(t2);
    }

    private boolean isSameWebsite(String web1, String web2) {
        if (web1 == null || web2 == null) return false;
        String w1 = normalizeWebsite(web1);
        String w2 = normalizeWebsite(web2);
        if (w1.isEmpty() || w2.isEmpty()) return false;
        return w1.equalsIgnoreCase(w2);
    }

    private String normalizeWebsite(String url) {
        if (url == null) return "";
        String s = url.trim().toLowerCase();
        s = s.replaceFirst("^https?://", "");
        s = s.replaceFirst("^www\\.", "");
        if (s.endsWith("/")) {
            s = s.substring(0, s.length() - 1);
        }
        return s.trim();
    }

    private boolean isSimilarName(String name1, String name2) {
        if (name1 == null || name2 == null) return false;
        String raw1 = name1.trim();
        String raw2 = name2.trim();
        if (raw1.isEmpty() || raw2.isEmpty()) return false;
        if (raw1.equalsIgnoreCase(raw2)) return true;

        String norm1 = normalizeName(raw1);
        String norm2 = normalizeName(raw2);
        if (norm1.isEmpty() || norm2.isEmpty()) return false;
        if (norm1.equals(norm2)) return true;

        if (norm1.length() >= 4 && norm2.length() >= 4) {
            if (norm1.contains(norm2) || norm2.contains(norm1)) return true;
        }

        return false;
    }

    private String normalizeName(String name) {
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

    public boolean mergeCustomers(int primaryId, int secondaryId, int mergedBy) {
        if (primaryId <= 0 || secondaryId <= 0 || primaryId == secondaryId) {
            return false;
        }

        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            // 0. Verify both customers exist
            String checkSql = "SELECT customer_id, customer_name, phone, email, tax_code FROM customers WHERE customer_id IN (?, ?)";
            int foundCount = 0;
            String secondaryName = "";
            try (PreparedStatement psCheck = conn.prepareStatement(checkSql)) {
                psCheck.setInt(1, primaryId);
                psCheck.setInt(2, secondaryId);
                try (ResultSet rs = psCheck.executeQuery()) {
                    while (rs.next()) {
                        foundCount++;
                        if (rs.getInt("customer_id") == secondaryId) {
                            secondaryName = rs.getString("customer_name");
                        }
                    }
                }
            }

            if (foundCount < 2) {
                LOGGER.warning("Không tìm thấy đủ 2 khách hàng để gộp: primary=" + primaryId + ", secondary=" + secondaryId);
                conn.rollback();
                return false;
            }

            // 1. Reassign contacts (critical FK dependency)
            String updateContacts = "UPDATE contacts SET customer_id = ? WHERE customer_id = ?";
            try (PreparedStatement ps = conn.prepareStatement(updateContacts)) {
                ps.setInt(1, primaryId);
                ps.setInt(2, secondaryId);
                ps.executeUpdate();
            }

            // 2. Reassign attachments (critical FK dependency)
            String updateAttachments = "UPDATE attachments SET customer_id = ? WHERE customer_id = ?";
            try (PreparedStatement ps = conn.prepareStatement(updateAttachments)) {
                ps.setInt(1, primaryId);
                ps.setInt(2, secondaryId);
                ps.executeUpdate();
            }

            // 3. Reassign custom_field_values
            String updateCf = "UPDATE IGNORE custom_field_values SET entity_id = ? WHERE entity_type = 'CUSTOMER' AND entity_id = ?";
            try (PreparedStatement ps = conn.prepareStatement(updateCf)) {
                ps.setInt(1, primaryId);
                ps.setInt(2, secondaryId);
                ps.executeUpdate();
            }
            String deleteRemainingCf = "DELETE FROM custom_field_values WHERE entity_type = 'CUSTOMER' AND entity_id = ?";
            try (PreparedStatement ps = conn.prepareStatement(deleteRemainingCf)) {
                ps.setInt(1, secondaryId);
                ps.executeUpdate();
            }

            // 4. Reassign customer_relationships (parent)
            String updateRelParent = "UPDATE IGNORE customer_relationships SET parent_customer_id = ? WHERE parent_customer_id = ?";
            try (PreparedStatement ps = conn.prepareStatement(updateRelParent)) {
                ps.setInt(1, primaryId);
                ps.setInt(2, secondaryId);
                ps.executeUpdate();
            }

            // 5. Reassign customer_relationships (child)
            String updateRelChild = "UPDATE IGNORE customer_relationships SET child_customer_id = ? WHERE child_customer_id = ?";
            try (PreparedStatement ps = conn.prepareStatement(updateRelChild)) {
                ps.setInt(1, primaryId);
                ps.setInt(2, secondaryId);
                ps.executeUpdate();
            }

            String deleteRelOrphan = "DELETE FROM customer_relationships WHERE parent_customer_id = ? OR child_customer_id = ?";
            try (PreparedStatement ps = conn.prepareStatement(deleteRelOrphan)) {
                ps.setInt(1, secondaryId);
                ps.setInt(2, secondaryId);
                ps.executeUpdate();
            }

            // 6. Reassign contact_company_history
            String updateHistFrom = "UPDATE IGNORE contact_company_history SET from_customer_id = ? WHERE from_customer_id = ?";
            try (PreparedStatement ps = conn.prepareStatement(updateHistFrom)) {
                ps.setInt(1, primaryId);
                ps.setInt(2, secondaryId);
                ps.executeUpdate();
            }
            String updateHistTo = "UPDATE IGNORE contact_company_history SET to_customer_id = ? WHERE to_customer_id = ?";
            try (PreparedStatement ps = conn.prepareStatement(updateHistTo)) {
                ps.setInt(1, primaryId);
                ps.setInt(2, secondaryId);
                ps.executeUpdate();
            }

            // 7. Reassign support_requests
            String updateSupport = "UPDATE IGNORE support_requests SET customer_id = ? WHERE customer_id = ?";
            try (PreparedStatement ps = conn.prepareStatement(updateSupport)) {
                ps.setInt(1, primaryId);
                ps.setInt(2, secondaryId);
                ps.executeUpdate();
            }

            // 8. Reassign customer_care
            String updateCare = "UPDATE IGNORE customer_care SET customer_id = ? WHERE customer_id = ?";
            try (PreparedStatement ps = conn.prepareStatement(updateCare)) {
                ps.setInt(1, primaryId);
                ps.setInt(2, secondaryId);
                ps.executeUpdate();
            }

            // 9. Reassign opportunities
            String updateOpps = "UPDATE IGNORE opportunities SET customer_id = ? WHERE customer_id = ?";
            try (PreparedStatement ps = conn.prepareStatement(updateOpps)) {
                ps.setInt(1, primaryId);
                ps.setInt(2, secondaryId);
                ps.executeUpdate();
            }

            // 10. Reassign activities
            String updateActs = "UPDATE IGNORE activities SET customer_id = ? WHERE customer_id = ?";
            try (PreparedStatement ps = conn.prepareStatement(updateActs)) {
                ps.setInt(1, primaryId);
                ps.setInt(2, secondaryId);
                ps.executeUpdate();
            }

            // 11. Log merge audit into customer_merges
            String logSql = "INSERT INTO customer_merges(primary_customer_id, secondary_customer_id, merged_data, merged_by) VALUES (?, ?, ?, ?)";
            try (PreparedStatement ps = conn.prepareStatement(logSql)) {
                ps.setInt(1, primaryId);
                ps.setInt(2, secondaryId);
                ps.setString(3, "{\"secondaryName\":\"" + secondaryName.replace("\"", "\\\"") + "\", \"note\":\"Merged via System S30-05\"}");
                ps.setInt(4, mergedBy);
                ps.executeUpdate();
            }

            // 12. Delete secondary customer
            String deleteSql = "DELETE FROM customers WHERE customer_id = ?";
            try (PreparedStatement ps = conn.prepareStatement(deleteSql)) {
                ps.setInt(1, secondaryId);
                ps.executeUpdate();
            }

            conn.commit();
            LOGGER.info("Gộp khách hàng thành công: primary=" + primaryId + ", secondary=" + secondaryId + " bởi userId=" + mergedBy);
            return true;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Lỗi khi gộp khách hàng primary=" + primaryId + ", secondary=" + secondaryId, e);
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException ex) {
                    LOGGER.log(Level.SEVERE, "Lỗi rollback transaction gộp khách hàng", ex);
                }
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
}

package com.crm.dao;

import com.crm.dto.CustomerFilterRequest;
import com.crm.model.Customer;
import com.crm.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class CustomerDAO {

    public CustomerDAO() {
        ensureSchema();
    }

    private void ensureSchema() {
        String alterSql = "ALTER TABLE customers " +
                "ADD COLUMN IF NOT EXISTS tax_code VARCHAR(50), " +
                "ADD COLUMN IF NOT EXISTS email VARCHAR(150), " +
                "ADD COLUMN IF NOT EXISTS status VARCHAR(50) DEFAULT 'ACTIVE', " +
                "ADD COLUMN IF NOT EXISTS industry VARCHAR(100), " +
                "ADD COLUMN IF NOT EXISTS company_size VARCHAR(50), " +
                "ADD COLUMN IF NOT EXISTS region VARCHAR(100), " +
                "ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP;";

        String contactsSql = "CREATE TABLE IF NOT EXISTS contacts (" +
                "contact_id INT AUTO_INCREMENT PRIMARY KEY, " +
                "customer_id INT NOT NULL, " +
                "contact_name VARCHAR(100) NOT NULL, " +
                "phone VARCHAR(20), " +
                "email VARCHAR(150), " +
                "position VARCHAR(100), " +
                "is_primary TINYINT(1) DEFAULT 0, " +
                "created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, " +
                "FOREIGN KEY (customer_id) REFERENCES customers(customer_id) ON DELETE CASCADE" +
                ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;";

        String attachmentsSql = "CREATE TABLE IF NOT EXISTS attachments (" +
                "attachment_id INT AUTO_INCREMENT PRIMARY KEY, " +
                "customer_id INT NOT NULL, " +
                "file_name VARCHAR(255) NOT NULL, " +
                "file_path VARCHAR(500) NOT NULL, " +
                "file_size BIGINT DEFAULT 0, " +
                "uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, " +
                "FOREIGN KEY (customer_id) REFERENCES customers(customer_id) ON DELETE CASCADE" +
                ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;";

        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement()) {
            try { stmt.executeUpdate(alterSql); } catch (SQLException ignored) {}
            try { stmt.executeUpdate(contactsSql); } catch (SQLException ignored) {}
            try { stmt.executeUpdate(attachmentsSql); } catch (SQLException ignored) {}
        } catch (SQLException e) {
            // DB connection might be unavailable during certain static initialization or test contexts
        }
    }

    private Customer mapResultSetToCustomer(ResultSet rs) throws SQLException {
        Customer obj = new Customer();
        obj.setCustomerid(rs.getInt("customer_id"));
        obj.setCustomername(rs.getString("customer_name"));
        obj.setPhone(rs.getString("phone"));
        obj.setOwnerId(rs.getInt("owner_id"));
        obj.setCreatedAt(rs.getTimestamp("created_at"));

        try { obj.setTaxCode(rs.getString("tax_code")); } catch (SQLException ignored) {}
        try { obj.setEmail(rs.getString("email")); } catch (SQLException ignored) {}
        try { obj.setStatus(rs.getString("status")); } catch (SQLException ignored) {}
        try { obj.setIndustry(rs.getString("industry")); } catch (SQLException ignored) {}
        try { obj.setCompanySize(rs.getString("company_size")); } catch (SQLException ignored) {}
        try { obj.setRegion(rs.getString("region")); } catch (SQLException ignored) {}
        try { obj.setUpdatedAt(rs.getTimestamp("updated_at")); } catch (SQLException ignored) {}

        return obj;
    }

    public List<Customer> getList(String keyword, List<Integer> ownerIds, int page, int pageSize) {
        CustomerFilterRequest req = new CustomerFilterRequest();
        req.setKeyword(keyword);
        req.setPage(page);
        req.setPageSize(pageSize);
        return getList(req, ownerIds);
    }

    public List<Customer> getList(CustomerFilterRequest filterReq, List<Integer> ownerIds) {
        if (ownerIds != null && ownerIds.isEmpty()) return new ArrayList<>();

        List<Customer> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder("SELECT * FROM customers WHERE 1=1");
        List<Object> params = new ArrayList<>();

        buildFilterWhereClause(sql, params, filterReq, ownerIds);

        sql.append(" ORDER BY customer_id DESC LIMIT ? OFFSET ?");
        params.add(filterReq.getPageSize());
        params.add((filterReq.getPage() - 1) * filterReq.getPageSize());

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }

            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                list.add(mapResultSetToCustomer(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public int count(String keyword, List<Integer> ownerIds) {
        CustomerFilterRequest req = new CustomerFilterRequest();
        req.setKeyword(keyword);
        return count(req, ownerIds);
    }

    public int count(CustomerFilterRequest filterReq, List<Integer> ownerIds) {
        if (ownerIds != null && ownerIds.isEmpty()) return 0;

        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM customers WHERE 1=1");
        List<Object> params = new ArrayList<>();

        buildFilterWhereClause(sql, params, filterReq, ownerIds);

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    private void buildFilterWhereClause(StringBuilder sql, List<Object> params, CustomerFilterRequest req, List<Integer> ownerIds) {
        if (req != null) {
            String kw = req.getKeyword();
            if (kw != null && !kw.trim().isEmpty()) {
                String term = "%" + kw.trim() + "%";
                sql.append(" AND (customer_name LIKE ? OR phone LIKE ?");
                params.add(term);
                params.add(term);

                try {
                    sql.append(" OR tax_code LIKE ?");
                    params.add(term);
                } catch (Exception ignored) {}

                sql.append(" OR customer_id IN (SELECT customer_id FROM contacts WHERE phone LIKE ? OR contact_name LIKE ?))");
                params.add(term);
                params.add(term);
            }

            if (req.getStatus() != null && !req.getStatus().trim().isEmpty()) {
                sql.append(" AND status = ?");
                params.add(req.getStatus().trim());
            }

            if (req.getIndustry() != null && !req.getIndustry().trim().isEmpty()) {
                sql.append(" AND industry = ?");
                params.add(req.getIndustry().trim());
            }

            if (req.getCompanySize() != null && !req.getCompanySize().trim().isEmpty()) {
                sql.append(" AND company_size = ?");
                params.add(req.getCompanySize().trim());
            }

            if (req.getRegion() != null && !req.getRegion().trim().isEmpty()) {
                sql.append(" AND region = ?");
                params.add(req.getRegion().trim());
            }

            if (req.getOwnerId() != null && req.getOwnerId() > 0) {
                sql.append(" AND owner_id = ?");
                params.add(req.getOwnerId());
            }
        }

        if (ownerIds != null) {
            String inClause = String.join(",", java.util.Collections.nCopies(ownerIds.size(), "?"));
            sql.append(" AND owner_id IN (").append(inClause).append(")");
            params.addAll(ownerIds);
        }
    }

    public List<Customer> getListForExport(String keyword, List<Integer> ownerIds) {
        CustomerFilterRequest req = new CustomerFilterRequest();
        req.setKeyword(keyword);
        req.setPageSize(100000);
        return getList(req, ownerIds);
    }

    public Customer findById(int id) {
        String sql = "SELECT * FROM customers WHERE customer_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return mapResultSetToCustomer(rs);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public List<Map<String, Object>> getContactsByCustomerId(int customerId) {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT * FROM contacts WHERE customer_id = ? ORDER BY is_primary DESC, contact_id ASC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, customerId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Map<String, Object> map = new HashMap<>();
                map.put("contactId", rs.getInt("contact_id"));
                map.put("customerId", rs.getInt("customer_id"));
                map.put("contactName", rs.getString("contact_name"));
                map.put("phone", rs.getString("phone"));
                map.put("email", rs.getString("email"));
                map.put("position", rs.getString("position"));
                map.put("isPrimary", rs.getBoolean("is_primary"));
                map.put("createdAt", rs.getTimestamp("created_at"));
                list.add(map);
            }
        } catch (SQLException e) {
            // Table might be missing or empty
        }
        return list;
    }

    public List<Map<String, Object>> getAttachmentsByCustomerId(int customerId) {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT * FROM attachments WHERE customer_id = ? ORDER BY attachment_id DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, customerId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Map<String, Object> map = new HashMap<>();
                map.put("attachmentId", rs.getInt("attachment_id"));
                map.put("customerId", rs.getInt("customer_id"));
                map.put("fileName", rs.getString("file_name"));
                map.put("filePath", rs.getString("file_path"));
                map.put("fileSize", rs.getLong("file_size"));
                map.put("uploadedAt", rs.getTimestamp("uploaded_at"));
                list.add(map);
            }
        } catch (SQLException e) {
            // Table might be missing or empty
        }
        return list;
    }
}

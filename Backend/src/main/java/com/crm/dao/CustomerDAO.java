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
                "ADD COLUMN IF NOT EXISTS size VARCHAR(50), " +
                "ADD COLUMN IF NOT EXISTS website VARCHAR(255), " +
                "ADD COLUMN IF NOT EXISTS address TEXT, " +
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

        try { obj.setTaxCode(rs.getString("tax_code")); } catch (SQLException ignored) {}
        try { obj.setEmail(rs.getString("email")); } catch (SQLException ignored) {}
        try { obj.setStatus(rs.getString("status")); } catch (SQLException ignored) {}
        try { obj.setIndustry(rs.getString("industry")); } catch (SQLException ignored) {}
        try { obj.setCompanySize(rs.getString("company_size")); } catch (SQLException ignored) {}
        try {
            String sz = rs.getString("size");
            if (sz != null && !sz.isEmpty()) obj.setSize(sz);
        } catch (SQLException ignored) {}
        try { obj.setWebsite(rs.getString("website")); } catch (SQLException ignored) {}
        try { obj.setAddress(rs.getString("address")); } catch (SQLException ignored) {}
        try { obj.setRegion(rs.getString("region")); } catch (SQLException ignored) {}
        obj.setOwnerId(rs.getInt("owner_id"));
        obj.setCreatedAt(rs.getTimestamp("created_at"));
        try { obj.setUpdatedAt(rs.getTimestamp("updated_at")); } catch (SQLException ignored) {}

        return obj;
    }

    public List<Customer> getList(String keyword, List<Integer> ownerIds, int page, int pageSize) {
        return getList(keyword, ownerIds, null, null, page, pageSize);
    }

    public List<Customer> getList(String keyword, List<Integer> ownerIds, Integer filterFieldId, String filterFieldValue, int page, int pageSize) {
        CustomerFilterRequest req = new CustomerFilterRequest();
        req.setKeyword(keyword);
        req.setFilterFieldId(filterFieldId);
        req.setFilterFieldValue(filterFieldValue);
        req.setPage(page);
        req.setPageSize(pageSize);
        return getList(req, ownerIds);
    }

    public List<Customer> getList(CustomerFilterRequest filterReq, List<Integer> ownerIds) {
        if (ownerIds != null && ownerIds.isEmpty()) return new ArrayList<>();

        List<Customer> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder();
        boolean hasCustomField = filterReq != null && filterReq.getFilterFieldId() != null 
                && filterReq.getFilterFieldValue() != null && !filterReq.getFilterFieldValue().trim().isEmpty();

        if (hasCustomField) {
            sql.append("SELECT DISTINCT c.* FROM customers c ");
            sql.append("JOIN custom_field_values cfv ON c.customer_id = cfv.entity_id AND cfv.entity_type = 'CUSTOMER' ");
        } else {
            sql.append("SELECT DISTINCT c.* FROM customers c ");
        }
        sql.append("WHERE 1=1");

        List<Object> params = new ArrayList<>();
        buildFilterWhereClause(sql, params, filterReq, ownerIds);

        int page = (filterReq != null) ? filterReq.getPage() : 1;
        int pageSize = (filterReq != null) ? filterReq.getPageSize() : 20;

        sql.append(" ORDER BY c.customer_id DESC LIMIT ? OFFSET ?");
        params.add(pageSize);
        params.add((page - 1) * pageSize);

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
        return count(keyword, ownerIds, null, null);
    }

    public int count(String keyword, List<Integer> ownerIds, Integer filterFieldId, String filterFieldValue) {
        CustomerFilterRequest req = new CustomerFilterRequest();
        req.setKeyword(keyword);
        req.setFilterFieldId(filterFieldId);
        req.setFilterFieldValue(filterFieldValue);
        return count(req, ownerIds);
    }

    public int count(CustomerFilterRequest filterReq, List<Integer> ownerIds) {
        if (ownerIds != null && ownerIds.isEmpty()) return 0;

        StringBuilder sql = new StringBuilder();
        boolean hasCustomField = filterReq != null && filterReq.getFilterFieldId() != null 
                && filterReq.getFilterFieldValue() != null && !filterReq.getFilterFieldValue().trim().isEmpty();

        if (hasCustomField) {
            sql.append("SELECT COUNT(DISTINCT c.customer_id) FROM customers c ");
            sql.append("JOIN custom_field_values cfv ON c.customer_id = cfv.entity_id AND cfv.entity_type = 'CUSTOMER' ");
        } else {
            sql.append("SELECT COUNT(DISTINCT c.customer_id) FROM customers c ");
        }
        sql.append("WHERE 1=1");

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
                sql.append(" AND (c.customer_name LIKE ? OR c.phone LIKE ?");
                params.add(term);
                params.add(term);

                try {
                    sql.append(" OR c.tax_code LIKE ?");
                    params.add(term);
                } catch (Exception ignored) {}

                sql.append(" OR c.customer_id IN (SELECT customer_id FROM contacts WHERE phone LIKE ? OR contact_name LIKE ?))");
                params.add(term);
                params.add(term);
            }

            if (req.getStatus() != null && !req.getStatus().trim().isEmpty()) {
                sql.append(" AND c.status = ?");
                params.add(req.getStatus().trim());
            }

            if (req.getIndustry() != null && !req.getIndustry().trim().isEmpty()) {
                sql.append(" AND c.industry = ?");
                params.add(req.getIndustry().trim());
            }

            if (req.getCompanySize() != null && !req.getCompanySize().trim().isEmpty()) {
                sql.append(" AND c.company_size = ?");
                params.add(req.getCompanySize().trim());
            }

            if (req.getRegion() != null && !req.getRegion().trim().isEmpty()) {
                sql.append(" AND c.region = ?");
                params.add(req.getRegion().trim());
            }

            if (req.getOwnerId() != null && req.getOwnerId() > 0) {
                sql.append(" AND c.owner_id = ?");
                params.add(req.getOwnerId());
            }

            if (req.getFilterFieldId() != null && req.getFilterFieldValue() != null && !req.getFilterFieldValue().trim().isEmpty()) {
                sql.append(" AND cfv.field_id = ? AND cfv.field_value LIKE ?");
                params.add(req.getFilterFieldId());
                params.add("%" + req.getFilterFieldValue().trim() + "%");
            }
        }

        if (ownerIds != null) {
            String inClause = String.join(",", java.util.Collections.nCopies(ownerIds.size(), "?"));
            sql.append(" AND c.owner_id IN (").append(inClause).append(")");
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

    public boolean isTaxCodeExists(String taxCode, Integer excludeCustomerId) {
        if (taxCode == null || taxCode.trim().isEmpty()) {
            return false;
        }
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM customers WHERE LOWER(TRIM(tax_code)) = LOWER(TRIM(?))");
        if (excludeCustomerId != null && excludeCustomerId > 0) {
            sql.append(" AND customer_id != ?");
        }
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            ps.setString(1, taxCode.trim());
            if (excludeCustomerId != null && excludeCustomerId > 0) {
                ps.setInt(2, excludeCustomerId);
            }
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1) > 0;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public Customer findDuplicateCustomer(String taxCode, String phone, String customerName) {
        List<String> conditions = new ArrayList<>();
        List<Object> params = new ArrayList<>();

        if (taxCode != null && !taxCode.trim().isEmpty()) {
            conditions.add("tax_code = ?");
            params.add(taxCode.trim());
        }
        if (phone != null && !phone.trim().isEmpty()) {
            conditions.add("phone = ?");
            params.add(phone.trim());
        }
        if (customerName != null && !customerName.trim().isEmpty()) {
            conditions.add("customer_name = ?");
            params.add(customerName.trim());
        }

        if (conditions.isEmpty()) {
            return null;
        }

        String sql = "SELECT * FROM customers WHERE " + String.join(" OR ", conditions) + " LIMIT 1";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return mapResultSetToCustomer(rs);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public boolean insert(Customer customer) {
        String sql = "INSERT INTO customers (customer_name, phone, tax_code, industry, size, website, address, status, owner_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, customer.getCustomerName());
            ps.setString(2, customer.getPhone());
            ps.setString(3, (customer.getTaxCode() != null && !customer.getTaxCode().trim().isEmpty()) ? customer.getTaxCode().trim() : null);
            ps.setString(4, customer.getIndustry());
            ps.setString(5, customer.getSize());
            ps.setString(6, customer.getWebsite());
            ps.setString(7, customer.getAddress());
            ps.setString(8, (customer.getStatus() != null && !customer.getStatus().trim().isEmpty()) ? customer.getStatus().trim() : "ACTIVE");
            ps.setInt(9, customer.getOwnerId());
            int rows = ps.executeUpdate();
            if (rows > 0) {
                try (ResultSet keys = ps.getGeneratedKeys()) {
                    if (keys.next()) {
                        customer.setCustomerId(keys.getInt(1));
                    }
                }
                return true;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean insertCustomer(Customer customer) {
        return insert(customer);
    }

    public boolean update(Customer customer) {
        String sql = "UPDATE customers SET customer_name = ?, phone = ?, tax_code = ?, industry = ?, size = ?, website = ?, address = ?, status = ?, owner_id = ? WHERE customer_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, customer.getCustomerName());
            ps.setString(2, customer.getPhone());
            ps.setString(3, (customer.getTaxCode() != null && !customer.getTaxCode().trim().isEmpty()) ? customer.getTaxCode().trim() : null);
            ps.setString(4, customer.getIndustry());
            ps.setString(5, customer.getSize());
            ps.setString(6, customer.getWebsite());
            ps.setString(7, customer.getAddress());
            ps.setString(8, (customer.getStatus() != null && !customer.getStatus().trim().isEmpty()) ? customer.getStatus().trim() : "ACTIVE");
            ps.setInt(9, customer.getOwnerId());
            ps.setInt(10, customer.getCustomerId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean updateCustomer(Customer customer) {
        return update(customer);
    }

    public boolean delete(int customerId) {
        String sql = "DELETE FROM customers WHERE customer_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, customerId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
}

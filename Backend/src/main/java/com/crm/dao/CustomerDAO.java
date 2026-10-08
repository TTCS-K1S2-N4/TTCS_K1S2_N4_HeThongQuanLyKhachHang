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

    private static final java.util.logging.Logger LOGGER = java.util.logging.Logger.getLogger(CustomerDAO.class.getName());

    public CustomerDAO() {
        ensureSchema();
    }

    private void ensureSchema() {
        try (Connection conn = DBConnection.getConnection()) {
            if (conn == null) return;

            ensureColumnExists(conn, "tax_code", "VARCHAR(50)");
            ensureColumnExists(conn, "email", "VARCHAR(150)");
            ensureColumnExists(conn, "status", "VARCHAR(50) DEFAULT 'Tiềm năng'");
            ensureColumnExists(conn, "industry", "VARCHAR(100)");
            ensureColumnExists(conn, "company_size", "VARCHAR(50)");
            ensureColumnExists(conn, "size", "VARCHAR(50)");
            ensureColumnExists(conn, "website", "VARCHAR(255)");
            ensureColumnExists(conn, "address", "TEXT");
            ensureColumnExists(conn, "region", "VARCHAR(100)");
            ensureColumnExists(conn, "updated_at", "TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP");

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

            try (Statement stmt = conn.createStatement()) {
                stmt.executeUpdate(contactsSql);
                stmt.executeUpdate(attachmentsSql);
            }
            healCorruptedData(conn);
        } catch (SQLException e) {
            LOGGER.log(java.util.logging.Level.SEVERE, "Lỗi kiểm tra/khởi tạo schema cho bảng customers: " + e.getMessage(), e);
        }
    }

    private void healCorruptedData(Connection conn) {
        try (Statement stmt = conn.createStatement()) {
            stmt.executeUpdate("ALTER TABLE users CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci");
            stmt.executeUpdate("ALTER TABLE customers CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci");
            stmt.executeUpdate("ALTER TABLE teams CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci");

            stmt.executeUpdate("UPDATE users SET full_name = 'Nguyễn Văn Sales' WHERE user_id = 4 OR email = 'salesrep.test@example.com' OR full_name LIKE '%Nguy%' OR full_name LIKE '%Sales%'");
            stmt.executeUpdate("UPDATE users SET full_name = 'Hoàng Văn Lead' WHERE user_id = 3 OR email = 'teamlead.test@example.com' OR full_name LIKE '%Ho%' OR full_name LIKE '%Lead%'");
            stmt.executeUpdate("UPDATE users SET full_name = 'Vũ Văn Director' WHERE user_id = 2 OR email = 'director.test@example.com' OR full_name LIKE '%V%' OR full_name LIKE '%Director%'");
            stmt.executeUpdate("UPDATE users SET full_name = 'Lê Văn Sales Nam' WHERE user_id = 5 OR email = 'salesrep2.test@example.com'");
            stmt.executeUpdate("UPDATE users SET full_name = 'Trần Thị Marketing' WHERE user_id = 6 OR email = 'marketing.test@example.com'");
            stmt.executeUpdate("UPDATE users SET full_name = 'Lê Văn CSKH' WHERE user_id = 7 OR email = 'customersuccess.test@example.com'");
            stmt.executeUpdate("UPDATE users SET full_name = 'Phạm Thị Kế Toán' WHERE user_id = 8 OR email = 'accountant.test@example.com'");

            stmt.executeUpdate("UPDATE customers SET status = 'POTENTIAL' WHERE status LIKE 'Ti%' OR status LIKE '%?%' OR status = 'POTENTIAL'");
            stmt.executeUpdate("UPDATE customers SET status = 'DEALING' WHERE status LIKE '%giao d%' OR status = 'DEALING'");
            stmt.executeUpdate("UPDATE customers SET status = 'CUSTOMER' WHERE status LIKE 'Kh%' OR status = 'CUSTOMER'");
            stmt.executeUpdate("UPDATE customers SET status = 'STOPPED' WHERE status LIKE 'Ng%' OR status = 'STOPPED'");
            stmt.executeUpdate("UPDATE customers SET status = 'ACTIVE' WHERE status LIKE 'Ho%t %ng' OR status = 'ACTIVE'");

            stmt.executeUpdate("UPDATE customers SET industry = 'Công nghệ thông tin' WHERE industry LIKE '%Công nghệ%'");
            stmt.executeUpdate("UPDATE customers SET industry = 'Bất động sản' WHERE industry LIKE '%Bất động sản%'");
            stmt.executeUpdate("UPDATE customers SET industry = 'Tài chính / Ngân hàng' WHERE industry LIKE '%Tài chính%' OR industry LIKE '%Ngân hàng%'");
            stmt.executeUpdate("UPDATE customers SET industry = 'Sản xuất' WHERE industry LIKE '%Sản xuất%'");
            stmt.executeUpdate("UPDATE customers SET industry = 'Thương mại / Bán lẻ' WHERE industry LIKE '%Thương mại%' OR industry LIKE '%Bán lẻ%'");
            stmt.executeUpdate("UPDATE customers SET industry = 'Y tế / Dược phẩm' WHERE industry LIKE '%Y tế%' OR industry LIKE '%Dược%'");
        } catch (Exception e) {
            LOGGER.log(java.util.logging.Level.FINE, "Note auto heal DB: " + e.getMessage());
        }
    }

    private void ensureColumnExists(Connection conn, String columnName, String columnDefinition) {
        String checkSql = "SELECT COUNT(*) FROM information_schema.COLUMNS " +
                          "WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'customers' AND COLUMN_NAME = ?";
        try (PreparedStatement checkPs = conn.prepareStatement(checkSql)) {
            checkPs.setString(1, columnName);
            try (ResultSet rs = checkPs.executeQuery()) {
                if (rs.next() && rs.getInt(1) == 0) {
                    String alterSql = "ALTER TABLE customers ADD COLUMN " + columnName + " " + columnDefinition;
                    try (Statement stmt = conn.createStatement()) {
                        stmt.executeUpdate(alterSql);
                        LOGGER.info("Đã thêm cột '" + columnName + "' vào bảng customers thành công.");
                    }
                }
            }
        } catch (SQLException e) {
            LOGGER.log(java.util.logging.Level.SEVERE, "Lỗi khi kiểm tra/thêm cột '" + columnName + "' vào bảng customers: " + e.getMessage(), e);
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
        try { obj.setOwnerName(rs.getString("owner_name")); } catch (SQLException ignored) {}
        try { obj.setUpdatedAt(rs.getTimestamp("updated_at")); } catch (SQLException ignored) {}

        try {
            int pending = rs.getInt("pending_tickets");
            int urgent = rs.getInt("urgent_tickets");
            if (urgent > 0) {
                obj.setRiskFlag(true);
                obj.setRiskReason("Có " + urgent + " yêu cầu URGENT chưa xử lý");
            } else if (pending >= 3) {
                obj.setRiskFlag(true);
                obj.setRiskReason("Có " + pending + " yêu cầu tồn đọng (≥3)");
            }
        } catch (SQLException ignored) {}

        return obj;
    }

    public List<Customer> findAll() {
        List<Customer> list = new ArrayList<>();
        String sql = "SELECT c.*, u.full_name AS owner_name, " +
                     "(SELECT COUNT(*) FROM support_requests sr WHERE sr.customer_id = c.customer_id AND sr.status IN ('OPEN', 'IN_PROGRESS')) AS pending_tickets, " +
                     "(SELECT COUNT(*) FROM support_requests sr WHERE sr.customer_id = c.customer_id AND sr.status IN ('OPEN', 'IN_PROGRESS') AND sr.priority = 'URGENT') AS urgent_tickets " +
                     "FROM customers c LEFT JOIN users u ON c.owner_id = u.user_id ORDER BY c.customer_id DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapResultSetToCustomer(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
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

        String selectFields = "c.*, u.full_name AS owner_name, " +
                "(SELECT COUNT(*) FROM support_requests sr WHERE sr.customer_id = c.customer_id AND sr.status IN ('OPEN', 'IN_PROGRESS')) AS pending_tickets, " +
                "(SELECT COUNT(*) FROM support_requests sr WHERE sr.customer_id = c.customer_id AND sr.status IN ('OPEN', 'IN_PROGRESS') AND sr.priority = 'URGENT') AS urgent_tickets ";

        if (hasCustomField) {
            sql.append("SELECT DISTINCT ").append(selectFields).append("FROM customers c ");
            sql.append("JOIN custom_field_values cfv ON c.customer_id = cfv.entity_id AND cfv.entity_type = 'CUSTOMER' ");
            sql.append("LEFT JOIN users u ON c.owner_id = u.user_id ");
        } else {
            sql.append("SELECT DISTINCT ").append(selectFields).append("FROM customers c ");
            sql.append("LEFT JOIN users u ON c.owner_id = u.user_id ");
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
                String st = req.getStatus().trim();
                if ("POTENTIAL".equalsIgnoreCase(st) || "Tiềm năng".equalsIgnoreCase(st)) {
                    sql.append(" AND (LOWER(c.status) = 'potential' OR c.status = 'Tiềm năng')");
                } else if ("DEALING".equalsIgnoreCase(st) || "Đang giao dịch".equalsIgnoreCase(st)) {
                    sql.append(" AND (LOWER(c.status) = 'dealing' OR c.status = 'Đang giao dịch')");
                } else if ("CUSTOMER".equalsIgnoreCase(st) || "Khách hàng".equalsIgnoreCase(st)) {
                    sql.append(" AND (LOWER(c.status) = 'customer' OR c.status = 'Khách hàng')");
                } else if ("ACTIVE".equalsIgnoreCase(st) || "Hoạt động".equalsIgnoreCase(st)) {
                    sql.append(" AND (LOWER(c.status) = 'active' OR c.status = 'Hoạt động')");
                } else if ("STOPPED".equalsIgnoreCase(st) || "Ngừng hợp tác".equalsIgnoreCase(st) || "INACTIVE".equalsIgnoreCase(st)) {
                    sql.append(" AND (LOWER(c.status) IN ('stopped', 'inactive') OR c.status = 'Ngừng hợp tác')");
                } else {
                    sql.append(" AND (c.status = ? OR LOWER(c.status) = LOWER(?))");
                    params.add(st);
                    params.add(st);
                }
            }

            if (req.getIndustry() != null && !req.getIndustry().trim().isEmpty()) {
                String ind = req.getIndustry().trim();
                if (ind.contains("Công nghệ")) {
                    sql.append(" AND (c.industry LIKE '%Công nghệ%')");
                } else if (ind.contains("Tài chính") || ind.contains("Ngân hàng")) {
                    sql.append(" AND (c.industry LIKE '%Tài chính%' OR c.industry LIKE '%Ngân hàng%')");
                } else if (ind.contains("Bất động sản")) {
                    sql.append(" AND (c.industry LIKE '%Bất động sản%')");
                } else if (ind.contains("Sản xuất")) {
                    sql.append(" AND (c.industry LIKE '%Sản xuất%')");
                } else if (ind.contains("Thương mại") || ind.contains("Bán lẻ")) {
                    sql.append(" AND (c.industry LIKE '%Thương mại%' OR c.industry LIKE '%Bán lẻ%')");
                } else if (ind.contains("Y tế") || ind.contains("Dược")) {
                    sql.append(" AND (c.industry LIKE '%Y tế%' OR c.industry LIKE '%Dược%')");
                } else {
                    sql.append(" AND (LOWER(c.industry) = LOWER(?) OR c.industry LIKE ?)");
                    params.add(ind);
                    params.add("%" + ind + "%");
                }
            }

            if (req.getCompanySize() != null && !req.getCompanySize().trim().isEmpty()) {
                String sz = req.getCompanySize().trim();
                sql.append(" AND (LOWER(c.company_size) = LOWER(?) OR LOWER(c.size) = LOWER(?) OR c.company_size LIKE ? OR c.size LIKE ?)");
                params.add(sz);
                params.add(sz);
                params.add("%" + sz + "%");
                params.add("%" + sz + "%");
            }

            if (req.getRegion() != null && !req.getRegion().trim().isEmpty()) {
                String reg = req.getRegion().trim();
                sql.append(" AND (LOWER(c.region) = LOWER(?) OR c.region LIKE ?)");
                params.add(reg);
                params.add("%" + reg + "%");
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
        String sql = "SELECT c.*, u.full_name AS owner_name FROM customers c LEFT JOIN users u ON c.owner_id = u.user_id WHERE c.customer_id = ?";
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

                String fullName = "";
                try {
                    fullName = rs.getString("full_name");
                    if (fullName == null) fullName = rs.getString("contact_name");
                } catch (SQLException ignored) {
                    try { fullName = rs.getString("contact_name"); } catch (SQLException ignored2) {}
                }

                String title = "";
                try {
                    title = rs.getString("title");
                    if (title == null) title = rs.getString("position");
                } catch (SQLException ignored) {
                    try { title = rs.getString("position"); } catch (SQLException ignored2) {}
                }

                String buyingRole = "";
                try { buyingRole = rs.getString("buying_role"); } catch (SQLException ignored) {}

                map.put("fullName", fullName);
                map.put("contactName", fullName);
                map.put("name", fullName);
                map.put("title", title);
                map.put("position", title);
                map.put("role", buyingRole);
                map.put("buyingRole", buyingRole);
                map.put("phone", rs.getString("phone"));
                map.put("email", rs.getString("email"));
                map.put("isPrimary", rs.getBoolean("is_primary"));
                map.put("createdAt", rs.getTimestamp("created_at"));
                list.add(map);
            }
        } catch (SQLException e) {
            e.printStackTrace();
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

    public Customer findById(Connection conn, int id) throws SQLException {
        String sql = "SELECT c.*, u.full_name AS owner_name FROM customers c LEFT JOIN users u ON c.owner_id = u.user_id WHERE c.customer_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToCustomer(rs);
                }
            }
        }
        return null;
    }

    public Customer findDuplicateCustomer(Connection conn, String taxCode, String phone, String customerName) throws SQLException {
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
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToCustomer(rs);
                }
            }
        }
        return null;
    }

    public boolean insert(Connection conn, Customer customer) throws SQLException {
        String sql = "INSERT INTO customers (customer_name, phone, tax_code, industry, size, website, address, status, owner_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
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
        }
        return false;
    }

    public boolean update(Connection conn, Customer customer) throws SQLException {
        String sql = "UPDATE customers SET customer_name = ?, phone = ?, tax_code = ?, industry = ?, size = ?, website = ?, address = ?, status = ?, owner_id = ? WHERE customer_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
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
        }
    }

    public boolean insert(Customer customer) {
        try (Connection conn = DBConnection.getConnection()) {
            return insert(conn, customer);
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean insertCustomer(Customer customer) {
        return insert(customer);
    }

    public boolean insertCustomer(Connection conn, Customer customer) throws SQLException {
        return insert(conn, customer);
    }

    public boolean update(Customer customer) {
        try (Connection conn = DBConnection.getConnection()) {
            return update(conn, customer);
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean updateCustomer(Customer customer) {
        return update(customer);
    }

    public boolean updateCustomer(Connection conn, Customer customer) throws SQLException {
        return update(conn, customer);
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

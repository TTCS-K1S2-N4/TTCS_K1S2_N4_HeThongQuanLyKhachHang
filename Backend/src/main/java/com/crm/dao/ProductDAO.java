package com.crm.dao;

import com.crm.model.Product;
import com.crm.util.DBConnection;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

public class ProductDAO {

    private static final Logger LOGGER = Logger.getLogger(ProductDAO.class.getName());

    public List<Product> getList(String keyword, String productType, String status, boolean includeCostPrice, int page, int pageSize) {
        List<Product> products = new ArrayList<>();
        StringBuilder sql = new StringBuilder("SELECT product_id, product_code, product_name, product_type, unit, list_price, floor_price, ");
        if (includeCostPrice) {
            sql.append("cost_price, ");
        } else {
            sql.append("NULL AS cost_price, ");
        }
        sql.append("status, created_at, updated_at FROM products WHERE 1=1 ");

        List<Object> params = new ArrayList<>();

        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append("AND (product_code LIKE ? OR product_name LIKE ?) ");
            String kwParam = "%" + keyword.trim() + "%";
            params.add(kwParam);
            params.add(kwParam);
        }

        if (productType != null && !productType.trim().isEmpty()) {
            sql.append("AND product_type = ? ");
            params.add(productType.trim());
        }

        if (status != null && !status.trim().isEmpty()) {
            sql.append("AND status = ? ");
            params.add(status.trim());
        }

        sql.append("ORDER BY product_id DESC LIMIT ? OFFSET ?");
        int offset = Math.max(0, (page - 1) * pageSize);
        params.add(pageSize);
        params.add(offset);

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql.toString())) {

            for (int i = 0; i < params.size(); i++) {
                stmt.setObject(i + 1, params.get(i));
            }

            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    products.add(mapResultSetToProduct(rs, includeCostPrice));
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Lỗi truy vấn danh sách sản phẩm", e);
        }

        return products;
    }

    public int count(String keyword, String productType, String status) {
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM products WHERE 1=1 ");
        List<Object> params = new ArrayList<>();

        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append("AND (product_code LIKE ? OR product_name LIKE ?) ");
            String kwParam = "%" + keyword.trim() + "%";
            params.add(kwParam);
            params.add(kwParam);
        }

        if (productType != null && !productType.trim().isEmpty()) {
            sql.append("AND product_type = ? ");
            params.add(productType.trim());
        }

        if (status != null && !status.trim().isEmpty()) {
            sql.append("AND status = ? ");
            params.add(status.trim());
        }

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql.toString())) {

            for (int i = 0; i < params.size(); i++) {
                stmt.setObject(i + 1, params.get(i));
            }

            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Lỗi đếm số lượng sản phẩm", e);
        }

        return 0;
    }

    public Product getById(int productId, boolean includeCostPrice) {
        StringBuilder sql = new StringBuilder("SELECT product_id, product_code, product_name, product_type, unit, list_price, floor_price, ");
        if (includeCostPrice) {
            sql.append("cost_price, ");
        } else {
            sql.append("NULL AS cost_price, ");
        }
        sql.append("status, created_at, updated_at FROM products WHERE product_id = ?");

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql.toString())) {

            stmt.setInt(1, productId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToProduct(rs, includeCostPrice);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Lỗi lấy chi tiết sản phẩm với ID: " + productId, e);
        }

        return null;
    }

    public Product getByCode(String productCode, boolean includeCostPrice) {
        if (productCode == null || productCode.trim().isEmpty()) return null;
        StringBuilder sql = new StringBuilder("SELECT product_id, product_code, product_name, product_type, unit, list_price, floor_price, ");
        if (includeCostPrice) {
            sql.append("cost_price, ");
        } else {
            sql.append("NULL AS cost_price, ");
        }
        sql.append("status, created_at, updated_at FROM products WHERE product_code = ?");

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql.toString())) {

            stmt.setString(1, productCode.trim());
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToProduct(rs, includeCostPrice);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Lỗi tìm sản phẩm theo mã: " + productCode, e);
        }

        return null;
    }

    public boolean create(Product product, boolean includeCostPrice) {
        return create(product, includeCostPrice, null);
    }

    public boolean create(Product product, boolean includeCostPrice, com.crm.model.AuditLog auditLog) {
        String sql = "INSERT INTO products (product_code, product_name, product_type, unit, list_price, floor_price, cost_price, status) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            try (PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
                stmt.setString(1, product.getProductCode());
                stmt.setString(2, product.getProductName());
                stmt.setString(3, product.getProductType());
                stmt.setString(4, product.getUnit());
                stmt.setBigDecimal(5, product.getListPrice() != null ? product.getListPrice() : BigDecimal.ZERO);
                stmt.setBigDecimal(6, product.getFloorPrice() != null ? product.getFloorPrice() : BigDecimal.ZERO);

                if (includeCostPrice && product.getCostPrice() != null) {
                    stmt.setBigDecimal(7, product.getCostPrice());
                } else {
                    stmt.setNull(7, java.sql.Types.DECIMAL);
                }

                stmt.setString(8, product.getStatus() != null ? product.getStatus() : "ACTIVE");

                int rowsAffected = stmt.executeUpdate();
                if (rowsAffected > 0) {
                    try (ResultSet generatedKeys = stmt.getGeneratedKeys()) {
                        if (generatedKeys.next()) {
                            product.setProductId(generatedKeys.getInt(1));
                        }
                    }
                    if (auditLog != null) {
                        auditLog.setTargetUserId(product.getProductId());
                        new AuditLogDAO().insertLog(conn, auditLog);
                    }
                    conn.commit();
                    return true;
                }
                conn.rollback();
            }
        } catch (SQLException e) {
            if (conn != null) try { conn.rollback(); } catch (SQLException ignored) {}
            LOGGER.log(Level.SEVERE, "Lỗi tạo sản phẩm mới", e);
        } finally {
            if (conn != null) try { conn.setAutoCommit(true); conn.close(); } catch (SQLException ignored) {}
        }

        return false;
    }

    public boolean update(Product product, boolean includeCostPrice) {
        return update(product, includeCostPrice, null);
    }

    public boolean update(Product product, boolean includeCostPrice, com.crm.model.AuditLog auditLog) {
        StringBuilder sql = new StringBuilder("UPDATE products SET product_code = ?, product_name = ?, product_type = ?, unit = ?, list_price = ?, floor_price = ?, status = ? ");
        if (includeCostPrice) {
            sql.append(", cost_price = ? ");
        }
        sql.append("WHERE product_id = ?");

        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            try (PreparedStatement stmt = conn.prepareStatement(sql.toString())) {
                int idx = 1;
                stmt.setString(idx++, product.getProductCode());
                stmt.setString(idx++, product.getProductName());
                stmt.setString(idx++, product.getProductType());
                stmt.setString(idx++, product.getUnit());
                stmt.setBigDecimal(idx++, product.getListPrice() != null ? product.getListPrice() : BigDecimal.ZERO);
                stmt.setBigDecimal(idx++, product.getFloorPrice() != null ? product.getFloorPrice() : BigDecimal.ZERO);
                stmt.setString(idx++, product.getStatus() != null ? product.getStatus() : "ACTIVE");

                if (includeCostPrice) {
                    if (product.getCostPrice() != null) {
                        stmt.setBigDecimal(idx++, product.getCostPrice());
                    } else {
                        stmt.setNull(idx++, java.sql.Types.DECIMAL);
                    }
                }

                stmt.setInt(idx, product.getProductId());

                if (stmt.executeUpdate() > 0) {
                    if (auditLog != null) {
                        auditLog.setTargetUserId(product.getProductId());
                        new AuditLogDAO().insertLog(conn, auditLog);
                    }
                    conn.commit();
                    return true;
                }
                conn.rollback();
            }
        } catch (SQLException e) {
            if (conn != null) try { conn.rollback(); } catch (SQLException ignored) {}
            LOGGER.log(Level.SEVERE, "Lỗi cập nhật sản phẩm ID: " + product.getProductId(), e);
        } finally {
            if (conn != null) try { conn.setAutoCommit(true); conn.close(); } catch (SQLException ignored) {}
        }

        return false;
    }

    public boolean updateStatus(int productId, String status) {
        return updateStatus(productId, status, null);
    }

    public boolean updateStatus(int productId, String status, com.crm.model.AuditLog auditLog) {
        String sql = "UPDATE products SET status = ? WHERE product_id = ?";

        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                stmt.setString(1, status);
                stmt.setInt(2, productId);

                if (stmt.executeUpdate() > 0) {
                    if (auditLog != null) {
                        auditLog.setTargetUserId(productId);
                        new AuditLogDAO().insertLog(conn, auditLog);
                    }
                    conn.commit();
                    return true;
                }
                conn.rollback();
            }
        } catch (SQLException e) {
            if (conn != null) try { conn.rollback(); } catch (SQLException ignored) {}
            LOGGER.log(Level.SEVERE, "Lỗi cập nhật trạng thái sản phẩm ID: " + productId, e);
        } finally {
            if (conn != null) try { conn.setAutoCommit(true); conn.close(); } catch (SQLException ignored) {}
        }

        return false;
    }

    public boolean exists(int productId) {
        String sql = "SELECT 1 FROM products WHERE product_id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, productId);
            try (ResultSet rs = stmt.executeQuery()) {
                return rs.next();
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Lỗi kiểm tra sản phẩm tồn tại ID: " + productId, e);
        }

        return false;
    }

    public boolean isCodeExists(String productCode, Integer excludeProductId) {
        if (productCode == null || productCode.trim().isEmpty()) return false;
        StringBuilder sql = new StringBuilder("SELECT 1 FROM products WHERE product_code = ? ");
        if (excludeProductId != null && excludeProductId > 0) {
            sql.append("AND product_id <> ? ");
        }

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql.toString())) {

            stmt.setString(1, productCode.trim());
            if (excludeProductId != null && excludeProductId > 0) {
                stmt.setInt(2, excludeProductId);
            }

            try (ResultSet rs = stmt.executeQuery()) {
                return rs.next();
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Lỗi kiểm tra trùng mã sản phẩm: " + productCode, e);
        }

        return false;
    }

    private Product mapResultSetToProduct(ResultSet rs, boolean includeCostPrice) throws SQLException {
        Product product = new Product();
        product.setProductId(rs.getInt("product_id"));
        product.setProductCode(rs.getString("product_code"));
        product.setProductName(rs.getString("product_name"));
        product.setProductType(rs.getString("product_type"));
        product.setUnit(rs.getString("unit"));
        product.setListPrice(rs.getBigDecimal("list_price"));
        product.setFloorPrice(rs.getBigDecimal("floor_price"));

        if (includeCostPrice) {
            product.setCostPrice(rs.getBigDecimal("cost_price"));
        } else {
            product.setCostPrice(null);
        }

        product.setStatus(rs.getString("status"));
        product.setCreatedAt(rs.getTimestamp("created_at"));
        product.setUpdatedAt(rs.getTimestamp("updated_at"));

        return product;
    }
}

package com.crm.dao;

import com.crm.model.Category;
import com.crm.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class CategoryDAO {

    public List<Category> findAll() throws SQLException {
        List<Category> list = new ArrayList<>();
        String sql = "SELECT category_id, category_type, category_name, display_order, status, created_at, updated_at " +
                     "FROM categories ORDER BY category_type ASC, display_order ASC, category_name ASC";

        try (
            Connection conn = DBConnection.getConnection();
            PreparedStatement ps = conn.prepareStatement(sql);
            ResultSet rs = ps.executeQuery()
        ) {
            while (rs.next()) {
                list.add(mapResultSetToCategory(rs));
            }
        }
        return list;
    }

    public List<Category> findByType(String categoryType) throws SQLException {
        List<Category> list = new ArrayList<>();
        String sql = "SELECT category_id, category_type, category_name, display_order, status, created_at, updated_at " +
                     "FROM categories WHERE category_type = ? ORDER BY display_order ASC, category_name ASC";

        try (
            Connection conn = DBConnection.getConnection();
            PreparedStatement ps = conn.prepareStatement(sql)
        ) {
            ps.setString(1, categoryType);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSetToCategory(rs));
                }
            }
        }
        return list;
    }

    public Category findById(int categoryId) throws SQLException {
        String sql = "SELECT category_id, category_type, category_name, display_order, status, created_at, updated_at " +
                     "FROM categories WHERE category_id = ?";

        try (
            Connection conn = DBConnection.getConnection();
            PreparedStatement ps = conn.prepareStatement(sql)
        ) {
            ps.setInt(1, categoryId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToCategory(rs);
                }
            }
        }
        return null;
    }

    public boolean existsByTypeAndNameExcludingId(String categoryType, String categoryName, int excludeCategoryId) throws SQLException {
        String sql = "SELECT 1 FROM categories WHERE LOWER(category_type) = LOWER(?) AND LOWER(category_name) = LOWER(?) AND category_id <> ?";

        try (
            Connection conn = DBConnection.getConnection();
            PreparedStatement ps = conn.prepareStatement(sql)
        ) {
            ps.setString(1, categoryType);
            ps.setString(2, categoryName);
            ps.setInt(3, excludeCategoryId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    public boolean insert(Category category) throws SQLException {
        String sql = "INSERT INTO categories (category_type, category_name, display_order, status) VALUES (?, ?, ?, ?)";

        try (
            Connection conn = DBConnection.getConnection();
            PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)
        ) {
            ps.setString(1, category.getCategoryType());
            ps.setString(2, category.getCategoryName());
            ps.setInt(3, category.getDisplayOrder());
            ps.setString(4, category.getStatus() != null ? category.getStatus() : "ACTIVE");

            int rows = ps.executeUpdate();
            if (rows > 0) {
                try (ResultSet keys = ps.getGeneratedKeys()) {
                    if (keys.next()) {
                        category.setCategoryId(keys.getInt(1));
                    }
                }
                return true;
            }
        }
        return false;
    }

    public boolean update(Category category) throws SQLException {
        String sql = "UPDATE categories SET category_type = ?, category_name = ?, display_order = ?, status = ? WHERE category_id = ?";

        try (
            Connection conn = DBConnection.getConnection();
            PreparedStatement ps = conn.prepareStatement(sql)
        ) {
            ps.setString(1, category.getCategoryType());
            ps.setString(2, category.getCategoryName());
            ps.setInt(3, category.getDisplayOrder());
            ps.setString(4, category.getStatus() != null ? category.getStatus() : "ACTIVE");
            ps.setInt(5, category.getCategoryId());

            return ps.executeUpdate() > 0;
        }
    }

    public boolean updateStatus(int categoryId, String status) throws SQLException {
        String sql = "UPDATE categories SET status = ? WHERE category_id = ?";

        try (
            Connection conn = DBConnection.getConnection();
            PreparedStatement ps = conn.prepareStatement(sql)
        ) {
            ps.setString(1, status);
            ps.setInt(2, categoryId);

            return ps.executeUpdate() > 0;
        }
    }

    public boolean delete(int categoryId) throws SQLException {
        String sql = "DELETE FROM categories WHERE category_id = ?";

        try (
            Connection conn = DBConnection.getConnection();
            PreparedStatement ps = conn.prepareStatement(sql)
        ) {
            ps.setInt(1, categoryId);
            return ps.executeUpdate() > 0;
        }
    }

    public int countUsage(String categoryType, String categoryName) {
        if (categoryName == null || categoryName.trim().isEmpty()) return 0;
        int count = 0;
        String val = categoryName.trim();

        // 1. Check custom_field_values
        String sqlCf = "SELECT COUNT(*) FROM custom_field_values WHERE field_value = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sqlCf)) {
            ps.setString(1, val);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) count += rs.getInt(1);
            }
        } catch (SQLException ignored) {}

        // 2. Check customers (if columns industry, company_size, lead_source exist)
        String[] customerCols = {"industry", "company_size", "lead_source"};
        for (String col : customerCols) {
            String sql = "SELECT COUNT(*) FROM customers WHERE " + col + " = ?";
            try (Connection conn = DBConnection.getConnection();
                 PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, val);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) count += rs.getInt(1);
                }
            } catch (SQLException ignored) {}
        }

        // 3. Check opportunities (lead_source)
        String sqlOpp = "SELECT COUNT(*) FROM opportunities WHERE lead_source = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sqlOpp)) {
            ps.setString(1, val);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) count += rs.getInt(1);
            }
        } catch (SQLException ignored) {}

        // 4. Check activities (activity_type)
        String sqlAct = "SELECT COUNT(*) FROM activities WHERE activity_type = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sqlAct)) {
            ps.setString(1, val);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) count += rs.getInt(1);
            }
        } catch (SQLException ignored) {}

        return count;
    }

    private Category mapResultSetToCategory(ResultSet rs) throws SQLException {
        Category category = new Category();
        category.setCategoryId(rs.getInt("category_id"));
        category.setCategoryType(rs.getString("category_type"));
        category.setCategoryName(rs.getString("category_name"));
        category.setDisplayOrder(rs.getInt("display_order"));
        category.setStatus(rs.getString("status"));
        category.setCreatedAt(rs.getTimestamp("created_at"));
        category.setUpdatedAt(rs.getTimestamp("updated_at"));
        return category;
    }
}

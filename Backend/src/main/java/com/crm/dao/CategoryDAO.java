package com.crm.dao;

import com.crm.util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

public class CategoryDAO {

    private static final Logger LOGGER = Logger.getLogger(CategoryDAO.class.getName());

    public static class CategoryItem {
        private int categoryId;
        private String categoryCode;
        private String categoryName;
        private String description;
        private String status;

        public CategoryItem() {}

        public CategoryItem(int categoryId, String categoryCode, String categoryName, String description, String status) {
            this.categoryId = categoryId;
            this.categoryCode = categoryCode;
            this.categoryName = categoryName;
            this.description = description;
            this.status = status;
        }

        public int getCategoryId() { return categoryId; }
        public void setCategoryId(int categoryId) { this.categoryId = categoryId; }

        public String getCategoryCode() { return categoryCode; }
        public void setCategoryCode(String categoryCode) { this.categoryCode = categoryCode; }

        public String getCategoryName() { return categoryName; }
        public void setCategoryName(String categoryName) { this.categoryName = categoryName; }

        public String getDescription() { return description; }
        public void setDescription(String description) { this.description = description; }

        public String getStatus() { return status; }
        public void setStatus(String status) { this.status = status; }
    }

    public List<CategoryItem> getAllCategories() {
        List<CategoryItem> list = new ArrayList<>();
        String sql = "SELECT category_id, category_code, category_name, description, status FROM categories ORDER BY category_id ASC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                CategoryItem item = new CategoryItem();
                item.setCategoryId(rs.getInt("category_id"));
                item.setCategoryCode(rs.getString("category_code"));
                item.setCategoryName(rs.getString("category_name"));
                item.setDescription(rs.getString("description"));
                item.setStatus(rs.getString("status"));
                list.add(item);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Lỗi lấy danh sách category", e);
        }
        return list;
    }

    public CategoryItem getCategoryById(int categoryId) {
        String sql = "SELECT category_id, category_code, category_name, description, status FROM categories WHERE category_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, categoryId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    CategoryItem item = new CategoryItem();
                    item.setCategoryId(rs.getInt("category_id"));
                    item.setCategoryCode(rs.getString("category_code"));
                    item.setCategoryName(rs.getString("category_name"));
                    item.setDescription(rs.getString("description"));
                    item.setStatus(rs.getString("status"));
                    return item;
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Lỗi lấy category ID: " + categoryId, e);
        }
        return null;
    }

    public boolean createCategory(CategoryItem item) {
        String sql = "INSERT INTO categories (category_code, category_name, description, status) VALUES (?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, item.getCategoryCode());
            ps.setString(2, item.getCategoryName());
            ps.setString(3, item.getDescription());
            ps.setString(4, item.getStatus() != null ? item.getStatus() : "ACTIVE");
            int affected = ps.executeUpdate();
            if (affected > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        item.setCategoryId(rs.getInt(1));
                    }
                }
                return true;
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Lỗi tạo category mới", e);
        }
        return false;
    }

    public boolean updateCategory(CategoryItem item) {
        String sql = "UPDATE categories SET category_code = ?, category_name = ?, description = ?, status = ? WHERE category_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, item.getCategoryCode());
            ps.setString(2, item.getCategoryName());
            ps.setString(3, item.getDescription());
            ps.setString(4, item.getStatus());
            ps.setInt(5, item.getCategoryId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Lỗi cập nhật category ID: " + item.getCategoryId(), e);
        }
        return false;
    }

    public boolean deleteCategory(int categoryId) {
        String sql = "DELETE FROM categories WHERE category_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, categoryId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Lỗi xóa category ID: " + categoryId, e);
        }
        return false;
    }
}

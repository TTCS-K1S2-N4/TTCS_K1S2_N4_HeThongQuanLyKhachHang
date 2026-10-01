package com.crm.service;

import com.crm.dao.CategoryDAO;
import com.crm.model.Category;

import java.sql.SQLException;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

public class CategoryService {

    private static final Logger LOGGER = Logger.getLogger(CategoryService.class.getName());

    private CategoryDAO categoryDAO = new CategoryDAO();

    public CategoryService() {
    }

    public CategoryService(CategoryDAO categoryDAO) {
        if (categoryDAO != null) {
            this.categoryDAO = categoryDAO;
        }
    }

    public void setCategoryDAO(CategoryDAO categoryDAO) {
        if (categoryDAO != null) {
            this.categoryDAO = categoryDAO;
        }
    }

    public List<Category> getCategories(String categoryType) {
        try {
            if (categoryType != null && !categoryType.trim().isEmpty()) {
                return categoryDAO.findByType(categoryType.trim());
            }
            return categoryDAO.findAll();
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Lỗi khi lấy danh sách danh mục: ", e);
            throw new RuntimeException("Lỗi hệ thống khi lấy danh sách danh mục: " + e.getMessage(), e);
        }
    }

    public Category getCategoryById(int categoryId) {
        if (categoryId <= 0) {
            return null;
        }
        try {
            return categoryDAO.findById(categoryId);
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Lỗi khi lấy danh mục ID=" + categoryId, e);
            throw new RuntimeException("Lỗi hệ thống khi lấy danh mục: " + e.getMessage(), e);
        }
    }

    public boolean processCategoryUpdate(Category.Action action, Category category, List<String> errors) {
        if (action == null) {
            errors.add("Thao tác (action) không hợp lệ. Chấp nhận: CREATE, UPDATE, DEACTIVATE.");
            return false;
        }

        if (category == null) {
            errors.add("Dữ liệu danh mục không được để trống.");
            return false;
        }

        try {
            switch (action) {
                case CREATE:
                    return handleCreateCategory(category, errors);
                case UPDATE:
                    return handleUpdateCategory(category, errors);
                case DEACTIVATE:
                    return handleDeactivateCategory(category.getCategoryId(), errors);
                default:
                    errors.add("Thao tác không hỗ trợ: " + action);
                    return false;
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Lỗi cơ sở dữ liệu khi thao tác danh mục: ", e);
            errors.add("Lỗi cơ sở dữ liệu: " + e.getMessage());
            return false;
        }
    }

    private boolean handleCreateCategory(Category category, List<String> errors) throws SQLException {
        validateTypeAndName(category.getCategoryType(), category.getCategoryName(), errors);

        if (category.getStatus() == null || category.getStatus().trim().isEmpty()) {
            category.setStatus("ACTIVE");
        } else {
            String status = category.getStatus().trim().toUpperCase();
            if (!"ACTIVE".equals(status) && !"INACTIVE".equals(status)) {
                errors.add("Trạng thái danh mục không hợp lệ (chấp nhận ACTIVE hoặc INACTIVE).");
            } else {
                category.setStatus(status);
            }
        }

        if (!errors.isEmpty()) {
            return false;
        }

        if (categoryDAO.existsByTypeAndNameExcludingId(category.getCategoryType(), category.getCategoryName(), 0)) {
            errors.add("Danh mục '" + category.getCategoryName() + "' thuộc loại '" + category.getCategoryType() + "' đã tồn tại.");
            return false;
        }

        return categoryDAO.insert(category);
    }

    private boolean handleUpdateCategory(Category category, List<String> errors) throws SQLException {
        if (category.getCategoryId() <= 0) {
            errors.add("ID danh mục không hợp lệ.");
            return false;
        }

        Category existing = categoryDAO.findById(category.getCategoryId());
        if (existing == null) {
            errors.add("Không tìm thấy danh mục với ID: " + category.getCategoryId());
            return false;
        }

        validateTypeAndName(category.getCategoryType(), category.getCategoryName(), errors);

        if (category.getStatus() == null || category.getStatus().trim().isEmpty()) {
            category.setStatus(existing.getStatus());
        } else {
            String status = category.getStatus().trim().toUpperCase();
            if (!"ACTIVE".equals(status) && !"INACTIVE".equals(status)) {
                errors.add("Trạng thái danh mục không hợp lệ (chấp nhận ACTIVE hoặc INACTIVE).");
            } else {
                category.setStatus(status);
            }
        }

        if (!errors.isEmpty()) {
            return false;
        }

        if (categoryDAO.existsByTypeAndNameExcludingId(category.getCategoryType(), category.getCategoryName(), category.getCategoryId())) {
            errors.add("Danh mục '" + category.getCategoryName() + "' thuộc loại '" + category.getCategoryType() + "' đã tồn tại.");
            return false;
        }

        return categoryDAO.update(category);
    }

    private boolean handleDeactivateCategory(int categoryId, List<String> errors) throws SQLException {
        if (categoryId <= 0) {
            errors.add("ID danh mục không hợp lệ.");
            return false;
        }

        Category existing = categoryDAO.findById(categoryId);
        if (existing == null) {
            errors.add("Không tìm thấy danh mục với ID: " + categoryId);
            return false;
        }

        return categoryDAO.updateStatus(categoryId, "INACTIVE");
    }

    private void validateTypeAndName(String type, String name, List<String> errors) {
        if (type == null || type.trim().isEmpty()) {
            errors.add("Loại danh mục (categoryType) không được để trống.");
        } else if (type.trim().length() > 50) {
            errors.add("Loại danh mục không được vượt quá 50 ký tự.");
        }

        if (name == null || name.trim().isEmpty()) {
            errors.add("Tên danh mục (categoryName) không được để trống.");
        } else if (name.trim().length() > 100) {
            errors.add("Tên danh mục không được vượt quá 100 ký tự.");
        }
    }
}

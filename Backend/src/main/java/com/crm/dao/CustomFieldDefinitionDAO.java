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

public class CustomFieldDefinitionDAO {

    private static final Logger LOGGER = Logger.getLogger(CustomFieldDefinitionDAO.class.getName());

    public static class CustomFieldDefinitionItem {
        private int fieldId;
        private String entityType; // ACCOUNT, DEAL, PRODUCT, etc.
        private String fieldName;
        private String fieldLabel;
        private String fieldType; // TEXT, NUMBER, DATE, SELECT, etc.
        private boolean isRequired;
        private String optionsJson;

        public CustomFieldDefinitionItem() {}

        public int getFieldId() { return fieldId; }
        public void setFieldId(int fieldId) { this.fieldId = fieldId; }

        public String getEntityType() { return entityType; }
        public void setEntityType(String entityType) { this.entityType = entityType; }

        public String getFieldName() { return fieldName; }
        public void setFieldName(String fieldName) { this.fieldName = fieldName; }

        public String getFieldLabel() { return fieldLabel; }
        public void setFieldLabel(String fieldLabel) { this.fieldLabel = fieldLabel; }

        public String getFieldType() { return fieldType; }
        public void setFieldType(String fieldType) { this.fieldType = fieldType; }

        public boolean isRequired() { return isRequired; }
        public void setRequired(boolean required) { isRequired = required; }

        public String getOptionsJson() { return optionsJson; }
        public void setOptionsJson(String optionsJson) { this.optionsJson = optionsJson; }
    }

    public List<CustomFieldDefinitionItem> getFieldsByEntityType(String entityType) {
        List<CustomFieldDefinitionItem> list = new ArrayList<>();
        String sql = "SELECT field_id, entity_type, field_name, field_label, field_type, is_required, options_json FROM custom_field_definitions WHERE entity_type = ? ORDER BY field_id ASC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, entityType);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    CustomFieldDefinitionItem item = new CustomFieldDefinitionItem();
                    item.setFieldId(rs.getInt("field_id"));
                    item.setEntityType(rs.getString("entity_type"));
                    item.setFieldName(rs.getString("field_name"));
                    item.setFieldLabel(rs.getString("field_label"));
                    item.setFieldType(rs.getString("field_type"));
                    item.setRequired(rs.getBoolean("is_required"));
                    item.setOptionsJson(rs.getString("options_json"));
                    list.add(item);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Lỗi lấy định nghĩa trường tùy chỉnh theo entityType: " + entityType, e);
        }
        return list;
    }

    public boolean createFieldDefinition(CustomFieldDefinitionItem item) {
        String sql = "INSERT INTO custom_field_definitions (entity_type, field_name, field_label, field_type, is_required, options_json) VALUES (?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, item.getEntityType());
            ps.setString(2, item.getFieldName());
            ps.setString(3, item.getFieldLabel());
            ps.setString(4, item.getFieldType());
            ps.setBoolean(5, item.isRequired());
            ps.setString(6, item.getOptionsJson());
            int affected = ps.executeUpdate();
            if (affected > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        item.setFieldId(rs.getInt(1));
                    }
                }
                return true;
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Lỗi tạo định nghĩa trường tùy chỉnh mới", e);
        }
        return false;
    }

    public boolean deleteFieldDefinition(int fieldId) {
        String sql = "DELETE FROM custom_field_definitions WHERE field_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, fieldId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Lỗi xóa định nghĩa trường tùy chỉnh ID: " + fieldId, e);
        }
        return false;
    }
}

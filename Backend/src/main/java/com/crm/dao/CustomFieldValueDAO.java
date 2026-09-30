package com.crm.dao;

import com.crm.util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

public class CustomFieldValueDAO {

    private static final Logger LOGGER = Logger.getLogger(CustomFieldValueDAO.class.getName());

    public static class CustomFieldValueItem {
        private int valueId;
        private int fieldId;
        private int entityId;
        private String fieldValue;

        public CustomFieldValueItem() {}

        public CustomFieldValueItem(int fieldId, int entityId, String fieldValue) {
            this.fieldId = fieldId;
            this.entityId = entityId;
            this.fieldValue = fieldValue;
        }

        public int getValueId() { return valueId; }
        public void setValueId(int valueId) { this.valueId = valueId; }

        public int getFieldId() { return fieldId; }
        public void setFieldId(int fieldId) { this.fieldId = fieldId; }

        public int getEntityId() { return entityId; }
        public void setEntityId(int entityId) { this.entityId = entityId; }

        public String getFieldValue() { return fieldValue; }
        public void setFieldValue(String fieldValue) { this.fieldValue = fieldValue; }
    }

    public List<CustomFieldValueItem> getValuesByEntityId(int entityId) {
        List<CustomFieldValueItem> list = new ArrayList<>();
        String sql = "SELECT value_id, field_id, entity_id, field_value FROM custom_field_values WHERE entity_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, entityId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    CustomFieldValueItem item = new CustomFieldValueItem();
                    item.setValueId(rs.getInt("value_id"));
                    item.setFieldId(rs.getInt("field_id"));
                    item.setEntityId(rs.getInt("entity_id"));
                    item.setFieldValue(rs.getString("field_value"));
                    list.add(item);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Lỗi lấy giá trị trường tùy chỉnh cho entityId: " + entityId, e);
        }
        return list;
    }

    public boolean saveOrUpdateValue(int fieldId, int entityId, String value) {
        String checkSql = "SELECT value_id FROM custom_field_values WHERE field_id = ? AND entity_id = ?";
        String insertSql = "INSERT INTO custom_field_values (field_id, entity_id, field_value) VALUES (?, ?, ?)";
        String updateSql = "UPDATE custom_field_values SET field_value = ? WHERE field_id = ? AND entity_id = ?";

        try (Connection conn = DBConnection.getConnection()) {
            boolean exists = false;
            try (PreparedStatement checkPs = conn.prepareStatement(checkSql)) {
                checkPs.setInt(1, fieldId);
                checkPs.setInt(2, entityId);
                try (ResultSet rs = checkPs.executeQuery()) {
                    exists = rs.next();
                }
            }

            if (exists) {
                try (PreparedStatement updatePs = conn.prepareStatement(updateSql)) {
                    updatePs.setString(1, value);
                    updatePs.setInt(2, fieldId);
                    updatePs.setInt(3, entityId);
                    return updatePs.executeUpdate() > 0;
                }
            } else {
                try (PreparedStatement insertPs = conn.prepareStatement(insertSql)) {
                    insertPs.setInt(1, fieldId);
                    insertPs.setInt(2, entityId);
                    insertPs.setString(3, value);
                    return insertPs.executeUpdate() > 0;
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Lỗi lưu giá trị trường tùy chỉnh fieldId: " + fieldId + ", entityId: " + entityId, e);
        }
        return false;
    }

    public boolean deleteValuesByEntityId(int entityId) {
        String sql = "DELETE FROM custom_field_values WHERE entity_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, entityId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Lỗi xóa giá trị trường tùy chỉnh cho entityId: " + entityId, e);
        }
        return false;
    }
}

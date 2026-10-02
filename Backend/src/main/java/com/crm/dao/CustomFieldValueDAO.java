package com.crm.dao;

import com.crm.model.CustomFieldValue;
import com.crm.util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;

public class CustomFieldValueDAO {
    private static final Logger LOGGER = Logger.getLogger(CustomFieldValueDAO.class.getName());

    public List<CustomFieldValue> getValuesByEntity(String entityType, int entityId) {
        List<CustomFieldValue> list = new ArrayList<>();
        String sql = "SELECT v.*, d.field_key, d.field_label, d.field_type " +
                "FROM custom_field_values v " +
                "JOIN custom_field_definitions d ON v.field_id = d.field_id " +
                "WHERE v.entity_type = ? AND v.entity_id = ? " +
                "ORDER BY d.display_order ASC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, entityType);
            stmt.setInt(2, entityId);

            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    CustomFieldValue val = new CustomFieldValue();
                    val.setValueId(rs.getInt("value_id"));
                    val.setFieldId(rs.getInt("field_id"));
                    val.setEntityType(rs.getString("entity_type"));
                    val.setEntityId(rs.getInt("entity_id"));
                    val.setFieldValue(rs.getString("field_value"));
                    val.setCreatedAt(rs.getTimestamp("created_at"));
                    val.setUpdatedAt(rs.getTimestamp("updated_at"));

                    val.setFieldKey(rs.getString("field_key"));
                    val.setFieldLabel(rs.getString("field_label"));
                    val.setFieldType(rs.getString("field_type"));
                    list.add(val);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Lỗi truy vấn giá trị trường tùy chỉnh cho entity " + entityType + " ID " + entityId, e);
        }
        return list;
    }

    public boolean saveOrUpdateValue(int fieldId, String entityType, int entityId, String fieldValue) {
        String sql = "INSERT INTO custom_field_values (field_id, entity_type, entity_id, field_value) " +
                "VALUES (?, ?, ?, ?) " +
                "ON DUPLICATE KEY UPDATE field_value = VALUES(field_value)";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, fieldId);
            stmt.setString(2, entityType);
            stmt.setInt(3, entityId);
            stmt.setString(4, fieldValue);

            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Lỗi lưu/cập nhật giá trị trường tùy chỉnh ID field " + fieldId, e);
        }
        return false;
    }

    public boolean saveBatchValues(String entityType, int entityId, Map<Integer, String> fieldValuesMap) {
        if (fieldValuesMap == null || fieldValuesMap.isEmpty()) {
            return true;
        }
        String sql = "INSERT INTO custom_field_values (field_id, entity_type, entity_id, field_value) " +
                "VALUES (?, ?, ?, ?) " +
                "ON DUPLICATE KEY UPDATE field_value = VALUES(field_value)";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            conn.setAutoCommit(false);
            for (Map.Entry<Integer, String> entry : fieldValuesMap.entrySet()) {
                stmt.setInt(1, entry.getKey());
                stmt.setString(2, entityType);
                stmt.setInt(3, entityId);
                stmt.setString(4, entry.getValue());
                stmt.addBatch();
            }
            stmt.executeBatch();
            conn.commit();
            return true;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Lỗi lưu batch giá trị trường tùy chỉnh cho entity " + entityType + " ID " + entityId, e);
        }
        return false;
    }

    public boolean deleteValuesByEntity(String entityType, int entityId) {
        String sql = "DELETE FROM custom_field_values WHERE entity_type = ? AND entity_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, entityType);
            stmt.setInt(2, entityId);
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Lỗi xóa giá trị trường tùy chỉnh cho entity " + entityType + " ID " + entityId, e);
        }
        return false;
    }
}

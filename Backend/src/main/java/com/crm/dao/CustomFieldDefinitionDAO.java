package com.crm.dao;

import com.crm.model.CustomFieldDefinition;
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

    public List<CustomFieldDefinition> getDefinitions(String entityType, String status) {
        List<CustomFieldDefinition> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder("SELECT * FROM custom_field_definitions WHERE 1=1 ");
        List<Object> params = new ArrayList<>();

        if (entityType != null && !entityType.trim().isEmpty()) {
            sql.append("AND entity_type = ? ");
            params.add(entityType.trim());
        }
        if (status != null && !status.trim().isEmpty()) {
            sql.append("AND status = ? ");
            params.add(status.trim());
        }
        sql.append("ORDER BY display_order ASC, field_id ASC");

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                stmt.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSetToDefinition(rs));
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Lỗi truy vấn danh sách trường tùy chỉnh", e);
        }
        return list;
    }

    public CustomFieldDefinition getById(int fieldId) {
        String sql = "SELECT * FROM custom_field_definitions WHERE field_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, fieldId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToDefinition(rs);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Lỗi lấy chi tiết trường tùy chỉnh ID = " + fieldId, e);
        }
        return null;
    }

    public CustomFieldDefinition getByKey(String entityType, String fieldKey) {
        String sql = "SELECT * FROM custom_field_definitions WHERE entity_type = ? AND field_key = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, entityType);
            stmt.setString(2, fieldKey);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToDefinition(rs);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Lỗi lấy trường tùy chỉnh theo key: " + fieldKey, e);
        }
        return null;
    }

    public boolean insert(CustomFieldDefinition def) {
        String sql = "INSERT INTO custom_field_definitions (entity_type, field_key, field_label, field_type, options, is_required, default_value, display_order, status) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            stmt.setString(1, def.getEntityType());
            stmt.setString(2, def.getFieldKey());
            stmt.setString(3, def.getFieldLabel());
            stmt.setString(4, def.getFieldType() != null ? def.getFieldType() : "TEXT");
            stmt.setString(5, def.getOptions());
            stmt.setBoolean(6, def.isRequired());
            stmt.setString(7, def.getDefaultValue());
            stmt.setInt(8, def.getDisplayOrder());
            stmt.setString(9, def.getStatus() != null ? def.getStatus() : "ACTIVE");

            int affected = stmt.executeUpdate();
            if (affected > 0) {
                try (ResultSet generatedKeys = stmt.getGeneratedKeys()) {
                    if (generatedKeys.next()) {
                        def.setFieldId(generatedKeys.getInt(1));
                    }
                }
                return true;
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Lỗi thêm trường tùy chỉnh", e);
        }
        return false;
    }

    public boolean update(CustomFieldDefinition def) {
        String sql = "UPDATE custom_field_definitions SET field_label = ?, field_type = ?, options = ?, is_required = ?, default_value = ?, display_order = ?, status = ? " +
                "WHERE field_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, def.getFieldLabel());
            stmt.setString(2, def.getFieldType());
            stmt.setString(3, def.getOptions());
            stmt.setBoolean(4, def.isRequired());
            stmt.setString(5, def.getDefaultValue());
            stmt.setInt(6, def.getDisplayOrder());
            stmt.setString(7, def.getStatus());
            stmt.setInt(8, def.getFieldId());

            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Lỗi cập nhật trường tùy chỉnh ID = " + def.getFieldId(), e);
        }
        return false;
    }

    public boolean delete(int fieldId) {
        String sql = "DELETE FROM custom_field_definitions WHERE field_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, fieldId);
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Lỗi xóa trường tùy chỉnh ID = " + fieldId, e);
        }
        return false;
    }

    private CustomFieldDefinition mapResultSetToDefinition(ResultSet rs) throws SQLException {
        CustomFieldDefinition def = new CustomFieldDefinition();
        def.setFieldId(rs.getInt("field_id"));
        def.setEntityType(rs.getString("entity_type"));
        def.setFieldKey(rs.getString("field_key"));
        def.setFieldLabel(rs.getString("field_label"));
        def.setFieldType(rs.getString("field_type"));
        def.setOptions(rs.getString("options"));
        def.setRequired(rs.getBoolean("is_required"));
        def.setDefaultValue(rs.getString("default_value"));
        def.setDisplayOrder(rs.getInt("display_order"));
        def.setStatus(rs.getString("status"));
        def.setCreatedAt(rs.getTimestamp("created_at"));
        def.setUpdatedAt(rs.getTimestamp("updated_at"));
        return def;
    }
}

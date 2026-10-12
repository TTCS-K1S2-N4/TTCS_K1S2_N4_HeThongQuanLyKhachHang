package com.crm.dao;

import com.crm.model.LeadWebForm;
import com.crm.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class LeadWebFormDAO {

    public List<LeadWebForm> getAllWebForms() {
        List<LeadWebForm> list = new ArrayList<>();
        String sql = "SELECT wf.*, u.full_name AS creator_name " +
                     "FROM lead_web_forms wf " +
                     "LEFT JOIN users u ON wf.created_by = u.user_id " +
                     "ORDER BY wf.form_id DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapResultSet(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public LeadWebForm getById(int formId) {
        String sql = "SELECT wf.*, u.full_name AS creator_name " +
                     "FROM lead_web_forms wf " +
                     "LEFT JOIN users u ON wf.created_by = u.user_id " +
                     "WHERE wf.form_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, formId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSet(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public boolean createWebForm(LeadWebForm form) {
        String sql = "INSERT INTO lead_web_forms (form_name, description, embed_code, allowed_domains, " +
                     "success_redirect_url, is_active, spam_protection_enabled, fields_json, created_by) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, form.getFormName());
            ps.setString(2, form.getDescription());
            ps.setString(3, form.getEmbedCode());
            ps.setString(4, form.getAllowedDomains());
            ps.setString(5, form.getSuccessRedirectUrl());
            ps.setBoolean(6, form.isActive());
            ps.setBoolean(7, form.isSpamProtectionEnabled());
            ps.setString(8, form.getFieldsJson());
            if (form.getCreatedBy() != null) {
                ps.setInt(9, form.getCreatedBy());
            } else {
                ps.setNull(9, java.sql.Types.INTEGER);
            }
            int rows = ps.executeUpdate();
            if (rows > 0) {
                try (ResultSet keys = ps.getGeneratedKeys()) {
                    if (keys.next()) {
                        form.setFormId(keys.getInt(1));
                    }
                }
                return true;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean updateWebForm(LeadWebForm form) {
        String sql = "UPDATE lead_web_forms SET form_name = ?, description = ?, embed_code = ?, allowed_domains = ?, " +
                     "success_redirect_url = ?, is_active = ?, spam_protection_enabled = ?, fields_json = ? " +
                     "WHERE form_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, form.getFormName());
            ps.setString(2, form.getDescription());
            ps.setString(3, form.getEmbedCode());
            ps.setString(4, form.getAllowedDomains());
            ps.setString(5, form.getSuccessRedirectUrl());
            ps.setBoolean(6, form.isActive());
            ps.setBoolean(7, form.isSpamProtectionEnabled());
            ps.setString(8, form.getFieldsJson());
            ps.setInt(9, form.getFormId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean deleteWebForm(int formId) {
        String sql = "DELETE FROM lead_web_forms WHERE form_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, formId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    private LeadWebForm mapResultSet(ResultSet rs) throws SQLException {
        LeadWebForm wf = new LeadWebForm();
        wf.setFormId(rs.getInt("form_id"));
        wf.setFormName(rs.getString("form_name"));
        wf.setDescription(rs.getString("description"));
        wf.setEmbedCode(rs.getString("embed_code"));
        wf.setAllowedDomains(rs.getString("allowed_domains"));
        wf.setSuccessRedirectUrl(rs.getString("success_redirect_url"));
        wf.setActive(rs.getBoolean("is_active"));
        wf.setSpamProtectionEnabled(rs.getBoolean("spam_protection_enabled"));
        wf.setFieldsJson(rs.getString("fields_json"));
        wf.setCreatedBy((Integer) rs.getObject("created_by"));
        wf.setCreatedAt(rs.getTimestamp("created_at"));
        wf.setUpdatedAt(rs.getTimestamp("updated_at"));

        try {
            wf.setCreatorName(rs.getString("creator_name"));
        } catch (SQLException ignore) {}

        return wf;
    }
}

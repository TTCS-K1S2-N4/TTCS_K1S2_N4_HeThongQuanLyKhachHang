package com.crm.dao;

import com.crm.model.Lead;
import com.crm.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class LeadDAO {

    public List<Lead> getAllLeads() {
        return getLeads(0, 1000, null, null, null, null);
    }

    /**
     * Lấy toàn bộ Lead không giới hạn số lượng (dùng cho tính toán lại điểm tự động).
     */
    public List<Lead> getAllLeadsUnlimited() {
        return getLeads(0, 0, null, null, null, null);
    }

    public List<Lead> getLeads(int offset, int limit, String search, String status, String rating, Integer ownerId) {
        List<Lead> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
            "SELECT l.*, s.source_name, wf.form_name AS web_form_name, u.full_name AS owner_name, camp.campaign_name " +
            "FROM leads l " +
            "LEFT JOIN lead_sources s ON l.lead_source_id = s.source_id " +
            "LEFT JOIN lead_web_forms wf ON l.web_form_id = wf.form_id " +
            "LEFT JOIN users u ON l.owner_id = u.user_id " +
            "LEFT JOIN campaigns camp ON l.campaign_id = camp.campaign_id " +
            "WHERE 1=1 "
        );

        List<Object> params = new ArrayList<>();

        if (search != null && !search.trim().isEmpty()) {
            sql.append("AND (l.full_name LIKE ? OR l.email LIKE ? OR l.phone LIKE ? OR l.company LIKE ?) ");
            String keyword = "%" + search.trim() + "%";
            params.add(keyword);
            params.add(keyword);
            params.add(keyword);
            params.add(keyword);
        }

        if (status != null && !status.trim().isEmpty()) {
            sql.append("AND l.status = ? ");
            params.add(status.trim());
        }

        if (rating != null && !rating.trim().isEmpty()) {
            sql.append("AND l.rating = ? ");
            params.add(rating.trim());
        }

        if (ownerId != null && ownerId > 0) {
            sql.append("AND l.owner_id = ? ");
            params.add(ownerId);
        }

        sql.append("ORDER BY l.lead_id DESC ");

        if (limit > 0) {
            sql.append("LIMIT ? OFFSET ? ");
            params.add(limit);
            params.add(offset);
        }

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSet(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public int countLeads(String search, String status, String rating, Integer ownerId) {
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM leads l WHERE 1=1 ");
        List<Object> params = new ArrayList<>();

        if (search != null && !search.trim().isEmpty()) {
            sql.append("AND (l.full_name LIKE ? OR l.email LIKE ? OR l.phone LIKE ? OR l.company LIKE ?) ");
            String keyword = "%" + search.trim() + "%";
            params.add(keyword);
            params.add(keyword);
            params.add(keyword);
            params.add(keyword);
        }

        if (status != null && !status.trim().isEmpty()) {
            sql.append("AND l.status = ? ");
            params.add(status.trim());
        }

        if (rating != null && !rating.trim().isEmpty()) {
            sql.append("AND l.rating = ? ");
            params.add(rating.trim());
        }

        if (ownerId != null && ownerId > 0) {
            sql.append("AND l.owner_id = ? ");
            params.add(ownerId);
        }

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    public Lead getById(int leadId) {
        String sql = "SELECT l.*, s.source_name, wf.form_name AS web_form_name, u.full_name AS owner_name, camp.campaign_name " +
                     "FROM leads l " +
                     "LEFT JOIN lead_sources s ON l.lead_source_id = s.source_id " +
                     "LEFT JOIN lead_web_forms wf ON l.web_form_id = wf.form_id " +
                     "LEFT JOIN users u ON l.owner_id = u.user_id " +
                     "LEFT JOIN campaigns camp ON l.campaign_id = camp.campaign_id " +
                     "WHERE l.lead_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, leadId);
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

    public Lead getByEmail(String email) {
        if (email == null || email.trim().isEmpty()) return null;
        String sql = "SELECT l.*, s.source_name, wf.form_name AS web_form_name, u.full_name AS owner_name, camp.campaign_name " +
                     "FROM leads l " +
                     "LEFT JOIN lead_sources s ON l.lead_source_id = s.source_id " +
                     "LEFT JOIN lead_web_forms wf ON l.web_form_id = wf.form_id " +
                     "LEFT JOIN users u ON l.owner_id = u.user_id " +
                     "LEFT JOIN campaigns camp ON l.campaign_id = camp.campaign_id " +
                     "WHERE l.email = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, email.trim());
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

    public Lead getByPhone(String phone) {
        if (phone == null || phone.trim().isEmpty()) return null;
        String sql = "SELECT l.*, s.source_name, wf.form_name AS web_form_name, u.full_name AS owner_name, camp.campaign_name " +
                     "FROM leads l " +
                     "LEFT JOIN lead_sources s ON l.lead_source_id = s.source_id " +
                     "LEFT JOIN lead_web_forms wf ON l.web_form_id = wf.form_id " +
                     "LEFT JOIN users u ON l.owner_id = u.user_id " +
                     "LEFT JOIN campaigns camp ON l.campaign_id = camp.campaign_id " +
                     "WHERE l.phone = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, phone.trim());
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

    public boolean createLead(Lead lead) {
        String sql = "INSERT INTO leads (full_name, first_name, last_name, title, company, company_name, contact_name, email, phone, " +
                     "lead_source_id, web_form_id, status, rating, score, industry, address, city, state, country, zip_code, owner_id, notes, campaign_id) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            setLeadStatementParameters(ps, lead);
            int rows = ps.executeUpdate();
            if (rows > 0) {
                try (ResultSet keys = ps.getGeneratedKeys()) {
                    if (keys.next()) {
                        lead.setLeadId(keys.getInt(1));
                    }
                }
                return true;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean updateLead(Lead lead) {
        String sql = "UPDATE leads SET full_name = ?, first_name = ?, last_name = ?, title = ?, company = ?, company_name = ?, contact_name = ?, email = ?, phone = ?, " +
                     "lead_source_id = ?, web_form_id = ?, status = ?, rating = ?, score = ?, industry = ?, address = ?, city = ?, state = ?, " +
                     "country = ?, zip_code = ?, owner_id = ?, notes = ?, campaign_id = ? WHERE lead_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            setLeadStatementParameters(ps, lead);
            ps.setInt(24, lead.getLeadId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean deleteLead(int leadId) {
        String sql = "DELETE FROM leads WHERE lead_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, leadId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public int batchCreateLeads(List<Lead> leads) {
        if (leads == null || leads.isEmpty()) return 0;
        String sql = "INSERT INTO leads (full_name, first_name, last_name, title, company, company_name, contact_name, email, phone, " +
                     "lead_source_id, web_form_id, status, rating, score, industry, address, city, state, country, zip_code, owner_id, notes, campaign_id) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        int count = 0;
        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);
            try (PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
                for (Lead lead : leads) {
                    setLeadStatementParameters(ps, lead);
                    ps.addBatch();
                }
                int[] results = ps.executeBatch();
                conn.commit();
                for (int r : results) {
                    if (r >= 0 || r == Statement.SUCCESS_NO_INFO) count++;
                }
            }
        } catch (SQLException e) {
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
            }
            e.printStackTrace();
        } finally {
            if (conn != null) {
                try { conn.setAutoCommit(true); conn.close(); } catch (SQLException ex) { ex.printStackTrace(); }
            }
        }
        return count;
    }

    private void setLeadStatementParameters(PreparedStatement ps, Lead lead) throws SQLException {
        ps.setString(1, lead.getFullName());
        ps.setString(2, lead.getFirstName());
        ps.setString(3, lead.getLastName());
        ps.setString(4, lead.getTitle());
        ps.setString(5, lead.getCompany());
        ps.setString(6, lead.getCompany()); // company_name
        ps.setString(7, lead.getFullName()); // contact_name
        ps.setString(8, lead.getEmail());
        ps.setString(9, lead.getPhone());

        if (lead.getLeadSourceId() != null) ps.setInt(10, lead.getLeadSourceId());
        else ps.setNull(10, Types.INTEGER);

        if (lead.getWebFormId() != null) ps.setInt(11, lead.getWebFormId());
        else ps.setNull(11, Types.INTEGER);

        ps.setString(12, lead.getStatus() != null ? lead.getStatus() : "NEW");
        ps.setString(13, lead.getRating() != null ? lead.getRating() : "WARM");
        ps.setInt(14, lead.getScore());
        ps.setString(15, lead.getIndustry());
        ps.setString(16, lead.getAddress());
        ps.setString(17, lead.getCity());
        ps.setString(18, lead.getState());
        ps.setString(19, lead.getCountry());
        ps.setString(20, lead.getZipCode());

        if (lead.getOwnerId() != null) ps.setInt(21, lead.getOwnerId());
        else ps.setNull(21, Types.INTEGER);

        ps.setString(22, lead.getNotes());

        if (lead.getCampaignId() != null && lead.getCampaignId() > 0) ps.setInt(23, lead.getCampaignId());
        else ps.setNull(23, Types.INTEGER);
    }

    private Lead mapResultSet(ResultSet rs) throws SQLException {
        Lead lead = new Lead();
        lead.setLeadId(rs.getInt("lead_id"));
        lead.setFullName(rs.getString("full_name"));
        lead.setFirstName(rs.getString("first_name"));
        lead.setLastName(rs.getString("last_name"));
        lead.setTitle(rs.getString("title"));
        lead.setCompany(rs.getString("company"));
        lead.setEmail(rs.getString("email"));
        lead.setPhone(rs.getString("phone"));
        lead.setLeadSourceId((Integer) rs.getObject("lead_source_id"));
        lead.setWebFormId((Integer) rs.getObject("web_form_id"));
        lead.setStatus(rs.getString("status"));
        lead.setRating(rs.getString("rating"));
        lead.setScore(rs.getInt("score"));
        lead.setIndustry(rs.getString("industry"));
        lead.setAddress(rs.getString("address"));
        lead.setCity(rs.getString("city"));
        lead.setState(rs.getString("state"));
        lead.setCountry(rs.getString("country"));
        lead.setZipCode(rs.getString("zip_code"));
        lead.setOwnerId((Integer) rs.getObject("owner_id"));
        lead.setNotes(rs.getString("notes"));
        lead.setCampaignId((Integer) rs.getObject("campaign_id"));
        lead.setCreatedAt(rs.getTimestamp("created_at"));
        lead.setUpdatedAt(rs.getTimestamp("updated_at"));

        try { lead.setAssignedAt(rs.getTimestamp("assigned_at")); } catch (SQLException ignore) {}
        try { lead.setSlaDueDate(rs.getTimestamp("sla_due_date")); } catch (SQLException ignore) {}
        try { lead.setOverdue(rs.getBoolean("is_overdue")); } catch (SQLException ignore) {}
        try { lead.setSlaStatus(rs.getString("sla_status")); } catch (SQLException ignore) {}

        try { lead.setSourceName(rs.getString("source_name")); } catch (SQLException ignore) {}
        try { lead.setWebFormName(rs.getString("web_form_name")); } catch (SQLException ignore) {}
        try { lead.setOwnerName(rs.getString("owner_name")); } catch (SQLException ignore) {}
        try { lead.setCampaignName(rs.getString("campaign_name")); } catch (SQLException ignore) {}

        try { lead.setConvertedCustomerId((Integer) rs.getObject("converted_customer_id")); } catch (SQLException ignore) {}
        try { lead.setConvertedContactId((Integer) rs.getObject("converted_contact_id")); } catch (SQLException ignore) {}
        try { lead.setConvertedOpportunityId((Integer) rs.getObject("converted_opportunity_id")); } catch (SQLException ignore) {}

        return lead;
    }
}

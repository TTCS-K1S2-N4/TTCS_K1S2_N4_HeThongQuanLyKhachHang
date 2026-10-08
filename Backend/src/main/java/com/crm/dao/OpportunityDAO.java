package com.crm.dao;

import com.crm.model.Opportunity;
import com.crm.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class OpportunityDAO {

    public OpportunityDAO() {
        ensureSchema();
    }

    private void ensureSchema() {
        String alterSql = "ALTER TABLE opportunities " +
                "ADD COLUMN IF NOT EXISTS customer_id INT NULL, " +
                "ADD COLUMN IF NOT EXISTS stage VARCHAR(100) NULL, " +
                "ADD COLUMN IF NOT EXISTS status VARCHAR(50) DEFAULT 'ACTIVE', " +
                "ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP;";
        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement()) {
            try { stmt.executeUpdate(alterSql); } catch (SQLException ignored) {}
        } catch (SQLException e) {
            // connection might be unavailable in static context
        }
    }

    private Opportunity mapResultSetToOpportunity(ResultSet rs) throws SQLException {
        Opportunity obj = new Opportunity();
        obj.setOpportunityid(rs.getInt("opportunity_id"));
        obj.setTitle(rs.getString("title"));
        obj.setAmount(rs.getDouble("amount"));
        obj.setOwnerId(rs.getInt("owner_id"));

        try {
            int stageId = rs.getInt("pipeline_stage_id");
            if (!rs.wasNull()) obj.setPipelineStageId(stageId);
        } catch (SQLException ignored) {}

        try {
            double prob = rs.getDouble("probability");
            if (!rs.wasNull()) obj.setProbability(prob);
        } catch (SQLException ignored) {}

        try {
            int reasonId = rs.getInt("win_loss_reason_id");
            if (!rs.wasNull()) obj.setWinLossReasonId(reasonId);
        } catch (SQLException ignored) {}

        try {
            int compId = rs.getInt("competitor_id");
            if (!rs.wasNull()) obj.setCompetitorId(compId);
        } catch (SQLException ignored) {}

        try {
            obj.setCloseDate(rs.getTimestamp("close_date"));
        } catch (SQLException ignored) {}

        try {
            obj.setStageName(rs.getString("stage_name"));
        } catch (SQLException ignored) {}

        try {
            obj.setReasonName(rs.getString("reason_name"));
        } catch (SQLException ignored) {}

        try {
            obj.setCompetitorName(rs.getString("competitor_name"));
        } catch (SQLException ignored) {}

        obj.setCreatedAt(rs.getTimestamp("created_at"));

        try {
            int cid = rs.getInt("customer_id");
            if (!rs.wasNull()) obj.setCustomerId(cid);
        } catch (SQLException ignored) {}

        try { obj.setStage(rs.getString("stage")); } catch (SQLException ignored) {}
        try { obj.setStatus(rs.getString("status")); } catch (SQLException ignored) {}
        try { obj.setUpdatedAt(rs.getTimestamp("updated_at")); } catch (SQLException ignored) {}

        return obj;
    }

    public List<Opportunity> getList(String keyword, List<Integer> ownerIds, int page, int pageSize) {
        return getList(keyword, ownerIds, null, null, page, pageSize);
    }

    public List<Opportunity> getList(String keyword, List<Integer> ownerIds, Integer filterFieldId, String filterFieldValue, int page, int pageSize) {
        if (ownerIds != null && ownerIds.isEmpty()) return new ArrayList<>();
        
        List<Opportunity> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
            "SELECT DISTINCT o.*, ps.stage_name, wlr.reason_name, c.competitor_name " +
            "FROM opportunities o " +
            "LEFT JOIN pipeline_stages ps ON o.pipeline_stage_id = ps.pipeline_stage_id " +
            "LEFT JOIN win_loss_reasons wlr ON o.win_loss_reason_id = wlr.reason_id " +
            "LEFT JOIN competitors c ON o.competitor_id = c.competitor_id "
        );
        if (filterFieldId != null && filterFieldValue != null && !filterFieldValue.trim().isEmpty()) {
            sql.append("JOIN custom_field_values cfv ON o.opportunity_id = cfv.entity_id AND cfv.entity_type = 'OPPORTUNITY' ");
        }
        sql.append("WHERE 1=1 ");
        
        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append("AND o.title LIKE ? ");
        }
        
        if (ownerIds != null) {
            String inClause = String.join(",", java.util.Collections.nCopies(ownerIds.size(), "?"));
            sql.append("AND o.owner_id IN (").append(inClause).append(") ");
        }

        if (filterFieldId != null && filterFieldValue != null && !filterFieldValue.trim().isEmpty()) {
            sql.append("AND cfv.field_id = ? AND cfv.field_value LIKE ? ");
        }
        
        sql.append("ORDER BY o.opportunity_id DESC LIMIT ? OFFSET ?");

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            int idx = 1;
            if (keyword != null && !keyword.trim().isEmpty()) {
                ps.setString(idx++, "%" + keyword.trim() + "%");
            }
            if (ownerIds != null) {
                for (Integer oid : ownerIds) {
                    ps.setInt(idx++, oid);
                }
            }
            if (filterFieldId != null && filterFieldValue != null && !filterFieldValue.trim().isEmpty()) {
                ps.setInt(idx++, filterFieldId);
                ps.setString(idx++, "%" + filterFieldValue.trim() + "%");
            }
            ps.setInt(idx++, pageSize);
            ps.setInt(idx++, (page - 1) * pageSize);

            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                list.add(mapResultSetToOpportunity(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<Opportunity> getListForExport(String keyword, List<Integer> ownerIds) {
        if (ownerIds != null && ownerIds.isEmpty()) return new ArrayList<>();
        
        List<Opportunity> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
            "SELECT o.*, ps.stage_name, wlr.reason_name, c.competitor_name " +
            "FROM opportunities o " +
            "LEFT JOIN pipeline_stages ps ON o.pipeline_stage_id = ps.pipeline_stage_id " +
            "LEFT JOIN win_loss_reasons wlr ON o.win_loss_reason_id = wlr.reason_id " +
            "LEFT JOIN competitors c ON o.competitor_id = c.competitor_id " +
            "WHERE 1=1"
        );
        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append(" AND o.title LIKE ?");
        }
        
        if (ownerIds != null) {
            String inClause = String.join(",", java.util.Collections.nCopies(ownerIds.size(), "?"));
            sql.append(" AND o.owner_id IN (").append(inClause).append(")");
        }
        
        sql.append(" ORDER BY o.opportunity_id DESC");

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            int idx = 1;
            if (keyword != null && !keyword.trim().isEmpty()) {
                ps.setString(idx++, "%" + keyword.trim() + "%");
            }
            if (ownerIds != null) {
                for (Integer oid : ownerIds) {
                    ps.setInt(idx++, oid);
                }
            }

            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                list.add(mapResultSetToOpportunity(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public int count(String keyword, List<Integer> ownerIds) {
        return count(keyword, ownerIds, null, null);
    }

    public int count(String keyword, List<Integer> ownerIds, Integer filterFieldId, String filterFieldValue) {
        if (ownerIds != null && ownerIds.isEmpty()) return 0;
        
        StringBuilder sql = new StringBuilder("SELECT COUNT(DISTINCT o.opportunity_id) FROM opportunities o ");
        if (filterFieldId != null && filterFieldValue != null && !filterFieldValue.trim().isEmpty()) {
            sql.append("JOIN custom_field_values cfv ON o.opportunity_id = cfv.entity_id AND cfv.entity_type = 'OPPORTUNITY' ");
        }
        sql.append("WHERE 1=1 ");

        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append("AND o.title LIKE ? ");
        }
        if (ownerIds != null) {
            String inClause = String.join(",", java.util.Collections.nCopies(ownerIds.size(), "?"));
            sql.append("AND o.owner_id IN (").append(inClause).append(") ");
        }
        if (filterFieldId != null && filterFieldValue != null && !filterFieldValue.trim().isEmpty()) {
            sql.append("AND cfv.field_id = ? AND cfv.field_value LIKE ? ");
        }

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            int idx = 1;
            if (keyword != null && !keyword.trim().isEmpty()) {
                ps.setString(idx++, "%" + keyword.trim() + "%");
            }
            if (ownerIds != null) {
                for (Integer oid : ownerIds) {
                    ps.setInt(idx++, oid);
                }
            }
            if (filterFieldId != null && filterFieldValue != null && !filterFieldValue.trim().isEmpty()) {
                ps.setInt(idx++, filterFieldId);
                ps.setString(idx++, "%" + filterFieldValue.trim() + "%");
            }
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    public Opportunity findById(int id) {
        String sql = "SELECT o.*, ps.stage_name, wlr.reason_name, c.competitor_name " +
                     "FROM opportunities o " +
                     "LEFT JOIN pipeline_stages ps ON o.pipeline_stage_id = ps.pipeline_stage_id " +
                     "LEFT JOIN win_loss_reasons wlr ON o.win_loss_reason_id = wlr.reason_id " +
                     "LEFT JOIN competitors c ON o.competitor_id = c.competitor_id " +
                     "WHERE o.opportunity_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return mapResultSetToOpportunity(rs);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public List<Opportunity> getOpportunitiesByCustomerId(int customerId) {
        List<Opportunity> list = new ArrayList<>();
        String sql = "SELECT o.*, ps.stage_name, wlr.reason_name, c.competitor_name " +
                     "FROM opportunities o " +
                     "LEFT JOIN pipeline_stages ps ON o.pipeline_stage_id = ps.pipeline_stage_id " +
                     "LEFT JOIN win_loss_reasons wlr ON o.win_loss_reason_id = wlr.reason_id " +
                     "LEFT JOIN competitors c ON o.competitor_id = c.competitor_id " +
                     "WHERE o.customer_id = ? ORDER BY o.opportunity_id DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, customerId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                list.add(mapResultSetToOpportunity(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<Opportunity> getOpenOpportunitiesByCustomerId(int customerId) {
        List<Opportunity> list = new ArrayList<>();
        String sql = "SELECT o.*, ps.stage_name, wlr.reason_name, c.competitor_name " +
                     "FROM opportunities o " +
                     "LEFT JOIN pipeline_stages ps ON o.pipeline_stage_id = ps.pipeline_stage_id " +
                     "LEFT JOIN win_loss_reasons wlr ON o.win_loss_reason_id = wlr.reason_id " +
                     "LEFT JOIN competitors c ON o.competitor_id = c.competitor_id " +
                     "WHERE o.customer_id = ? AND (o.stage IS NULL OR (o.stage NOT LIKE '%WON%' AND o.stage NOT LIKE '%LOST%' AND o.stage NOT LIKE '%CLOSED%')) ORDER BY o.opportunity_id DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, customerId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                list.add(mapResultSetToOpportunity(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<Opportunity> getClosedOpportunitiesByCustomerId(int customerId) {
        List<Opportunity> list = new ArrayList<>();
        String sql = "SELECT o.*, ps.stage_name, wlr.reason_name, c.competitor_name " +
                     "FROM opportunities o " +
                     "LEFT JOIN pipeline_stages ps ON o.pipeline_stage_id = ps.pipeline_stage_id " +
                     "LEFT JOIN win_loss_reasons wlr ON o.win_loss_reason_id = wlr.reason_id " +
                     "LEFT JOIN competitors c ON o.competitor_id = c.competitor_id " +
                     "WHERE o.customer_id = ? AND (o.stage LIKE '%WON%' OR o.stage LIKE '%LOST%' OR o.stage LIKE '%CLOSED%') ORDER BY o.opportunity_id DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, customerId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                list.add(mapResultSetToOpportunity(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public double calculateTotalOpenAmount(int customerId) {
        String sql = "SELECT SUM(amount) FROM opportunities WHERE customer_id = ? AND (stage IS NULL OR (stage NOT LIKE '%WON%' AND stage NOT LIKE '%LOST%' AND stage NOT LIKE '%CLOSED%'))";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, customerId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getDouble(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0.0;
    }

    public double calculateTotalSignedAmount(int customerId) {
        String sql = "SELECT SUM(o.amount) FROM opportunities o " +
                     "LEFT JOIN pipeline_stages ps ON o.pipeline_stage_id = ps.pipeline_stage_id " +
                     "WHERE o.customer_id = ? AND (" +
                     "  o.stage LIKE '%WON%' OR " +
                     "  o.stage LIKE '%CLOSED_WON%' OR " +
                     "  ps.stage_name LIKE '%Won%' OR " +
                     "  ps.stage_name LIKE '%thành công%' OR " +
                     "  ps.default_probability = 100" +
                     ")";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, customerId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getDouble(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0.0;
    }

    public boolean insert(Opportunity opp) {
        String sql = "INSERT INTO opportunities (title, amount, owner_id, pipeline_stage_id, probability, win_loss_reason_id, competitor_id, close_date, customer_id, stage, status) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, opp.getTitle());
            ps.setObject(2, opp.getAmount());
            ps.setInt(3, opp.getOwnerId());
            ps.setObject(4, opp.getPipelineStageId());
            ps.setObject(5, opp.getProbability());
            ps.setObject(6, opp.getWinLossReasonId());
            ps.setObject(7, opp.getCompetitorId());
            ps.setTimestamp(8, opp.getCloseDate());
            ps.setObject(9, opp.getCustomerId() > 0 ? opp.getCustomerId() : null);
            ps.setString(10, opp.getStage());
            ps.setString(11, opp.getStatus() != null ? opp.getStatus() : "ACTIVE");
            int rows = ps.executeUpdate();
            if (rows > 0) {
                try (ResultSet keys = ps.getGeneratedKeys()) {
                    if (keys.next()) {
                        opp.setOpportunityId(keys.getInt(1));
                    }
                }
                return true;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean update(Opportunity opp) {
        String sql = "UPDATE opportunities SET title = ?, amount = ?, owner_id = ?, pipeline_stage_id = ?, probability = ?, win_loss_reason_id = ?, competitor_id = ?, close_date = ?, customer_id = ?, stage = ?, status = ? WHERE opportunity_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, opp.getTitle());
            ps.setObject(2, opp.getAmount());
            ps.setInt(3, opp.getOwnerId());
            ps.setObject(4, opp.getPipelineStageId());
            ps.setObject(5, opp.getProbability());
            ps.setObject(6, opp.getWinLossReasonId());
            ps.setObject(7, opp.getCompetitorId());
            ps.setTimestamp(8, opp.getCloseDate());
            ps.setObject(9, opp.getCustomerId() > 0 ? opp.getCustomerId() : null);
            ps.setString(10, opp.getStage());
            ps.setString(11, opp.getStatus());
            ps.setInt(12, opp.getOpportunityId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean delete(int opportunityId) {
        String sql = "DELETE FROM opportunities WHERE opportunity_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, opportunityId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean updateTargetAmount(int opportunityId, double targetAmount, int performedBy) {
        Opportunity oldObj = findById(opportunityId);
        String sql = "UPDATE opportunities SET amount = ? WHERE opportunity_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setDouble(1, targetAmount);
            ps.setInt(2, opportunityId);
            boolean ok = ps.executeUpdate() > 0;
            if (ok) {
                com.crm.model.AuditLog log = new com.crm.model.AuditLog();
                log.setAction("TARGET_UPDATE");
                log.setUserId(performedBy);
                log.setTargetUserId(opportunityId);
                log.setDetails("Cập nhật chỉ tiêu / doanh số cơ hội ID " + opportunityId);
                log.setOldValue("Amount: " + (oldObj != null ? oldObj.getAmount() : 0));
                log.setNewValue("Amount: " + targetAmount);
                new com.crm.dao.AuditLogDAO().insertLog(log);
            }
            return ok;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
}

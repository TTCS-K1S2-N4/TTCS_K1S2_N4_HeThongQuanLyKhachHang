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
        if (ownerIds != null && ownerIds.isEmpty()) return new ArrayList<>();
        
        List<Opportunity> list = new ArrayList<>();
        String sql = "SELECT * FROM opportunities WHERE 1=1";
        if (keyword != null && !keyword.trim().isEmpty()) {
            sql += " AND title LIKE ?";
        }
        
        if (ownerIds != null) {
            String inClause = String.join(",", java.util.Collections.nCopies(ownerIds.size(), "?"));
            sql += " AND owner_id IN (" + inClause + ")";
        }
        
        sql += " ORDER BY opportunity_id DESC LIMIT ? OFFSET ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            int idx = 1;
            if (keyword != null && !keyword.trim().isEmpty()) {
                ps.setString(idx++, "%" + keyword.trim() + "%");
            }
            if (ownerIds != null) {
                for (Integer oid : ownerIds) {
                    ps.setInt(idx++, oid);
                }
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

    public int count(String keyword, List<Integer> ownerIds) {
        if (ownerIds != null && ownerIds.isEmpty()) return 0;
        
        String sql = "SELECT COUNT(*) FROM opportunities WHERE 1=1";
        if (keyword != null && !keyword.trim().isEmpty()) {
            sql += " AND title LIKE ?";
        }
        if (ownerIds != null) {
            String inClause = String.join(",", java.util.Collections.nCopies(ownerIds.size(), "?"));
            sql += " AND owner_id IN (" + inClause + ")";
        }

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
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
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    public Opportunity findById(int id) {
        String sql = "SELECT * FROM opportunities WHERE opportunity_id = ?";
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
        String sql = "SELECT * FROM opportunities WHERE customer_id = ? ORDER BY opportunity_id DESC";
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
        String sql = "SELECT * FROM opportunities WHERE customer_id = ? AND (stage IS NULL OR (stage NOT LIKE '%WON%' AND stage NOT LIKE '%LOST%' AND stage NOT LIKE '%CLOSED%')) ORDER BY opportunity_id DESC";
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
        String sql = "SELECT * FROM opportunities WHERE customer_id = ? AND (stage LIKE '%WON%' OR stage LIKE '%LOST%' OR stage LIKE '%CLOSED%') ORDER BY opportunity_id DESC";
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

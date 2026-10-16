package com.crm.dao;

import com.crm.model.LeadAssignmentRule;
import com.crm.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * LeadAssignmentRuleDAO - DAO xử lý các quy tắc phân bổ Lead và trạng thái Round-Robin.
 * Sử dụng JDBC PreparedStatement kết nối trực tiếp CSDL MySQL crm_db.
 */
public class LeadAssignmentRuleDAO {

    private static final Logger LOGGER = Logger.getLogger(LeadAssignmentRuleDAO.class.getName());

    public static class LeadLockRecord {
        private final int leadId;
        private final String contactName;
        private final String companyName;
        private final String status;
        private final Integer ownerId;
        private final String region;
        private final String industry;

        public LeadLockRecord(int leadId, String contactName, String companyName, String status, Integer ownerId, String region, String industry) {
            this.leadId = leadId;
            this.contactName = contactName;
            this.companyName = companyName;
            this.status = status;
            this.ownerId = ownerId;
            this.region = region;
            this.industry = industry;
        }

        public int getLeadId() { return leadId; }
        public String getContactName() { return contactName; }
        public String getCompanyName() { return companyName; }
        public String getStatus() { return status; }
        public Integer getOwnerId() { return ownerId; }
        public String getRegion() { return region; }
        public String getIndustry() { return industry; }
    }

    /**
     * Lấy danh sách quy tắc phân bổ đang hoạt động (kết nối độc lập).
     */
    public List<LeadAssignmentRule> getActiveRules() {
        try (Connection conn = DBConnection.getConnection()) {
            return getActiveRules(conn);
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Lỗi lấy danh sách LeadAssignmentRule", e);
            return new ArrayList<>();
        }
    }

    /**
     * Lấy danh sách quy tắc phân bổ đang hoạt động sử dụng Connection được truyền vào.
     */
    public List<LeadAssignmentRule> getActiveRules(Connection conn) throws SQLException {
        List<LeadAssignmentRule> list = new ArrayList<>();
        String sql = "SELECT rule_id, rule_name, priority, criterion, criterion_value, " +
                     "team_id, assignee_id, last_assigned_user_id, is_active, created_at, updated_at " +
                     "FROM lead_assignment_rules " +
                     "WHERE is_active = 1 " +
                     "ORDER BY priority ASC, rule_id ASC";
        try (PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapResultSet(rs));
            }
        }
        return list;
    }

    /**
     * Khóa bi quan (Pessimistic Lock) dòng quy tắc để phục vụ Round-Robin an toàn.
     */
    public LeadAssignmentRule getRuleByIdForUpdate(Connection conn, int ruleId) throws SQLException {
        String sql = "SELECT rule_id, rule_name, priority, criterion, criterion_value, " +
                     "team_id, assignee_id, last_assigned_user_id, is_active, created_at, updated_at " +
                     "FROM lead_assignment_rules " +
                     "WHERE rule_id = ? AND is_active = 1 " +
                     "FOR UPDATE";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, ruleId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSet(rs);
                }
            }
        }
        return null;
    }

    /**
     * Cập nhật con trỏ Round-Robin (last_assigned_user_id) trong cùng transaction.
     */
    public boolean updateLastAssignedUser(Connection conn, int ruleId, int userId) throws SQLException {
        String sql = "UPDATE lead_assignment_rules SET last_assigned_user_id = ?, updated_at = CURRENT_TIMESTAMP WHERE rule_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, ruleId);
            return ps.executeUpdate() > 0;
        }
    }

    /**
     * Lấy danh sách ID nhân viên đang hoạt động thuộc nhóm (team), sắp xếp tăng dần ổn định.
     * Bỏ qua các nhân viên đang bị khóa (lockout_until còn hiệu lực).
     */
    public List<Integer> getActiveUserIdsByTeam(Connection conn, int teamId) throws SQLException {
        List<Integer> userIds = new ArrayList<>();
        String sql = "SELECT user_id FROM users WHERE team_id = ? AND is_active = 1 " +
                     "AND (lockout_until IS NULL OR lockout_until <= CURRENT_TIMESTAMP) " +
                     "ORDER BY user_id ASC";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, teamId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    userIds.add(rs.getInt("user_id"));
                }
            }
        }
        return userIds;
    }

    public static class UserEligibilityRecord {
        private final int userId;
        private final Integer teamId;
        private final boolean active;
        private final boolean locked;

        public UserEligibilityRecord(int userId, Integer teamId, boolean active, boolean locked) {
            this.userId = userId;
            this.teamId = teamId;
            this.active = active;
            this.locked = locked;
        }

        public int getUserId() { return userId; }
        public Integer getTeamId() { return teamId; }
        public boolean isActive() { return active; }
        public boolean isLocked() { return locked; }
        public boolean isEligible() { return active && !locked; }
    }

    /**
     * Kiểm tra tính hợp lệ và thông tin nhóm của nhân viên mục tiêu.
     */
    public UserEligibilityRecord getUserEligibility(Connection conn, int userId) throws SQLException {
        String sql = "SELECT user_id, team_id, is_active, lockout_until FROM users WHERE user_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Integer teamId = (rs.getObject("team_id") != null) ? rs.getInt("team_id") : null;
                    boolean active = rs.getInt("is_active") == 1;
                    Timestamp lockout = rs.getTimestamp("lockout_until");
                    boolean locked = lockout != null && lockout.after(new Timestamp(System.currentTimeMillis()));
                    return new UserEligibilityRecord(userId, teamId, active, locked);
                }
            }
        }
        return null;
    }

    /**
     * Khóa bi quan Lead mục tiêu để đảm bảo không bị phân bổ trùng đồng thời.
     */
    public LeadLockRecord getLeadForUpdate(Connection conn, int leadId) throws SQLException {
        String sql = "SELECT lead_id, contact_name, company_name, status, owner_id, region, industry " +
                     "FROM leads WHERE lead_id = ? FOR UPDATE";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, leadId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Integer ownerId = (rs.getObject("owner_id") != null) ? rs.getInt("owner_id") : null;
                    return new LeadLockRecord(
                            rs.getInt("lead_id"),
                            rs.getString("contact_name"),
                            rs.getString("company_name"),
                            rs.getString("status"),
                            ownerId,
                            rs.getString("region"),
                            rs.getString("industry")
                    );
                }
            }
        }
        return null;
    }

    /**
     * Cập nhật chủ sở hữu và trạng thái Lead trong transaction phân bổ.
     */
    public boolean updateLeadOwnerAndStatus(Connection conn, int leadId, Integer ownerId, String status) throws SQLException {
        String sql;
        if (ownerId != null) {
            sql = "UPDATE leads SET owner_id = ?, status = ?, assigned_at = CURRENT_TIMESTAMP, is_overdue = 0, updated_at = CURRENT_TIMESTAMP WHERE lead_id = ?";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, ownerId);
                ps.setString(2, status);
                ps.setInt(3, leadId);
                return ps.executeUpdate() > 0;
            }
        } else {
            sql = "UPDATE leads SET owner_id = NULL, status = ?, assigned_at = NULL, updated_at = CURRENT_TIMESTAMP WHERE lead_id = ?";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, status);
                ps.setInt(2, leadId);
                return ps.executeUpdate() > 0;
            }
        }
    }

    /**
     * Thêm mới một quy tắc phân bổ vào CSDL.
     */
    public boolean saveRule(LeadAssignmentRule rule) {
        String sql = "INSERT INTO lead_assignment_rules (rule_name, priority, criterion, criterion_value, team_id, assignee_id, last_assigned_user_id, is_active) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, rule.getRuleName());
            ps.setInt(2, rule.getPriority());
            ps.setString(3, rule.getCriterion());
            ps.setString(4, rule.getCriterionValue());
            if (rule.getTeamId() != null) ps.setInt(5, rule.getTeamId()); else ps.setNull(5, Types.INTEGER);
            if (rule.getAssigneeId() != null) ps.setInt(6, rule.getAssigneeId()); else ps.setNull(6, Types.INTEGER);
            if (rule.getLastAssignedUserId() != null) ps.setInt(7, rule.getLastAssignedUserId()); else ps.setNull(7, Types.INTEGER);
            ps.setBoolean(8, rule.isActive());

            int affected = ps.executeUpdate();
            if (affected > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        rule.setRuleId(rs.getInt(1));
                    }
                }
                return true;
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Lỗi lưu LeadAssignmentRule", e);
        }
        return false;
    }

    private LeadAssignmentRule mapResultSet(ResultSet rs) throws SQLException {
        LeadAssignmentRule rule = new LeadAssignmentRule();
        rule.setRuleId(rs.getInt("rule_id"));
        rule.setRuleName(rs.getString("rule_name"));
        rule.setPriority(rs.getInt("priority"));
        rule.setCriterion(rs.getString("criterion"));
        rule.setCriterionValue(rs.getString("criterion_value"));
        
        int teamId = rs.getInt("team_id");
        if (!rs.wasNull()) rule.setTeamId(teamId);
        
        int assigneeId = rs.getInt("assignee_id");
        if (!rs.wasNull()) rule.setAssigneeId(assigneeId);
        
        int lastUser = rs.getInt("last_assigned_user_id");
        if (!rs.wasNull()) rule.setLastAssignedUserId(lastUser);

        rule.setActive(rs.getBoolean("is_active"));
        rule.setCreatedAt(rs.getTimestamp("created_at"));
        rule.setUpdatedAt(rs.getTimestamp("updated_at"));
        return rule;
    }
}

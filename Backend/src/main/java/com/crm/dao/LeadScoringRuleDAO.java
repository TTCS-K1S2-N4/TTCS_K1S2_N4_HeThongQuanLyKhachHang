package com.crm.dao;

import com.crm.model.LeadScoringRule;
import com.crm.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * DAO xử lý truy vấn và cập nhật Quy tắc Chấm điểm Lead và Cấu hình Ngưỡng (S4-05).
 * Sử dụng PreparedStatement cho 100% câu lệnh để phòng chống SQL Injection.
 */
public class LeadScoringRuleDAO {

    private static final Logger LOGGER = Logger.getLogger(LeadScoringRuleDAO.class.getName());

    public LeadScoringRuleDAO() {
        // Constructor nhẹ không chạy lệnh DDL runtime
    }

    private void ensureTablesExist() {
        String createRulesTableSql = "CREATE TABLE IF NOT EXISTS lead_scoring_rules (" +
                "rule_id INT AUTO_INCREMENT PRIMARY KEY, " +
                "criterion VARCHAR(50) NOT NULL, " +
                "operator VARCHAR(20) NOT NULL DEFAULT 'EQUALS', " +
                "condition_value VARCHAR(255) NOT NULL, " +
                "score INT NOT NULL DEFAULT 0, " +
                "is_active TINYINT(1) NOT NULL DEFAULT 1, " +
                "created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, " +
                "updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP" +
                ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;";

        String createConfigTableSql = "CREATE TABLE IF NOT EXISTS lead_scoring_config (" +
                "config_key VARCHAR(50) PRIMARY KEY, " +
                "config_value VARCHAR(100) NOT NULL, " +
                "updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP" +
                ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;";

        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement()) {
            stmt.executeUpdate(createRulesTableSql);
            stmt.executeUpdate(createConfigTableSql);

            // Khởi tạo ngưỡng mặc định nếu chưa có
            initDefaultConfig(conn);

            // Khởi tạo quy tắc chấm điểm mặc định nếu bảng đang rỗng
            initDefaultRules(conn);
        } catch (SQLException e) {
            LOGGER.log(Level.WARNING, "Lỗi kiểm tra/tạo bảng cấu hình lead scoring: " + e.getMessage(), e);
        }
    }

    private void initDefaultConfig(Connection conn) {
        String checkSql = "SELECT COUNT(*) FROM lead_scoring_config WHERE config_key IN ('hot_threshold', 'warm_threshold')";
        String insertSql = "INSERT IGNORE INTO lead_scoring_config (config_key, config_value) VALUES (?, ?)";

        try (Statement st = conn.createStatement();
             ResultSet rs = st.executeQuery(checkSql)) {
            if (rs.next() && rs.getInt(1) < 2) {
                try (PreparedStatement ps = conn.prepareStatement(insertSql)) {
                    ps.setString(1, "hot_threshold");
                    ps.setString(2, "70");
                    ps.executeUpdate();

                    ps.setString(1, "warm_threshold");
                    ps.setString(2, "40");
                    ps.executeUpdate();
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.FINE, "Bỏ qua lỗi khởi tạo config mặc định: " + e.getMessage());
        }
    }

    private void initDefaultRules(Connection conn) {
        String countSql = "SELECT COUNT(*) FROM lead_scoring_rules";
        String insertRuleSql = "INSERT INTO lead_scoring_rules (criterion, operator, condition_value, score, is_active) VALUES (?, ?, ?, ?, 1)";

        try (Statement st = conn.createStatement();
             ResultSet rs = st.executeQuery(countSql)) {
            if (rs.next() && rs.getInt(1) == 0) {
                try (PreparedStatement ps = conn.prepareStatement(insertRuleSql)) {
                    // 1. Ngành nghề: Công nghệ thông tin (+25)
                    ps.setString(1, "INDUSTRY");
                    ps.setString(2, "EQUALS");
                    ps.setString(3, "Công nghệ thông tin");
                    ps.setInt(4, 25);
                    ps.executeUpdate();

                    // 2. Quy mô doanh nghiệp: 100-500 (+20)
                    ps.setString(1, "COMPANY_SIZE");
                    ps.setString(2, "EQUALS");
                    ps.setString(3, "100-500");
                    ps.setInt(4, 20);
                    ps.executeUpdate();

                    // 3. Nguồn Lead: Website (+15)
                    ps.setString(1, "SOURCE");
                    ps.setString(2, "EQUALS");
                    ps.setString(3, "Website");
                    ps.setInt(4, 15);
                    ps.executeUpdate();

                    // 4. Mức độ quan tâm: Rất cao (+30)
                    ps.setString(1, "INTEREST");
                    ps.setString(2, "EQUALS");
                    ps.setString(3, "Rất cao");
                    ps.setInt(4, 30);
                    ps.executeUpdate();
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.FINE, "Bỏ qua lỗi khởi tạo rules mặc định: " + e.getMessage());
        }
    }

    public List<LeadScoringRule> getAllRules() {
        List<LeadScoringRule> list = new ArrayList<>();
        String sql = "SELECT * FROM lead_scoring_rules ORDER BY rule_id ASC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapResultSet(rs));
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Lỗi lấy danh sách rules: " + e.getMessage(), e);
        }
        return list;
    }

    public List<LeadScoringRule> getActiveRules() {
        List<LeadScoringRule> list = new ArrayList<>();
        String sql = "SELECT * FROM lead_scoring_rules WHERE is_active = 1 ORDER BY rule_id ASC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapResultSet(rs));
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Lỗi lấy active rules: " + e.getMessage(), e);
        }
        return list;
    }

    public LeadScoringRule getById(int ruleId) {
        String sql = "SELECT * FROM lead_scoring_rules WHERE rule_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, ruleId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSet(rs);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Lỗi lấy rule theo id: " + e.getMessage(), e);
        }
        return null;
    }

    public boolean createRule(LeadScoringRule rule) {
        String sql = "INSERT INTO lead_scoring_rules (criterion, operator, condition_value, score, is_active) VALUES (?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, rule.getCriterion());
            ps.setString(2, rule.getOperator());
            ps.setString(3, rule.getConditionValue());
            ps.setInt(4, rule.getScore());
            ps.setBoolean(5, rule.isActive());

            int affected = ps.executeUpdate();
            if (affected > 0) {
                try (ResultSet keys = ps.getGeneratedKeys()) {
                    if (keys.next()) {
                        rule.setRuleId(keys.getInt(1));
                    }
                }
                return true;
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Lỗi tạo rule mới: " + e.getMessage(), e);
        }
        return false;
    }

    public boolean updateRule(LeadScoringRule rule) {
        String sql = "UPDATE lead_scoring_rules SET criterion = ?, operator = ?, condition_value = ?, score = ?, is_active = ? WHERE rule_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, rule.getCriterion());
            ps.setString(2, rule.getOperator());
            ps.setString(3, rule.getConditionValue());
            ps.setInt(4, rule.getScore());
            ps.setBoolean(5, rule.isActive());
            ps.setInt(6, rule.getRuleId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Lỗi cập nhật rule: " + e.getMessage(), e);
        }
        return false;
    }

    public boolean deleteRule(int ruleId) {
        String sql = "DELETE FROM lead_scoring_rules WHERE rule_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, ruleId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Lỗi xóa rule: " + e.getMessage(), e);
        }
        return false;
    }

    public int getHotThreshold() {
        return getConfigInt("hot_threshold", 70);
    }

    public int getWarmThreshold() {
        return getConfigInt("warm_threshold", 40);
    }

    public boolean updateThresholds(int hotThreshold, int warmThreshold) {
        String sql = "INSERT INTO lead_scoring_config (config_key, config_value) VALUES (?, ?) " +
                     "ON DUPLICATE KEY UPDATE config_value = VALUES(config_value)";
        try (Connection conn = DBConnection.getConnection()) {
            conn.setAutoCommit(false);
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, "hot_threshold");
                ps.setString(2, String.valueOf(hotThreshold));
                ps.executeUpdate();

                ps.setString(1, "warm_threshold");
                ps.setString(2, String.valueOf(warmThreshold));
                ps.executeUpdate();

                conn.commit();
                return true;
            } catch (SQLException ex) {
                conn.rollback();
                throw ex;
            } finally {
                conn.setAutoCommit(true);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Lỗi cập nhật ngưỡng phân loại Lead: " + e.getMessage(), e);
        }
        return false;
    }

    private int getConfigInt(String key, int defaultValue) {
        String sql = "SELECT config_value FROM lead_scoring_config WHERE config_key = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, key);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return Integer.parseInt(rs.getString("config_value").trim());
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.FINE, "Sử dụng giá trị mặc định cho " + key + ": " + defaultValue);
        }
        return defaultValue;
    }

    private LeadScoringRule mapResultSet(ResultSet rs) throws SQLException {
        LeadScoringRule rule = new LeadScoringRule();
        rule.setRuleId(rs.getInt("rule_id"));
        rule.setCriterion(rs.getString("criterion"));
        rule.setOperator(rs.getString("operator"));
        rule.setConditionValue(rs.getString("condition_value"));
        rule.setScore(rs.getInt("score"));
        rule.setActive(rs.getBoolean("is_active"));
        rule.setCreatedAt(rs.getTimestamp("created_at"));
        rule.setUpdatedAt(rs.getTimestamp("updated_at"));
        return rule;
    }
}

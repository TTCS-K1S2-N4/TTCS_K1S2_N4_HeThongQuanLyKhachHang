package com.crm.dao;

import com.crm.model.Campaign;
import com.crm.model.DataScope;
import com.crm.model.Lead;
import com.crm.model.Opportunity;
import com.crm.util.DBConnection;

import java.math.BigDecimal;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * DAO xử lý truy vấn cơ sở dữ liệu cho Chiến dịch tiếp thị (Campaign).
 * Sử dụng PreparedStatement cho 100% truy vấn để bảo vệ chống SQL Injection.
 */
public class CampaignDAO {

    private static final Logger LOGGER = Logger.getLogger(CampaignDAO.class.getName());

    public CampaignDAO() {
        ensureSchema();
    }

    /**
     * Khởi tạo schema tự động nếu chưa tồn tại (tương thích môi trường và test).
     */
    public void ensureSchema() {
        try (Connection conn = DBConnection.getConnection()) {
            if (conn == null) return;

            String createCampaignsSql = "CREATE TABLE IF NOT EXISTS campaigns (" +
                    "campaign_id INT AUTO_INCREMENT PRIMARY KEY, " +
                    "campaign_name VARCHAR(200) NOT NULL, " +
                    "budget DECIMAL(15, 2) DEFAULT 0.00, " +
                    "start_date DATE NULL, " +
                    "end_date DATE NULL, " +
                    "channel VARCHAR(100) NULL, " +
                    "description TEXT NULL, " +
                    "status VARCHAR(50) DEFAULT 'PLANNING', " +
                    "created_by INT NULL, " +
                    "created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, " +
                    "updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP" +
                    ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;";

            String createLeadsSql = "CREATE TABLE IF NOT EXISTS leads (" +
                    "lead_id INT AUTO_INCREMENT PRIMARY KEY, " +
                    "full_name VARCHAR(150), " +
                    "company_name VARCHAR(200), " +
                    "email VARCHAR(150), " +
                    "phone VARCHAR(50), " +
                    "status VARCHAR(50) DEFAULT 'NEW', " +
                    "owner_id INT NULL, " +
                    "campaign_id INT NULL, " +
                    "customer_id INT NULL, " +
                    "source VARCHAR(100) NULL, " +
                    "created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, " +
                    "updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP" +
                    ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;";

            try (Statement stmt = conn.createStatement()) {
                stmt.executeUpdate(createCampaignsSql);
                stmt.executeUpdate(createLeadsSql);
            } catch (SQLException e) {
                LOGGER.log(Level.FINE, "Ghi nhận tạo bảng campaigns/leads: " + e.getMessage());
            }

            // Bổ sung các cột liên kết nếu bảng opportunities/leads đã tồn tại từ trước
            ensureColumnExists(conn, "opportunities", "campaign_id", "INT NULL");
            ensureColumnExists(conn, "opportunities", "stage", "VARCHAR(100) NULL");
            ensureColumnExists(conn, "opportunities", "status", "VARCHAR(50) DEFAULT 'ACTIVE'");
            ensureColumnExists(conn, "leads", "campaign_id", "INT NULL");
            ensureColumnExists(conn, "leads", "customer_id", "INT NULL");

        } catch (SQLException e) {
            LOGGER.log(Level.WARNING, "Không thể kết nối DB trong ensureSchema của CampaignDAO: " + e.getMessage());
        }
    }

    private void ensureColumnExists(Connection conn, String tableName, String columnName, String columnDef) {
        try {
            DatabaseMetaData meta = conn.getMetaData();
            try (ResultSet rs = meta.getColumns(null, null, tableName, columnName)) {
                if (!rs.next()) {
                    String alterSql = "ALTER TABLE " + tableName + " ADD COLUMN " + columnName + " " + columnDef;
                    try (Statement stmt = conn.createStatement()) {
                        stmt.executeUpdate(alterSql);
                    } catch (SQLException ignored) {}
                }
            }
        } catch (SQLException ignored) {}
    }

    /**
     * Tạo mới một chiến dịch tiếp thị.
     * @param campaign Đối tượng chiến dịch cần thêm
     * @return ID tự sinh của chiến dịch, hoặc -1 nếu thất bại
     */
    public int insert(Campaign campaign) {
        String sql = "INSERT INTO campaigns (campaign_name, budget, start_date, end_date, channel, description, status, created_by) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            ps.setString(1, campaign.getCampaignName());
            ps.setBigDecimal(2, campaign.getBudget() != null ? campaign.getBudget() : BigDecimal.ZERO);
            ps.setDate(3, campaign.getStartDate());
            ps.setDate(4, campaign.getEndDate());
            ps.setString(5, campaign.getChannel());
            ps.setString(6, campaign.getDescription());
            ps.setString(7, campaign.getStatus() != null ? campaign.getStatus() : "PLANNING");
            if (campaign.getCreatedBy() != null) {
                ps.setInt(8, campaign.getCreatedBy());
            } else {
                ps.setNull(8, Types.INTEGER);
            }

            int affected = ps.executeUpdate();
            if (affected > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        int generatedId = rs.getInt(1);
                        campaign.setCampaignId(generatedId);
                        return generatedId;
                    }
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Lỗi khi thêm mới Campaign", e);
        }
        return -1;
    }

    /**
     * Cập nhật thông tin chiến dịch.
     */
    public boolean update(Campaign campaign) {
        String sql = "UPDATE campaigns SET campaign_name = ?, budget = ?, start_date = ?, end_date = ?, " +
                "channel = ?, description = ?, status = ? WHERE campaign_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, campaign.getCampaignName());
            ps.setBigDecimal(2, campaign.getBudget() != null ? campaign.getBudget() : BigDecimal.ZERO);
            ps.setDate(3, campaign.getStartDate());
            ps.setDate(4, campaign.getEndDate());
            ps.setString(5, campaign.getChannel());
            ps.setString(6, campaign.getDescription());
            ps.setString(7, campaign.getStatus() != null ? campaign.getStatus() : "PLANNING");
            ps.setInt(8, campaign.getCampaignId());

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Lỗi khi cập nhật Campaign id=" + campaign.getCampaignId(), e);
        }
        return false;
    }

    /**
     * Tìm chiến dịch theo ID.
     */
    public Campaign findById(int campaignId) {
        String sql = "SELECT c.*, u.full_name AS creator_name FROM campaigns c " +
                "LEFT JOIN users u ON c.created_by = u.user_id " +
                "WHERE c.campaign_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, campaignId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Campaign c = mapRow(rs);
                    loadMetrics(c, conn);
                    return c;
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Lỗi khi tìm Campaign id=" + campaignId, e);
        }
        return null;
    }

    /**
     * Lấy danh sách chiến dịch theo bộ lọc và phân quyền dữ liệu.
     */
    public List<Campaign> findAll(String keyword, String status, String channel, Integer ownerId, List<Integer> teamUserIds, DataScope scope, int page, int pageSize) {
        List<Campaign> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder("SELECT c.*, u.full_name AS creator_name FROM campaigns c ");
        sql.append("LEFT JOIN users u ON c.created_by = u.user_id WHERE 1=1 ");

        List<Object> params = new ArrayList<>();
        appendFilters(sql, params, keyword, status, channel, ownerId, teamUserIds, scope);

        sql.append("ORDER BY c.campaign_id DESC ");
        if (pageSize > 0) {
            int offset = Math.max(0, (page - 1) * pageSize);
            sql.append("LIMIT ? OFFSET ? ");
            params.add(pageSize);
            params.add(offset);
        }

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {

            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Campaign c = mapRow(rs);
                    loadMetrics(c, conn);
                    list.add(c);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Lỗi khi lấy danh sách Campaign", e);
        }
        return list;
    }

    /**
     * Lấy tất cả chiến dịch (dùng cho dropdown lựa chọn).
     */
    public List<Campaign> getAllCampaigns() {
        return findAll(null, null, null, null, null, DataScope.ALL, 1, 1000);
    }

    /**
     * Đếm tổng số chiến dịch thỏa mãn bộ lọc.
     */
    public int countAll(String keyword, String status, String channel, Integer ownerId, List<Integer> teamUserIds, DataScope scope) {
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM campaigns c WHERE 1=1 ");
        List<Object> params = new ArrayList<>();
        appendFilters(sql, params, keyword, status, channel, ownerId, teamUserIds, scope);

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
            LOGGER.log(Level.SEVERE, "Lỗi đếm số lượng Campaign", e);
        }
        return 0;
    }

    private void appendFilters(StringBuilder sql, List<Object> params, String keyword, String status, String channel, Integer ownerId, List<Integer> teamUserIds, DataScope scope) {
        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append("AND (c.campaign_name LIKE ? OR c.description LIKE ?) ");
            String kw = "%" + keyword.trim() + "%";
            params.add(kw);
            params.add(kw);
        }

        if (status != null && !status.trim().isEmpty() && !"ALL".equalsIgnoreCase(status.trim())) {
            sql.append("AND c.status = ? ");
            params.add(status.trim());
        }

        if (channel != null && !channel.trim().isEmpty() && !"ALL".equalsIgnoreCase(channel.trim())) {
            sql.append("AND c.channel = ? ");
            params.add(channel.trim());
        }

        if (scope == DataScope.MY && ownerId != null) {
            sql.append("AND c.created_by = ? ");
            params.add(ownerId);
        } else if (scope == DataScope.TEAM && teamUserIds != null && !teamUserIds.isEmpty()) {
            sql.append("AND c.created_by IN (");
            for (int i = 0; i < teamUserIds.size(); i++) {
                sql.append(i > 0 ? ", ?" : "?");
                params.add(teamUserIds.get(i));
            }
            sql.append(") ");
        }
    }

    /**
     * Tải các chỉ số thống kê hiệu quả của chiến dịch: số lead, số cơ hội và doanh thu đã chốt (S4-03-AC-03).
     * Thực hiện truy vấn độc lập từng bảng để tránh fan-out Cartesian product làm sai lệch số liệu.
     */
    public void loadMetrics(Campaign c, Connection conn) {
        if (c == null || c.getCampaignId() <= 0) return;
        int id = c.getCampaignId();

        // 1. Số Lead thuộc chiến dịch
        String leadCountSql = "SELECT COUNT(*) FROM leads WHERE campaign_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(leadCountSql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    c.setLeadCount(rs.getInt(1));
                }
            }
        } catch (SQLException e) {
            c.setLeadCount(0);
        }

        // 2. Số Cơ hội và Doanh thu đã chốt (closedValue)
        String oppMetricsSql = "SELECT COUNT(*) AS total_opp, " +
                "COALESCE(SUM(CASE WHEN (UPPER(stage) LIKE '%WON%' OR UPPER(status) LIKE '%WON%') " +
                "AND UPPER(stage) NOT LIKE '%LOST%' AND UPPER(status) NOT LIKE '%LOST%' THEN amount ELSE 0 END), 0) AS closed_val " +
                "FROM opportunities WHERE campaign_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(oppMetricsSql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    c.setOpportunityCount(rs.getInt("total_opp"));
                    BigDecimal closedVal = rs.getBigDecimal("closed_val");
                    c.setClosedValue(closedVal != null ? closedVal : BigDecimal.ZERO);
                }
            }
        } catch (SQLException e) {
            c.setOpportunityCount(0);
            c.setClosedValue(BigDecimal.ZERO);
        }
    }

    private Campaign mapRow(ResultSet rs) throws SQLException {
        Campaign c = new Campaign();
        c.setCampaignId(rs.getInt("campaign_id"));
        c.setCampaignName(rs.getString("campaign_name"));
        c.setBudget(rs.getBigDecimal("budget"));
        c.setStartDate(rs.getDate("start_date"));
        c.setEndDate(rs.getDate("end_date"));
        c.setChannel(rs.getString("channel"));
        c.setDescription(rs.getString("description"));
        c.setStatus(rs.getString("status"));
        c.setCreatedBy(rs.getObject("created_by") != null ? rs.getInt("created_by") : null);
        try {
            c.setCreatorName(rs.getString("creator_name"));
        } catch (SQLException ignored) {}
        c.setCreatedAt(rs.getTimestamp("created_at"));
        c.setUpdatedAt(rs.getTimestamp("updated_at"));
        return c;
    }

    /**
     * Lấy danh sách Lead được gắn với chiến dịch cụ thể.
     */
    public List<Lead> getLeadsByCampaignId(int campaignId) {
        List<Lead> list = new ArrayList<>();
        String sql = "SELECT l.*, s.source_name, u.full_name AS owner_name " +
                     "FROM leads l " +
                     "LEFT JOIN lead_sources s ON l.lead_source_id = s.source_id " +
                     "LEFT JOIN users u ON l.owner_id = u.user_id " +
                     "WHERE l.campaign_id = ? " +
                     "ORDER BY l.lead_id DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, campaignId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Lead l = new Lead();
                    l.setLeadId(rs.getInt("lead_id"));
                    l.setFullName(rs.getString("full_name"));
                    l.setCompany(rs.getString("company"));
                    l.setEmail(rs.getString("email"));
                    l.setPhone(rs.getString("phone"));
                    l.setStatus(rs.getString("status"));
                    l.setRating(rs.getString("rating"));
                    l.setOwnerId(rs.getObject("owner_id") != null ? rs.getInt("owner_id") : null);
                    l.setOwnerName(rs.getString("owner_name"));
                    l.setSourceName(rs.getString("source_name"));
                    l.setCampaignId(rs.getInt("campaign_id"));
                    l.setCreatedAt(rs.getTimestamp("created_at"));
                    l.setUpdatedAt(rs.getTimestamp("updated_at"));
                    list.add(l);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Lỗi khi lấy danh sách Lead theo Campaign id=" + campaignId, e);
        }
        return list;
    }

    /**
     * Lấy danh sách Cơ hội (Opportunity) thuộc chiến dịch cụ thể.
     */
    public List<Opportunity> getOpportunitiesByCampaignId(int campaignId) {
        List<Opportunity> list = new ArrayList<>();
        String sql = "SELECT o.*, c.customer_name, u.full_name AS owner_name, ps.stage_name " +
                     "FROM opportunities o " +
                     "LEFT JOIN customers c ON o.customer_id = c.customer_id " +
                     "LEFT JOIN users u ON o.owner_id = u.user_id " +
                     "LEFT JOIN pipeline_stages ps ON o.pipeline_stage_id = ps.pipeline_stage_id " +
                     "WHERE o.campaign_id = ? " +
                     "ORDER BY o.opportunity_id DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, campaignId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Opportunity opp = new Opportunity();
                    opp.setOpportunityId(rs.getInt("opportunity_id"));
                    opp.setTitle(rs.getString("title"));
                    opp.setAmount(rs.getDouble("amount"));
                    opp.setStage(rs.getString("stage"));
                    opp.setStatus(rs.getString("status"));
                    opp.setCustomerId(rs.getInt("customer_id"));
                    opp.setCustomerName(rs.getString("customer_name"));
                    opp.setOwnerId(rs.getInt("owner_id"));
                    opp.setOwnerName(rs.getString("owner_name"));
                    opp.setPipelineStageId(rs.getObject("pipeline_stage_id") != null ? rs.getInt("pipeline_stage_id") : null);
                    opp.setStageName(rs.getString("stage_name"));
                    opp.setCampaignId(rs.getInt("campaign_id"));
                    opp.setCloseDate(rs.getTimestamp("close_date"));
                    opp.setCreatedAt(rs.getTimestamp("created_at"));
                    list.add(opp);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Lỗi khi lấy danh sách Opportunity theo Campaign id=" + campaignId, e);
        }
        return list;
    }

    /**
     * Lấy danh sách Cơ hội đã chốt thắng (Closed Won) đóng góp vào doanh thu chiến dịch.
     */
    public List<Opportunity> getClosedWonOpportunitiesByCampaignId(int campaignId) {
        List<Opportunity> list = new ArrayList<>();
        String sql = "SELECT o.*, c.customer_name, u.full_name AS owner_name, ps.stage_name " +
                     "FROM opportunities o " +
                     "LEFT JOIN customers c ON o.customer_id = c.customer_id " +
                     "LEFT JOIN users u ON o.owner_id = u.user_id " +
                     "LEFT JOIN pipeline_stages ps ON o.pipeline_stage_id = ps.pipeline_stage_id " +
                     "WHERE o.campaign_id = ? " +
                     "AND (UPPER(o.stage) LIKE '%WON%' OR UPPER(o.status) LIKE '%WON%') " +
                     "AND UPPER(o.stage) NOT LIKE '%LOST%' AND UPPER(o.status) NOT LIKE '%LOST%' " +
                     "ORDER BY o.opportunity_id DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, campaignId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Opportunity opp = new Opportunity();
                    opp.setOpportunityId(rs.getInt("opportunity_id"));
                    opp.setTitle(rs.getString("title"));
                    opp.setAmount(rs.getDouble("amount"));
                    opp.setStage(rs.getString("stage"));
                    opp.setStatus(rs.getString("status"));
                    opp.setCustomerId(rs.getInt("customer_id"));
                    opp.setCustomerName(rs.getString("customer_name"));
                    opp.setOwnerId(rs.getInt("owner_id"));
                    opp.setOwnerName(rs.getString("owner_name"));
                    opp.setPipelineStageId(rs.getObject("pipeline_stage_id") != null ? rs.getInt("pipeline_stage_id") : null);
                    opp.setStageName(rs.getString("stage_name"));
                    opp.setCampaignId(rs.getInt("campaign_id"));
                    opp.setCloseDate(rs.getTimestamp("close_date"));
                    opp.setCreatedAt(rs.getTimestamp("created_at"));
                    list.add(opp);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Lỗi khi lấy danh sách Closed Won Opportunity theo Campaign id=" + campaignId, e);
        }
        return list;
    }
}

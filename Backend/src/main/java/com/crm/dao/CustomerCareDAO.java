package com.crm.dao;

import com.crm.dto.CustomerCareResponse;
import com.crm.model.CustomerCareState;
import com.crm.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * DAO quản lý dữ liệu Chăm sóc khách hàng định kỳ N ngày.
 * 100% PreparedStatement, Task S30-10 / S3-09.
 */
public class CustomerCareDAO {

    private static final Logger LOGGER = Logger.getLogger(CustomerCareDAO.class.getName());
    private static final int DEFAULT_INACTIVE_DAYS = 30;

    public CustomerCareState findByCustomerId(int customerId) {
        String sql = "SELECT cc.*, u.full_name AS last_contacted_by_name " +
                     "FROM customer_care cc " +
                     "LEFT JOIN users u ON cc.last_contacted_by = u.user_id " +
                     "WHERE cc.customer_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, customerId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    CustomerCareState s = new CustomerCareState();
                    s.setCareId(rs.getInt("care_id"));
                    s.setCustomerId(rs.getInt("customer_id"));
                    s.setLastContactedAt(rs.getTimestamp("last_contacted_at"));
                    
                    int contactedBy = rs.getInt("last_contacted_by");
                    if (!rs.wasNull()) {
                        s.setLastContactedBy(contactedBy);
                    }
                    s.setLastContactedByName(rs.getString("last_contacted_by_name"));
                    s.setNote(rs.getString("note"));
                    s.setCreatedAt(rs.getTimestamp("created_at"));
                    s.setUpdatedAt(rs.getTimestamp("updated_at"));
                    return s;
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Lỗi tìm CustomerCareState theo customerId: " + customerId, e);
        }
        return null;
    }

    public boolean recordContacted(int customerId, int contactedBy, String note) {
        String sql = "INSERT INTO customer_care (customer_id, last_contacted_at, last_contacted_by, note) " +
                     "VALUES (?, CURRENT_TIMESTAMP, ?, ?) " +
                     "ON DUPLICATE KEY UPDATE " +
                     "last_contacted_at = CURRENT_TIMESTAMP, " +
                     "last_contacted_by = VALUES(last_contacted_by), " +
                     "note = VALUES(note), " +
                     "updated_at = CURRENT_TIMESTAMP";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, customerId);
            ps.setInt(2, contactedBy);
            ps.setString(3, note != null ? note : "");
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Lỗi ghi nhận đã chăm sóc khách hàng: " + customerId, e);
            return false;
        }
    }

    public int getInactiveThreshold() {
        String sql = "SELECT inactive_threshold_days FROM customer_care WHERE customer_id = 0 OR customer_id IS NULL LIMIT 1";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                int val = rs.getInt("inactive_threshold_days");
                if (val > 0) return val;
            }
        } catch (SQLException e) {
            LOGGER.log(Level.FINE, "Chưa có cấu hình threshold trong DB, dùng mặc định " + DEFAULT_INACTIVE_DAYS, e);
        }
        return DEFAULT_INACTIVE_DAYS;
    }

    public boolean updateInactiveThreshold(int days) {
        String updateSql = "UPDATE customer_care SET inactive_threshold_days = ? WHERE customer_id IS NULL";
        String insertSql = "INSERT INTO customer_care (customer_id, inactive_threshold_days) VALUES (NULL, ?)";
        try (Connection conn = DBConnection.getConnection()) {
            try (PreparedStatement ups = conn.prepareStatement(updateSql)) {
                ups.setInt(1, days);
                int rows = ups.executeUpdate();
                if (rows > 0) return true;
            }
            try (PreparedStatement ips = conn.prepareStatement(insertSql)) {
                ips.setInt(1, days);
                return ips.executeUpdate() > 0;
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Lỗi cập nhật cấu hình threshold ngày định kỳ: " + days, e);
            return false;
        }
    }

    public List<CustomerCareResponse> findInactiveCustomers(int inactiveDays, List<Integer> ownerIds, int page, int pageSize) {
        if (ownerIds != null && ownerIds.isEmpty()) return new ArrayList<>();

        List<CustomerCareResponse> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT c.customer_id, c.customer_name, c.phone, c.owner_id, u.full_name AS owner_name, ")
           .append("cc.last_contacted_at, ")
           .append("TIMESTAMPDIFF(DAY, COALESCE(cc.last_contacted_at, c.created_at), CURRENT_TIMESTAMP) AS days_inactive, ")
           .append("COALESCE(( ")
           .append("    SELECT SUM(o.amount) FROM opportunities o ")
           .append("    LEFT JOIN pipeline_stages ps ON o.pipeline_stage_id = ps.pipeline_stage_id ")
           .append("    WHERE o.customer_id = c.customer_id AND ( ")
           .append("        o.stage LIKE '%WON%' OR ")
           .append("        o.stage LIKE '%CLOSED_WON%' OR ")
           .append("        ps.stage_name LIKE '%Won%' OR ")
           .append("        ps.stage_name LIKE '%thành công%' OR ")
           .append("        ps.default_probability = 100 ")
           .append("    ) ")
           .append("), 0.0) AS contract_value ")
           .append("FROM customers c ")
           .append("LEFT JOIN users u ON c.owner_id = u.user_id ")
           .append("LEFT JOIN customer_care cc ON c.customer_id = cc.customer_id ")
           .append("WHERE TIMESTAMPDIFF(DAY, COALESCE(cc.last_contacted_at, c.created_at), CURRENT_TIMESTAMP) >= ? ");

        if (ownerIds != null) {
            String inClause = String.join(",", java.util.Collections.nCopies(ownerIds.size(), "?"));
            sql.append("AND c.owner_id IN (").append(inClause).append(") ");
        }

        sql.append("ORDER BY contract_value DESC, days_inactive DESC, c.customer_id ASC ");
        sql.append("LIMIT ? OFFSET ?");

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            int idx = 1;
            ps.setInt(idx++, inactiveDays);

            if (ownerIds != null) {
                for (Integer oid : ownerIds) {
                    ps.setInt(idx++, oid);
                }
            }

            int safePageSize = pageSize > 0 ? pageSize : 20;
            int safePage = page > 0 ? page : 1;
            ps.setInt(idx++, safePageSize);
            ps.setInt(idx++, (safePage - 1) * safePageSize);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    CustomerCareResponse resp = new CustomerCareResponse();
                    resp.setCustomerId(rs.getInt("customer_id"));
                    resp.setCustomerName(rs.getString("customer_name"));
                    resp.setPhone(rs.getString("phone"));
                    resp.setOwnerId(rs.getInt("owner_id"));
                    resp.setOwnerName(rs.getString("owner_name"));
                    resp.setLastContactedAt(rs.getTimestamp("last_contacted_at"));
                    resp.setDaysInactive(rs.getLong("days_inactive"));
                    resp.setContractValue(rs.getDouble("contract_value"));
                    resp.setCareStatus(resp.getDaysInactive() > inactiveDays ? "CẦN CHĂM SÓC" : "ĐẾN HẠN");
                    list.add(resp);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Lỗi truy vấn danh sách khách hàng không tương tác", e);
        }
        return list;
    }

    public int countInactiveCustomers(int inactiveDays, List<Integer> ownerIds) {
        if (ownerIds != null && ownerIds.isEmpty()) return 0;

        StringBuilder sql = new StringBuilder();
        sql.append("SELECT COUNT(*) ")
           .append("FROM customers c ")
           .append("LEFT JOIN customer_care cc ON c.customer_id = cc.customer_id ")
           .append("WHERE TIMESTAMPDIFF(DAY, COALESCE(cc.last_contacted_at, c.created_at), CURRENT_TIMESTAMP) >= ? ");

        if (ownerIds != null) {
            String inClause = String.join(",", java.util.Collections.nCopies(ownerIds.size(), "?"));
            sql.append("AND c.owner_id IN (").append(inClause).append(") ");
        }

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            int idx = 1;
            ps.setInt(idx++, inactiveDays);

            if (ownerIds != null) {
                for (Integer oid : ownerIds) {
                    ps.setInt(idx++, oid);
                }
            }

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Lỗi đếm số lượng khách hàng không tương tác", e);
        }
        return 0;
    }
}

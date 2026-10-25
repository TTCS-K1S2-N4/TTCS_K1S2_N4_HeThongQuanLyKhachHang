package com.crm.dao;

import com.crm.model.SupportRequest;
import com.crm.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * DAO quản lý Yêu cầu hỗ trợ sau bán (Support Request).
 * 100% PreparedStatement, Task S30-09 / S3-08.
 */
public class SupportRequestDAO {

    private static final Logger LOGGER = Logger.getLogger(SupportRequestDAO.class.getName());

    private SupportRequest mapResultSet(ResultSet rs) throws SQLException {
        SupportRequest sr = new SupportRequest();
        sr.setRequestId(rs.getInt("request_id"));
        sr.setCustomerId(rs.getInt("customer_id"));
        sr.setTitle(rs.getString("title"));
        sr.setDescription(rs.getString("description"));
        sr.setPriority(rs.getString("priority"));
        sr.setStatus(rs.getString("status"));
        
        int assigneeId = rs.getInt("assignee_id");
        if (!rs.wasNull()) {
            sr.setAssigneeId(assigneeId);
        }
        
        try {
            sr.setAssigneeName(rs.getString("assignee_name"));
        } catch (SQLException ignored) {
        }

        int createdBy = rs.getInt("created_by");
        if (!rs.wasNull()) {
            sr.setCreatedBy(createdBy);
        }

        sr.setCreatedAt(rs.getTimestamp("created_at"));
        sr.setUpdatedAt(rs.getTimestamp("updated_at"));
        return sr;
    }

    public List<SupportRequest> findByCustomerId(int customerId) {
        List<SupportRequest> list = new ArrayList<>();
        String sql = "SELECT s.*, u.full_name AS assignee_name " +
                     "FROM support_requests s " +
                     "LEFT JOIN users u ON s.assignee_id = u.user_id " +
                     "WHERE s.customer_id = ? " +
                     "ORDER BY s.request_id DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, customerId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSet(rs));
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Lỗi truy vấn SupportRequest theo customerId: " + customerId, e);
        }
        return list;
    }

    public SupportRequest findById(int requestId) {
        String sql = "SELECT s.*, u.full_name AS assignee_name " +
                     "FROM support_requests s " +
                     "LEFT JOIN users u ON s.assignee_id = u.user_id " +
                     "WHERE s.request_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, requestId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSet(rs);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Lỗi tìm SupportRequest theo ID: " + requestId, e);
        }
        return null;
    }

    public int insert(SupportRequest req) {
        String sql = "INSERT INTO support_requests (customer_id, title, description, priority, status, assignee_id, created_by) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, req.getCustomerId());
            ps.setString(2, req.getTitle());
            ps.setString(3, req.getDescription());
            ps.setString(4, req.getPriority());
            ps.setString(5, req.getStatus());

            if (req.getAssigneeId() != null) {
                ps.setInt(6, req.getAssigneeId());
            } else {
                ps.setNull(6, Types.INTEGER);
            }

            if (req.getCreatedBy() != null) {
                ps.setInt(7, req.getCreatedBy());
            } else {
                ps.setNull(7, Types.INTEGER);
            }

            int affected = ps.executeUpdate();
            if (affected > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        int id = rs.getInt(1);
                        req.setRequestId(id);
                        return id;
                    }
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Lỗi thêm SupportRequest", e);
        }
        return 0;
    }

    public boolean update(SupportRequest req) {
        String sql = "UPDATE support_requests SET title = ?, description = ?, priority = ?, status = ?, assignee_id = ? " +
                     "WHERE request_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, req.getTitle());
            ps.setString(2, req.getDescription());
            ps.setString(3, req.getPriority());
            ps.setString(4, req.getStatus());

            if (req.getAssigneeId() != null) {
                ps.setInt(5, req.getAssigneeId());
            } else {
                ps.setNull(5, Types.INTEGER);
            }

            ps.setInt(6, req.getRequestId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Lỗi cập nhật SupportRequest ID: " + req.getRequestId(), e);
            return false;
        }
    }

    public int countPendingByCustomerId(int customerId) {
        String sql = "SELECT COUNT(*) FROM support_requests WHERE customer_id = ? AND status IN ('OPEN', 'IN_PROGRESS')";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, customerId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Lỗi đếm số lượng vé pending cho customerId: " + customerId, e);
        }
        return 0;
    }

    public int countUrgentPendingByCustomerId(int customerId) {
        String sql = "SELECT COUNT(*) FROM support_requests WHERE customer_id = ? AND status IN ('OPEN', 'IN_PROGRESS') AND priority = 'URGENT'";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, customerId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Lỗi đếm số lượng vé URGENT pending cho customerId: " + customerId, e);
        }
        return 0;
    }
}

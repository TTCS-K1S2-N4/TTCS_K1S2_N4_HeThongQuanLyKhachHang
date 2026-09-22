package com.crm.dao;

import com.crm.config.DBConnection;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class HandoverDAO {

    // 1. Kiểm tra số lượng bản ghi Khách hàng & Cơ hội thuộc sở hữu của User
    public int countOwnedRecords(int userId) {
        String sql = "SELECT " +
                     "(SELECT COUNT(*) FROM customers WHERE owner_id = ?) + " +
                     "(SELECT COUNT(*) FROM opportunities WHERE owner_id = ?) AS total";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, userId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getInt("total");
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    // 2. Transaction bàn giao và khóa tài khoản
    public boolean lockAndHandover(int lockedUserId, Integer targetUserId, int performedByAdminId) {
        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false); // Bắt đầu Transaction

            // Bước A: Chuyển dữ liệu khách hàng & cơ hội (nếu có chọn người nhận)
            if (targetUserId != null && targetUserId > 0) {
                String updateCust = "UPDATE customers SET owner_id = ? WHERE owner_id = ?";
                try (PreparedStatement ps = conn.prepareStatement(updateCust)) {
                    ps.setInt(1, targetUserId);
                    ps.setInt(2, lockedUserId);
                    ps.executeUpdate();
                }

                String updateOpp = "UPDATE opportunities SET owner_id = ? WHERE owner_id = ?";
                try (PreparedStatement ps = conn.prepareStatement(updateOpp)) {
                    ps.setInt(1, targetUserId);
                    ps.setInt(2, lockedUserId);
                    ps.executeUpdate();
                }
            }

            // Bước B: Cập nhật is_active = 0 (Khóa tài khoản)
            String lockSql = "UPDATE users SET is_active = 0 WHERE user_id = ?";
            try (PreparedStatement ps = conn.prepareStatement(lockSql)) {
                ps.setInt(1, lockedUserId);
                ps.executeUpdate();
            }

            // Bước C: Ghi Audit Log hành động
            String logSql = "INSERT INTO audit_logs (action_type, performed_by, target_user_id, description) VALUES (?, ?, ?, ?)";
            try (PreparedStatement ps = conn.prepareStatement(logSql)) {
                ps.setString(1, "LOCK_USER");
                ps.setInt(2, performedByAdminId);
                ps.setInt(3, lockedUserId);
                String desc = (targetUserId != null && targetUserId > 0)
                        ? "Khóa tài khoản và chuyển giao dữ liệu sang User ID: " + targetUserId
                        : "Khóa tài khoản (không có dữ liệu bàn giao)";
                ps.setString(4, desc);
                ps.executeUpdate();
            }

            conn.commit(); // Thành công tất cả
            return true;
        } catch (SQLException e) {
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
            }
            e.printStackTrace();
            return false;
        } finally {
            if (conn != null) {
                try { conn.setAutoCommit(true); conn.close(); } catch (SQLException ignored) {}
            }
        }
    }
}

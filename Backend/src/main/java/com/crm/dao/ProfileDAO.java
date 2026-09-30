package com.crm.dao;

import com.crm.model.Account;
import com.crm.util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.logging.Level;
import java.util.logging.Logger;

public class ProfileDAO {

    private static final Logger LOGGER = Logger.getLogger(ProfileDAO.class.getName());

    public Account getProfileByUserId(int userId) {
        String sql = "SELECT user_id, email, full_name, phone, team_id, is_active, created_at, updated_at FROM users WHERE user_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Account account = new Account();
                    account.setAccountId(rs.getInt("user_id"));
                    account.setEmail(rs.getString("email"));
                    account.setFullName(rs.getString("full_name"));
                    account.setPhone(rs.getString("phone"));
                    account.setTeamId(rs.getObject("team_id") != null ? rs.getInt("team_id") : null);
                    account.setStatus(rs.getBoolean("is_active") ? "ACTIVE" : "INACTIVE");
                    account.setCreatedAt(rs.getTimestamp("created_at"));
                    account.setUpdatedAt(rs.getTimestamp("updated_at"));
                    return account;
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Lỗi lấy thông tin cá nhân cho userId: " + userId, e);
        }
        return null;
    }

    public boolean updateProfileInfo(int userId, String fullName, String phone) {
        String sql = "UPDATE users SET full_name = ?, phone = ? WHERE user_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, fullName);
            ps.setString(2, phone);
            ps.setInt(3, userId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Lỗi cập nhật hồ sơ cá nhân cho userId: " + userId, e);
        }
        return false;
    }

    public boolean updatePassword(int userId, String newPasswordHash) {
        String sql = "UPDATE users SET password_hash = ? WHERE user_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, newPasswordHash);
            ps.setInt(2, userId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Lỗi đổi mật khẩu cho userId: " + userId, e);
        }
        return false;
    }
}

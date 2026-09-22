package com.crm.dao;

import com.crm.config.DBConnection;
import com.crm.model.User;
import org.mindrot.jbcrypt.BCrypt;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class UserDAO {
    public static final int PAGE_SIZE = 20; // Yêu cầu S1-08: Phân trang 20 bản ghi

    // Kiểm tra trùng Email
    public boolean isEmailExists(String email, int excludeUserId) {
        String sql = "SELECT COUNT(*) FROM users WHERE email = ? AND user_id != ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, email);
            ps.setInt(2, excludeUserId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getInt(1) > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // Tạo mới tài khoản (Hash password bằng BCrypt)
    public boolean createUser(String email, String rawPassword, String fullName, String phone, Integer teamId) {
        String hashedPassword = BCrypt.hashpw(rawPassword, BCrypt.gensalt(12));
        String sql = "INSERT INTO users (email, password_hash, full_name, phone, team_id, is_active) VALUES (?, ?, ?, ?, ?, 1)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, email);
            ps.setString(2, hashedPassword);
            ps.setString(3, fullName);
            ps.setString(4, phone);
            if (teamId != null) ps.setInt(5, teamId); else ps.setNull(5, Types.INTEGER);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // Cập nhật thông tin tài khoản
    public boolean updateUser(int userId, String fullName, String phone, Integer teamId) {
        String sql = "UPDATE users SET full_name = ?, phone = ?, team_id = ? WHERE user_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, fullName);
            ps.setString(2, phone);
            if (teamId != null) ps.setInt(3, teamId); else ps.setNull(3, Types.INTEGER);
            ps.setInt(4, userId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // Lấy thông tin 1 user
    public User getUserById(int userId) {
        String sql = "SELECT u.*, t.team_name FROM users u LEFT JOIN teams t ON u.team_id = t.team_id WHERE u.user_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                User u = new User();
                u.setUserId(rs.getInt("user_id"));
                u.setEmail(rs.getString("email"));
                u.setFullName(rs.getString("full_name"));
                u.setPhone(rs.getString("phone"));
                u.setTeamId(rs.getObject("team_id") != null ? rs.getInt("team_id") : null);
                u.setTeamName(rs.getString("team_name"));
                u.setActive(rs.getBoolean("is_active"));
                return u;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    // Tìm kiếm + Lọc + Phân trang 20 dòng
    public List getUsers(String keyword, Integer teamId, Integer status, int page) {
        List list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
            "SELECT u.*, t.team_name FROM users u " +
            "LEFT JOIN teams t ON u.team_id = t.team_id WHERE 1=1 "
        );

        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append(" AND (u.full_name LIKE ? OR u.email LIKE ?) ");
        }
        if (teamId != null) sql.append(" AND u.team_id = ? ");
        if (status != null) sql.append(" AND u.is_active = ? ");

        sql.append(" ORDER BY u.user_id DESC LIMIT ? OFFSET ?");

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            int idx = 1;
            if (keyword != null && !keyword.trim().isEmpty()) {
                String kw = "%" + keyword.trim() + "%";
                ps.setString(idx++, kw);
                ps.setString(idx++, kw);
            }
            if (teamId != null) ps.setInt(idx++, teamId);
            if (status != null) ps.setInt(idx++, status);

            ps.setInt(idx++, PAGE_SIZE);
            ps.setInt(idx, (page - 1) * PAGE_SIZE);

            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                User u = new User();
                u.setUserId(rs.getInt("user_id"));
                u.setEmail(rs.getString("email"));
                u.setFullName(rs.getString("full_name"));
                u.setPhone(rs.getString("phone"));
                u.setTeamName(rs.getString("team_name"));
                u.setActive(rs.getBoolean("is_active"));
                list.add(u);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    // Đếm tổng số bản ghi để tính số trang
    public int countUsers(String keyword, Integer teamId, Integer status) {
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM users WHERE 1=1 ");
        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append(" AND (full_name LIKE ? OR email LIKE ?) ");
        }
        if (teamId != null) sql.append(" AND team_id = ? ");
        if (status != null) sql.append(" AND is_active = ? ");

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            int idx = 1;
            if (keyword != null && !keyword.trim().isEmpty()) {
                String kw = "%" + keyword.trim() + "%";
                ps.setString(idx++, kw);
                ps.setString(idx++, kw);
            }
            if (teamId != null) ps.setInt(idx++, teamId);
            if (status != null) ps.setInt(idx++, status);

            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getInt(1);
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }
}

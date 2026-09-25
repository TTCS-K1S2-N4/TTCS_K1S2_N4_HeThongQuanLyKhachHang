package com.crm.dao;

import com.crm.model.Account;
import com.crm.util.DBConnection;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class AccountDAO {
    public static final int PAGE_SIZE = 20;

    public boolean isEmailExists(String email, int excludeAccountId) {
        String sql = "SELECT COUNT(*) FROM users WHERE email = ? AND user_id != ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, email);
            ps.setInt(2, excludeAccountId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getInt(1) > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean createAccount(String email, String passwordHash, String fullName, String phone, Integer teamId) {
        String sql = "INSERT INTO users (email, password_hash, full_name, phone, team_id, is_active) VALUES (?, ?, ?, ?, ?, 1)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, email);
            ps.setString(2, passwordHash);
            ps.setString(3, fullName);
            ps.setString(4, phone);
            if (teamId != null) ps.setInt(5, teamId); else ps.setNull(5, Types.INTEGER);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean updateAccount(int accountId, String fullName, String phone, Integer teamId) {
        String sql = "UPDATE users SET full_name = ?, phone = ?, team_id = ? WHERE user_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, fullName);
            ps.setString(2, phone);
            if (teamId != null) ps.setInt(3, teamId); else ps.setNull(3, Types.INTEGER);
            ps.setInt(4, accountId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public Account getAccountById(int accountId) {
        String sql = "SELECT u.*, t.team_name FROM users u LEFT JOIN teams t ON u.team_id = t.team_id WHERE u.user_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, accountId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                Account acc = new Account();
                acc.setAccountId(rs.getInt("user_id"));
                acc.setEmail(rs.getString("email"));
                acc.setPasswordHash(rs.getString("password_hash"));
                acc.setFullName(rs.getString("full_name"));
                acc.setPhone(rs.getString("phone"));
                acc.setTeamId(rs.getObject("team_id") != null ? rs.getInt("team_id") : null);
                acc.setTeamName(rs.getString("team_name"));
                acc.setStatus(rs.getInt("is_active") == 1 ? "ACTIVE" : "LOCKED");
                return acc;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public List<Account> getAccounts(String keyword, Integer teamId, String status, int page) {
        List<Account> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
            "SELECT u.*, t.team_name FROM users u " +
            "LEFT JOIN teams t ON u.team_id = t.team_id WHERE 1=1 "
        );

        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append(" AND (u.full_name LIKE ? OR u.email LIKE ?) ");
        }
        if (teamId != null) sql.append(" AND u.team_id = ? ");
        if ("ACTIVE".equalsIgnoreCase(status)) {
            sql.append(" AND u.is_active = 1 ");
        } else if ("LOCKED".equalsIgnoreCase(status)) {
            sql.append(" AND u.is_active = 0 ");
        }

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

            ps.setInt(idx++, PAGE_SIZE);
            ps.setInt(idx, (page - 1) * PAGE_SIZE);

            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Account acc = new Account();
                acc.setAccountId(rs.getInt("user_id"));
                acc.setEmail(rs.getString("email"));
                acc.setFullName(rs.getString("full_name"));
                acc.setPhone(rs.getString("phone"));
                acc.setTeamName(rs.getString("team_name"));
                acc.setStatus(rs.getInt("is_active") == 1 ? "ACTIVE" : "LOCKED");
                list.add(acc);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public int countAccounts(String keyword, Integer teamId, String status) {
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM users WHERE 1=1 ");
        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append(" AND (full_name LIKE ? OR email LIKE ?) ");
        }
        if (teamId != null) sql.append(" AND team_id = ? ");
        if ("ACTIVE".equalsIgnoreCase(status)) {
            sql.append(" AND is_active = 1 ");
        } else if ("LOCKED".equalsIgnoreCase(status)) {
            sql.append(" AND is_active = 0 ");
        }

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            int idx = 1;
            if (keyword != null && !keyword.trim().isEmpty()) {
                String kw = "%" + keyword.trim() + "%";
                ps.setString(idx++, kw);
                ps.setString(idx++, kw);
            }
            if (teamId != null) ps.setInt(idx++, teamId);

            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getInt(1);
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    public int countOwnedRecords(int accountId) {
        int count = 0;
        String sqlCust = "SELECT COUNT(*) FROM customers WHERE owner_id = ?";
        String sqlOpp = "SELECT COUNT(*) FROM opportunities WHERE owner_id = ?";
        try (Connection conn = DBConnection.getConnection()) {
            try (PreparedStatement ps1 = conn.prepareStatement(sqlCust)) {
                ps1.setInt(1, accountId);
                ResultSet rs1 = ps1.executeQuery();
                if (rs1.next()) count += rs1.getInt(1);
            }
            try (PreparedStatement ps2 = conn.prepareStatement(sqlOpp)) {
                ps2.setInt(1, accountId);
                ResultSet rs2 = ps2.executeQuery();
                if (rs2.next()) count += rs2.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return count;
    }

    public boolean lockAccountAndTransfer(int lockedAccountId, Integer receiverAccountId, int performedByAdminId) {
        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            if (receiverAccountId != null && receiverAccountId > 0) {
                String transferCustSql = "UPDATE customers SET owner_id = ? WHERE owner_id = ?";
                try (PreparedStatement ps = conn.prepareStatement(transferCustSql)) {
                    ps.setInt(1, receiverAccountId);
                    ps.setInt(2, lockedAccountId);
                    ps.executeUpdate();
                }

                String transferOppSql = "UPDATE opportunities SET owner_id = ? WHERE owner_id = ?";
                try (PreparedStatement ps = conn.prepareStatement(transferOppSql)) {
                    ps.setInt(1, receiverAccountId);
                    ps.setInt(2, lockedAccountId);
                    ps.executeUpdate();
                }
            }

            String lockUserSql = "UPDATE users SET is_active = 0 WHERE user_id = ?";
            try (PreparedStatement ps = conn.prepareStatement(lockUserSql)) {
                ps.setInt(1, lockedAccountId);
                ps.executeUpdate();
            }

            String logSql = "INSERT INTO audit_logs (action_type, performed_by, target_user_id, description) VALUES (?, ?, ?, ?)";
             try (PreparedStatement ps = conn.prepareStatement(logSql)) {
                ps.setString(1, "ACCOUNT_LOCK");
                ps.setInt(2, performedByAdminId);
                ps.setInt(3, lockedAccountId);
                ps.setString(4, "Locked account " + lockedAccountId + (receiverAccountId != null ? " and transferred assets to " + receiverAccountId : ""));
                ps.executeUpdate();
            }

            conn.commit();
            return true;
        } catch (Exception e) {
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
            }
            e.printStackTrace();
            return false;
        } finally {
            if (conn != null) {
                try {
                    conn.setAutoCommit(true);
                    conn.close();
                } catch (SQLException ex) { ex.printStackTrace(); }
            }
        }
    }

    public Account findByUsername(String username) {
        String sql = "SELECT u.*, t.team_name FROM users u LEFT JOIN teams t ON u.team_id = t.team_id WHERE u.email = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, username);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                Account acc = new Account();
                acc.setAccountId(rs.getInt("user_id"));
                acc.setEmail(rs.getString("email"));
                acc.setPasswordHash(rs.getString("password_hash"));
                acc.setFullName(rs.getString("full_name"));
                acc.setPhone(rs.getString("phone"));
                acc.setTeamId(rs.getObject("team_id") != null ? rs.getInt("team_id") : null);
                acc.setTeamName(rs.getString("team_name"));
                acc.setStatus(rs.getInt("is_active") == 1 ? "ACTIVE" : "LOCKED");
                return acc;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public boolean updatePassword(int accountId, String newPasswordHash) {
        String sql = "UPDATE users SET password_hash = ? WHERE user_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, newPasswordHash);
            ps.setInt(2, accountId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
}

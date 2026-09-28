package com.crm.dao;

import com.crm.model.Account;
import com.crm.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * Data Access Object quan ly thao tac Voi bang users va cac thong tin lien quan.
 */
public class AccountDAO {
    public Account findByActivationToken(String tokenHash) {
        if (tokenHash == null) return null;
        String sql = "SELECT u.*, t.team_name FROM users u LEFT JOIN teams t ON u.team_id = t.team_id WHERE u.activation_token = ? AND u.activation_token_expiry > CURRENT_TIMESTAMP AND u.is_active = 0";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, tokenHash);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapResultSetToAccount(rs);
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return null;
    }

    public boolean activateAccount(String tokenHash) {
        String sql = "UPDATE users SET is_active = 1, activation_token = NULL, activation_token_expiry = NULL WHERE activation_token = ? AND activation_token_expiry > CURRENT_TIMESTAMP AND is_active = 0";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, tokenHash);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) { e.printStackTrace(); }
        return false;
    }

    public java.util.List<Account> getAllActiveAccounts() {
        java.util.List<Account> list = new java.util.ArrayList<>();
        String sql = "SELECT u.*, t.team_name FROM users u LEFT JOIN teams t ON u.team_id = t.team_id WHERE u.is_active = 1 ORDER BY u.full_name ASC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapResultSetToAccount(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }


    public static final int PAGE_SIZE = 20;

    private Account mapResultSetToAccount(ResultSet rs) throws SQLException {
        Account acc = new Account();
        acc.setAccountId(rs.getInt("user_id"));
        acc.setEmail(rs.getString("email"));
        acc.setPasswordHash(rs.getString("password_hash"));
        acc.setFullName(rs.getString("full_name"));
        acc.setPhone(rs.getString("phone"));
        acc.setTeamId(rs.getObject("team_id") != null ? rs.getInt("team_id") : null);
        try {
            acc.setTeamName(rs.getString("team_name"));
        } catch (SQLException ignored) {}
        try {
            acc.setRoleId(rs.getObject("role_id") != null ? rs.getInt("role_id") : null);
        } catch (SQLException ignored) {}
        try {
            acc.setRoleName(rs.getString("role_name"));
        } catch (SQLException ignored) {}
        acc.setStatus(rs.getInt("is_active") == 1 ? "ACTIVE" : "LOCKED");
        try {
            acc.setResetToken(rs.getString("reset_token"));
            acc.setResetTokenExpiry(rs.getTimestamp("reset_token_expiry"));
        } catch (SQLException ignored) {}
        try {
            acc.setActivationToken(rs.getString("activation_token"));
            acc.setActivationTokenExpiry(rs.getTimestamp("activation_token_expiry"));
        } catch (SQLException ignored) {}
        try {
            acc.setFailedAttempts(rs.getInt("failed_attempts"));
            acc.setUpdatedAt(rs.getTimestamp("updated_at"));
        } catch (SQLException ignored) {}
        try {
            acc.setCreatedAt(rs.getTimestamp("created_at"));
        } catch (SQLException ignored) {}
        return acc;
    }

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

    public boolean createAccount(String email, String passwordHash, String fullName, String phone, java.util.List<Integer> roleIds, Integer teamId, String tokenHash, java.sql.Timestamp expiry) {
        String sql = "INSERT INTO users (email, password_hash, full_name, phone, team_id, activation_token, activation_token_expiry, is_active) VALUES (?, ?, ?, ?, ?, ?, ?, 0)";
        if (roleIds == null || roleIds.isEmpty()) return false;
        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);
            int userId;
            try (PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
                ps.setString(1, email);
                ps.setString(2, passwordHash);
                ps.setString(3, fullName);
                ps.setString(4, phone);
                if (teamId != null) ps.setInt(5, teamId); else ps.setNull(5, Types.INTEGER);
                ps.setString(6, tokenHash);
                ps.setTimestamp(7, expiry);
                if (ps.executeUpdate() == 0) return false;
                try (ResultSet generatedKeys = ps.getGeneratedKeys()) {
                    if (!generatedKeys.next()) return false;
                    userId = generatedKeys.getInt(1);
                }
            }
            try (PreparedStatement rps = conn.prepareStatement("INSERT INTO user_roles (user_id, role_id) VALUES (?, ?)")) {
                for (Integer roleId : roleIds) {
                    rps.setInt(1, userId);
                    rps.setInt(2, roleId);
                    rps.addBatch();
                }
                rps.executeBatch();
            }
            conn.commit();
            return true;
        } catch (SQLException e) {
            if (conn != null) try { conn.rollback(); } catch (SQLException ignored) {}
            e.printStackTrace();
        } finally {
            if (conn != null) try { conn.close(); } catch (SQLException ignored) {}
        }
        return false;
    }

    public boolean updateAccount(int accountId, String fullName, String phone, Integer teamId, java.util.List<Integer> roleIds) {
        String sql = "UPDATE users SET full_name = ?, phone = ?, team_id = ? WHERE user_id = ?";
        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);
            int affectedRows;
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, fullName);
                ps.setString(2, phone);
                if (teamId != null) ps.setInt(3, teamId); else ps.setNull(3, Types.INTEGER);
                ps.setInt(4, accountId);
                affectedRows = ps.executeUpdate();
            }
            if (affectedRows > 0 && roleIds != null && !roleIds.isEmpty()) {
                try (PreparedStatement dps = conn.prepareStatement("DELETE FROM user_roles WHERE user_id = ?")) {
                    dps.setInt(1, accountId);
                    dps.executeUpdate();
                }
                try (PreparedStatement ips = conn.prepareStatement("INSERT INTO user_roles (user_id, role_id) VALUES (?, ?)")) {
                    for (Integer rId : roleIds) {
                        ips.setInt(1, accountId);
                        ips.setInt(2, rId);
                        ips.addBatch();
                    }
                    ips.executeBatch();
                }
            }
            conn.commit();
            return affectedRows > 0;
        } catch (SQLException e) {
            if (conn != null) try { conn.rollback(); } catch (SQLException ignored) {}
            e.printStackTrace();
        } finally {
            if (conn != null) try { conn.close(); } catch (SQLException ignored) {}
        }
        return false;
    }

        public Account getAccountById(int accountId) {
        String sql = "SELECT u.*, t.team_name, ur.role_id, r.role_name, r.role_code FROM users u " +
                     "LEFT JOIN teams t ON u.team_id = t.team_id " +
                     "LEFT JOIN user_roles ur ON u.user_id = ur.user_id " +
                     "LEFT JOIN roles r ON ur.role_id = r.role_id WHERE u.user_id = ?";
        try (java.sql.Connection conn = com.crm.util.DBConnection.getConnection();
             java.sql.PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, accountId);
            java.sql.ResultSet rs = ps.executeQuery();
            Account acc = null;
            while (rs.next()) {
                if (acc == null) {
                    acc = mapResultSetToAccount(rs);
                    acc.setRoleIds(new java.util.ArrayList<>());
                    acc.setRoleNames(new java.util.ArrayList<>());
                    acc.setRoleCodes(new java.util.ArrayList<>());
                }
                int rId = rs.getInt("role_id");
                if (!rs.wasNull() && !acc.getRoleIds().contains(rId)) {
                    acc.getRoleIds().add(rId);
                    acc.getRoleNames().add(rs.getString("role_name"));
                    try {
                        acc.getRoleCodes().add(rs.getString("role_code"));
                    } catch (Exception ignored) {}
                }
            }
            return acc;
        } catch (java.sql.SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public Account findById(int accountId) {
        return getAccountById(accountId);
    }

    public Account findByEmail(String email) {
        if (email == null || email.trim().isEmpty()) {
            return null;
        }
        String sql = "SELECT u.*, t.team_name, ur.role_id, r.role_name, r.role_code FROM users u " +
                     "LEFT JOIN teams t ON u.team_id = t.team_id " +
                     "LEFT JOIN user_roles ur ON u.user_id = ur.user_id " +
                     "LEFT JOIN roles r ON ur.role_id = r.role_id WHERE u.email = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, email.trim());
            try (ResultSet rs = ps.executeQuery()) {
                Account account = null;
                while (rs.next()) {
                    if (account == null) {
                        account = mapResultSetToAccount(rs);
                        account.setRoleIds(new ArrayList<>());
                        account.setRoleNames(new ArrayList<>());
                        account.setRoleCodes(new ArrayList<>());
                    }
                    int roleId = rs.getInt("role_id");
                    if (!rs.wasNull() && !account.getRoleIds().contains(roleId)) {
                        account.getRoleIds().add(roleId);
                        account.getRoleNames().add(rs.getString("role_name"));
                        account.getRoleCodes().add(rs.getString("role_code"));
                    }
                }
                return account;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public Account findByUsername(String username) {
        return findByEmail(username);
    }

    public Account findByResetToken(String token) {
        if (token == null || token.trim().isEmpty()) {
            return null;
        }
        String sql = "SELECT u.*, t.team_name FROM users u " +
                     "LEFT JOIN teams t ON u.team_id = t.team_id " +
                     "WHERE u.reset_token = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, token.trim());
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return mapResultSetToAccount(rs);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public boolean saveResetToken(int userId, String resetToken, Timestamp expiryTime) {
        String sql = "UPDATE users SET reset_token = ?, reset_token_expiry = ? WHERE user_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, resetToken);
            ps.setTimestamp(2, expiryTime);
            ps.setInt(3, userId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean updatePasswordAndClearResetToken(String tokenHash, String newPasswordHash) {
        String sql = "UPDATE users SET password_hash = ?, reset_token = NULL, reset_token_expiry = NULL " +
                     "WHERE reset_token = ? AND reset_token_expiry > ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, newPasswordHash);
            ps.setString(2, tokenHash);
            ps.setTimestamp(3, new Timestamp(System.currentTimeMillis()));
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
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
            e.printStackTrace();
        }
        return false;
    }

    public boolean updateRoleAndTeam(int accountId, int roleId, int teamId) {
        return updateRoleAndTeam(accountId, java.util.Collections.singletonList(roleId), teamId);
    }

    public boolean updateRoleAndTeam(int accountId, List<Integer> roleIds, Integer teamId) {
        if (roleIds == null || roleIds.isEmpty()) return false;
        String updateTeamSql = "UPDATE users SET team_id = ? WHERE user_id = ?";
        String deleteRoleSql = "DELETE FROM user_roles WHERE user_id = ?";
        String insertRoleSql = "INSERT INTO user_roles (user_id, role_id) VALUES (?, ?)";
        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            try (PreparedStatement ps1 = conn.prepareStatement(updateTeamSql)) {
                if (teamId == null) ps1.setNull(1, Types.INTEGER); else ps1.setInt(1, teamId);
                ps1.setInt(2, accountId);
                if (ps1.executeUpdate() == 0) {
                    conn.rollback();
                    return false;
                }
            }

            try (PreparedStatement ps2 = conn.prepareStatement(deleteRoleSql)) {
                ps2.setInt(1, accountId);
                ps2.executeUpdate();
            }

            try (PreparedStatement ps3 = conn.prepareStatement(insertRoleSql)) {
                for (Integer roleId : roleIds) {
                    ps3.setInt(1, accountId);
                    ps3.setInt(2, roleId);
                    ps3.addBatch();
                }
                ps3.executeBatch();
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

    public List<Account> getAccounts(String keyword, Integer teamId, Integer roleId, String status, int offset, int limit) {
        List<Account> list = new ArrayList<>();
        String sql = "SELECT DISTINCT u.*, t.team_name FROM users u LEFT JOIN teams t ON u.team_id = t.team_id ";
        if (roleId != null) {
            sql += "INNER JOIN user_roles ur ON u.user_id = ur.user_id ";
        }
        sql += "WHERE 1=1 ";
        if (keyword != null && !keyword.trim().isEmpty()) {
            sql += " AND (u.full_name LIKE ? OR u.email LIKE ?) ";
        }
        if (teamId != null) sql += " AND u.team_id = ? ";
        if (roleId != null) sql += " AND ur.role_id = ? ";
        if ("ACTIVE".equalsIgnoreCase(status)) {
            sql += " AND u.is_active = 1 ";
        } else if ("INACTIVE".equalsIgnoreCase(status) || "LOCKED".equalsIgnoreCase(status)) {
            sql += " AND u.is_active = 0 ";
        }
        sql += " ORDER BY u.created_at DESC LIMIT ? OFFSET ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            int idx = 1;
            if (keyword != null && !keyword.trim().isEmpty()) {
                String kw = "%" + keyword.trim() + "%";
                ps.setString(idx++, kw);
                ps.setString(idx++, kw);
            }
            if (teamId != null) {
                ps.setInt(idx++, teamId);
            }
            if (roleId != null) {
                ps.setInt(idx++, roleId);
            }
            ps.setInt(idx++, limit);
            ps.setInt(idx, offset);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSetToAccount(rs));
                }
            }
            for (Account account : list) loadRoles(conn, account);
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public int countAccounts(String keyword, Integer teamId, Integer roleId, String status) {
        String sql = "SELECT COUNT(*) FROM users u ";
        if (roleId != null) {
            sql += "INNER JOIN user_roles ur ON u.user_id = ur.user_id ";
        }
        sql += "WHERE 1=1 ";
        if (keyword != null && !keyword.trim().isEmpty()) {
            sql += " AND (u.full_name LIKE ? OR u.email LIKE ?) ";
        }
        if (teamId != null) sql += " AND u.team_id = ? ";
        if (roleId != null) sql += " AND ur.role_id = ? ";
        if ("ACTIVE".equalsIgnoreCase(status)) {
            sql += " AND u.is_active = 1 ";
        } else if ("INACTIVE".equalsIgnoreCase(status) || "LOCKED".equalsIgnoreCase(status)) {
            sql += " AND u.is_active = 0 ";
        }

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            int idx = 1;
            if (keyword != null && !keyword.trim().isEmpty()) {
                String kw = "%" + keyword.trim() + "%";
                ps.setString(idx++, kw);
                ps.setString(idx++, kw);
            }
            if (teamId != null) {
                ps.setInt(idx++, teamId);
            }
            if (roleId != null) {
                ps.setInt(idx++, roleId);
            }
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    private void loadRoles(Connection conn, Account account) throws SQLException {
        String sql = "SELECT r.role_id, r.role_name, r.role_code FROM user_roles ur " +
                     "JOIN roles r ON r.role_id = ur.role_id WHERE ur.user_id = ? ORDER BY r.role_name";
        account.setRoleIds(new ArrayList<>());
        account.setRoleNames(new ArrayList<>());
        account.setRoleCodes(new ArrayList<>());
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, account.getAccountId());
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    account.getRoleIds().add(rs.getInt("role_id"));
                    account.getRoleNames().add(rs.getString("role_name"));
                    account.getRoleCodes().add(rs.getString("role_code"));
                }
            }
        }
    }

    public int countOwnedRecords(int accountId) {
        int count = 0;
        String[] queries = {
            "SELECT COUNT(*) FROM customers WHERE owner_id = ?",
            "SELECT COUNT(*) FROM opportunities WHERE owner_id = ?",
            "SELECT COUNT(*) FROM activities WHERE owner_id = ?",
            "SELECT COUNT(*) FROM quotes WHERE owner_id = ?"
        };
        try (Connection conn = DBConnection.getConnection()) {
            for (String sql : queries) {
                try (PreparedStatement ps = conn.prepareStatement(sql)) {
                    ps.setInt(1, accountId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) count += rs.getInt(1);
                    }
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return count;
    }

    public boolean lockAccountAndTransfer(int lockedAccountId, Integer receiverAccountId, int performedByAdminId, String reason) {
        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            if (receiverAccountId != null && receiverAccountId > 0) {
                String[] transferSql = {
                    "UPDATE customers SET owner_id = ? WHERE owner_id = ?",
                    "UPDATE opportunities SET owner_id = ? WHERE owner_id = ?",
                    "UPDATE activities SET owner_id = ? WHERE owner_id = ?",
                    "UPDATE quotes SET owner_id = ? WHERE owner_id = ?"
                };
                for (String sql : transferSql) {
                    try (PreparedStatement ps = conn.prepareStatement(sql)) {
                        ps.setInt(1, receiverAccountId);
                        ps.setInt(2, lockedAccountId);
                        ps.executeUpdate();
                    }
                }
            }

            String lockUserSql = "UPDATE users SET is_active = 0 WHERE user_id = ?";
            try (PreparedStatement ps = conn.prepareStatement(lockUserSql)) {
                ps.setInt(1, lockedAccountId);
                if (ps.executeUpdate() == 0) {
                    conn.rollback();
                    return false;
                }
            }

            String logSql = "INSERT INTO audit_logs (action_type, performed_by, target_user_id, description) VALUES (?, ?, ?, ?)";
            try (PreparedStatement ps = conn.prepareStatement(logSql)) {
                ps.setString(1, "ACCOUNT_LOCK");
                ps.setInt(2, performedByAdminId);
                ps.setInt(3, lockedAccountId);
                ps.setString(4, "Khóa tài khoản " + lockedAccountId + ", bàn giao dữ liệu cho " + receiverAccountId + ". Lý do: " + reason);
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
}



package com.crm.dao;

import com.crm.model.DataScope;
import com.crm.model.MenuItem;
import com.crm.model.Permission;
import com.crm.util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * DAO truy vấn thông tin Phân quyền, Phạm vi dữ liệu (DataScope) và Danh sách Menu theo vai trò (Role).
 * Sử dụng PreparedStatement để phòng chống SQL Injection.
 */
public class PermissionDAO {

    private static final Logger LOGGER = Logger.getLogger(PermissionDAO.class.getName());

    /**
     * Lấy danh sách tất cả quyền của một Role ID.
     *
     * @param roleId ID của vai trò
     * @return Danh sách Permission
     */
    public List<Permission> findPermissionsByRoleId(int roleId) {
        List<Permission> list = new ArrayList<>();
        String sql = "SELECT p.permission_id, p.permission_code, p.permission_name, p.module, rp.data_scope " +
                     "FROM permissions p " +
                     "JOIN role_permissions rp ON p.permission_id = rp.permission_id " +
                     "WHERE rp.role_id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, roleId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Permission p = new Permission();
                    p.setPermissionId(rs.getInt("permission_id"));
                    p.setPermissionCode(rs.getString("permission_code"));
                    p.setPermissionName(rs.getString("permission_name"));
                    p.setModule(rs.getString("module"));
                    p.setDataScope(DataScope.fromString(rs.getString("data_scope")));
                    list.add(p);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Lỗi truy vấn findPermissionsByRoleId với roleId = " + roleId, e);
        }
        return list;
    }

    /**
     * Lấy DataScope áp dụng cho một Role và một Module cụ thể (ACCOUNT, DEAL, ACTIVITY, QUOTE).
     * Ưu tiên scope rộng nhất nếu có nhiều hơn 1 bản ghi cấu hình (ALL > TEAM > MY).
     *
     * @param roleId ID của vai trò
     * @param module Tên module nghiệp vụ
     * @return DataScope (MY, TEAM, ALL). Mặc định là MY nếu không tìm thấy.
     */
    public DataScope findDataScopeByRoleAndModule(int roleId, String module) {
        String sql = "SELECT rp.data_scope " +
                     "FROM role_permissions rp " +
                     "JOIN permissions p ON rp.permission_id = p.permission_id " +
                     "WHERE rp.role_id = ? AND UPPER(p.module) = UPPER(?) " +
                     "ORDER BY CASE rp.data_scope " +
                     "  WHEN 'ALL' THEN 1 " +
                     "  WHEN 'TEAM' THEN 2 " +
                     "  WHEN 'MY' THEN 3 " +
                     "  ELSE 4 END " +
                     "LIMIT 1";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, roleId);
            ps.setString(2, module);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return DataScope.fromString(rs.getString("data_scope"));
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Lỗi khi truy vấn DataScope cho roleId = " + roleId + ", module = " + module, e);
        }
        return DataScope.MY; // Thu hẹp an toàn về MY nếu gặp sự cố
    }

    /**
     * Truy vấn danh sách account_id thuộc cùng Team với một userId.
     * Phục vụ cho tính năng lọc dữ liệu phạm vi TEAM.
     *
     * @param userId ID người dùng
     * @return Danh sách account_id cùng team
     */
    public List<Integer> findTeamMemberUserIdsByUserId(int userId) {
        List<Integer> memberIds = new ArrayList<>();
        String sql = "SELECT account_id FROM accounts " +
                     "WHERE team_id = (SELECT team_id FROM accounts WHERE account_id = ? AND team_id IS NOT NULL)";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    memberIds.add(rs.getInt("account_id"));
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Lỗi khi truy vấn danh sách thành viên team cho userId = " + userId, e);
        }

        if (memberIds.isEmpty()) {
            memberIds.add(userId);
        }
        return memberIds;
    }

    /**
     * Lấy Team ID của người dùng từ bảng accounts.
     *
     * @param userId ID người dùng
     * @return Team ID hoặc null nếu không thuộc nhóm nào
     */
    public Integer findTeamIdByUserId(int userId) {
        String sql = "SELECT team_id FROM accounts WHERE account_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    int teamId = rs.getInt("team_id");
                    return rs.wasNull() ? null : teamId;
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Lỗi truy vấn teamId cho userId = " + userId, e);
        }
        return null;
    }

    /**
     * Truy vấn các mục Menu điều hướng mà vai trò được phép nhìn thấy.
     *
     * @param roleId ID của vai trò
     * @return Danh sách các MenuItem
     */
    public List<MenuItem> findMenuItemsByRoleId(int roleId) {
        List<MenuItem> menuItems = new ArrayList<>();
        String sql = "SELECT DISTINCT m.id, m.title, m.url, m.icon, m.permission_code, m.display_order, m.parent_id " +
                     "FROM menu_items m " +
                     "JOIN permissions p ON m.permission_code = p.permission_code " +
                     "JOIN role_permissions rp ON p.permission_id = rp.permission_id " +
                     "WHERE rp.role_id = ? " +
                     "ORDER BY m.display_order ASC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, roleId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    MenuItem item = new MenuItem();
                    item.setId(rs.getInt("id"));
                    item.setTitle(rs.getString("title"));
                    item.setUrl(rs.getString("url"));
                    item.setIcon(rs.getString("icon"));
                    item.setPermissionCode(rs.getString("permission_code"));
                    item.setDisplayOrder(rs.getInt("display_order"));
                    item.setParentId(rs.getInt("parent_id"));
                    menuItems.add(item);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Lỗi truy vấn menuItems cho roleId = " + roleId, e);
        }
        return menuItems;
    }

    /**
     * Kiểm tra nhanh vai trò có chứa mã quyền permissionCode hay không.
     *
     * @param roleId ID vai trò
     * @param permissionCode Mã quyền
     * @return true nếu có, false nếu không
     */
    public boolean hasPermission(int roleId, String permissionCode) {
        String sql = "SELECT 1 FROM role_permissions rp " +
                     "JOIN permissions p ON rp.permission_id = p.permission_id " +
                     "WHERE rp.role_id = ? AND UPPER(p.permission_code) = UPPER(?)";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, roleId);
            ps.setString(2, permissionCode);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Lỗi kiểm tra permissionCode = " + permissionCode + " cho roleId = " + roleId, e);
        }
        return false;
    }
}

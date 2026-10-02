package com.crm.service;

import com.crm.dao.PermissionDAO;
import com.crm.exception.AuthorizationException;
import com.crm.model.DataScope;
import com.crm.model.MenuItem;

import java.util.Collections;
import java.util.List;
import java.util.Objects;
import java.util.logging.Logger;

public class PermissionService {

    private static final Logger LOGGER = Logger.getLogger(PermissionService.class.getName());

    private final PermissionDAO permissionDAO;

    public PermissionService() {
        this.permissionDAO = new PermissionDAO();
    }

    public PermissionService(PermissionDAO permissionDAO) {
        this.permissionDAO = Objects.requireNonNull(permissionDAO, "PermissionDAO không được để null");
    }

    public List<MenuItem> getMenuByRole(int roleId) {
        if (roleId <= 0) return Collections.emptyList();
        return permissionDAO.findMenuItemsByRoleId(roleId);
    }
    
    public List<MenuItem> getMenuByRoles(List<Integer> roleIds) {
        if (roleIds == null || roleIds.isEmpty()) return Collections.emptyList();
        return permissionDAO.findMenuItemsByRoleIds(roleIds);
    }

    public DataScope getDataScope(int roleId, String module) {
        if (roleId <= 0 || module == null || module.trim().isEmpty()) {
            return DataScope.MY;
        }
        return permissionDAO.findDataScopeByRoleAndModule(roleId, module);
    }
    
    public DataScope getDataScopeForRoles(List<Integer> roleIds, String module) {
        if (roleIds == null || roleIds.isEmpty() || module == null || module.trim().isEmpty()) {
            return DataScope.MY;
        }
        return permissionDAO.findDataScopeByRolesAndModule(roleIds, module);
    }

    public List<Integer> getAccessibleAccountIds(int userId, int roleId, String module) {
        return accessibleIdsForScope(userId, getDataScope(roleId, module));
    }
    
    public List<Integer> getAccessibleAccountIdsForRoles(int userId, List<Integer> roleIds, String module) {
        return accessibleIdsForScope(userId, getDataScopeForRoles(roleIds, module));
    }

    private List<Integer> accessibleIdsForScope(int userId, DataScope scope) {
        switch (scope) {
            case MY:
                return Collections.singletonList(userId);
            case TEAM:
                return permissionDAO.findTeamMemberUserIdsByUserId(userId);
            case ALL:
                return null;
            default:
                return Collections.singletonList(userId);
        }
    }

    public boolean canAccessData(int userId, int roleId, String module, int ownerId) {
        return canAccessScope(userId, getDataScope(roleId, module), ownerId);
    }
    
    public boolean canAccessDataForRoles(int userId, List<Integer> roleIds, String module, int ownerId) {
        return canAccessScope(userId, getDataScopeForRoles(roleIds, module), ownerId);
    }

    private boolean canAccessScope(int userId, DataScope scope, int ownerId) {
        if (scope == DataScope.ALL) return true;
        if (scope == DataScope.MY) return userId == ownerId;
        if (scope == DataScope.TEAM) {
            List<Integer> teamMembers = permissionDAO.findTeamMemberUserIdsByUserId(userId);
            return teamMembers != null && teamMembers.contains(ownerId);
        }

        return false;
    }

    public void validateDataAccess(int userId, int roleId, String module, int ownerId) throws AuthorizationException {
        if (!canAccessData(userId, roleId, module, ownerId)) {
            LOGGER.warning(String.format("Từ chối truy cập: userId=%d cố xem bản ghi của ownerId=%d ở module=%s (scope=%s)",
                    userId, ownerId, module, getDataScope(roleId, module)));
            throw new AuthorizationException("Bạn không có quyền xem hoặc thao tác trên dữ liệu này.");
        }
    }
    
    public void validateDataAccessForRoles(int userId, List<Integer> roleIds, String module, int ownerId) throws AuthorizationException {
        if (!canAccessDataForRoles(userId, roleIds, module, ownerId)) {
            LOGGER.warning(String.format("Từ chối truy cập: userId=%d cố xem bản ghi của ownerId=%d ở module=%s (scope=%s)",
                    userId, ownerId, module, getDataScopeForRoles(roleIds, module)));
            throw new AuthorizationException("Bạn không có quyền xem hoặc thao tác trên dữ liệu này.");
        }
    }

    public boolean hasPermission(int roleId, String permissionCode) {
        if (roleId <= 0 || permissionCode == null || permissionCode.trim().isEmpty()) {
            return false;
        }
        return permissionDAO.hasPermission(roleId, permissionCode);
    }
    
    public boolean hasPermissionForRoles(List<Integer> roleIds, String permissionCode) {
        if (roleIds == null || roleIds.isEmpty() || permissionCode == null || permissionCode.trim().isEmpty()) {
            return false;
        }
        return permissionDAO.hasPermissionForRoles(roleIds, permissionCode);
    }

    public boolean canViewProductCost(List<Integer> roleIds) {
        if (roleIds == null || roleIds.isEmpty()) {
            return false;
        }
        return hasPermissionForRoles(roleIds, "PRODUCT_COST_VIEW");
    }
}

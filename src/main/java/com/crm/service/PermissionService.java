package com.crm.service;

import com.crm.dao.PermissionDAO;
import com.crm.exception.AuthorizationException;
import com.crm.model.DataScope;
import com.crm.model.MenuItem;

import java.util.Collections;
import java.util.List;
import java.util.Objects;
import java.util.logging.Logger;

/**
 * Service xử lý nghiệp vụ Phân quyền dữ liệu (DataScope: MY, TEAM, ALL) và Menu điều hướng theo vai trò.
 * Thiết kế generic theo tham số module (ACCOUNT, DEAL, ACTIVITY, QUOTE) để tránh lặp code.
 */
public class PermissionService {

    private static final Logger LOGGER = Logger.getLogger(PermissionService.class.getName());

    private final PermissionDAO permissionDAO;

    public PermissionService() {
        this.permissionDAO = new PermissionDAO();
    }

    public PermissionService(PermissionDAO permissionDAO) {
        this.permissionDAO = Objects.requireNonNull(permissionDAO, "PermissionDAO không được để null");
    }

    /**
     * Lấy danh sách các mục Menu hiển thị tương ứng với vai trò (Role).
     * Áp dụng cho User Story S1-06 (Ẩn hoàn toàn các menu người dùng không có quyền).
     *
     * @param roleId ID vai trò
     * @return Danh sách MenuItem
     */
    public List<MenuItem> getMenuByRole(int roleId) {
        if (roleId <= 0) {
            return Collections.emptyList();
        }
        return permissionDAO.findMenuItemsByRoleId(roleId);
    }

    /**
     * Lấy DataScope áp dụng cho module cụ thể (ACCOUNT, DEAL, ACTIVITY, QUOTE).
     *
     * @param roleId ID vai trò
     * @param module Tên module
     * @return DataScope (MY, TEAM, ALL)
     */
    public DataScope getDataScope(int roleId, String module) {
        if (roleId <= 0 || module == null || module.trim().isEmpty()) {
            return DataScope.MY; // Thu hẹp an toàn
        }
        return permissionDAO.findDataScopeByRoleAndModule(roleId, module);
    }

    /**
     * Trả về danh sách ID người sở hữu (account_id) mà người dùng hiện tại có quyền truy cập.
     * 
     * - Scope MY: Trả về [userId]
     * - Scope TEAM: Trả về danh sách ID của các thành viên cùng team với userId
     * - Scope ALL: Trả về danh sách rỗng (empty list) -> Tầng Controller/DAO khác sẽ không append điều kiện WHERE owner_id IN (...)
     *
     * @param userId ID người dùng
     * @param roleId ID vai trò
     * @param module Tên module nghiệp vụ
     * @return List Integer chứa các account_id được phép truy cập
     */
    public List<Integer> getAccessibleAccountIds(int userId, int roleId, String module) {
        DataScope scope = getDataScope(roleId, module);

        switch (scope) {
            case MY:
                return Collections.singletonList(userId);
            case TEAM:
                return permissionDAO.findTeamMemberUserIdsByUserId(userId);
            case ALL:
                return Collections.emptyList();
            default:
                return Collections.singletonList(userId);
        }
    }

    /**
     * Kiểm tra người dùng (userId, roleId) có quyền xem hoặc thao tác trên bản ghi do ownerId sở hữu hay không.
     *
     * @param userId  ID người dùng
     * @param roleId  ID vai trò
     * @param module  Tên module (ACCOUNT, DEAL, ACTIVITY, QUOTE)
     * @param ownerId ID người sở hữu bản ghi
     * @return true nếu có quyền truy cập, false nếu bị cấm
     */
    public boolean canAccessData(int userId, int roleId, String module, int ownerId) {
        DataScope scope = getDataScope(roleId, module);

        if (scope == DataScope.ALL) {
            return true;
        }

        if (scope == DataScope.MY) {
            return userId == ownerId;
        }

        if (scope == DataScope.TEAM) {
            List<Integer> teamMembers = permissionDAO.findTeamMemberUserIdsByUserId(userId);
            return teamMembers != null && teamMembers.contains(ownerId);
        }

        return false;
    }

    /**
     * Thực hiện kiểm tra an toàn truy cập dữ liệu. Nếu từ chối, ném ngoại lệ AuthorizationException chứa thông báo tiếng Việt.
     *
     * @param userId  ID người dùng
     * @param roleId  ID vai trò
     * @param module  Tên module
     * @param ownerId ID chủ sở hữu bản ghi
     * @throws AuthorizationException nếu người dùng cố truy cập ngoài phạm vi
     */
    public void validateDataAccess(int userId, int roleId, String module, int ownerId) throws AuthorizationException {
        if (!canAccessData(userId, roleId, module, ownerId)) {
            LOGGER.warning(String.format("Từ chối truy cập: userId=%d cố xem bản ghi của ownerId=%d ở module=%s (scope=%s)",
                    userId, ownerId, module, getDataScope(roleId, module)));
            throw new AuthorizationException("Bạn không có quyền xem hoặc thao tác trên dữ liệu này.");
        }
    }

    /**
     * Kiểm tra người dùng có một quyền chức năng cụ thể hay không (ví dụ: ACCOUNT_CREATE, DEAL_EXPORT).
     *
     * @param roleId         ID vai trò
     * @param permissionCode Mã quyền
     * @return true nếu có quyền, false nếu không
     */
    public boolean hasPermission(int roleId, String permissionCode) {
        if (roleId <= 0 || permissionCode == null || permissionCode.trim().isEmpty()) {
            return false;
        }
        return permissionDAO.hasPermission(roleId, permissionCode);
    }
}

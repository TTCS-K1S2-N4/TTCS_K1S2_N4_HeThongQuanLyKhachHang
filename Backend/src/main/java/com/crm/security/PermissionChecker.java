package com.crm.security;

import com.crm.exception.AuthorizationException;
import com.crm.model.DataScope;
import com.crm.service.PermissionService;

import java.util.List;

/**
 * Utility Class tiện ích bảo mật dùng ở Controller / Service của các BE khác (BE1, BE4...)
 * để nhanh chóng kiểm tra quyền hạn và phạm vi dữ liệu trước khi xử lý logic nghiệp vụ.
 */
public class PermissionChecker {

    private static PermissionService permissionService = new PermissionService();

    /**
     * Cho phép inject/override PermissionService trong trường hợp Unit test hoặc Custom Context.
     *
     * @param service Instance của PermissionService
     */
    public static void setPermissionService(PermissionService service) {
        if (service != null) {
            permissionService = service;
        }
    }

    /**
     * Kiểm tra xem người dùng userId (vai trò roleId) có được phép truy cập bản ghi sở hữu bởi ownerId ở module hay không.
     *
     * @param userId  ID người dùng
     * @param roleId  ID vai trò
     * @param module  Tên module (ACCOUNT, DEAL, ACTIVITY, QUOTE)
     * @param ownerId ID chủ sở hữu bản ghi
     * @return true nếu có quyền truy cập, false nếu không
     */
    public static boolean canAccess(int userId, int roleId, String module, int ownerId) {
        return permissionService.canAccessData(userId, roleId, module, ownerId);
    }

    /**
     * Kiểm tra an toàn truy cập bản ghi. Ném AuthorizationException nếu vi phạm quyền.
     *
     * @param userId  ID người dùng
     * @param roleId  ID vai trò
     * @param module  Tên module
     * @param ownerId ID chủ sở hữu bản ghi
     * @throws AuthorizationException nếu người dùng không thuộc phạm vi sở hữu
     */
    public static void checkAccessOrThrow(int userId, int roleId, String module, int ownerId) throws AuthorizationException {
        permissionService.validateDataAccess(userId, roleId, module, ownerId);
    }

    /**
     * Kiểm tra xem người dùng có quyền chức năng cụ thể không.
     *
     * @param roleId         ID vai trò
     * @param permissionCode Mã quyền (ví dụ: ACCOUNT_CREATE, DEAL_EXPORT)
     * @return true nếu có quyền, false nếu không
     */
    public static boolean hasPermission(int roleId, String permissionCode) {
        return permissionService.hasPermission(roleId, permissionCode);
    }

    /**
     * Lấy DataScope hiện tại của vai trò đối với một module.
     *
     * @param roleId ID vai trò
     * @param module Tên module
     * @return DataScope (MY, TEAM, ALL)
     */
    public static DataScope getScope(int roleId, String module) {
        return permissionService.getDataScope(roleId, module);
    }

    /**
     * Lấy danh sách Account ID có thể truy cập để tự động lọc dữ liệu trong SQL query.
     *
     * @param userId ID người dùng
     * @param roleId ID vai trò
     * @param module Tên module
     * @return List ID người dùng được phép xem
     */
    public static List<Integer> getAccessibleAccountIds(int userId, int roleId, String module) {
        return permissionService.getAccessibleAccountIds(userId, roleId, module);
    }
}

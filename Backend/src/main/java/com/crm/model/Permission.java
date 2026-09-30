package com.crm.model;

import java.io.Serializable;

/**
 * Class đại diện cho thông tin Phân quyền (Permission) trong hệ thống CRM.
 * Bao gồm thông tin mã quyền, tên quyền, module áp dụng và phạm vi dữ liệu (DataScope).
 */
public class Permission implements Serializable {
    private static final long serialVersionUID = 1L;

    private int permissionId;
    private String permissionCode; // Ví dụ: ACCOUNT_VIEW, DEAL_CREATE, ACTIVITY_EDIT, QUOTE_VIEW
    private String permissionName; // Tên hiển thị quyền (ví dụ: Xem thông tin khách hàng)
    private String module;         // Module nghiệp vụ: ACCOUNT, DEAL, ACTIVITY, QUOTE, SYSTEM...
    private DataScope dataScope;   // MY, TEAM, ALL

    public Permission() {
    }

    public Permission(int permissionId, String permissionCode, String permissionName, String module, DataScope dataScope) {
        this.permissionId = permissionId;
        this.permissionCode = permissionCode;
        this.permissionName = permissionName;
        this.module = module;
        this.dataScope = dataScope;
    }

    public int getPermissionId() {
        return permissionId;
    }

    public void setPermissionId(int permissionId) {
        this.permissionId = permissionId;
    }

    public String getPermissionCode() {
        return permissionCode;
    }

    public void setPermissionCode(String permissionCode) {
        this.permissionCode = permissionCode;
    }

    public String getPermissionName() {
        return permissionName;
    }

    public void setPermissionName(String permissionName) {
        this.permissionName = permissionName;
    }

    public String getModule() {
        return module;
    }

    public void setModule(String module) {
        this.module = module;
    }

    public DataScope getDataScope() {
        return dataScope;
    }

    public void setDataScope(DataScope dataScope) {
        this.dataScope = dataScope;
    }

    @Override
    public String toString() {
        return "Permission{" +
                "permissionId=" + permissionId +
                ", permissionCode='" + permissionCode + '\'' +
                ", permissionName='" + permissionName + '\'' +
                ", module='" + module + '\'' +
                ", dataScope=" + dataScope +
                '}';
    }
}

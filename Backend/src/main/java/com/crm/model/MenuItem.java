package com.crm.model;

import java.io.Serializable;

/**
 * Class đại diện cho một mục menu điều hướng trong giao diện CRM.
 * Phục vụ cho User Story S1-06 (Menu điều hướng hiển thị đúng theo quyền của người dùng).
 */
public class MenuItem implements Serializable {
    private static final long serialVersionUID = 1L;

    private int id;
    private String title;          // Tên hiển thị menu (ví dụ: Khách hàng, Cơ hội, Báo giá)
    private String url;            // Đường dẫn URL điều hướng
    private String icon;           // Icon CSS class (ví dụ: fa-users, fa-chart-line)
    private String permissionCode; // Mã quyền bắt buộc để nhìn thấy menu này (ví dụ: MENU_ACCOUNT)
    private int displayOrder;      // Thứ tự hiển thị menu
    private int parentId;          // ID menu cha (nếu là menu cấp 2)

    public MenuItem() {
    }

    public MenuItem(int id, String title, String url, String icon, String permissionCode, int displayOrder, int parentId) {
        this.id = id;
        this.title = title;
        this.url = url;
        this.icon = icon;
        this.permissionCode = permissionCode;
        this.displayOrder = displayOrder;
        this.parentId = parentId;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getUrl() {
        return url;
    }

    public void setUrl(String url) {
        this.url = url;
    }

    public String getIcon() {
        return icon;
    }

    public void setIcon(String icon) {
        this.icon = icon;
    }

    public String getPermissionCode() {
        return permissionCode;
    }

    public void setPermissionCode(String permissionCode) {
        this.permissionCode = permissionCode;
    }

    public int getDisplayOrder() {
        return displayOrder;
    }

    public void setDisplayOrder(int displayOrder) {
        this.displayOrder = displayOrder;
    }

    public int getParentId() {
        return parentId;
    }

    public void setParentId(int parentId) {
        this.parentId = parentId;
    }

    @Override
    public String toString() {
        return "MenuItem{" +
                "id=" + id +
                ", title='" + title + '\'' +
                ", url='" + url + '\'' +
                ", permissionCode='" + permissionCode + '\'' +
                ", displayOrder=" + displayOrder +
                '}';
    }
}

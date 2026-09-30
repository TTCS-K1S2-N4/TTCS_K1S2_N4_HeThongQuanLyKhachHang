package com.crm.model;

/**
 * Enum đại diện cho 3 phạm vi dữ liệu theo vị trí/vai trò của người dùng trong hệ thống CRM:
 * - MY: Chỉ dữ liệu thuộc sở hữu của chính người dùng đó.
 * - TEAM: Dữ liệu thuộc sở hữu của tất cả thành viên trong nhóm (team) của người dùng.
 * - ALL: Toàn bộ dữ liệu trong hệ thống (không giới hạn sở hữu).
 */
public enum DataScope {
    MY("Của tôi"),
    TEAM("Của nhóm"),
    ALL("Tất cả");

    private final String description;

    DataScope(String description) {
        this.description = description;
    }

    public String getDescription() {
        return description;
    }

    /**
     * Chuyển đổi an toàn từ chuỗi sang DataScope (mặc định trả về MY nếu không hợp lệ).
     *
     * @param scopeStr Chuỗi đại diện cho scope ("MY", "TEAM", "ALL")
     * @return DataScope tương ứng
     */
    public static DataScope fromString(String scopeStr) {
        if (scopeStr == null || scopeStr.trim().isEmpty()) {
            return MY;
        }
        try {
            return DataScope.valueOf(scopeStr.trim().toUpperCase());
        } catch (IllegalArgumentException e) {
            return MY; // Fallback an toàn về MY khi chuỗi không hợp lệ
        }
    }
}

package com.qlkh.entity;

/**
 * Phạm vi dữ liệu gắn với Role (S1-05).
 * MY   - chỉ dữ liệu do chính user sở hữu
 * TEAM - dữ liệu của nhóm kinh doanh (bao gồm nhóm con nếu user là trưởng nhóm)
 * ALL  - toàn bộ dữ liệu trong hệ thống
 */
public enum DataScope {
    MY,
    TEAM,
    ALL
}

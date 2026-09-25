-- ====================================================================
-- SCRIPT TẠO BẢNG VÀ DỮ LIỆU MẪU CHO MODULE BE3 (PHÂN QUYỀN DỮ LIỆU & MENU)
-- ====================================================================

-- 1. Bảng lưu thông tin quyền hạn (Permissions)
CREATE TABLE IF NOT EXISTS permissions (
    permission_id INT AUTO_INCREMENT PRIMARY KEY,
    permission_code VARCHAR(50) NOT NULL UNIQUE,
    permission_name VARCHAR(100) NOT NULL,
    module VARCHAR(50) NOT NULL -- ACCOUNT, DEAL, ACTIVITY, QUOTE, SYSTEM
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 2. Bảng gán quyền cho Vai trò (Role) kèm Phạm vi dữ liệu (DataScope: MY, TEAM, ALL)
CREATE TABLE IF NOT EXISTS role_permissions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    role_id INT NOT NULL,
    permission_id INT NOT NULL,
    data_scope ENUM('MY', 'TEAM', 'ALL') NOT NULL DEFAULT 'MY',
    FOREIGN KEY (permission_id) REFERENCES permissions(permission_id) ON DELETE CASCADE,
    UNIQUE KEY uk_role_permission (role_id, permission_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 3. Bảng lưu danh sách Mục Menu điều hướng
CREATE TABLE IF NOT EXISTS menu_items (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(100) NOT NULL,
    url VARCHAR(255) NOT NULL,
    icon VARCHAR(50) DEFAULT 'fa-folder',
    permission_code VARCHAR(50) NOT NULL,
    display_order INT DEFAULT 0,
    parent_id INT DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ====================================================================
-- DỮ LIỆU MẪU (SEED DATA)
-- ====================================================================

-- Chèn dữ liệu Quyền mẫu
INSERT INTO permissions (permission_id, permission_code, permission_name, module) VALUES
(1, 'ACCOUNT_VIEW', 'Xem Khách hàng', 'ACCOUNT'),
(2, 'ACCOUNT_CREATE', 'Tạo mới Khách hàng', 'ACCOUNT'),
(3, 'ACCOUNT_EDIT', 'Chỉnh sửa Khách hàng', 'ACCOUNT'),
(4, 'ACCOUNT_DELETE', 'Xóa Khách hàng', 'ACCOUNT'),
(5, 'ACCOUNT_EXPORT', 'Xuất Excel Khách hàng', 'ACCOUNT'),

(6, 'DEAL_VIEW', 'Xem Cơ hội', 'DEAL'),
(7, 'DEAL_CREATE', 'Tạo mới Cơ hội', 'DEAL'),
(8, 'DEAL_EDIT', 'Chỉnh sửa Cơ hội', 'DEAL'),

(9, 'ACTIVITY_VIEW', 'Xem Hoạt động', 'ACTIVITY'),
(10, 'QUOTE_VIEW', 'Xem Báo giá', 'QUOTE');

-- Giả định Role IDs:
-- Role 1: Nhân viên Kinh doanh (Data Scope: MY)
-- Role 2: Trưởng nhóm (Data Scope: TEAM)
-- Role 3: Giám đốc (Data Scope: ALL)

-- Role 1 (Nhân viên): Chỉ thấy dữ liệu của mình (MY)
INSERT INTO role_permissions (role_id, permission_id, data_scope) VALUES
(1, 1, 'MY'), -- Xem Khách hàng MY
(1, 2, 'MY'), -- Tạo Khách hàng
(1, 6, 'MY'), -- Xem Cơ hội MY
(1, 9, 'MY'), -- Xem Hoạt động MY
(1, 10, 'MY'); -- Xem Báo giá MY

-- Role 2 (Trưởng nhóm): Thấy dữ liệu của cả nhóm (TEAM)
INSERT INTO role_permissions (role_id, permission_id, data_scope) VALUES
(2, 1, 'TEAM'), -- Xem Khách hàng TEAM
(2, 2, 'TEAM'),
(2, 3, 'TEAM'),
(2, 5, 'TEAM'), -- Xuất Excel TEAM
(2, 6, 'TEAM'), -- Xem Cơ hội TEAM
(2, 9, 'TEAM'),
(2, 10, 'TEAM');

-- Role 3 (Giám đốc): Thấy tất cả dữ liệu (ALL)
INSERT INTO role_permissions (role_id, permission_id, data_scope) VALUES
(3, 1, 'ALL'), -- Xem Tất cả Khách hàng
(3, 2, 'ALL'),
(3, 3, 'ALL'),
(3, 4, 'ALL'),
(3, 5, 'ALL'),
(3, 6, 'ALL'),
(3, 9, 'ALL'),
(3, 10, 'ALL');

-- Chèn dữ liệu Menu
INSERT INTO menu_items (id, title, url, icon, permission_code, display_order, parent_id) VALUES
(1, 'Khách hàng', '/accounts', 'fa-users', 'ACCOUNT_VIEW', 1, 0),
(2, 'Cơ hội kinh doanh', '/deals', 'fa-chart-line', 'DEAL_VIEW', 2, 0),
(3, 'Hoạt động & Lịch hẹn', '/activities', 'fa-calendar-alt', 'ACTIVITY_VIEW', 3, 0),
(4, 'Báo giá', '/quotes', 'fa-file-invoice-dollar', 'QUOTE_VIEW', 4, 0);

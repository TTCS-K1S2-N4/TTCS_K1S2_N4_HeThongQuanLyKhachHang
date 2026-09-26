CREATE DATABASE IF NOT EXISTS crm_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE crm_db;

-- 1. Bảng Nhóm kinh doanh
CREATE TABLE IF NOT EXISTS teams (
    team_id INT AUTO_INCREMENT PRIMARY KEY,
    team_name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. Bảng Vai trò (7 vai trò theo tài liệu)
CREATE TABLE IF NOT EXISTS roles (
    role_id INT AUTO_INCREMENT PRIMARY KEY,
    role_code VARCHAR(50) NOT NULL UNIQUE,
    role_name VARCHAR(100) NOT NULL
);

-- 3. Bảng Người dùng (Bổ sung reset_token và reset_token_expiry cho S1-03)
CREATE TABLE IF NOT EXISTS users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(150) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    phone VARCHAR(20),
    team_id INT NULL,
    is_active TINYINT(1) DEFAULT 1,
    failed_attempts INT DEFAULT 0,
    reset_token VARCHAR(255) NULL,
    reset_token_expiry TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (team_id) REFERENCES teams(team_id) ON DELETE SET NULL
);

-- 4. Bảng liên kết N-N: User - Role
CREATE TABLE IF NOT EXISTS user_roles (
    user_id INT NOT NULL,
    role_id INT NOT NULL,
    PRIMARY KEY (user_id, role_id),
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (role_id) REFERENCES roles(role_id) ON DELETE CASCADE
);

-- 5. Bảng Khách hàng (Có trường owner_id phục vụ bàn giao dữ liệu S1-10)
CREATE TABLE IF NOT EXISTS customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_name VARCHAR(200) NOT NULL,
    phone VARCHAR(20),
    owner_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (owner_id) REFERENCES users(user_id)
);

-- 6. Bảng Cơ hội bán hàng (Có trường owner_id phục vụ S1-10)
CREATE TABLE IF NOT EXISTS opportunities (
    opportunity_id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    amount DECIMAL(15, 2) DEFAULT 0,
    owner_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (owner_id) REFERENCES users(user_id)
);

-- 7. Bảng Nhật ký thao tác (Audit log bàn giao S1-10)
CREATE TABLE IF NOT EXISTS audit_logs (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    action_type VARCHAR(50) NOT NULL,
    performed_by INT NOT NULL,
    target_user_id INT NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (performed_by) REFERENCES users(user_id),
    FOREIGN KEY (target_user_id) REFERENCES users(user_id)
);

-- 8. Bảng lưu thông tin quyền hạn (Permissions - Module BE3)
CREATE TABLE IF NOT EXISTS permissions (
    permission_id INT AUTO_INCREMENT PRIMARY KEY,
    permission_code VARCHAR(50) NOT NULL UNIQUE,
    permission_name VARCHAR(100) NOT NULL,
    module VARCHAR(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 9. Bảng gán quyền cho Vai trò kèm Phạm vi dữ liệu (DataScope: MY, TEAM, ALL - Module BE3)
CREATE TABLE IF NOT EXISTS role_permissions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    role_id INT NOT NULL,
    permission_id INT NOT NULL,
    data_scope ENUM('MY', 'TEAM', 'ALL') NOT NULL DEFAULT 'MY',
    FOREIGN KEY (permission_id) REFERENCES permissions(permission_id) ON DELETE CASCADE,
    UNIQUE KEY uk_role_permission (role_id, permission_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 10. Bảng lưu danh sách Mục Menu điều hướng (Module BE3)
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
-- DỮ LIỆU MẪU (SEED DATA - Module BE3)
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

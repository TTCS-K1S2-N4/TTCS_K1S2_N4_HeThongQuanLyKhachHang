-- Dữ liệu nền có thể chạy lại an toàn. Mọi liên kết quyền dùng role_code,
-- không phụ thuộc thứ tự AUTO_INCREMENT.

INSERT INTO roles (role_code, role_name) VALUES
('ADMIN', 'Quản trị hệ thống'),
('SALES_REP', 'Nhân viên kinh doanh'),
('TEAM_LEAD', 'Trưởng nhóm kinh doanh'),
('DIRECTOR', 'Giám đốc kinh doanh'),
('MARKETING', 'Nhân viên Marketing'),
('CUST_SUCCESS', 'Chăm sóc khách hàng'),
('ACCOUNTANT', 'Kế toán')
ON DUPLICATE KEY UPDATE role_name = VALUES(role_name);

INSERT INTO teams (team_name, description) VALUES
('Team Kinh Doanh 1', 'Phụ trách thị trường miền Bắc'),
('Team Kinh Doanh 2', 'Phụ trách thị trường miền Nam')
ON DUPLICATE KEY UPDATE description = VALUES(description);

INSERT INTO permissions (permission_code, permission_name, module) VALUES
('ACCOUNT_VIEW', 'Xem Khách hàng', 'ACCOUNT'),
('ACCOUNT_CREATE', 'Tạo mới Khách hàng', 'ACCOUNT'),
('ACCOUNT_EDIT', 'Chỉnh sửa Khách hàng', 'ACCOUNT'),
('ACCOUNT_DELETE', 'Xóa Khách hàng', 'ACCOUNT'),
('ACCOUNT_EXPORT', 'Xuất Excel Khách hàng', 'ACCOUNT'),
('DEAL_VIEW', 'Xem Cơ hội', 'DEAL'),
('DEAL_CREATE', 'Tạo mới Cơ hội', 'DEAL'),
('DEAL_EDIT', 'Chỉnh sửa Cơ hội', 'DEAL'),
('ACTIVITY_VIEW', 'Xem Hoạt động', 'ACTIVITY'),
('QUOTE_VIEW', 'Xem Báo giá', 'QUOTE'),
('USER_VIEW', 'Xem Tài khoản', 'USER'),
('USER_CREATE', 'Tạo mới Tài khoản', 'USER'),
('USER_EDIT', 'Chỉnh sửa/Gán quyền Tài khoản', 'USER'),
('USER_DELETE', 'Khóa/Bàn giao Tài khoản', 'USER'),
('PRODUCT_VIEW', 'Xem Sản phẩm/Dịch vụ', 'PRODUCT'),
('PRODUCT_EDIT', 'Khai báo/Chỉnh sửa Sản phẩm/Dịch vụ', 'PRODUCT')
ON DUPLICATE KEY UPDATE
permission_name = VALUES(permission_name), module = VALUES(module);

-- Chuẩn hóa lại các vai trò hệ thống nếu database từng chạy seed theo ID cũ.
DELETE rp FROM role_permissions rp
JOIN roles r ON r.role_id = rp.role_id
WHERE r.role_code IN ('ADMIN', 'SALES_REP', 'TEAM_LEAD', 'DIRECTOR');

-- Nhân viên kinh doanh: dữ liệu cá nhân.
INSERT INTO role_permissions (role_id, permission_id, data_scope)
SELECT r.role_id, p.permission_id, 'MY'
FROM roles r JOIN permissions p
  ON p.permission_code IN ('ACCOUNT_VIEW','ACCOUNT_CREATE','DEAL_VIEW','ACTIVITY_VIEW','QUOTE_VIEW')
WHERE r.role_code = 'SALES_REP'
ON DUPLICATE KEY UPDATE data_scope = VALUES(data_scope);

-- Trưởng nhóm: dữ liệu trong nhóm.
INSERT INTO role_permissions (role_id, permission_id, data_scope)
SELECT r.role_id, p.permission_id, 'TEAM'
FROM roles r JOIN permissions p
  ON p.permission_code IN ('ACCOUNT_VIEW','ACCOUNT_CREATE','ACCOUNT_EDIT','ACCOUNT_EXPORT','DEAL_VIEW','DEAL_CREATE','DEAL_EDIT','ACTIVITY_VIEW','QUOTE_VIEW')
WHERE r.role_code = 'TEAM_LEAD'
ON DUPLICATE KEY UPDATE data_scope = VALUES(data_scope);

-- Giám đốc và quản trị viên: toàn bộ dữ liệu và quản lý tài khoản.
INSERT INTO role_permissions (role_id, permission_id, data_scope)
SELECT r.role_id, p.permission_id, 'ALL'
FROM roles r CROSS JOIN permissions p
WHERE r.role_code IN ('DIRECTOR', 'ADMIN')
ON DUPLICATE KEY UPDATE data_scope = VALUES(data_scope);

DELETE newer
FROM menu_items AS newer
JOIN menu_items AS older
  ON newer.url = older.url
 AND newer.permission_code = older.permission_code
 AND newer.id > older.id;

INSERT INTO menu_items (id, title, url, icon, permission_code, display_order, parent_id) VALUES
(1, 'Khách hàng', '/customers', 'fa-users', 'ACCOUNT_VIEW', 1, 0),
(2, 'Cơ hội kinh doanh', '/deals', 'fa-chart-line', 'DEAL_VIEW', 2, 0),
(3, 'Hoạt động & Lịch hẹn', '/activities', 'fa-calendar-alt', 'ACTIVITY_VIEW', 3, 0),
(4, 'Báo giá', '/quotes', 'fa-file-invoice-dollar', 'QUOTE_VIEW', 4, 0),
(5, 'Quản lý tài khoản', '/accounts/list', 'fa-user-cog', 'USER_VIEW', 5, 0),
(6, 'Nhật ký hệ thống', '/audit/list', 'fa-history', 'USER_VIEW', 6, 0)
ON DUPLICATE KEY UPDATE
title = VALUES(title), url = VALUES(url), icon = VALUES(icon),
permission_code = VALUES(permission_code), display_order = VALUES(display_order);

-- Tài khoản khởi tạo cho môi trường phát triển: Admin12345.
-- Phải đổi mật khẩu ngay sau lần đăng nhập đầu tiên.
INSERT INTO users (email, password_hash, full_name, is_active) VALUES
('admin@company.com', '$2a$12$dUD9NdjA/XqMNErHhR3WJuTzoyo4mT2oXuPBDb6QPaPGPKiBzkrBe', 'Quản Trị Viên', 1)
ON DUPLICATE KEY UPDATE full_name = VALUES(full_name), is_active = 1;

INSERT IGNORE INTO user_roles (user_id, role_id)
SELECT u.user_id, r.role_id
FROM users u JOIN roles r ON r.role_code = 'ADMIN'
WHERE u.email = 'admin@company.com';

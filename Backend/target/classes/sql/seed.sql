-- Dữ liệu mẫu ban đầu
INSERT INTO roles (role_code, role_name) VALUES
('ADMIN', 'Quản trị hệ thống'),
('SALES_REP', 'Nhân viên kinh doanh'),
('TEAM_LEAD', 'Trưởng nhóm kinh doanh'),
('DIRECTOR', 'Giám đốc kinh doanh'),
('MARKETING', 'Nhân viên Marketing'),
('CUST_SUCCESS', 'Chăm sóc khách hàng'),
('ACCOUNTANT', 'Kế toán');

INSERT INTO teams (team_name, description) VALUES
('Team Kinh Doanh 1', 'Phụ trách thị trường miền Bắc'),
('Team Kinh Doanh 2', 'Phụ trách thị trường miền Nam');

-- Mật khẩu mặc định: 123456
INSERT INTO users (email, password_hash, full_name, is_active) VALUES
('admin@company.com', '$2a$12$e80yVvUfG3GjE3x/dJ7V7u6lGzN9fQ4n0dZ9t/oM7nQ5n.Bq0S2aG', 'Quản Trị Viên', 1);

INSERT INTO user_roles (user_id, role_id) VALUES (1, 1);
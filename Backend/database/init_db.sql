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

-- 3. Bảng Người dùng
CREATE TABLE IF NOT EXISTS users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(150) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    phone VARCHAR(20),
    team_id INT NULL,
    is_active TINYINT(1) DEFAULT 1,
    failed_attempts INT DEFAULT 0,
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
CREATE DATABASE IF NOT EXISTS crm_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE crm_db;

-- 1. Bảng Nhóm kinh doanh (Cập nhật Sprint 02)
CREATE TABLE IF NOT EXISTS teams (
    team_id INT AUTO_INCREMENT PRIMARY KEY,
    team_name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    parent_team_id INT NULL,
    leader_id INT NULL,
    region VARCHAR(100) NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (parent_team_id) REFERENCES teams(team_id) ON DELETE SET NULL
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
    email_signature TEXT NULL,
    team_id INT NULL,
    is_active TINYINT(1) DEFAULT 1,
    failed_attempts INT DEFAULT 0,
    lockout_until TIMESTAMP NULL DEFAULT NULL,
    reset_token VARCHAR(255) NULL,
    reset_token_expiry TIMESTAMP NULL,
    activation_token VARCHAR(255) NULL,
    activation_token_expiry TIMESTAMP NULL,
    avatar_url VARCHAR(255) NULL,
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

-- 6.1. Bảng Hoạt động (Activities)
CREATE TABLE IF NOT EXISTS activities (
    activity_id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    description TEXT,
    owner_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (owner_id) REFERENCES users(user_id)
);

-- 6.2. Bảng Báo giá (Quotes)
CREATE TABLE IF NOT EXISTS quotes (
    quote_id INT AUTO_INCREMENT PRIMARY KEY,
    quote_number VARCHAR(100) NOT NULL,
    owner_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (owner_id) REFERENCES users(user_id)
);

-- 7. Bảng Nhật ký thao tác (Audit log bàn giao S1-10)
CREATE TABLE IF NOT EXISTS audit_logs (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    action_type VARCHAR(50) NOT NULL,
    performed_by INT NOT NULL,
    target_user_id INT DEFAULT 0,
    description TEXT,
    old_value TEXT,
    new_value TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (performed_by) REFERENCES users(user_id)
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
    FOREIGN KEY (role_id) REFERENCES roles(role_id) ON DELETE CASCADE,
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
    parent_id INT DEFAULT 0,
    UNIQUE KEY uk_menu_url_permission (url, permission_code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
-- 6.3. Bảng cấu hình các giai đoạn Pipeline - S2-09
CREATE TABLE IF NOT EXISTS pipeline_stages (
    pipeline_stage_id INT AUTO_INCREMENT PRIMARY KEY,
    stage_name VARCHAR(100) NOT NULL,
    display_order INT NOT NULL DEFAULT 0,
    default_probability DECIMAL(5,2) NOT NULL DEFAULT 0,
    exit_condition TEXT,
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- 6.4. Bảng lý do thắng/thua - S2-10
CREATE TABLE IF NOT EXISTS win_loss_reasons (
    reason_id INT AUTO_INCREMENT PRIMARY KEY,
    reason_type ENUM('WIN', 'LOSS') NOT NULL,
    reason_name VARCHAR(200) NOT NULL,
    display_order INT NOT NULL DEFAULT 0,
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- 6.5. Bảng đối thủ cạnh tranh - S2-10
CREATE TABLE IF NOT EXISTS competitors (
    competitor_id INT AUTO_INCREMENT PRIMARY KEY,
    competitor_name VARCHAR(200) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- 11. Bảng Danh mục Sản phẩm / Dịch vụ (S2-05)
CREATE TABLE IF NOT EXISTS products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    product_code VARCHAR(50) NOT NULL UNIQUE,
    product_name VARCHAR(200) NOT NULL,
    product_type ENUM('ONE_TIME', 'SUBSCRIPTION') NOT NULL DEFAULT 'ONE_TIME',
    unit VARCHAR(50) NOT NULL,
    list_price DECIMAL(15, 2) NOT NULL DEFAULT 0.00,
    floor_price DECIMAL(15, 2) NOT NULL DEFAULT 0.00,
    cost_price DECIMAL(15, 2) DEFAULT NULL,
    status ENUM('ACTIVE', 'INACTIVE') NOT NULL DEFAULT 'ACTIVE',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 12. Bảng Danh mục dùng chung (S2-07)
CREATE TABLE IF NOT EXISTS categories (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    category_type VARCHAR(50) NOT NULL,
    category_name VARCHAR(100) NOT NULL,
    display_order INT DEFAULT 0,
    status ENUM('ACTIVE', 'INACTIVE') NOT NULL DEFAULT 'ACTIVE',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uk_type_name (category_type, category_name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 13. Bảng Định nghĩa Trường tùy chỉnh (Custom Field Definitions)
CREATE TABLE IF NOT EXISTS custom_field_definitions (
    field_id INT AUTO_INCREMENT PRIMARY KEY,
    entity_type VARCHAR(50) NOT NULL,
    field_key VARCHAR(50) NOT NULL,
    field_label VARCHAR(100) NOT NULL,
    field_type VARCHAR(30) NOT NULL DEFAULT 'TEXT',
    options TEXT,
    is_required TINYINT(1) DEFAULT 0,
    default_value VARCHAR(255),
    display_order INT DEFAULT 0,
    status VARCHAR(20) DEFAULT 'ACTIVE',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uk_entity_field (entity_type, field_key)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 14. Bảng Giá trị Trường tùy chỉnh (Custom Field Values)
CREATE TABLE IF NOT EXISTS custom_field_values (
    value_id INT AUTO_INCREMENT PRIMARY KEY,
    field_id INT NOT NULL,
    entity_type VARCHAR(50) NOT NULL,
    entity_id INT NOT NULL,
    field_value TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (field_id) REFERENCES custom_field_definitions(field_id) ON DELETE CASCADE,
    UNIQUE KEY uk_field_entity (field_id, entity_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 15. Bảng Quan hệ Khách hàng (S3-05)
CREATE TABLE IF NOT EXISTS customer_relationships (
    relationship_id INT AUTO_INCREMENT PRIMARY KEY,
    parent_customer_id INT NOT NULL,
    child_customer_id INT NOT NULL,
    relationship_type VARCHAR(50) DEFAULT 'SUBSIDIARY', -- SUBSIDIARY, BRANCH, AFFILIATE
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (parent_customer_id) REFERENCES customers(customer_id) ON DELETE CASCADE,
    FOREIGN KEY (child_customer_id) REFERENCES customers(customer_id) ON DELETE CASCADE,
    UNIQUE KEY uk_parent_child (parent_customer_id, child_customer_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 16. Bảng Lịch sử gộp Khách hàng (S3-04)
CREATE TABLE IF NOT EXISTS customer_merges (
    merge_id INT AUTO_INCREMENT PRIMARY KEY,
    primary_customer_id INT NOT NULL,
    secondary_customer_id INT NOT NULL,
    merged_data TEXT, -- JSON containing old data
    merged_by INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (primary_customer_id) REFERENCES customers(customer_id) ON DELETE CASCADE,
    FOREIGN KEY (merged_by) REFERENCES users(user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =============================================================================
-- CSDL HỆ THỐNG QUẢN LÝ KHÁCH HÀNG (CRM SYSTEM) - SCHEMA CHUẨN HÓA
-- File: schema.sql
-- Thư mục: Backend/src/main/resources/sql/
-- Bộ ký tự: UTF-8 / utf8mb4
-- Mô tả: File cấu trúc dữ liệu duy nhất chứa toàn bộ các bảng, chỉ mục,
--       ràng buộc toàn vẹn và khóa ngoại của toàn bộ hệ thống CRM.
-- =============================================================================

CREATE DATABASE IF NOT EXISTS crm_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE crm_db;
SET NAMES utf8mb4;
SET CHARACTER SET utf8mb4;

-- -----------------------------------------------------------------------------
-- 1. BẢNG PHÒNG BAN / NHÓM KINH DOANH (teams)
-- -----------------------------------------------------------------------------
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- 2. BẢNG VAI TRÒ HỆ THỐNG (roles)
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS roles (
    role_id INT AUTO_INCREMENT PRIMARY KEY,
    role_code VARCHAR(50) NOT NULL UNIQUE,
    role_name VARCHAR(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- 3. BẢNG NGƯỜI DÙNG / TÀI KHOẢN (users)
-- -----------------------------------------------------------------------------
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- 4. BẢNG LIÊN KẾT NGƯỜI DÙNG - VAI TRÒ (user_roles)
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS user_roles (
    user_id INT NOT NULL,
    role_id INT NOT NULL,
    PRIMARY KEY (user_id, role_id),
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (role_id) REFERENCES roles(role_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- 5. BẢNG QUYỀN HẠN HỆ THỐNG (permissions)
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS permissions (
    permission_id INT AUTO_INCREMENT PRIMARY KEY,
    permission_code VARCHAR(50) NOT NULL UNIQUE,
    permission_name VARCHAR(100) NOT NULL,
    module VARCHAR(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- 6. BẢNG GÁN QUYỀN CHO VAI TRÒ VÀ DATA SCOPE (role_permissions)
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS role_permissions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    role_id INT NOT NULL,
    permission_id INT NOT NULL,
    data_scope ENUM('MY', 'TEAM', 'ALL') NOT NULL DEFAULT 'MY',
    FOREIGN KEY (role_id) REFERENCES roles(role_id) ON DELETE CASCADE,
    FOREIGN KEY (permission_id) REFERENCES permissions(permission_id) ON DELETE CASCADE,
    UNIQUE KEY uk_role_permission (role_id, permission_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- 7. BẢNG MENU ĐIỀU HƯỚNG (menu_items)
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS menu_items (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(100) NOT NULL,
    url VARCHAR(255) NOT NULL,
    icon VARCHAR(50) DEFAULT 'fa-folder',
    permission_code VARCHAR(50) NOT NULL,
    display_order INT DEFAULT 0,
    parent_id INT DEFAULT 0,
    UNIQUE KEY uk_menu_url_permission (url, permission_code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- 8. BẢNG KHÁCH HÀNG / DOANH NGHIỆP (customers)
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_name VARCHAR(200) NOT NULL,
    phone VARCHAR(20),
    tax_code VARCHAR(50) UNIQUE,
    email VARCHAR(150),
    status VARCHAR(50) DEFAULT 'Tiềm năng',
    industry VARCHAR(100),
    company_size VARCHAR(50),
    size VARCHAR(50),
    website VARCHAR(255),
    address TEXT,
    region VARCHAR(100),
    owner_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (owner_id) REFERENCES users(user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- 9. BẢNG GIAI ĐOẠN BÁN HÀNG PIPELINE (pipeline_stages)
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS pipeline_stages (
    pipeline_stage_id INT AUTO_INCREMENT PRIMARY KEY,
    stage_name VARCHAR(100) NOT NULL,
    display_order INT NOT NULL DEFAULT 0,
    default_probability DECIMAL(5,2) NOT NULL DEFAULT 0,
    exit_condition TEXT,
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- 10. BẢNG LÝ DO THẮNG / THUA THƯƠNG VỤ (win_loss_reasons)
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS win_loss_reasons (
    reason_id INT AUTO_INCREMENT PRIMARY KEY,
    reason_type ENUM('WIN', 'LOSS') NOT NULL,
    reason_name VARCHAR(200) NOT NULL,
    display_order INT NOT NULL DEFAULT 0,
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- 11. BẢNG ĐỐI THỦ CẠNH TRANH (competitors)
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS competitors (
    competitor_id INT AUTO_INCREMENT PRIMARY KEY,
    competitor_name VARCHAR(200) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- 12. BẢNG CHIẾN DỊCH TIẾP THỊ (campaigns) - S4-03
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS campaigns (
    campaign_id INT AUTO_INCREMENT PRIMARY KEY,
    campaign_name VARCHAR(200) NOT NULL,
    budget DECIMAL(15, 2) DEFAULT 0.00,
    start_date DATE NULL,
    end_date DATE NULL,
    channel VARCHAR(100) NULL,
    description TEXT NULL,
    status VARCHAR(50) DEFAULT 'PLANNING',
    created_by INT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_campaigns_status (status),
    INDEX idx_campaigns_created_by (created_by),
    FOREIGN KEY (created_by) REFERENCES users(user_id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- 13. BẢNG CƠ HỘI BÁN HÀNG (opportunities)
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS opportunities (
    opportunity_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NULL,
    campaign_id INT NULL,
    title VARCHAR(200) NOT NULL,
    amount DECIMAL(15, 2) DEFAULT 0.00,
    owner_id INT NOT NULL,
    pipeline_stage_id INT NULL,
    probability DECIMAL(5, 2) DEFAULT 0.00,
    stage VARCHAR(50) NULL,
    win_loss_reason_id INT NULL,
    competitor_id INT NULL,
    close_date TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_opportunities_campaign (campaign_id),
    FOREIGN KEY (owner_id) REFERENCES users(user_id),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id) ON DELETE CASCADE,
    FOREIGN KEY (campaign_id) REFERENCES campaigns(campaign_id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- 13. BẢNG HOẠT ĐỘNG & TƯƠNG TÁC (activities)
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS activities (
    activity_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NULL,
    title VARCHAR(200) NOT NULL,
    description TEXT,
    activity_type VARCHAR(50) DEFAULT 'NOTE',
    owner_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    KEY idx_activities_customer_created (customer_id, created_at DESC),
    FOREIGN KEY (owner_id) REFERENCES users(user_id),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- 14. BẢNG BÁO GIÁ (quotes)
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS quotes (
    quote_id INT AUTO_INCREMENT PRIMARY KEY,
    quote_number VARCHAR(100) NOT NULL,
    owner_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (owner_id) REFERENCES users(user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- 15. BẢNG NHẬT KÝ THAO TÁC / AUDIT TRAIL (audit_logs)
-- -----------------------------------------------------------------------------
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- 16. BẢNG SẢN PHẨM & DỊCH VỤ (products)
-- -----------------------------------------------------------------------------
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- 17. BẢNG DANH MỤC DÙNG CHUNG (categories)
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS categories (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    category_type VARCHAR(50) NOT NULL,
    category_name VARCHAR(100) NOT NULL,
    display_order INT DEFAULT 0,
    status ENUM('ACTIVE', 'INACTIVE') NOT NULL DEFAULT 'ACTIVE',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uk_type_name (category_type, category_name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- 18. BẢNG ĐỊNH NGHĨA TRƯỜNG TÙY CHỈNH (custom_field_definitions)
-- -----------------------------------------------------------------------------
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- 19. BẢNG GIÁ TRỊ TRƯỜNG TÙY CHỈNH (custom_field_values)
-- -----------------------------------------------------------------------------
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- 20. BẢNG QUAN HỆ CÔNG TY MẸ - CON / TẬP ĐOÀN (customer_relationships)
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS customer_relationships (
    relationship_id INT AUTO_INCREMENT PRIMARY KEY,
    parent_customer_id INT NOT NULL,
    child_customer_id INT NOT NULL,
    relationship_type VARCHAR(50) DEFAULT 'SUBSIDIARY', -- SUBSIDIARY, BRANCH, MEMBER
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (parent_customer_id) REFERENCES customers(customer_id) ON DELETE CASCADE,
    FOREIGN KEY (child_customer_id) REFERENCES customers(customer_id) ON DELETE CASCADE,
    UNIQUE KEY uk_parent_child (parent_customer_id, child_customer_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- 21. BẢNG LỊCH SỬ GỘP KHÁCH HÀNG TRÙNG LẶP (customer_merges)
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS customer_merges (
    merge_id INT AUTO_INCREMENT PRIMARY KEY,
    primary_customer_id INT NOT NULL,
    secondary_customer_id INT NOT NULL,
    merged_data TEXT,
    merged_by INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (primary_customer_id) REFERENCES customers(customer_id) ON DELETE CASCADE,
    FOREIGN KEY (merged_by) REFERENCES users(user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- 22. BẢNG NGƯỜI LIÊN HỆ & VAI TRÒ QUYẾT ĐỊNH MUA (contacts)
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS contacts (
    contact_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    full_name VARCHAR(150) NOT NULL,
    position VARCHAR(100) NULL,
    title VARCHAR(100) NULL,
    email VARCHAR(150) NULL,
    phone VARCHAR(20) NULL,
    buying_role ENUM('DECIDER', 'INFLUENCER', 'END_USER', 'BLOCKER') NOT NULL DEFAULT 'END_USER',
    is_primary TINYINT(1) NOT NULL DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- 23. BẢNG LỊCH SỬ CHUYỂN CÔNG TY CỦA NGƯỜI LIÊN HỆ (contact_company_history)
-- Ràng buộc: ON DELETE RESTRICT để bảo vệ dữ liệu audit trail không bị mất
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS contact_company_history (
    history_id INT AUTO_INCREMENT PRIMARY KEY,
    contact_id INT NOT NULL,
    from_customer_id INT NOT NULL,
    to_customer_id INT NOT NULL,
    transferred_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    reason TEXT NULL,
    transferred_by INT NULL,
    FOREIGN KEY (contact_id) REFERENCES contacts(contact_id) ON DELETE CASCADE,
    FOREIGN KEY (from_customer_id) REFERENCES customers(customer_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (to_customer_id) REFERENCES customers(customer_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (transferred_by) REFERENCES users(user_id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- 24. BẢNG YÊU CẦU HỖ TRỢ SAU BÁN (support_requests)
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS support_requests (
    request_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    title VARCHAR(255) NOT NULL,
    description TEXT NULL,
    priority ENUM('LOW', 'MEDIUM', 'HIGH', 'URGENT') NOT NULL DEFAULT 'MEDIUM',
    status ENUM('OPEN', 'IN_PROGRESS', 'RESOLVED', 'CLOSED') NOT NULL DEFAULT 'OPEN',
    assignee_id INT NULL,
    created_by INT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id) ON DELETE CASCADE,
    FOREIGN KEY (assignee_id) REFERENCES users(user_id) ON DELETE SET NULL,
    FOREIGN KEY (created_by) REFERENCES users(user_id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- 25. BẢNG CHĂM SÓC KHÁCH HÀNG ĐỊNH KỲ (customer_care)
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS customer_care (
    care_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NULL UNIQUE,
    last_contacted_at TIMESTAMP NULL,
    last_contacted_by INT NULL,
    inactive_threshold_days INT DEFAULT 30,
    note TEXT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id) ON DELETE CASCADE,
    FOREIGN KEY (last_contacted_by) REFERENCES users(user_id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- 26. BẢNG BỘ LỌC ĐÃ LƯU (saved_filters)
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS saved_filters (
    filter_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    filter_name VARCHAR(100) NOT NULL,
    module VARCHAR(50) DEFAULT 'CUSTOMER',
    keyword VARCHAR(200) DEFAULT NULL,
    status VARCHAR(50) DEFAULT NULL,
    industry VARCHAR(100) DEFAULT NULL,
    company_size VARCHAR(50) DEFAULT NULL,
    region VARCHAR(100) DEFAULT NULL,
    owner_id INT DEFAULT NULL,
    filter_query TEXT,
    is_default TINYINT(1) DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- 27. BẢNG TỆP ĐÍNH KÈM HỒ SƠ KHÁCH HÀNG (attachments)
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attachments (
    attachment_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    file_name VARCHAR(255) NOT NULL,
    file_path VARCHAR(500) NOT NULL,
    file_size BIGINT DEFAULT 0,
    uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    KEY idx_attachment_customer (customer_id),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- 28. BẢNG NGUỒN LEAD (lead_sources) - S401 / S402
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS lead_sources (
    source_id INT AUTO_INCREMENT PRIMARY KEY,
    source_code VARCHAR(50) NOT NULL UNIQUE,
    source_name VARCHAR(100) NOT NULL,
    description TEXT,
    is_active TINYINT(1) DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- 29. BẢNG BIỂU MẪU THU THẬP LEAD TRÊN WEB (lead_web_forms) - S401
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS lead_web_forms (
    form_id INT AUTO_INCREMENT PRIMARY KEY,
    form_name VARCHAR(150) NOT NULL,
    description TEXT,
    embed_code TEXT,
    allowed_domains VARCHAR(255),
    success_redirect_url VARCHAR(255),
    is_active TINYINT(1) DEFAULT 1,
    spam_protection_enabled TINYINT(1) DEFAULT 1,
    fields_json TEXT,
    lead_source_id INT NULL,
    created_by INT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_lead_web_forms_source (lead_source_id),
    CONSTRAINT fk_lead_web_forms_source FOREIGN KEY (lead_source_id) REFERENCES lead_sources(source_id) ON DELETE SET NULL,
    CONSTRAINT fk_lead_web_forms_creator FOREIGN KEY (created_by) REFERENCES users(user_id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- 30. BẢNG ĐẦU MỐI KINH DOANH / TIỀM NĂNG (leads) - S401 / S402
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS leads (
    lead_id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(150) NOT NULL,
    first_name VARCHAR(100) NULL,
    last_name VARCHAR(100) NULL,
    title VARCHAR(100) NULL,
    company VARCHAR(200) NULL,
    email VARCHAR(150) NULL,
    phone VARCHAR(20) NULL,
    lead_source_id INT NULL,
    web_form_id INT NULL,
    status VARCHAR(30) NOT NULL DEFAULT 'NEW',
    rating VARCHAR(30) DEFAULT 'WARM',
    score INT DEFAULT 0,
    industry VARCHAR(100) NULL,
    address TEXT NULL,
    city VARCHAR(100) NULL,
    state VARCHAR(100) NULL,
    country VARCHAR(100) NULL,
    zip_code VARCHAR(20) NULL,
    owner_id INT NULL,
    notes TEXT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_leads_status (status),
    INDEX idx_leads_owner (owner_id),
    INDEX idx_leads_email (email),
    INDEX idx_leads_phone (phone),
    CONSTRAINT fk_leads_source FOREIGN KEY (lead_source_id) REFERENCES lead_sources(source_id) ON DELETE SET NULL,
    CONSTRAINT fk_leads_web_form FOREIGN KEY (web_form_id) REFERENCES lead_web_forms(form_id) ON DELETE SET NULL,
    CONSTRAINT fk_leads_owner FOREIGN KEY (owner_id) REFERENCES users(user_id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- 31. BẢNG LỊCH SỬ GỘP LEAD (lead_merge_history)
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS lead_merge_history (
    merge_id INT AUTO_INCREMENT PRIMARY KEY,
    primary_lead_id INT NOT NULL,
    duplicate_lead_id INT NOT NULL,
    merged_by INT NULL,
    merged_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    retained_fields TEXT NULL,
    note TEXT NULL,
    CONSTRAINT fk_lead_merge_primary FOREIGN KEY (primary_lead_id) REFERENCES leads(lead_id) ON DELETE CASCADE,
    CONSTRAINT fk_lead_merge_user FOREIGN KEY (merged_by) REFERENCES users(user_id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- 32. BẢNG QUY TẮC PHÂN BỔ LEAD (lead_assignment_rules)
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS lead_assignment_rules (
    rule_id INT AUTO_INCREMENT PRIMARY KEY,
    rule_name VARCHAR(100) NOT NULL,
    priority INT NOT NULL DEFAULT 1,
    criterion VARCHAR(50) NOT NULL,
    criterion_value VARCHAR(100) NULL,
    assignee_id INT NULL,
    team_id INT NULL,
    is_active TINYINT(1) DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_lead_rule_user FOREIGN KEY (assignee_id) REFERENCES users(user_id) ON DELETE SET NULL,
    CONSTRAINT fk_lead_rule_team FOREIGN KEY (team_id) REFERENCES teams(team_id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- 33. BẢNG LỊCH SỬ PHÂN BỔ LEAD (lead_assignment_history)
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS lead_assignment_history (
    history_id INT AUTO_INCREMENT PRIMARY KEY,
    lead_id INT NOT NULL,
    rule_id INT NULL,
    assigned_to INT NULL,
    status VARCHAR(50) DEFAULT 'ASSIGNED',
    assigned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_lead_assign_lead FOREIGN KEY (lead_id) REFERENCES leads(lead_id) ON DELETE CASCADE,
    CONSTRAINT fk_lead_assign_rule FOREIGN KEY (rule_id) REFERENCES lead_assignment_rules(rule_id) ON DELETE SET NULL,
    CONSTRAINT fk_lead_assign_user FOREIGN KEY (assigned_to) REFERENCES users(user_id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


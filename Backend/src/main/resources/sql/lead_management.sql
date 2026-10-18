-- =============================================================================
-- CSDL HỆ THỐNG QUẢN LÝ KHÁCH HÀNG (CRM SYSTEM) - PHÂN HỆ QUẢN LÝ LEAD (S4-01..S4-09)
-- File: lead_management.sql
-- Thư mục: Backend/src/main/resources/sql/
-- Bộ ký tự: UTF-8 / utf8mb4
-- Mô tả: File cấu trúc dữ liệu chuẩn cho phân hệ Khách hàng tiềm năng (Lead Management).
--       Bao gồm đầy đủ các bảng, chỉ mục, khóa ngoại phục vụ trọn vẹn backlog US1 -> US9.
-- =============================================================================

USE crm_db;
SET NAMES utf8mb4;
SET CHARACTER SET utf8mb4;

-- -----------------------------------------------------------------------------
-- 1. BẢNG CHIẾN DỊCH TIẾP THỊ / MARKETING (campaigns) - S4-03
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
    CONSTRAINT fk_campaigns_created_by FOREIGN KEY (created_by) REFERENCES users(user_id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- 2. BẢNG NGUỒN GỐC LEAD (lead_sources) - S4-01, S4-02
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS lead_sources (
    source_id INT AUTO_INCREMENT PRIMARY KEY,
    source_code VARCHAR(50) NOT NULL UNIQUE,
    source_name VARCHAR(100) NOT NULL,
    description VARCHAR(255) NULL,
    is_active TINYINT(1) DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_lead_sources_code (source_code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- 3. BẢNG BIỂU MẪU WEB FORM THU THẬP LEAD (lead_web_forms) - S4-01
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS lead_web_forms (
    form_id INT AUTO_INCREMENT PRIMARY KEY,
    form_name VARCHAR(150) NOT NULL,
    description TEXT NULL,
    embed_code TEXT NULL,
    allowed_domains VARCHAR(255) NULL,
    success_redirect_url VARCHAR(255) NULL,
    is_active TINYINT(1) DEFAULT 1,
    spam_protection_enabled TINYINT(1) DEFAULT 1,
    fields_json TEXT NULL,
    lead_source_id INT NULL,
    created_by INT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_lead_web_forms_active (is_active),
    INDEX idx_lead_web_forms_source (lead_source_id),
    INDEX idx_lead_web_forms_created_by (created_by),
    CONSTRAINT fk_lead_web_forms_source FOREIGN KEY (lead_source_id) REFERENCES lead_sources(source_id) ON DELETE SET NULL,
    CONSTRAINT fk_lead_web_forms_created_by FOREIGN KEY (created_by) REFERENCES users(user_id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- 4. BẢNG KHÁCH HÀNG TIỀM NĂNG (leads) - TRỌNG TÂM S4-01..S4-09
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS leads (
    lead_id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(150) NOT NULL,
    first_name VARCHAR(100) NULL,
    last_name VARCHAR(100) NULL,
    title VARCHAR(100) NULL,
    company VARCHAR(200) NULL,
    company_name VARCHAR(200) NULL,
    contact_name VARCHAR(150) NULL,
    email VARCHAR(150) NULL,
    phone VARCHAR(50) NULL,
    lead_source_id INT NULL,
    web_form_id INT NULL,
    campaign_id INT NULL,
    customer_id INT NULL,
    converted_customer_id INT NULL,
    converted_contact_id INT NULL,
    converted_opportunity_id INT NULL,
    source VARCHAR(100) NULL,
    status VARCHAR(50) NOT NULL DEFAULT 'NEW',
    rating VARCHAR(20) DEFAULT 'WARM',
    score INT DEFAULT 0,
    industry VARCHAR(100) NULL,
    address VARCHAR(255) NULL,
    city VARCHAR(100) NULL,
    state VARCHAR(100) NULL,
    country VARCHAR(100) NULL,
    zip_code VARCHAR(20) NULL,
    owner_id INT NULL,
    notes TEXT NULL,
    assigned_at TIMESTAMP NULL,
    rejection_reason VARCHAR(255) NULL,
    sla_due_at TIMESTAMP NULL,
    sla_due_date TIMESTAMP NULL,
    sla_status VARCHAR(50) NULL,
    is_overdue TINYINT(1) DEFAULT 0,
    sla_breached TINYINT(1) DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_leads_status (status),
    INDEX idx_leads_owner (owner_id),
    INDEX idx_leads_source_id (lead_source_id),
    INDEX idx_leads_web_form (web_form_id),
    INDEX idx_leads_campaign (campaign_id),
    INDEX idx_leads_customer (customer_id),
    INDEX idx_leads_conv_customer (converted_customer_id),
    INDEX idx_leads_email (email),
    INDEX idx_leads_phone (phone),
    CONSTRAINT fk_leads_source FOREIGN KEY (lead_source_id) REFERENCES lead_sources(source_id) ON DELETE SET NULL,
    CONSTRAINT fk_leads_web_form FOREIGN KEY (web_form_id) REFERENCES lead_web_forms(form_id) ON DELETE SET NULL,
    CONSTRAINT fk_leads_campaign FOREIGN KEY (campaign_id) REFERENCES campaigns(campaign_id) ON DELETE SET NULL,
    CONSTRAINT fk_leads_customer FOREIGN KEY (customer_id) REFERENCES customers(customer_id) ON DELETE SET NULL,
    CONSTRAINT fk_leads_conv_customer FOREIGN KEY (converted_customer_id) REFERENCES customers(customer_id) ON DELETE SET NULL,
    CONSTRAINT fk_leads_owner FOREIGN KEY (owner_id) REFERENCES users(user_id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- NÂNG CẤP BẢNG LEADS NẾU ĐÃ TỒN TẠI TỪ PHIÊN BẢN CŨ (TƯƠNG THÍCH MYSQL 8.0)
-- -----------------------------------------------------------------------------
DELIMITER //
DROP PROCEDURE IF EXISTS upgrade_leads_schema //
CREATE PROCEDURE upgrade_leads_schema()
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'leads' AND COLUMN_NAME = 'first_name') THEN
        ALTER TABLE leads ADD COLUMN first_name VARCHAR(100) NULL AFTER full_name;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'leads' AND COLUMN_NAME = 'last_name') THEN
        ALTER TABLE leads ADD COLUMN last_name VARCHAR(100) NULL AFTER first_name;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'leads' AND COLUMN_NAME = 'title') THEN
        ALTER TABLE leads ADD COLUMN title VARCHAR(100) NULL AFTER last_name;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'leads' AND COLUMN_NAME = 'company') THEN
        ALTER TABLE leads ADD COLUMN company VARCHAR(200) NULL AFTER title;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'leads' AND COLUMN_NAME = 'company_name') THEN
        ALTER TABLE leads ADD COLUMN company_name VARCHAR(200) NULL AFTER company;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'leads' AND COLUMN_NAME = 'contact_name') THEN
        ALTER TABLE leads ADD COLUMN contact_name VARCHAR(150) NULL AFTER company_name;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'leads' AND COLUMN_NAME = 'converted_customer_id') THEN
        ALTER TABLE leads ADD COLUMN converted_customer_id INT NULL AFTER customer_id;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'leads' AND COLUMN_NAME = 'converted_contact_id') THEN
        ALTER TABLE leads ADD COLUMN converted_contact_id INT NULL AFTER converted_customer_id;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'leads' AND COLUMN_NAME = 'converted_opportunity_id') THEN
        ALTER TABLE leads ADD COLUMN converted_opportunity_id INT NULL AFTER converted_contact_id;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'leads' AND COLUMN_NAME = 'lead_source_id') THEN
        ALTER TABLE leads ADD COLUMN lead_source_id INT NULL AFTER phone;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'leads' AND COLUMN_NAME = 'web_form_id') THEN
        ALTER TABLE leads ADD COLUMN web_form_id INT NULL AFTER lead_source_id;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'leads' AND COLUMN_NAME = 'rating') THEN
        ALTER TABLE leads ADD COLUMN rating VARCHAR(20) DEFAULT 'WARM' AFTER status;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'leads' AND COLUMN_NAME = 'score') THEN
        ALTER TABLE leads ADD COLUMN score INT DEFAULT 0 AFTER rating;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'leads' AND COLUMN_NAME = 'industry') THEN
        ALTER TABLE leads ADD COLUMN industry VARCHAR(100) NULL AFTER score;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'leads' AND COLUMN_NAME = 'address') THEN
        ALTER TABLE leads ADD COLUMN address VARCHAR(255) NULL AFTER industry;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'leads' AND COLUMN_NAME = 'city') THEN
        ALTER TABLE leads ADD COLUMN city VARCHAR(100) NULL AFTER address;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'leads' AND COLUMN_NAME = 'state') THEN
        ALTER TABLE leads ADD COLUMN state VARCHAR(100) NULL AFTER city;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'leads' AND COLUMN_NAME = 'country') THEN
        ALTER TABLE leads ADD COLUMN country VARCHAR(100) NULL AFTER state;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'leads' AND COLUMN_NAME = 'zip_code') THEN
        ALTER TABLE leads ADD COLUMN zip_code VARCHAR(20) NULL AFTER country;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'leads' AND COLUMN_NAME = 'notes') THEN
        ALTER TABLE leads ADD COLUMN notes TEXT NULL AFTER owner_id;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'leads' AND COLUMN_NAME = 'assigned_at') THEN
        ALTER TABLE leads ADD COLUMN assigned_at TIMESTAMP NULL AFTER notes;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'leads' AND COLUMN_NAME = 'rejection_reason') THEN
        ALTER TABLE leads ADD COLUMN rejection_reason VARCHAR(255) NULL AFTER assigned_at;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'leads' AND COLUMN_NAME = 'sla_due_at') THEN
        ALTER TABLE leads ADD COLUMN sla_due_at TIMESTAMP NULL AFTER rejection_reason;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'leads' AND COLUMN_NAME = 'is_overdue') THEN
        ALTER TABLE leads ADD COLUMN is_overdue TINYINT(1) DEFAULT 0 AFTER sla_due_at;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'leads' AND COLUMN_NAME = 'sla_breached') THEN
        ALTER TABLE leads ADD COLUMN sla_breached TINYINT(1) DEFAULT 0 AFTER is_overdue;
    END IF;
END //
DELIMITER ;
CALL upgrade_leads_schema();
DROP PROCEDURE IF EXISTS upgrade_leads_schema;

-- -----------------------------------------------------------------------------
-- 5. BẢNG QUY TẮC PHÂN BỔ LEAD (lead_assignment_rules) - S4-06
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS lead_assignment_rules (
    rule_id INT AUTO_INCREMENT PRIMARY KEY,
    rule_name VARCHAR(150) NULL,
    priority INT NOT NULL DEFAULT 1,
    criterion VARCHAR(50) NOT NULL,
    criterion_value VARCHAR(100) NULL,
    assignee_id INT NULL,
    team_id INT NULL,
    is_active TINYINT(1) DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_assign_rules_priority (priority),
    INDEX idx_assign_rules_active (is_active),
    CONSTRAINT fk_assign_rules_user FOREIGN KEY (assignee_id) REFERENCES users(user_id) ON DELETE SET NULL,
    CONSTRAINT fk_assign_rules_team FOREIGN KEY (team_id) REFERENCES teams(team_id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- 6. BẢNG LỊCH SỬ PHÂN BỔ LEAD (lead_assignment_history) - S4-06, S4-07
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS lead_assignment_history (
    history_id INT AUTO_INCREMENT PRIMARY KEY,
    lead_id INT NOT NULL,
    rule_id INT NULL,
    assigned_to INT NULL,
    performed_by INT NULL,
    status VARCHAR(50) NOT NULL DEFAULT 'ASSIGNED',
    reject_reason VARCHAR(255) NULL,
    assigned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_assign_hist_lead (lead_id),
    INDEX idx_assign_hist_user (assigned_to),
    INDEX idx_assign_hist_performer (performed_by),
    CONSTRAINT fk_assign_hist_lead FOREIGN KEY (lead_id) REFERENCES leads(lead_id) ON DELETE CASCADE,
    CONSTRAINT fk_assign_hist_rule FOREIGN KEY (rule_id) REFERENCES lead_assignment_rules(rule_id) ON DELETE SET NULL,
    CONSTRAINT fk_assign_hist_user FOREIGN KEY (assigned_to) REFERENCES users(user_id) ON DELETE SET NULL,
    CONSTRAINT fk_assign_hist_performer FOREIGN KEY (performed_by) REFERENCES users(user_id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- 7. BẢNG QUY TẮC CHẤM ĐIỂM LEAD (lead_scoring_rules) - S4-05
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS lead_scoring_rules (
    rule_id INT AUTO_INCREMENT PRIMARY KEY,
    criterion VARCHAR(50) NOT NULL,
    operator VARCHAR(20) NOT NULL DEFAULT 'EQUALS',
    condition_value VARCHAR(255) NOT NULL,
    score INT NOT NULL DEFAULT 0,
    is_active TINYINT(1) NOT NULL DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_scoring_rules_active (is_active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- 8. BẢNG CẤU HÌNH NGƯỠNG ĐIỂM LEAD (lead_scoring_config) - S4-05
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS lead_scoring_config (
    config_key VARCHAR(50) PRIMARY KEY,
    config_value VARCHAR(100) NOT NULL,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- 9. BẢNG LỊCH SỬ GỘP LEAD TRÙNG LẶP (lead_merge_history) - S4-04
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS lead_merge_history (
    merge_id INT AUTO_INCREMENT PRIMARY KEY,
    primary_lead_id INT NOT NULL,
    duplicate_lead_id INT NOT NULL,
    merged_by INT NULL,
    merged_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    retained_fields TEXT NULL,
    note TEXT NULL,
    INDEX idx_merge_primary (primary_lead_id),
    INDEX idx_merge_duplicate (duplicate_lead_id),
    CONSTRAINT fk_merge_user FOREIGN KEY (merged_by) REFERENCES users(user_id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- 10. BẢNG CẤU HÌNH THỜI HẠN PHẢN HỒI LEAD SLA (lead_sla_configs) - S4-07
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS lead_sla_configs (
    sla_id INT AUTO_INCREMENT PRIMARY KEY,
    priority_level VARCHAR(50) NOT NULL,
    response_time_minutes INT NOT NULL,
    is_active TINYINT(1) DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_sla_priority (priority_level),
    INDEX idx_sla_active (is_active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- 11. LIÊN KẾT LIÊN BẢNG BỔ SUNG (ACTIVITIES & OPPORTUNITIES) - S4-03, S4-08
-- -----------------------------------------------------------------------------
-- Bổ sung cột lead_id cho activities (nếu chưa có)
SET @exist_act_lead := (
    SELECT COUNT(*) FROM information_schema.COLUMNS 
    WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'activities' AND COLUMN_NAME = 'lead_id'
);
SET @sql_act_lead := IF(@exist_act_lead = 0, 'ALTER TABLE activities ADD COLUMN lead_id INT NULL AFTER customer_id, ADD CONSTRAINT fk_activities_lead FOREIGN KEY (lead_id) REFERENCES leads(lead_id) ON DELETE SET NULL;', 'SELECT \"activities.lead_id already exists\";');
PREPARE stmt_act_lead FROM @sql_act_lead;
EXECUTE stmt_act_lead;
DEALLOCATE PREPARE stmt_act_lead;

-- Bổ sung cột campaign_id cho opportunities (nếu chưa có)
SET @exist_opp_camp := (
    SELECT COUNT(*) FROM information_schema.COLUMNS 
    WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'opportunities' AND COLUMN_NAME = 'campaign_id'
);
SET @sql_opp_camp := IF(@exist_opp_camp = 0, 'ALTER TABLE opportunities ADD COLUMN campaign_id INT NULL AFTER customer_id, ADD CONSTRAINT fk_opportunities_campaign FOREIGN KEY (campaign_id) REFERENCES campaigns(campaign_id) ON DELETE SET NULL;', 'SELECT \"opportunities.campaign_id already exists\";');
PREPARE stmt_opp_camp FROM @sql_opp_camp;
EXECUTE stmt_opp_camp;
DEALLOCATE PREPARE stmt_opp_camp;

-- =============================================================================
-- Project CRM - Master Test Data & Seed Script (test_data.sql)
-- Character Set: UTF-8 / utf8mb4
-- Description: Consolidated master dataset containing:
--              1. Base RBAC, Roles, Teams, Permissions, Role Permissions, Menu Items
--              2. Seed Users (2-8 & Admin) & Global Test Users (801-804)
--              3. Seed Data (Categories, Products, Stages, Reasons, Competitors)
--              4. Seed & Test Customers (101-110 & 801-817)
--              5. Seed & Test Opportunities, Contacts, Care, Support, Activities,
--                 Attachments, Saved Filters, Quotes, Audit Logs.
-- =============================================================================

USE crm_db;

START TRANSACTION;

-- =============================================================================
-- PART 1: BASE SYSTEM ROLES, TEAMS, PERMISSIONS, ROLE PERMISSIONS & MENU ITEMS
-- =============================================================================

-- Roles setup
INSERT INTO roles (role_code, role_name) VALUES
('ADMIN', 'Quản trị hệ thống'),
('SALES_REP', 'Nhân viên kinh doanh'),
('TEAM_LEAD', 'Trưởng nhóm kinh doanh'),
('DIRECTOR', 'Giám đốc kinh doanh'),
('MARKETING', 'Nhân viên Marketing'),
('CUST_SUCCESS', 'Chăm sóc khách hàng'),
('ACCOUNTANT', 'Kế toán')
ON DUPLICATE KEY UPDATE role_name = VALUES(role_name);

-- Teams setup
INSERT INTO teams (team_name, description) VALUES
('Team Kinh Doanh 1', 'Phụ trách thị trường miền Bắc'),
('Team Kinh Doanh 2', 'Phụ trách thị trường miền Nam')
ON DUPLICATE KEY UPDATE description = VALUES(description);

-- Permissions setup
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
('PRODUCT_VIEW', 'Xem Sản phẩm', 'PRODUCT'),
('PRODUCT_MANAGE', 'Quản lý Sản phẩm', 'PRODUCT'),
('PRODUCT_COST_VIEW', 'Xem Giá vốn Sản phẩm', 'PRODUCT'),
('CATEGORY_VIEW', 'Xem Danh mục dùng chung', 'CATEGORY'),
('CATEGORY_MANAGE', 'Quản lý Danh mục dùng chung', 'CATEGORY'),
('ORG_VIEW', 'Xem Cấu trúc Tổ chức', 'ORGANIZATION'),
('ORG_MANAGE', 'Quản lý Cấu trúc Tổ chức', 'ORGANIZATION'),
('AUDIT_VIEW', 'Xem Nhật ký Hệ thống', 'AUDIT'),
('IMPORT_DATA', 'Import Dữ liệu Excel', 'IMPORT')
ON DUPLICATE KEY UPDATE
permission_name = VALUES(permission_name), module = VALUES(module);

-- Role Permissions setup
-- 1. ADMIN: ALL
INSERT INTO role_permissions (role_id, permission_id, data_scope)
SELECT r.role_id, p.permission_id, 'ALL'
FROM roles r CROSS JOIN permissions p
WHERE r.role_code = 'ADMIN'
ON DUPLICATE KEY UPDATE data_scope = VALUES(data_scope);

-- 2. DIRECTOR
INSERT INTO role_permissions (role_id, permission_id, data_scope)
SELECT r.role_id, p.permission_id, 'ALL'
FROM roles r JOIN permissions p
  ON p.permission_code NOT IN ('USER_CREATE', 'USER_EDIT', 'USER_DELETE')
WHERE r.role_code = 'DIRECTOR'
ON DUPLICATE KEY UPDATE data_scope = VALUES(data_scope);

-- 3. TEAM_LEAD
INSERT INTO role_permissions (role_id, permission_id, data_scope)
SELECT r.role_id, p.permission_id, 'TEAM'
FROM roles r JOIN permissions p
  ON p.permission_code IN ('ACCOUNT_VIEW','ACCOUNT_CREATE','ACCOUNT_EDIT','ACCOUNT_DELETE','ACCOUNT_EXPORT','DEAL_VIEW','DEAL_CREATE','DEAL_EDIT','ACTIVITY_VIEW','QUOTE_VIEW','IMPORT_DATA')
WHERE r.role_code = 'TEAM_LEAD'
ON DUPLICATE KEY UPDATE data_scope = VALUES(data_scope);

INSERT INTO role_permissions (role_id, permission_id, data_scope)
SELECT r.role_id, p.permission_id, 'ALL'
FROM roles r JOIN permissions p
  ON p.permission_code IN ('CATEGORY_VIEW','PRODUCT_VIEW','ORG_VIEW')
WHERE r.role_code = 'TEAM_LEAD'
ON DUPLICATE KEY UPDATE data_scope = VALUES(data_scope);

-- 4. SALES_REP
INSERT INTO role_permissions (role_id, permission_id, data_scope)
SELECT r.role_id, p.permission_id, 'MY'
FROM roles r JOIN permissions p
  ON p.permission_code IN ('ACCOUNT_VIEW','ACCOUNT_CREATE','ACCOUNT_EDIT','DEAL_VIEW','DEAL_CREATE','DEAL_EDIT','ACTIVITY_VIEW','QUOTE_VIEW')
WHERE r.role_code = 'SALES_REP'
ON DUPLICATE KEY UPDATE data_scope = VALUES(data_scope);

INSERT INTO role_permissions (role_id, permission_id, data_scope)
SELECT r.role_id, p.permission_id, 'ALL'
FROM roles r JOIN permissions p
  ON p.permission_code IN ('CATEGORY_VIEW','PRODUCT_VIEW')
WHERE r.role_code = 'SALES_REP'
ON DUPLICATE KEY UPDATE data_scope = VALUES(data_scope);

-- 5. MARKETING
INSERT INTO role_permissions (role_id, permission_id, data_scope)
SELECT r.role_id, p.permission_id, 'ALL'
FROM roles r JOIN permissions p
  ON p.permission_code IN ('ACCOUNT_VIEW','ACCOUNT_CREATE','ACCOUNT_EDIT','DEAL_VIEW','ACTIVITY_VIEW','CATEGORY_VIEW','PRODUCT_VIEW')
WHERE r.role_code = 'MARKETING'
ON DUPLICATE KEY UPDATE data_scope = VALUES(data_scope);

-- 6. CUSTOMER SUCCESS
INSERT INTO role_permissions (role_id, permission_id, data_scope)
SELECT r.role_id, p.permission_id, 'MY'
FROM roles r JOIN permissions p
  ON p.permission_code IN ('ACCOUNT_VIEW','ACCOUNT_CREATE','ACCOUNT_EDIT','DEAL_VIEW','ACTIVITY_VIEW','QUOTE_VIEW')
WHERE r.role_code = 'CUST_SUCCESS'
ON DUPLICATE KEY UPDATE data_scope = VALUES(data_scope);

INSERT INTO role_permissions (role_id, permission_id, data_scope)
SELECT r.role_id, p.permission_id, 'ALL'
FROM roles r JOIN permissions p
  ON p.permission_code IN ('CATEGORY_VIEW','PRODUCT_VIEW')
WHERE r.role_code = 'CUST_SUCCESS'
ON DUPLICATE KEY UPDATE data_scope = VALUES(data_scope);

-- 7. ACCOUNTANT
INSERT INTO role_permissions (role_id, permission_id, data_scope)
SELECT r.role_id, p.permission_id, 'ALL'
FROM roles r JOIN permissions p
  ON p.permission_code IN ('ACCOUNT_VIEW','DEAL_VIEW','QUOTE_VIEW','CATEGORY_VIEW','PRODUCT_VIEW')
WHERE r.role_code = 'ACCOUNTANT'
ON DUPLICATE KEY UPDATE data_scope = VALUES(data_scope);

-- Clean up duplicate menu items
DELETE newer
FROM menu_items AS newer
JOIN menu_items AS older
  ON newer.url = older.url
 AND newer.permission_code = older.permission_code
 AND newer.id > older.id;

DELETE FROM menu_items WHERE url = '/audit/list' AND permission_code = 'USER_VIEW';

-- Menu Items setup
INSERT INTO menu_items (title, url, icon, permission_code, display_order, parent_id) VALUES
('Khách hàng', '/customers', 'fa-users', 'ACCOUNT_VIEW', 1, 0),
('Cơ hội kinh doanh', '/deals', 'fa-chart-line', 'DEAL_VIEW', 2, 0),
('Hoạt động & Lịch hẹn', '/activities', 'fa-calendar-alt', 'ACTIVITY_VIEW', 3, 0),
('Báo giá', '/quotes', 'fa-file-invoice-dollar', 'QUOTE_VIEW', 4, 0),
('Sản phẩm & Dịch vụ', '/products', 'fa-box-open', 'PRODUCT_VIEW', 5, 0),
('Danh mục dùng chung', '/categories', 'fa-tags', 'CATEGORY_VIEW', 6, 0),
('Cấu trúc tổ chức', '/organization/teams', 'fa-sitemap', 'ORG_VIEW', 7, 0),
('Quản lý tài khoản', '/accounts/list', 'fa-user-cog', 'USER_VIEW', 8, 0),
('Nhật ký hệ thống', '/audit/list', 'fa-history', 'AUDIT_VIEW', 9, 0)
ON DUPLICATE KEY UPDATE
title = VALUES(title), url = VALUES(url), icon = VALUES(icon),
permission_code = VALUES(permission_code), display_order = VALUES(display_order);

-- =============================================================================
-- PART 2: USERS & USER ROLES
-- =============================================================================

-- Default Admin User
INSERT INTO users (email, password_hash, full_name, is_active) VALUES
('admin@company.com', '$2a$12$dUD9NdjA/XqMNErHhR3WJuTzoyo4mT2oXuPBDb6QPaPGPKiBzkrBe', 'Quản Trị Viên', 1)
ON DUPLICATE KEY UPDATE full_name = VALUES(full_name), is_active = 1;

INSERT IGNORE INTO user_roles (user_id, role_id)
SELECT u.user_id, r.role_id
FROM users u JOIN roles r ON r.role_code = 'ADMIN'
WHERE u.email = 'admin@company.com';

-- Seed Test Users (IDs 2 - 8)
INSERT INTO users (user_id, email, password_hash, full_name, phone, team_id, is_active) VALUES
(2, 'director.test@example.com', '$2a$12$mr0RRBInQq8M8FKJSKQxcObtfir/V6QiaCjdP1uQUdmjhKyYWJy3i', 'Vũ Văn Giám Đốc', '0906789012', NULL, 1),
(3, 'teamlead.test@example.com', '$2a$12$mr0RRBInQq8M8FKJSKQxcObtfir/V6QiaCjdP1uQUdmjhKyYWJy3i', 'Hoàng Văn Trưởng Nhóm', '0905678901', 1, 1),
(4, 'salesrep.test@example.com', '$2a$12$mr0RRBInQq8M8FKJSKQxcObtfir/V6QiaCjdP1uQUdmjhKyYWJy3i', 'Nguyễn Văn Kinh Doanh', '0901234567', 1, 1),
(5, 'salesrep2.test@example.com', '$2a$12$mr0RRBInQq8M8FKJSKQxcObtfir/V6QiaCjdP1uQUdmjhKyYWJy3i', 'Lê Văn Kinh Doanh Nam', '0901234568', 2, 1),
(6, 'marketing.test@example.com', '$2a$12$mr0RRBInQq8M8FKJSKQxcObtfir/V6QiaCjdP1uQUdmjhKyYWJy3i', 'Trần Thị Marketing', '0902345678', NULL, 1),
(7, 'customersuccess.test@example.com', '$2a$12$mr0RRBInQq8M8FKJSKQxcObtfir/V6QiaCjdP1uQUdmjhKyYWJy3i', 'Lê Văn Chăm Sóc Khách Hàng', '0903456789', NULL, 1),
(8, 'accountant.test@example.com', '$2a$12$mr0RRBInQq8M8FKJSKQxcObtfir/V6QiaCjdP1uQUdmjhKyYWJy3i', 'Phạm Thị Kế Toán', '0904567890', NULL, 1)
ON DUPLICATE KEY UPDATE
email = VALUES(email),
password_hash = VALUES(password_hash),
full_name = VALUES(full_name),
phone = VALUES(phone),
team_id = VALUES(team_id),
is_active = VALUES(is_active);

-- Link Seed Users (2-8) to Roles
INSERT IGNORE INTO user_roles (user_id, role_id) VALUES
(2, 4), -- DIRECTOR
(3, 3), -- TEAM_LEAD
(4, 2), -- SALES_REP
(5, 2), -- SALES_REP
(6, 5), -- MARKETING
(7, 6), -- CUST_SUCCESS
(8, 7); -- ACCOUNTANT

-- E2E Test Users (IDs 801 - 804)
INSERT IGNORE INTO users (user_id, email, password_hash, full_name, phone, team_id, is_active) VALUES
(801, 'test.admin@crm.com',   '$2a$12$2Y9HBa0DPEwvXtP6AmtPFuoXRmEuXP/7NWzd12qcTqk70Nc73h97u', 'Test System Admin', '0900000801', 1, 1),
(802, 'test.manager@crm.com', '$2a$12$2Y9HBa0DPEwvXtP6AmtPFuoXRmEuXP/7NWzd12qcTqk70Nc73h97u', 'Test Sales Manager', '0900000802', 1, 1),
(803, 'test.sales@crm.com',   '$2a$12$2Y9HBa0DPEwvXtP6AmtPFuoXRmEuXP/7NWzd12qcTqk70Nc73h97u', 'Test Sales Rep',    '0900000803', 1, 1),
(804, 'test.care@crm.com',    '$2a$12$2Y9HBa0DPEwvXtP6AmtPFuoXRmEuXP/7NWzd12qcTqk70Nc73h97u', 'Test Customer Care', '0900000804', 2, 1);

-- Link E2E Test Users (801-804) to Roles
INSERT IGNORE INTO user_roles (user_id, role_id) VALUES
(801, 1), -- ADMIN
(802, 3), -- TEAM_LEAD / MANAGER
(803, 2), -- SALES_REP
(804, 6); -- CUST_SUCCESS / CARE

-- =============================================================================
-- PART 3: LOOKUP TABLES & MASTER CATEGORIES
-- =============================================================================

-- 1. DANH MỤC DÙNG CHUNG (categories)
INSERT INTO categories (category_type, category_name, display_order, status) VALUES
('INDUSTRY', 'Công nghệ thông tin & Phần mềm', 1, 'ACTIVE'),
('INDUSTRY', 'Tài chính - Ngân hàng', 2, 'ACTIVE'),
('INDUSTRY', 'Bất động sản & Xây dựng', 3, 'ACTIVE'),
('INDUSTRY', 'Bán lẻ & Thương mại điện tử', 4, 'ACTIVE'),
('INDUSTRY', 'Y tế & Dược phẩm', 5, 'ACTIVE'),
('SOURCE', 'Website / Giới thiệu từ Web', 1, 'ACTIVE'),
('SOURCE', 'Giới thiệu từ đối tác', 2, 'ACTIVE'),
('SOURCE', 'Hội thảo / Sự kiện', 3, 'ACTIVE'),
('SOURCE', 'Gọi điện tiếp cận trực tiếp (Cold Call)', 4, 'ACTIVE'),
('LEAD_STATUS', 'Mới tạo', 1, 'ACTIVE'),
('LEAD_STATUS', 'Đang liên hệ', 2, 'ACTIVE'),
('LEAD_STATUS', 'Đã xác định nhu cầu', 3, 'ACTIVE'),
('LEAD_STATUS', 'Không tiềm năng', 4, 'ACTIVE')
ON DUPLICATE KEY UPDATE display_order = VALUES(display_order), status = VALUES(status);

-- 2. SẢN PHẨM & DỊCH VỤ (products)
INSERT INTO products (product_code, product_name, product_type, unit, list_price, floor_price, cost_price, status) VALUES
('PROD-CRM-ENT', 'Phần mềm CRM Bản Enterprise (Gói năm)', 'SUBSCRIPTION', 'Gói/Năm', 120000000.00, 100000000.00, 60000000.00, 'ACTIVE'),
('PROD-CRM-STD', 'Phần mềm CRM Bản Standard (Gói năm)', 'SUBSCRIPTION', 'Gói/Năm', 48000000.00, 40000000.00, 24000000.00, 'ACTIVE'),
('PROD-IMP-SVC', 'Dịch vụ Tư vấn & Triển khai Hệ thống', 'ONE_TIME', 'Dự án', 50000000.00, 40000000.00, 20000000.00, 'ACTIVE'),
('PROD-TRN-SVC', 'Dịch vụ Đào tạo Nhân sự Sử dụng CRM', 'ONE_TIME', 'Khóa học', 15000000.00, 12000000.00, 5000000.00, 'ACTIVE'),
('PROD-SUP-247', 'Gói Hỗ trợ Kỹ thuật ưu tiên 24/7', 'SUBSCRIPTION', 'Năm', 30000000.00, 25000000.00, 10000000.00, 'ACTIVE')
ON DUPLICATE KEY UPDATE product_name = VALUES(product_name), list_price = VALUES(list_price), status = VALUES(status);

-- 3. GIAI ĐOẠN BÁN HÀNG (pipeline_stages)
INSERT INTO pipeline_stages (stage_name, display_order, default_probability, exit_condition, status) VALUES
('Khởi tạo / Tiếp cận', 1, 10.00, 'Đã xác định người liên hệ chính', 'ACTIVE'),
('Xác định nhu cầu', 2, 30.00, 'Đã hoàn thành khảo sát yêu cầu', 'ACTIVE'),
('Đề xuất giải pháp & Báo giá', 3, 50.00, 'Đã gửi báo giá chính thức', 'ACTIVE'),
('Thương lượng hợp đồng', 4, 80.00, 'Đã đồng ý điều khoản chính', 'ACTIVE'),
('Chốt thành công (Won)', 5, 100.00, 'Hợp đồng đã ký và thanh toán', 'ACTIVE'),
('Thất bại (Lost)', 6, 0.00, 'Khách hàng từ chối hoặc chọn đối thủ', 'ACTIVE')
ON DUPLICATE KEY UPDATE display_order = VALUES(display_order), default_probability = VALUES(default_probability);

-- 4. LÝ DO THẮNG / THUA (win_loss_reasons)
INSERT INTO win_loss_reasons (reason_type, reason_name, display_order, status) VALUES
('WIN', 'Giá cả cạnh tranh & Hợp lý', 1, 'ACTIVE'),
('WIN', 'Tính năng đáp ứng hoàn hảo yêu cầu', 2, 'ACTIVE'),
('WIN', 'Dịch vụ hỗ trợ & Đào tạo chuyên nghiệp', 3, 'ACTIVE'),
('LOSS', 'Giá thành cao hơn ngân sách', 1, 'ACTIVE'),
('LOSS', 'Khách hàng chọn đối thủ cạnh tranh', 2, 'ACTIVE'),
('LOSS', 'Tạm dừng dự án do thay đổi kế hoạch', 3, 'ACTIVE')
ON DUPLICATE KEY UPDATE display_order = VALUES(display_order);

-- 5. ĐỐI THỦ CẠNH TRANH (competitors)
INSERT INTO competitors (competitor_name, status) VALUES
('Công ty Giải pháp Phần mềm Alpha', 'ACTIVE'),
('Công ty Công nghệ CRM Beta', 'ACTIVE'),
('Tập đoàn Hệ thống Thông tin Gamma', 'ACTIVE')
ON DUPLICATE KEY UPDATE status = VALUES(status);

-- =============================================================================
-- PART 4: CUSTOMERS & CONTACTS
-- =============================================================================

-- Customers Seed (IDs 101 - 110)
INSERT INTO customers (customer_id, customer_name, phone, owner_id) VALUES
(101, 'Tập đoàn Công nghệ FPT Global', '02437689001', 4),
(102, 'Công ty Cổ phần Đầu tư Bất động sản Vinhomes', '02439749999', 4),
(103, 'Ngân hàng TMCP Kỹ Thương Việt Nam (Techcombank)', '02439446368', 4),
(104, 'Công ty TNHH Bán lẻ Masan Retail', '02854161234', 4),
(105, 'Tổng Công ty Dược phẩm Hậu Giang', '02923891433', 4),
(106, 'Công ty Cổ phần Sữa Việt Nam (Vinamilk)', '02854155555', 5),
(107, 'Tập đoàn Hòa Phát Group', '02462820700', 5),
(108, 'Công ty TNHH Phần mềm MISA', '02437959595', 5),
(109, 'Tổng Công ty Hàng không Việt Nam (Vietnam Airlines)', '02438732732', 5),
(110, 'Công ty Cổ phần Thế Giới Di Động', '02838125960', 5)
ON DUPLICATE KEY UPDATE customer_name = VALUES(customer_name), phone = VALUES(phone), owner_id = VALUES(owner_id);

-- Test Customers (IDs 801 - 817)
INSERT IGNORE INTO customers (customer_id, customer_name, phone, tax_code, email, status, industry, company_size, size, website, address, region, owner_id, created_at, updated_at) VALUES
(801, 'TEST - Công ty A (Tập đoàn An Phát)', '02438880001', '0108888001', 'contact@anphat-test.com', 'Chính thức', 'Công nghệ thông tin', 'ENTERPRISE', '500-1000', 'https://anphat-test.com', 'Tòa nhà An Phát, Nam Từ Liêm, Hà Nội', 'Miền Bắc', 803, DATE_SUB(NOW(), INTERVAL 90 DAY), DATE_SUB(NOW(), INTERVAL 45 DAY)),
(802, 'TEST - Công ty B (Tổng Công ty Bảo An)', '02438880002', '0108888002', 'info@baoan-test.com', 'Chính thức', 'Tài chính - Ngân hàng', 'ENTERPRISE', '1000+', 'https://baoan-test.com', 'Số 10 Lý Thường Kiệt, Hoàn Kiếm, Hà Nội', 'Miền Bắc', 803, DATE_SUB(NOW(), INTERVAL 120 DAY), DATE_SUB(NOW(), INTERVAL 60 DAY)),
(803, 'TEST - Công ty C (Công ty Cổ phần Cường Thịnh)', '02838880003', '0308888003', 'sales@cuongthinh-test.com', 'Chính thức', 'Sản xuất - Công nghiệp', 'MEDIUM', '100-500', 'https://cuongthinh-test.com', 'KCN Tân Bình, Tân Phú, TP.HCM', 'Miền Nam', 803, DATE_SUB(NOW(), INTERVAL 80 DAY), DATE_SUB(NOW(), INTERVAL 40 DAY)),
(804, 'TEST - Công ty D (Tập đoàn Đại Nam)', '02438880004', '0108888004', 'support@dainam-test.com', 'Chính thức', 'Bất động sản', 'LARGE', '500-1000', 'https://dainam-test.com', 'Tòa nhà Đại Nam, Cầu Giấy, Hà Nội', 'Miền Bắc', 803, DATE_SUB(NOW(), INTERVAL 60 DAY), DATE_SUB(NOW(), INTERVAL 2 DAY)),
(805, 'TEST - Công ty E (Công ty TNHH E-Commerce)', '02838880005', '0308888005', 'contact@ecom-test.com', 'Chính thức', 'Bán lẻ - Tiêu dùng', 'MEDIUM', '50-100', 'https://ecom-test.com', 'Tầng 5 Bitexco, Quận 1, TP.HCM', 'Miền Nam', 803, DATE_SUB(NOW(), INTERVAL 45 DAY), DATE_SUB(NOW(), INTERVAL 10 DAY)),
(806, 'TEST - Công ty F (Công ty TNHH Dịch vụ Phong Nam)', '02438880006', '0108888006', 'info@phongnam-test.com', 'Tiềm năng', 'Y tế - Dược phẩm', 'SMALL', '10-50', 'https://phongnam-test.com', 'Phố Đội Cấn, Ba Đình, Hà Nội', 'Miền Bắc', 803, DATE_SUB(NOW(), INTERVAL 30 DAY), DATE_SUB(NOW(), INTERVAL 5 DAY)),
(807, 'TEST - Tập đoàn ABC (Parent)', '02438880007', '0108888007', 'group@abc-corp-test.com', 'Chính thức', 'Tài chính - Ngân hàng', 'ENTERPRISE', '1000+', 'https://abc-corp-test.com', 'Tòa nhà ABC Tower, Ba Đình, Hà Nội', 'Miền Bắc', 803, DATE_SUB(NOW(), INTERVAL 150 DAY), DATE_SUB(NOW(), INTERVAL 50 DAY)),
(808, 'TEST - ABC Công ty con 1', '02438880008', '0108888008', 'sub1@abc-corp-test.com', 'Chính thức', 'Công nghệ thông tin', 'LARGE', '100-500', 'https://sub1.abc-corp-test.com', 'Khu CNC Hòa Lạc, Hà Nội', 'Miền Bắc', 803, DATE_SUB(NOW(), INTERVAL 100 DAY), DATE_SUB(NOW(), INTERVAL 30 DAY)),
(809, 'TEST - ABC Công ty con 2', '02838880009', '0308888009', 'sub2@abc-corp-test.com', 'Chính thức', 'Bán lẻ - Tiêu dùng', 'MEDIUM', '50-100', 'https://sub2.abc-corp-test.com', 'Quận 3, TP.HCM', 'Miền Nam', 803, DATE_SUB(NOW(), INTERVAL 90 DAY), DATE_SUB(NOW(), INTERVAL 25 DAY)),
(810, 'TEST - ABC Công ty con 3', '02438880010', '0108888010', 'sub3@abc-corp-test.com', 'Chính thức', 'Dịch vụ', 'SMALL', '10-50', 'https://sub3.abc-corp-test.com', 'Quận Hải Châu, Đà Nẵng', 'Miền Nam', 803, DATE_SUB(NOW(), INTERVAL 80 DAY), DATE_SUB(NOW(), INTERVAL 20 DAY)),
(811, 'TEST - Công ty ABC Việt Nam', '0988111222', '0109999111', 'contact@abcvietnam-test.com', 'Chính thức', 'Công nghệ thông tin', 'MEDIUM', '50-100', 'https://abcvietnam-test.com', 'Số 88 Nguyễn Chí Thanh, Hà Nội', 'Miền Bắc', 801, DATE_SUB(NOW(), INTERVAL 40 DAY), DATE_SUB(NOW(), INTERVAL 15 DAY)),
(812, 'TEST - Công ty ABC Việt Nam Technology', '0988111222', '0109999111', 'sec@abcvietnam-test.com', 'Tiềm năng', 'Công nghệ thông tin', 'MEDIUM', '50-100', 'https://abcvietnam-test.com', 'Số 88 Nguyễn Chí Thanh, Hà Nội', 'Miền Bắc', 801, DATE_SUB(NOW(), INTERVAL 35 DAY), DATE_SUB(NOW(), INTERVAL 10 DAY)),
(813, 'TEST - Công ty Gia Định (Never Contacted)', '02838880013', '0308888013', 'contact@giadinh-test.com', 'Chính thức', 'Vận tải - Lữ hành', 'MEDIUM', '100-500', 'https://giadinh-test.com', 'Quận Bình Thạnh, TP.HCM', 'Miền Nam', 803, DATE_SUB(NOW(), INTERVAL 90 DAY), DATE_SUB(NOW(), INTERVAL 90 DAY)),
(814, 'TEST - Công ty Hải Hà (Low Value Old Contact)', '02438880014', '0108888014', 'info@haiha-test.com', 'Chính thức', 'Thực phẩm - Đồ uống', 'SMALL', '10-50', 'https://haiha-test.com', 'Quận Long Biên, Hà Nội', 'Miền Bắc', 803, DATE_SUB(NOW(), INTERVAL 70 DAY), DATE_SUB(NOW(), INTERVAL 50 DAY)),
(815, 'TEST - Công ty Hoàng Kim (No Contract Inactive)', '02438880015', '0108888015', 'sales@hoangkim-test.com', 'Tiềm năng', 'Dịch vụ', 'SMALL', '10-50', 'https://hoangkim-test.com', 'Quận Thanh Xuân, Hà Nội', 'Miền Bắc', 803, DATE_SUB(NOW(), INTERVAL 60 DAY), DATE_SUB(NOW(), INTERVAL 40 DAY)),
(816, 'TEST - Công ty Khánh Hòa (Multi Contacts & Files)', '02583880016', '0408888016', 'contact@khanhhoa-test.com', 'Chính thức', 'Vận tải - Lữ hành', 'LARGE', '500-1000', 'https://khanhhoa-test.com', 'TP. Nha Trang, Khánh Hòa', 'Miền Nam', 803, DATE_SUB(NOW(), INTERVAL 50 DAY), DATE_SUB(NOW(), INTERVAL 5 DAY)),
(817, 'TEST - Công ty Lâm Đồng (Filter Test)', '02633888999', '0318888777', 'info@lamdong-test.com', 'Ngừng hợp tác', 'Nông nghiệp', 'SMALL', '10-50', 'https://lamdong-test.com', 'TP. Đà Lạt, Lâm Đồng', 'Miền Nam', 803, DATE_SUB(NOW(), INTERVAL 100 DAY), DATE_SUB(NOW(), INTERVAL 30 DAY));

-- TEST CONTACTS (IDs 8001 - 8022)
INSERT IGNORE INTO contacts (contact_id, customer_id, full_name, position, title, email, phone, buying_role, is_primary, created_at) VALUES
(8001, 801, 'Nguyễn Văn An', 'Giám đốc Công nghệ (CTO)', 'Giám đốc Công nghệ (CTO)', 'an.nguyen@anphat-test.com', '0901118001', 'DECIDER', 1, NOW()),
(8002, 801, 'Trần Thị Bích', 'Trưởng phòng IT', 'Trưởng phòng IT', 'bich.tran@anphat-test.com', '0901118002', 'INFLUENCER', 0, NOW()),
(8003, 802, 'Bảo Văn Nam', 'Tổng Giám đốc (CEO)', 'Tổng Giám đốc (CEO)', 'nam.bao@baoan-test.com', '0901118003', 'DECIDER', 1, NOW()),
(8004, 802, 'Phạm Thị Hoa', 'Giám đốc Tài chính (CFO)', 'Giám đốc Tài chính (CFO)', 'hoa.pham@baoan-test.com', '0901118004', 'INFLUENCER', 0, NOW()),
(8005, 803, 'Cường Văn Thịnh', 'Giám đốc Nhà máy', 'Giám đốc Nhà máy', 'thinh.cuong@cuongthinh-test.com', '0901118005', 'DECIDER', 1, NOW()),
(8006, 804, 'Đặng Văn Dũng', 'Phó Tổng Giám đốc', 'Phó Tổng Giám đốc', 'dung.dang@dainam-test.com', '0901118006', 'DECIDER', 1, NOW()),
(8007, 804, 'Vũ Thị Em', 'Trưởng phòng Chăm sóc khách hàng', 'Trưởng phòng Chăm sóc khách hàng', 'em.vu@dainam-test.com', '0901118007', 'END_USER', 0, NOW()),
(8008, 805, 'Hồ Văn Giang', 'Trưởng phòng Mua hàng', 'Trưởng phòng Mua hàng', 'giang.ho@ecom-test.com', '0901118008', 'DECIDER', 1, NOW()),
(8009, 806, 'Lê Văn Hải', 'Giám đốc Điều hành', 'Giám đốc Điều hành', 'hai.le@phongnam-test.com', '0901118009', 'DECIDER', 1, NOW()),
(8010, 807, 'Đỗ Văn Hùng', 'Chủ tịch HĐQT', 'Chủ tịch HĐQT', 'hung.do@abc-corp-test.com', '0901118010', 'DECIDER', 1, NOW()),
(8011, 808, 'Ngô Thị Mai', 'Giám đốc Chi nhánh 1', 'Giám đốc Chi nhánh 1', 'mai.ngo@sub1.abc-corp-test.com', '0901118011', 'DECIDER', 1, NOW()),
(8012, 809, 'Phan Văn Phong', 'Giám đốc Chi nhánh 2', 'Giám đốc Chi nhánh 2', 'phong.phan@sub2.abc-corp-test.com', '0901118012', 'DECIDER', 1, NOW()),
(8013, 810, 'Bùi Văn Quảng', 'Trưởng đại diện', 'Trưởng đại diện', 'quang.bui@sub3.abc-corp-test.com', '0901118013', 'DECIDER', 1, NOW()),
(8014, 811, 'Nguyễn Văn Primary', 'Trưởng phòng Kinh doanh', 'Trưởng phòng Kinh doanh', 'pri@abcvietnam-test.com', '0988111222', 'DECIDER', 1, NOW()),
(8015, 812, 'Nguyễn Văn Secondary', 'Trưởng phòng IT', 'Trưởng phòng IT', 'sec@abcvietnam-test.com', '0988111222', 'DECIDER', 1, NOW()),
(8016, 813, 'Trịnh Văn Sơn', 'Giám đốc Điều hành', 'Giám đốc Điều hành', 'son.trinh@giadinh-test.com', '0901118016', 'DECIDER', 1, NOW()),
(8017, 814, 'Đinh Thị Thu', 'Kế toán trưởng', 'Kế toán trưởng', 'thu.dinh@haiha-test.com', '0901118017', 'INFLUENCER', 1, NOW()),
(8018, 815, 'Hoàng Văn Uy', 'Chủ cơ sở', 'Chủ cơ sở', 'uy.hoang@hoangkim-test.com', '0901118018', 'DECIDER', 1, NOW()),
(8019, 816, 'Nguyễn Thị Vinh', 'Tổng Giám đốc', 'Tổng Giám đốc', 'vinh.nguyen@khanhhoa-test.com', '0901118019', 'DECIDER', 1, NOW()),
(8020, 816, 'Trần Văn Xuân', 'Trưởng phòng CNTT', 'Trưởng phòng CNTT', 'xuan.tran@khanhhoa-test.com', '0901118020', 'INFLUENCER', 0, NOW()),
(8021, 816, 'Lê Thị Yến', 'Nhân viên Vận hành', 'Nhân viên Vận hành', 'yen.le@khanhhoa-test.com', '0901118021', 'END_USER', 0, NOW()),
(8022, 816, 'Phạm Văn Zuy', 'Trưởng phòng Pháp chế', 'Trưởng phòng Pháp chế', 'zuy.pham@khanhhoa-test.com', '0901118022', 'BLOCKER', 0, NOW());

-- =============================================================================
-- PART 5: OPPORTUNITIES, CARE, SUPPORT & ACTIVITIES
-- =============================================================================

-- Opportunities Seed (IDs 201 - 210)
INSERT INTO opportunities (opportunity_id, title, amount, owner_id, pipeline_stage_id, probability, win_loss_reason_id, competitor_id) VALUES
(201, 'Triển khai CRM Enterprise cho FPT Global', 170000000.00, 4, 1, 10.00, NULL, NULL),
(202, 'Nâng cấp Hệ thống Quản lý Khách hàng Vinhomes', 120000000.00, 4, 2, 30.00, NULL, NULL),
(203, 'Tư vấn giải pháp Chăm sóc Khách hàng Techcombank', 98000000.00, 4, 3, 50.00, NULL, NULL),
(204, 'Gói CRM Standard cho Masan Retail', 48000000.00, 4, 4, 80.00, NULL, NULL),
(205, 'Đào tạo & Chuyển giao Hệ thống Dược Hậu Giang', 15000000.00, 4, 5, 100.00, 1, NULL),
(206, 'Số hóa quy trình bán hàng Vinamilk Miền Nam', 200000000.00, 5, 6, 0.00, 5, 1),
(207, 'Triển khai CRM cho Tập đoàn Hòa Phát', 150000000.00, 5, 1, 10.00, NULL, NULL),
(208, 'Hợp đồng Gói Hỗ trợ Kỹ thuật 24/7 MISA', 30000000.00, 5, 2, 30.00, NULL, NULL),
(209, 'Tư vấn CRM Quản lý Đặt chỗ Vietnam Airlines', 250000000.00, 5, 3, 50.00, NULL, NULL),
(210, 'Trang bị Phần mềm CRM cho Thế Giới Di Động', 180000000.00, 5, 5, 100.00, 2, NULL)
ON DUPLICATE KEY UPDATE title = VALUES(title), amount = VALUES(amount), owner_id = VALUES(owner_id), pipeline_stage_id = VALUES(pipeline_stage_id), probability = VALUES(probability), win_loss_reason_id = VALUES(win_loss_reason_id), competitor_id = VALUES(competitor_id);

-- Update customer_id linkage for Seed Opportunities 201..210
UPDATE opportunities SET customer_id = 101 WHERE opportunity_id = 201 AND customer_id IS NULL;
UPDATE opportunities SET customer_id = 102 WHERE opportunity_id = 202 AND customer_id IS NULL;
UPDATE opportunities SET customer_id = 103 WHERE opportunity_id = 203 AND customer_id IS NULL;
UPDATE opportunities SET customer_id = 104 WHERE opportunity_id = 204 AND customer_id IS NULL;
UPDATE opportunities SET customer_id = 105 WHERE opportunity_id = 205 AND customer_id IS NULL;
UPDATE opportunities SET customer_id = 106 WHERE opportunity_id = 206 AND customer_id IS NULL;
UPDATE opportunities SET customer_id = 107 WHERE opportunity_id = 207 AND customer_id IS NULL;
UPDATE opportunities SET customer_id = 108 WHERE opportunity_id = 208 AND customer_id IS NULL;
UPDATE opportunities SET customer_id = 109 WHERE opportunity_id = 209 AND customer_id IS NULL;
UPDATE opportunities SET customer_id = 110 WHERE opportunity_id = 210 AND customer_id IS NULL;

-- Test Opportunities (IDs 8001 - 8017)
INSERT IGNORE INTO opportunities (opportunity_id, customer_id, title, amount, owner_id, pipeline_stage_id, probability, stage, close_date, created_at) VALUES
(8001, 801, 'Hợp đồng ERP Tổng thể An Phát - Giai đoạn 1', 1000000000.00, 803, 5, 100.00, 'CLOSED_WON', DATE_SUB(NOW(), INTERVAL 60 DAY), DATE_SUB(NOW(), INTERVAL 90 DAY)),
(8002, 801, 'Bản quyền Phần mềm CRM An Phát - Giai đoạn 2', 500000000.00, 803, 5, 100.00, 'CLOSED_WON', DATE_SUB(NOW(), INTERVAL 30 DAY), DATE_SUB(NOW(), INTERVAL 60 DAY)),
(8003, 801, 'Gói Bảo trì & Nâng cấp Hệ thống An Phát',      300000000.00, 803, 3,  50.00, 'OPEN',       DATE_ADD(NOW(), INTERVAL 30 DAY), DATE_SUB(NOW(), INTERVAL 15 DAY)),
(8004, 802, 'Hợp đồng Chuyển đổi số Toàn diện Bảo An',   2000000000.00, 803, 5, 100.00, 'CLOSED_WON', DATE_SUB(NOW(), INTERVAL 90 DAY), DATE_SUB(NOW(), INTERVAL 120 DAY)),
(8005, 803, 'Gói CRM Tự động hóa Bán hàng Cường Thịnh',   100000000.00, 803, 5, 100.00, 'CLOSED_WON', DATE_SUB(NOW(), INTERVAL 45 DAY), DATE_SUB(NOW(), INTERVAL 80 DAY)),
(8006, 804, 'Số hóa Quản lý Dự án BĐS Đại Nam',            800000000.00, 803, 5, 100.00, 'CLOSED_WON', DATE_SUB(NOW(), INTERVAL 15 DAY), DATE_SUB(NOW(), INTERVAL 60 DAY)),
(8007, 805, 'Hệ thống Quản lý Đơn hàng E-Commerce',       450000000.00, 803, 5, 100.00, 'CLOSED_WON', DATE_SUB(NOW(), INTERVAL 20 DAY), DATE_SUB(NOW(), INTERVAL 45 DAY)),
(8008, 806, 'Tư vấn Giải pháp Quản lý Y tế Phong Nam',    150000000.00, 803, 2,  30.00, 'OPEN',       DATE_ADD(NOW(), INTERVAL 45 DAY), DATE_SUB(NOW(), INTERVAL 20 DAY)),
(8009, 806, 'Cung cấp Thiết bị Công nghệ Phong Nam',        80000000.00, 803, 1,  10.00, 'OPEN',       DATE_ADD(NOW(), INTERVAL 60 DAY), DATE_SUB(NOW(), INTERVAL 10 DAY)),
(8010, 806, 'Gói Đào tạo Nhân sự Y tế (Thất bại)',        200000000.00, 803, 6,   0.00, 'CLOSED_LOST',DATE_SUB(NOW(), INTERVAL 10 DAY), DATE_SUB(NOW(), INTERVAL 30 DAY)),
(8011, 807, 'Triển khai CRM Core Tập đoàn ABC',            3000000000.00, 803, 5, 100.00, 'CLOSED_WON', DATE_SUB(NOW(), INTERVAL 100 DAY), DATE_SUB(NOW(), INTERVAL 150 DAY)),
(8012, 808, 'Triển khai CRM Chi nhánh 1 ABC',              1000000000.00, 803, 5, 100.00, 'CLOSED_WON', DATE_SUB(NOW(), INTERVAL 70 DAY), DATE_SUB(NOW(), INTERVAL 100 DAY)),
(8013, 809, 'Triển khai CRM Chi nhánh 2 ABC',               500000000.00, 803, 5, 100.00, 'CLOSED_WON', DATE_SUB(NOW(), INTERVAL 60 DAY), DATE_SUB(NOW(), INTERVAL 90 DAY)),
(8014, 810, 'Triển khai CRM Chi nhánh 3 ABC',               200000000.00, 803, 5, 100.00, 'CLOSED_WON', DATE_SUB(NOW(), INTERVAL 40 DAY), DATE_SUB(NOW(), INTERVAL 80 DAY)),
(8015, 813, 'Hợp đồng Quản lý Tour Du lịch Gia Định',       600000000.00, 803, 5, 100.00, 'CLOSED_WON', DATE_SUB(NOW(), INTERVAL 80 DAY), DATE_SUB(NOW(), INTERVAL 90 DAY)),
(8016, 814, 'Gói CRM Mini Hải Hà',                           50000000.00, 803, 5, 100.00, 'CLOSED_WON', DATE_SUB(NOW(), INTERVAL 55 DAY), DATE_SUB(NOW(), INTERVAL 70 DAY)),
(8017, 816, 'Hệ thống Quản lý Vận tải Khánh Hòa',          900000000.00, 803, 5, 100.00, 'CLOSED_WON', DATE_SUB(NOW(), INTERVAL 25 DAY), DATE_SUB(NOW(), INTERVAL 50 DAY));

-- TEST CUSTOMER CARE (IDs 8001 - 8009)
INSERT IGNORE INTO customer_care (care_id, customer_id, last_contacted_at, last_contacted_by, inactive_threshold_days, note, created_at, updated_at) VALUES
(8001, 801, DATE_SUB(NOW(), INTERVAL 45 DAY), 803, 30, 'Khách hàng chưa liên hệ lại từ tháng trước.', DATE_SUB(NOW(), INTERVAL 90 DAY), DATE_SUB(NOW(), INTERVAL 45 DAY)),
(8002, 802, DATE_SUB(NOW(), INTERVAL 60 DAY), 803, 30, 'Cần lên lịch gọi điện chăm sóc gia hạn hợp đồng.', DATE_SUB(NOW(), INTERVAL 120 DAY), DATE_SUB(NOW(), INTERVAL 60 DAY)),
(8003, 803, DATE_SUB(NOW(), INTERVAL 40 DAY), 803, 30, 'Khách hàng hài lòng nhưng cần hỏi thăm định kỳ.', DATE_SUB(NOW(), INTERVAL 80 DAY), DATE_SUB(NOW(), INTERVAL 40 DAY)),
(8004, 804, DATE_SUB(NOW(), INTERVAL 2 DAY), 804, 30, 'Vừa trao đổi xử lý các sự cố hỗ trợ kỹ thuật.', DATE_SUB(NOW(), INTERVAL 60 DAY), DATE_SUB(NOW(), INTERVAL 2 DAY)),
(8005, 805, DATE_SUB(NOW(), INTERVAL 10 DAY), 804, 30, 'Đã xác nhận sự cố khẩn cấp.', DATE_SUB(NOW(), INTERVAL 45 DAY), DATE_SUB(NOW(), INTERVAL 10 DAY)),
(8006, 807, DATE_SUB(NOW(), INTERVAL 50 DAY), 803, 30, 'Tập đoàn mẹ lâu chưa tương tác.', DATE_SUB(NOW(), INTERVAL 150 DAY), DATE_SUB(NOW(), INTERVAL 50 DAY)),
(8007, 813, NULL, NULL, 30, 'Khách mới ký hợp đồng nhưng chưa từng có lượt tương tác chăm sóc.', DATE_SUB(NOW(), INTERVAL 90 DAY), DATE_SUB(NOW(), INTERVAL 90 DAY)),
(8008, 814, DATE_SUB(NOW(), INTERVAL 50 DAY), 803, 30, 'Giá trị hợp đồng nhỏ, lâu chưa tương tác.', DATE_SUB(NOW(), INTERVAL 70 DAY), DATE_SUB(NOW(), INTERVAL 50 DAY)),
(8009, 815, DATE_SUB(NOW(), INTERVAL 40 DAY), 803, 30, 'Chưa ký hợp đồng nhưng quá hạn chăm sóc tiềm năng.', DATE_SUB(NOW(), INTERVAL 60 DAY), DATE_SUB(NOW(), INTERVAL 40 DAY));

-- TEST SUPPORT REQUESTS (IDs 8001 - 8007)
INSERT IGNORE INTO support_requests (request_id, customer_id, title, description, priority, status, assignee_id, created_by, created_at, updated_at) VALUES
(8001, 801, 'Hướng dẫn xuất báo cáo doanh thu', 'Khách hàng cần hỗ trợ xuất báo cáo định dạng Excel.', 'LOW', 'OPEN', 804, 803, DATE_SUB(NOW(), INTERVAL 5 DAY), DATE_SUB(NOW(), INTERVAL 5 DAY)),
(8002, 804, 'Lỗi kết nối cơ sở dữ liệu hệ thống BĐS', 'Hệ thống báo lỗi mất kết nối máy chủ dữ liệu từ 8h sáng.', 'HIGH', 'OPEN', 804, 803, DATE_SUB(NOW(), INTERVAL 2 DAY), DATE_SUB(NOW(), INTERVAL 2 DAY)),
(8003, 804, 'Không đồng bộ được danh sách căn hộ', 'Dữ liệu căn hộ mới thêm không hiển thị trên giao diện CRM.', 'HIGH', 'IN_PROGRESS', 804, 803, DATE_SUB(NOW(), INTERVAL 1 DAY), DATE_SUB(NOW(), INTERVAL 1 DAY)),
(8004, 804, 'Yêu cầu tùy chỉnh phân quyền xem hợp đồng', 'Khách hàng muốn giới hạn quyền xem hợp đồng của nhân viên.', 'MEDIUM', 'OPEN', 804, 803, DATE_SUB(NOW(), INTERVAL 12 HOUR), DATE_SUB(NOW(), INTERVAL 12 HOUR)),
(8005, 805, 'SỰ CỐ KHẨN CẤP: Ngừng hoạt động cổng thanh toán', 'Khách hàng phản ánh cổng thanh toán đơn hàng bị sập toàn bộ.', 'URGENT', 'OPEN', 804, 803, DATE_SUB(NOW(), INTERVAL 3 HOUR), DATE_SUB(NOW(), INTERVAL 3 HOUR)),
(8006, 806, 'Hỏi đáp về quy trình bảo hành phần mềm', 'Khách hàng thắc mắc điều khoản bảo hành năm thứ 2.', 'MEDIUM', 'RESOLVED', 804, 803, DATE_SUB(NOW(), INTERVAL 20 DAY), DATE_SUB(NOW(), INTERVAL 15 DAY)),
(8007, 806, 'Thay đổi thông tin người quản trị tài khoản', 'Khách hàng gửi công văn đổi admin hệ thống.', 'LOW', 'CLOSED', 804, 803, DATE_SUB(NOW(), INTERVAL 10 DAY), DATE_SUB(NOW(), INTERVAL 8 DAY));

-- TEST CUSTOMER HIERARCHY (IDs 8001 - 8003)
INSERT IGNORE INTO customer_relationships (relationship_id, parent_customer_id, child_customer_id, relationship_type, created_at) VALUES
(8001, 807, 808, 'SUBSIDIARY', NOW()),
(8002, 807, 809, 'SUBSIDIARY', NOW()),
(8003, 807, 810, 'BRANCH',     NOW());

-- Activities Seed (IDs 301 - 310)
INSERT INTO activities (activity_id, title, description, owner_id) VALUES
(301, 'Cuộc họp trao đổi yêu cầu với FPT Global', 'Gặp trực tiếp Ban Giám đốc FPT để khảo sát quy trình bán hàng hiện tại.', 4),
(302, 'Gọi điện demo tính năng CRM cho Vinhomes', 'Trình bày tính năng phân quyền phạm vi dữ liệu và báo cáo doanh thu.', 4),
(303, 'Gửi hồ sơ năng lực & Đề xuất dịch vụ Techcombank', 'Đã gửi file PDF đề xuất giải pháp qua email cho Trưởng phòng IT.', 4),
(304, 'Tư vấn trực tiếp gói Standard Masan Retail', 'Giải đáp thắc mắc về chi phí duy trì hàng năm và khả năng mở rộng.', 4),
(305, 'Khảo sát nhu cầu đào tạo Dược Hậu Giang', 'Thống nhất lịch đào tạo 3 buổi cho 20 nhân viên phòng kinh doanh.', 4),
(306, 'Cuộc họp khởi động dự án Vinamilk Miền Nam', 'Thống nhất mốc thời gian triển khai giai đoạn 1 với Team Miền Nam.', 5),
(307, 'Thương lượng điều khoản hợp đồng Hòa Phát', 'Đàm phán chiết khấu cho hợp đồng triển khai quy mô lớn.', 5),
(308, 'Kiểm tra kỹ thuật gói 24/7 cho MISA', 'Xác nhận hạ tầng máy chủ và thông số kết nối API.', 5),
(309, 'Demo tính năng báo cáo Quản trị Vietnam Airlines', 'Trình bày dashboard phân tích doanh số theo từng nhóm bán hàng.', 5),
(310, 'Gọi điện chăm sóc định kỳ Thế Giới Di Động', 'Ghi nhận phản hồi về trải nghiệm sử dụng thử bản demo.', 5)
ON DUPLICATE KEY UPDATE title = VALUES(title), description = VALUES(description), owner_id = VALUES(owner_id);

-- Test Activities (IDs 8001 - 8010)
INSERT IGNORE INTO activities (activity_id, title, description, owner_id, customer_id, activity_type, created_at) VALUES
(8001, 'Cuộc gọi tư vấn giải pháp CRM', 'Đã trao đổi với anh An CTO về kế hoạch nâng cấp giai đoạn 2.', 803, 801, 'CALL', DATE_SUB(NOW(), INTERVAL 45 DAY)),
(8002, 'Họp trực tiếp thống nhất yêu cầu', 'Họp tại văn phòng An Phát chốt danh sách tính năng.', 803, 801, 'MEETING', DATE_SUB(NOW(), INTERVAL 50 DAY)),
(8003, 'Gửi báo giá nâng cấp hệ thống', 'Đã gửi file PDF báo giá chi tiết qua email.', 803, 801, 'EMAIL', DATE_SUB(NOW(), INTERVAL 55 DAY)),
(8004, 'Cuộc gọi kiểm tra định kỳ Bảo An', 'Đã liên hệ chị Hoa CFO trao đổi lịch thanh toán.', 803, 802, 'CALL', DATE_SUB(NOW(), INTERVAL 60 DAY)),
(8005, 'Gửi email đề xuất gia hạn dịch vụ', 'Đã gửi email nhắc hạn hợp đồng năm tiếp theo.', 803, 802, 'EMAIL', DATE_SUB(NOW(), INTERVAL 65 DAY)),
(8006, 'Họp online xử lý sự cố BĐS Đại Nam', 'Họp khẩn làm rõ nguyên nhân lỗi kết nối CSDL.', 804, 804, 'MEETING', DATE_SUB(NOW(), INTERVAL 2 DAY)),
(8007, 'Tiếp nhận cuộc gọi báo lỗi E-Commerce', 'Đã ghi nhận sự cố gián đoạn cổng thanh toán.', 804, 805, 'CALL', DATE_SUB(NOW(), INTERVAL 3 HOUR)),
(8008, 'Gặp mặt ban giám đốc Khánh Hòa', 'Thảo luận hợp đồng dịch vụ vận tải du lịch.', 803, 816, 'MEETING', DATE_SUB(NOW(), INTERVAL 25 DAY)),
(8009, 'Gửi hợp đồng nguyên tắc qua email', 'Đã gửi dự thảo hợp đồng chính thức.', 803, 816, 'EMAIL', DATE_SUB(NOW(), INTERVAL 20 DAY)),
(8010, 'Cuộc gọi xác nhận ký kết', 'Đã chốt ngày ký hợp đồng.', 803, 816, 'CALL', DATE_SUB(NOW(), INTERVAL 15 DAY));

-- =============================================================================
-- PART 6: ATTACHMENTS, SAVED FILTERS, QUOTES & AUDIT LOGS
-- =============================================================================

-- TEST ATTACHMENTS (IDs 8001 - 8003)
INSERT IGNORE INTO attachments (attachment_id, customer_id, file_name, file_path, file_size, uploaded_at) VALUES
(8001, 816, 'Hop_dong_nguyen_tac_KhanhHoa.pdf', '/uploads/customers/816/Hop_dong_nguyen_tac_KhanhHoa.pdf', 2458000, DATE_SUB(NOW(), INTERVAL 20 DAY)),
(8002, 816, 'Bao_gia_phu_luc_KhanhHoa.docx',     '/uploads/customers/816/Bao_gia_phu_luc_KhanhHoa.docx',     1024000, DATE_SUB(NOW(), INTERVAL 18 DAY)),
(8003, 801, 'Bien_ban_nghiem_thu_AnPhat.pdf',   '/uploads/customers/801/Bien_ban_nghiem_thu_AnPhat.pdf',   3120000, DATE_SUB(NOW(), INTERVAL 40 DAY));

-- TEST SAVED FILTERS (IDs 8001 - 8003)
INSERT IGNORE INTO saved_filters (filter_id, user_id, filter_name, module, keyword, status, industry, company_size, region, owner_id, filter_query, is_default, created_at) VALUES
(8001, 803, 'Khách hàng Miền Bắc - IT', 'CUSTOMER', '', 'Chính thức', 'Công nghệ thông tin', '', 'Miền Bắc', 803, 'status=Chính thức&industry=Công nghệ thông tin&region=Miền Bắc', 1, NOW()),
(8002, 803, 'Khách hàng Doanh nghiệp lớn', 'CUSTOMER', '', 'Chính thức', '', 'ENTERPRISE', '', 803, 'status=Chính thức&company_size=ENTERPRISE', 0, NOW()),
(8003, 804, 'Khách hàng Tiềm năng Miền Nam', 'CUSTOMER', '', 'Tiềm năng', '', '', 'Miền Nam', 804, 'status=Tiềm năng&region=Miền Nam', 0, NOW());

-- Quotes Seed (IDs 401 - 410)
INSERT INTO quotes (quote_id, quote_number, owner_id) VALUES
(401, 'BG-2026-FPT-01', 4),
(402, 'BG-2026-VHM-02', 4),
(403, 'BG-2026-TCB-03', 4),
(404, 'BG-2026-MSN-04', 4),
(405, 'BG-2026-DHG-05', 4),
(406, 'BG-2026-VNM-06', 5),
(407, 'BG-2026-HPG-07', 5),
(408, 'BG-2026-MSA-08', 5),
(409, 'BG-2026-VNA-09', 5),
(410, 'BG-2026-TGD-10', 5)
ON DUPLICATE KEY UPDATE quote_number = VALUES(quote_number), owner_id = VALUES(owner_id);

-- Audit Logs Seed
INSERT INTO audit_logs (action_type, performed_by, target_user_id, description, old_value, new_value) VALUES
('CREATE_CUSTOMER', 4, 4, 'Khởi tạo hồ sơ khách hàng doanh nghiệp FPT Global', NULL, 'customer_id=101'),
('CREATE_OPPORTUNITY', 4, 4, 'Tạo cơ hội bán hàng FPT Global giá trị 170.000.000 VNĐ', NULL, 'opportunity_id=201'),
('CREATE_ACTIVITY', 4, 4, 'Tạo lịch hẹn cuộc họp trao đổi với FPT Global', NULL, 'activity_id=301'),
('CREATE_CUSTOMER', 5, 5, 'Khởi tạo hồ sơ khách hàng Vinamilk Miền Nam', NULL, 'customer_id=106'),
('CREATE_OPPORTUNITY', 5, 5, 'Tạo cơ hội bán hàng Vinamilk Miền Nam giá trị 200.000.000 VNĐ', NULL, 'opportunity_id=206'),
('CREATE_ACTIVITY', 5, 5, 'Tạo lịch hẹn cuộc họp khởi động dự án Vinamilk Miền Nam', NULL, 'activity_id=306');

COMMIT;

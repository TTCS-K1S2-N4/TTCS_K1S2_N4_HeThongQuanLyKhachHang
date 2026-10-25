-- =============================================================================
-- CSDL HỆ THỐNG QUẢN LÝ KHÁCH HÀNG (CRM SYSTEM) - MASTER TEST DATA & SEED SCRIPT
-- File: test_data.sql
-- Thư mục: Backend/src/main/resources/sql/
-- Bộ ký tự: UTF-8 / utf8mb4
-- Quy mô: Chuẩn hóa 100 danh tính người Việt Nam (22 nhân viên, 78 khách hàng)
-- =============================================================================

USE crm_db;
SET NAMES utf8mb4;
SET CHARACTER SET utf8mb4;

SET FOREIGN_KEY_CHECKS = 0;
START TRANSACTION;

-- =============================================================================
-- 1. BẢNG PHÒNG BAN / NHÓM KINH DOANH (teams)
-- =============================================================================
INSERT INTO teams (team_id, team_name, description, leader_id, region) VALUES
(1, 'Team Kinh Doanh Miền Bắc', 'Phụ trách thị trường Hà Nội và các tỉnh phía Bắc', 3, 'Miền Bắc'),
(2, 'Team Kinh Doanh Miền Nam', 'Phụ trách thị trường TP.HCM và các tỉnh phía Nam', 5, 'Miền Nam'),
(3, 'Team Kinh Doanh Miền Trung', 'Phụ trách thị trường Đà Nẵng và khu vực miền Trung', 4, 'Miền Trung')
ON DUPLICATE KEY UPDATE
    team_name = VALUES(team_name),
    description = VALUES(description),
    leader_id = VALUES(leader_id),
    region = VALUES(region);

-- =============================================================================
-- 2. BẢNG VAI TRÒ HỆ THỐNG (roles)
-- =============================================================================
INSERT INTO roles (role_id, role_code, role_name) VALUES
(1, 'ADMIN', 'Quản trị hệ thống'),
(2, 'SALES_REP', 'Nhân viên kinh doanh'),
(3, 'TEAM_LEAD', 'Trưởng nhóm kinh doanh'),
(4, 'DIRECTOR', 'Giám đốc kinh doanh'),
(5, 'MARKETING', 'Nhân viên Marketing'),
(6, 'CUST_SUCCESS', 'Chăm sóc khách hàng'),
(7, 'ACCOUNTANT', 'Kế toán')
ON DUPLICATE KEY UPDATE
    role_code = VALUES(role_code),
    role_name = VALUES(role_name);

-- =============================================================================
-- 3. BẢNG QUYỀN HẠN HỆ THỐNG (permissions)
-- =============================================================================
INSERT INTO permissions (permission_id, permission_code, permission_name, module) VALUES
(1,  'ACCOUNT_VIEW',      'Xem Khách hàng',                'ACCOUNT'),
(2,  'ACCOUNT_CREATE',    'Tạo mới Khách hàng',             'ACCOUNT'),
(3,  'ACCOUNT_EDIT',      'Chỉnh sửa Khách hàng',          'ACCOUNT'),
(4,  'ACCOUNT_DELETE',    'Xóa Khách hàng',                'ACCOUNT'),
(5,  'ACCOUNT_EXPORT',    'Xuất Excel Khách hàng',         'ACCOUNT'),
(6,  'DEAL_VIEW',         'Xem Cơ hội',                    'DEAL'),
(7,  'DEAL_CREATE',       'Tạo mới Cơ hội',                'DEAL'),
(8,  'DEAL_EDIT',         'Chỉnh sửa Cơ hội',              'DEAL'),
(9,  'ACTIVITY_VIEW',     'Xem Hoạt động',                 'ACTIVITY'),
(10, 'QUOTE_VIEW',        'Xem Báo giá',                   'QUOTE'),
(11, 'USER_VIEW',         'Xem Tài khoản',                 'USER'),
(12, 'USER_CREATE',       'Tạo mới Tài khoản',             'USER'),
(13, 'USER_EDIT',         'Chỉnh sửa/Gán quyền Tài khoản', 'USER'),
(14, 'USER_DELETE',       'Khóa/Bàn giao Tài khoản',       'USER'),
(15, 'PRODUCT_VIEW',      'Xem Sản phẩm',                  'PRODUCT'),
(16, 'PRODUCT_MANAGE',    'Quản lý Sản phẩm',              'PRODUCT'),
(17, 'PRODUCT_COST_VIEW', 'Xem Giá vốn Sản phẩm',          'PRODUCT'),
(18, 'CATEGORY_VIEW',     'Xem Danh mục dùng chung',       'CATEGORY'),
(19, 'CATEGORY_MANAGE',   'Quản lý Danh mục dùng chung',   'CATEGORY'),
(20, 'ORG_VIEW',          'Xem Cấu trúc Tổ chức',          'ORGANIZATION'),
(21, 'ORG_MANAGE',        'Quản lý Cấu trúc Tổ chức',      'ORGANIZATION'),
(22, 'AUDIT_VIEW',        'Xem Nhật ký Hệ thống',          'AUDIT'),
(23, 'IMPORT_DATA',       'Import Dữ liệu Excel',          'IMPORT')
ON DUPLICATE KEY UPDATE
    permission_name = VALUES(permission_name),
    module = VALUES(module);

-- =============================================================================
-- 4. BẢNG GÁN QUYỀN CHO VAI TRÒ (role_permissions) - 87 LIÊN KẾT RBAC CHUẨN
-- =============================================================================
-- 1. ADMIN (ALL tất cả 23 quyền)
INSERT INTO role_permissions (role_id, permission_id, data_scope)
SELECT 1, p.permission_id, 'ALL' FROM permissions p
ON DUPLICATE KEY UPDATE data_scope = VALUES(data_scope);

-- 2. DIRECTOR (20 quyền ALL trừ quyền quản trị tài khoản USER_CREATE/EDIT/DELETE)
INSERT INTO role_permissions (role_id, permission_id, data_scope)
SELECT 4, p.permission_id, 'ALL' FROM permissions p
WHERE p.permission_code NOT IN ('USER_CREATE', 'USER_EDIT', 'USER_DELETE')
ON DUPLICATE KEY UPDATE data_scope = VALUES(data_scope);

-- 3. TEAM_LEAD (11 quyền TEAM + 3 quyền ALL)
INSERT INTO role_permissions (role_id, permission_id, data_scope)
SELECT 3, p.permission_id, 'TEAM' FROM permissions p
WHERE p.permission_code IN ('ACCOUNT_VIEW','ACCOUNT_CREATE','ACCOUNT_EDIT','ACCOUNT_DELETE','ACCOUNT_EXPORT','DEAL_VIEW','DEAL_CREATE','DEAL_EDIT','ACTIVITY_VIEW','QUOTE_VIEW','IMPORT_DATA')
ON DUPLICATE KEY UPDATE data_scope = VALUES(data_scope);

INSERT INTO role_permissions (role_id, permission_id, data_scope)
SELECT 3, p.permission_id, 'ALL' FROM permissions p
WHERE p.permission_code IN ('CATEGORY_VIEW','PRODUCT_VIEW','ORG_VIEW')
ON DUPLICATE KEY UPDATE data_scope = VALUES(data_scope);

-- 4. SALES_REP (8 quyền MY + 2 quyền ALL)
INSERT INTO role_permissions (role_id, permission_id, data_scope)
SELECT 2, p.permission_id, 'MY' FROM permissions p
WHERE p.permission_code IN ('ACCOUNT_VIEW','ACCOUNT_CREATE','ACCOUNT_EDIT','DEAL_VIEW','DEAL_CREATE','DEAL_EDIT','ACTIVITY_VIEW','QUOTE_VIEW')
ON DUPLICATE KEY UPDATE data_scope = VALUES(data_scope);

INSERT INTO role_permissions (role_id, permission_id, data_scope)
SELECT 2, p.permission_id, 'ALL' FROM permissions p
WHERE p.permission_code IN ('CATEGORY_VIEW','PRODUCT_VIEW')
ON DUPLICATE KEY UPDATE data_scope = VALUES(data_scope);

-- 5. MARKETING (5 quyền ALL + 2 danh mục)
INSERT INTO role_permissions (role_id, permission_id, data_scope)
SELECT 5, p.permission_id, 'ALL' FROM permissions p
WHERE p.permission_code IN ('ACCOUNT_VIEW','ACCOUNT_CREATE','ACCOUNT_EDIT','DEAL_VIEW','ACTIVITY_VIEW','CATEGORY_VIEW','PRODUCT_VIEW')
ON DUPLICATE KEY UPDATE data_scope = VALUES(data_scope);

-- 6. CUST_SUCCESS (6 quyền MY + 2 danh mục)
INSERT INTO role_permissions (role_id, permission_id, data_scope)
SELECT 6, p.permission_id, 'MY' FROM permissions p
WHERE p.permission_code IN ('ACCOUNT_VIEW','ACCOUNT_CREATE','ACCOUNT_EDIT','DEAL_VIEW','ACTIVITY_VIEW','QUOTE_VIEW')
ON DUPLICATE KEY UPDATE data_scope = VALUES(data_scope);

INSERT INTO role_permissions (role_id, permission_id, data_scope)
SELECT 6, p.permission_id, 'ALL' FROM permissions p
WHERE p.permission_code IN ('CATEGORY_VIEW','PRODUCT_VIEW')
ON DUPLICATE KEY UPDATE data_scope = VALUES(data_scope);

-- 7. ACCOUNTANT (5 quyền ALL)
INSERT INTO role_permissions (role_id, permission_id, data_scope)
SELECT 7, p.permission_id, 'ALL' FROM permissions p
WHERE p.permission_code IN ('ACCOUNT_VIEW','DEAL_VIEW','QUOTE_VIEW','CATEGORY_VIEW','PRODUCT_VIEW')
ON DUPLICATE KEY UPDATE data_scope = VALUES(data_scope);

-- =============================================================================
-- 5. BẢNG MENU ĐIỀU HƯỚNG (menu_items)
-- =============================================================================
INSERT INTO menu_items (id, title, url, icon, permission_code, display_order, parent_id) VALUES
(1, 'Khách hàng',          '/customers',          'fa-users',               'ACCOUNT_VIEW',  1, 0),
(2, 'Cơ hội kinh doanh',   '/deals',              'fa-chart-line',          'DEAL_VIEW',     2, 0),
(3, 'Hoạt động & Lịch hẹn', '/activities',         'fa-calendar-alt',        'ACTIVITY_VIEW', 3, 0),
(4, 'Báo giá',             '/quotes',              'fa-file-invoice-dollar', 'QUOTE_VIEW',    4, 0),
(5, 'Sản phẩm & Dịch vụ',  '/products',            'fa-box-open',            'PRODUCT_VIEW',  5, 0),
(6, 'Danh mục dùng chung',  '/categories',          'fa-tags',                'CATEGORY_VIEW', 6, 0),
(7, 'Cấu trúc tổ chức',    '/organization/teams', 'fa-sitemap',             'ORG_VIEW',      7, 0),
(8, 'Quản lý tài khoản',   '/accounts/list',      'fa-user-cog',            'USER_VIEW',     8, 0),
(9, 'Nhật ký hệ thống',    '/audit/list',         'fa-history',             'AUDIT_VIEW',    9, 0)
ON DUPLICATE KEY UPDATE
    title = VALUES(title),
    url = VALUES(url),
    icon = VALUES(icon),
    permission_code = VALUES(permission_code),
    display_order = VALUES(display_order);

-- =============================================================================
-- 6. BẢNG DANH MỤC DÙNG CHUNG (categories)
-- =============================================================================
INSERT INTO categories (category_id, category_type, category_name, display_order, status) VALUES
(1,  'INDUSTRY',    'Công nghệ thông tin & Phần mềm', 1, 'ACTIVE'),
(2,  'INDUSTRY',    'Tài chính - Ngân hàng',          2, 'ACTIVE'),
(3,  'INDUSTRY',    'Bất động sản & Xây dựng',       3, 'ACTIVE'),
(4,  'INDUSTRY',    'Bán lẻ & Thương mại điện tử',   4, 'ACTIVE'),
(5,  'INDUSTRY',    'Y tế & Dược phẩm',              5, 'ACTIVE'),
(6,  'SOURCE',      'Website / Đăng ký qua Web',     1, 'ACTIVE'),
(7,  'SOURCE',      'Giới thiệu từ đối tác',         2, 'ACTIVE'),
(8,  'SOURCE',      'Hội thảo / Sự kiện chuyên đề',  3, 'ACTIVE'),
(9,  'SOURCE',      'Gọi điện tiếp cận (Cold Call)', 4, 'ACTIVE'),
(10, 'LEAD_STATUS', 'Mới tạo',                       1, 'ACTIVE'),
(11, 'LEAD_STATUS', 'Đang tiếp cận liên hệ',         2, 'ACTIVE'),
(12, 'LEAD_STATUS', 'Đã xác định nhu cầu',           3, 'ACTIVE'),
(13, 'LEAD_STATUS', 'Không tiềm năng',               4, 'ACTIVE')
ON DUPLICATE KEY UPDATE
    display_order = VALUES(display_order),
    status = VALUES(status);

-- =============================================================================
-- 7. BẢNG SẢN PHẨM & DỊCH VỤ (products)
-- =============================================================================
INSERT INTO products (product_id, product_code, product_name, product_type, unit, list_price, floor_price, cost_price, status) VALUES
(1, 'PROD-CRM-ENT', 'Phần mềm CRM Bản Enterprise (Gói năm)', 'SUBSCRIPTION', 'Gói/Năm', 120000000.00, 100000000.00, 60000000.00, 'ACTIVE'),
(2, 'PROD-CRM-STD', 'Phần mềm CRM Bản Standard (Gói năm)',   'SUBSCRIPTION', 'Gói/Năm',  48000000.00,  40000000.00, 24000000.00, 'ACTIVE'),
(3, 'PROD-IMP-SVC', 'Dịch vụ Tư vấn & Triển khai Hệ thống',  'ONE_TIME',     'Dự án',    50000000.00,  40000000.00, 20000000.00, 'ACTIVE'),
(4, 'PROD-TRN-SVC', 'Dịch vụ Đào tạo Nhân sự Sử dụng CRM',  'ONE_TIME',     'Khóa học', 15000000.00,  12000000.00,  5000000.00, 'ACTIVE'),
(5, 'PROD-SUP-247', 'Gói Hỗ trợ Kỹ thuật Ưu tiên 24/7',      'SUBSCRIPTION', 'Năm',      30000000.00,  25000000.00, 10000000.00, 'ACTIVE')
ON DUPLICATE KEY UPDATE
    product_name = VALUES(product_name),
    list_price = VALUES(list_price),
    status = VALUES(status);

-- =============================================================================
-- 8. BẢNG GIAI ĐOẠN BÁN HÀNG PIPELINE (pipeline_stages)
-- =============================================================================
INSERT INTO pipeline_stages (pipeline_stage_id, stage_name, display_order, default_probability, exit_condition, status) VALUES
(1, 'Khởi tạo / Tiếp cận',          1,  10.00, 'Đã xác định người liên hệ chính', 'ACTIVE'),
(2, 'Xác định nhu cầu',              2,  30.00, 'Đã hoàn thành khảo sát yêu cầu',   'ACTIVE'),
(3, 'Đề xuất giải pháp & Báo giá', 3,  50.00, 'Đã gửi báo giá chính thức',         'ACTIVE'),
(4, 'Thương lượng hợp đồng',        4,  80.00, 'Đã đồng ý các điều khoản chính',   'ACTIVE'),
(5, 'Chốt thành công (Won)',        5, 100.00, 'Hợp đồng đã ký và thanh toán',     'ACTIVE'),
(6, 'Thất bại (Lost)',              6,   0.00, 'Khách hàng từ chối hoặc chọn đối thủ', 'ACTIVE')
ON DUPLICATE KEY UPDATE
    display_order = VALUES(display_order),
    default_probability = VALUES(default_probability);

-- =============================================================================
-- 9. BẢNG LÝ DO THẮNG / THUA (win_loss_reasons)
-- =============================================================================
INSERT INTO win_loss_reasons (reason_id, reason_type, reason_name, display_order, status) VALUES
(1, 'WIN',  'Giá cả cạnh tranh & Hợp lý',             1, 'ACTIVE'),
(2, 'WIN',  'Tính năng đáp ứng hoàn hảo yêu cầu',     2, 'ACTIVE'),
(3, 'WIN',  'Dịch vụ hỗ trợ & Đào tạo chuyên nghiệp', 3, 'ACTIVE'),
(4, 'LOSS', 'Giá thành vượt ngân sách dự toán',       1, 'ACTIVE'),
(5, 'LOSS', 'Khách hàng chọn đối thủ cạnh tranh khác', 2, 'ACTIVE'),
(6, 'LOSS', 'Khách hàng hủy dự án / Thay đổi kế hoạch',3, 'ACTIVE')
ON DUPLICATE KEY UPDATE
    display_order = VALUES(display_order),
    status = VALUES(status);

-- =============================================================================
-- 10. BẢNG ĐỐI THỦ CẠNH TRANH (competitors)
-- =============================================================================
INSERT INTO competitors (competitor_id, competitor_name, status) VALUES
(1, 'Công ty Giải pháp Phần mềm Alpha', 'ACTIVE'),
(2, 'Công ty Công nghệ CRM Beta',       'ACTIVE'),
(3, 'Tập đoàn Hệ thống Thông tin Gamma', 'ACTIVE')
ON DUPLICATE KEY UPDATE status = VALUES(status);

-- =============================================================================
-- 11. BẢNG NGUỒN GỐC LEAD (lead_sources) - 14 NGUỒN NGHIỆP VỤ CHUẨN
-- =============================================================================
INSERT INTO lead_sources (source_id, source_code, source_name, description, is_active) VALUES
(1,  'WEB_FORM',       'Biểu mẫu Website',            'Lead thu thập tự động từ biểu mẫu nhúng trên website', 1),
(2,  'MANUAL',         'Tạo thủ công',                'Lead do nhân viên kinh doanh tự nhập tay vào CRM', 1),
(3,  'EXCEL',          'Nhập từ file Excel',          'Lead import hàng loạt từ danh sách file bảng tính', 1),
(4,  'FACEBOOK',       'Facebook Lead Ads',           'Chiến dịch quảng cáo thu thập lead từ mạng xã hội Facebook', 1),
(5,  'GOOGLE_ADS',     'Google Ads Search',           'Khách hàng tìm kiếm từ khóa và click quảng cáo Google', 1),
(6,  'HOTLINE',        'Tổng đài Hotline',            'Khách hàng gọi trực tiếp vào số hotline tư vấn', 1),
(7,  'EVENT',          'Hội thảo / Sự kiện',          'Thu thập danh thiếp tại các sự kiện triển lãm xúc tiến thương mại', 1),
(8,  'PARTNER',        'Đối tác giới thiệu',          'Nguồn giới thiệu từ mạng lưới đối tác chiến lược', 1),
(9,  'IMPORT_EXCEL',   'Nhập từ Excel (Hệ thống)',    'Lead được import định kỳ từ file Excel dữ liệu', 1),
(10, 'DIRECT',        'Trực tiếp / Khách đến',      'Khách hàng tự tìm đến văn phòng hoặc liên hệ trực tiếp', 1),
(11, 'REFERRAL',      'Giới thiệu',                 'Khách hàng được đối tác hoặc khách hàng cũ giới thiệu', 1),
(12, 'COLD_CALL',     'Gọi điện thoại (Telesales)', 'Nguồn tiếp cận qua chiến dịch gọi điện', 1),
(13, 'EMAIL_CAMPAIGN','Chiến dịch Email',           'Lead phản hồi qua các chiến dịch tiếp thị qua email', 1),
(14, 'SOCIAL_MEDIA',  'Mạng xã hội',                'Lead từ Facebook, LinkedIn, Zalo...', 1)
ON DUPLICATE KEY UPDATE
    source_name = VALUES(source_name),
    description = VALUES(description),
    is_active = VALUES(is_active);

-- =============================================================================
-- 12. BẢNG CẤU HÌNH & QUY TẮC CHẤM ĐIỂM LEAD (lead_scoring_config & rules)
-- =============================================================================
INSERT INTO lead_scoring_config (config_key, config_value) VALUES
('hot_threshold', '70'),
('warm_threshold', '40')
ON DUPLICATE KEY UPDATE config_value = VALUES(config_value);

INSERT INTO lead_scoring_rules (rule_id, criterion, operator, condition_value, score, is_active) VALUES
(1, 'INDUSTRY',     'EQUALS', 'Công nghệ thông tin', 25, 1),
(2, 'COMPANY_SIZE', 'EQUALS', '100-500',             20, 1),
(3, 'HAS_PHONE',    'EQUALS', 'TRUE',                15, 1),
(4, 'HAS_EMAIL',    'EQUALS', 'TRUE',                10, 1)
ON DUPLICATE KEY UPDATE score = VALUES(score), is_active = VALUES(is_active);

-- =============================================================================
-- 13. BẢNG CẤU HÌNH THỜI HẠN PHẢN HỒI LEAD SLA (lead_sla_configs)
-- =============================================================================
INSERT INTO lead_sla_configs (sla_id, priority_level, response_time_minutes, is_active) VALUES
(1, 'DEFAULT', 4320, 1),
(2, 'HOT',     1440, 1),
(3, 'WARM',    2880, 1),
(4, 'COLD',    4320, 1)
ON DUPLICATE KEY UPDATE response_time_minutes = VALUES(response_time_minutes), is_active = VALUES(is_active);

-- =============================================================================
-- 14. BẢNG ĐỊNH NGHĨA TRƯỜNG TÙY CHỈNH (custom_field_definitions)
-- =============================================================================
INSERT INTO custom_field_definitions (field_id, entity_type, field_key, field_label, field_type, options, is_required, default_value, display_order, status) VALUES
(1, 'CUSTOMER',    'tax_bracket',           'Phân nhóm Doanh nghiệp',       'SELECT', 'Doanh nghiệp lớn (Hạng A),Doanh nghiệp vừa (Hạng B),Doanh nghiệp nhỏ (Hạng C)', 0, 'Doanh nghiệp lớn (Hạng A)', 1, 'ACTIVE'),
(2, 'CUSTOMER',    'facebook_fanpage',      'Trang Fanpage Doanh nghiệp',   'TEXT',   NULL, 0, NULL, 2, 'ACTIVE'),
(3, 'CUSTOMER',    'annual_revenue_usd',    'Doanh thu Ước tính (USD)',     'NUMBER', NULL, 0, '0', 3, 'ACTIVE'),
(4, 'CUSTOMER',    'erp_system',            'Hệ thống ERP đang dùng',       'TEXT',   NULL, 0, 'Chưa có', 4, 'ACTIVE'),
(5, 'CUSTOMER',    'contract_renewal_date', 'Hạn gia hạn hợp đồng',         'DATE',   NULL, 0, NULL, 5, 'ACTIVE'),
(6, 'OPPORTUNITY', 'deploy_deadline',       'Hạn hoàn thành triển khai',    'DATE',   NULL, 0, NULL, 1, 'ACTIVE'),
(7, 'OPPORTUNITY', 'software_edition',      'Phiên bản phần mềm dự kiến',   'SELECT', 'Standard Cloud,Enterprise Dedicated,On-Premise Custom', 1, 'Enterprise Dedicated', 2, 'ACTIVE'),
(8, 'OPPORTUNITY', 'user_licenses',         'Số lượng tài khoản dự kiến',   'NUMBER', NULL, 0, '50', 3, 'ACTIVE'),
(9, 'OPPORTUNITY', 'procurement_poc',       'Đầu mối mua sắm khách hàng',  'TEXT',   NULL, 0, NULL, 4, 'ACTIVE')
ON DUPLICATE KEY UPDATE
    field_label = VALUES(field_label),
    field_type = VALUES(field_type),
    options = VALUES(options),
    is_required = VALUES(is_required);

-- =============================================================================
-- 15. BẢNG NGƯỜI DÙNG / TÀI KHOẢN (users) - ĐÚNG 22 NHÂN VIÊN NỘI BỘ
-- Mật khẩu mặc định đồng bộ cho 100% tài khoản: Admin12345@
-- Hash BCrypt chuẩn cost 12: $2a$12$8PrSeh2OtQfKeCeX1E6y0eIkFcSHigJq5Q.ZEknmUcmvGWHOINpn.
-- =============================================================================
INSERT INTO users (user_id, email, password_hash, full_name, phone, team_id, is_active, failed_attempts, lockout_until) VALUES
(1, 'phuongthituyetmai@gmail.com', '$2a$12$8PrSeh2OtQfKeCeX1E6y0eIkFcSHigJq5Q.ZEknmUcmvGWHOINpn.', 'Phương Thị Tuyết Mai', '0900000001', NULL, 1, 0, NULL),
(2, 'hoangtunglinh@gmail.com', '$2a$12$8PrSeh2OtQfKeCeX1E6y0eIkFcSHigJq5Q.ZEknmUcmvGWHOINpn.', 'Hoàng Tùng Linh', '0900000002', NULL, 1, 0, NULL),
(3, 'lanhnguyencongluat@gmail.com', '$2a$12$8PrSeh2OtQfKeCeX1E6y0eIkFcSHigJq5Q.ZEknmUcmvGWHOINpn.', 'Lành Nguyễn Công Luật', '0900000003', 1, 1, 0, NULL),
(4, 'mabanam@gmail.com', '$2a$12$8PrSeh2OtQfKeCeX1E6y0eIkFcSHigJq5Q.ZEknmUcmvGWHOINpn.', 'Ma Bá Nam', '0900000004', 3, 1, 0, NULL),
(5, 'luongducmanh@gmail.com', '$2a$12$8PrSeh2OtQfKeCeX1E6y0eIkFcSHigJq5Q.ZEknmUcmvGWHOINpn.', 'Lường Đức Mạnh', '0900000005', 2, 1, 0, NULL),
(6, 'buiducminh@gmail.com', '$2a$12$8PrSeh2OtQfKeCeX1E6y0eIkFcSHigJq5Q.ZEknmUcmvGWHOINpn.', 'Bùi Đức Minh', '0900000006', 1, 1, 0, NULL),
(7, 'nonghoanglong@gmail.com', '$2a$12$8PrSeh2OtQfKeCeX1E6y0eIkFcSHigJq5Q.ZEknmUcmvGWHOINpn.', 'Nông Hoàng Long', '0900000007', 1, 1, 0, NULL),
(8, 'nguyenduclong@gmail.com', '$2a$12$8PrSeh2OtQfKeCeX1E6y0eIkFcSHigJq5Q.ZEknmUcmvGWHOINpn.', 'Nguyễn Đức Long', '0900000008', NULL, 1, 0, NULL),
(9, 'leduchainam@gmail.com', '$2a$12$8PrSeh2OtQfKeCeX1E6y0eIkFcSHigJq5Q.ZEknmUcmvGWHOINpn.', 'Lê Đức Hải Nam', '0900000009', NULL, 1, 0, NULL),
(10, 'phamngohoang@gmail.com', '$2a$12$8PrSeh2OtQfKeCeX1E6y0eIkFcSHigJq5Q.ZEknmUcmvGWHOINpn.', 'Phạm Ngô Hoàng', '0900000010', NULL, 1, 0, NULL),
(11, 'nonghoaimai@gmail.com', '$2a$12$8PrSeh2OtQfKeCeX1E6y0eIkFcSHigJq5Q.ZEknmUcmvGWHOINpn.', 'Nông Hoài Mai', '0900000011', 1, 1, 0, NULL),
(12, 'lythanhan@gmail.com', '$2a$12$8PrSeh2OtQfKeCeX1E6y0eIkFcSHigJq5Q.ZEknmUcmvGWHOINpn.', 'Lý Thanh An', '0900000012', 1, 1, 0, NULL),
(13, 'buidinhlam@gmail.com', '$2a$12$8PrSeh2OtQfKeCeX1E6y0eIkFcSHigJq5Q.ZEknmUcmvGWHOINpn.', 'Bùi Đình Lâm', '0900000013', 3, 1, 0, NULL),
(14, 'chubaoloc@gmail.com', '$2a$12$8PrSeh2OtQfKeCeX1E6y0eIkFcSHigJq5Q.ZEknmUcmvGWHOINpn.', 'Chu Bảo Lộc', '0900000014', 3, 1, 0, NULL),
(15, 'nguyenducphuc@gmail.com', '$2a$12$8PrSeh2OtQfKeCeX1E6y0eIkFcSHigJq5Q.ZEknmUcmvGWHOINpn.', 'Nguyễn Đức Phúc', '0900000015', 3, 1, 0, NULL),
(16, 'hathanhlong@gmail.com', '$2a$12$8PrSeh2OtQfKeCeX1E6y0eIkFcSHigJq5Q.ZEknmUcmvGWHOINpn.', 'Hà Thanh Long', '0900000016', 2, 1, 0, NULL),
(17, 'phanphuongtrung@gmail.com', '$2a$12$8PrSeh2OtQfKeCeX1E6y0eIkFcSHigJq5Q.ZEknmUcmvGWHOINpn.', 'Phan Phương Trung', '0900000017', 2, 1, 0, NULL),
(18, 'nongquangnhan@gmail.com', '$2a$12$8PrSeh2OtQfKeCeX1E6y0eIkFcSHigJq5Q.ZEknmUcmvGWHOINpn.', 'Nông Quang Nhân', '0900000018', 2, 1, 5, DATE_ADD(NOW(), INTERVAL 1 HOUR)),
(19, 'dinhhuulinh@gmail.com', '$2a$12$8PrSeh2OtQfKeCeX1E6y0eIkFcSHigJq5Q.ZEknmUcmvGWHOINpn.', 'Đinh Hữu Linh', '0900000019', NULL, 1, 0, NULL),
(20, 'hadinhuyen@gmail.com', '$2a$12$8PrSeh2OtQfKeCeX1E6y0eIkFcSHigJq5Q.ZEknmUcmvGWHOINpn.', 'Hà Đình Uyên', '0900000020', NULL, 1, 0, NULL),
(21, 'dothanhchau@gmail.com', '$2a$12$8PrSeh2OtQfKeCeX1E6y0eIkFcSHigJq5Q.ZEknmUcmvGWHOINpn.', 'Đỗ Thanh Châu', '0900000021', NULL, 1, 0, NULL),
(22, 'doanvantung@gmail.com', '$2a$12$8PrSeh2OtQfKeCeX1E6y0eIkFcSHigJq5Q.ZEknmUcmvGWHOINpn.', 'Đoàn Văn Tùng', '0900000022', NULL, 1, 0, NULL)
ON DUPLICATE KEY UPDATE
    email = VALUES(email),
    password_hash = VALUES(password_hash),
    full_name = VALUES(full_name),
    phone = VALUES(phone),
    team_id = VALUES(team_id),
    is_active = VALUES(is_active),
    failed_attempts = VALUES(failed_attempts),
    lockout_until = VALUES(lockout_until);

-- =============================================================================
-- 16. BẢNG GÁN VAI TRÒ NGƯỜI DÙNG (user_roles) - 22 NHÂN SỰ CHÍNH XÁC
-- =============================================================================
INSERT IGNORE INTO user_roles (user_id, role_id) VALUES
(1, 1),
(2, 4),
(3, 3),
(4, 3),
(5, 3),
(6, 2),
(7, 2),
(8, 5),
(9, 6),
(10, 7),
(11, 2),
(12, 2),
(13, 2),
(14, 2),
(15, 2),
(16, 2),
(17, 2),
(18, 2),
(19, 5),
(20, 5),
(21, 6),
(22, 6);

-- =============================================================================
-- 17. BẢNG CHIẾN DỊCH TIẾP THỊ (campaigns) - S4-03
-- =============================================================================
INSERT INTO campaigns (campaign_id, campaign_name, budget, start_date, end_date, channel, description, status, created_by) VALUES
(1, 'Chiến dịch Tiếp thị Số Q4/2026', 150000000.00, '2026-10-01', '2026-12-31', 'GOOGLE_ADS', 'Quảng cáo tìm kiếm Google cho gói phần mềm CRM doanh nghiệp', 'ACTIVE', 8),
(2, 'Ra mắt Nền tảng Chuyển đổi số B2B', 200000000.00, '2026-09-15', '2026-11-30', 'FACEBOOK', 'Quảng cáo tiếp cận lãnh đạo doanh nghiệp vừa và nhỏ trên Facebook/LinkedIn', 'ACTIVE', 8),
(3, 'Hội thảo Chuyển đổi số Ngành Bán lẻ 2026', 80000000.00, '2026-10-10', '2026-10-25', 'EVENT', 'Sự kiện Offline kết nối 100+ CEO/CTO chuỗi bán lẻ tại Hà Nội', 'COMPLETED', 19),
(4, 'Chương trình Ưu đãi Mùa Thu 2026', 50000000.00, '2026-11-01', '2026-11-30', 'EMAIL', 'Email marketing gửi khách hàng đăng ký dùng thử 30 ngày', 'PLANNING', 19)
ON DUPLICATE KEY UPDATE
    campaign_name = VALUES(campaign_name),
    budget = VALUES(budget),
    channel = VALUES(channel),
    status = VALUES(status);

-- =============================================================================
-- 18. BẢNG BIỂU MẪU WEB FORM THU THẬP LEAD (lead_web_forms) - S4-01
-- =============================================================================
INSERT INTO lead_web_forms (form_id, form_name, description, embed_code, allowed_domains, success_redirect_url, is_active, spam_protection_enabled, fields_json, lead_source_id, created_by) VALUES
(1, 'Form Liên hệ tư vấn Website', 'Biểu mẫu tư vấn đặt tại trang chủ frostlinecrm.com',
 '<!-- Frostline CRM Web Form ID: 1 -->\n<iframe src="http://localhost:8080/CRM/leads/public-form?formId=1" width="100%" height="480" frameborder="0"></iframe>',
 '*, frostlinecrm.com, localhost', 'http://localhost:8080/CRM/thank-you.html', 1, 1,
 '[{"name":"fullName","label":"Họ và tên","required":true},{"name":"email","label":"Email","required":true},{"name":"phone","label":"Số điện thoại","required":true}]', 1, 8),
(2, 'Form Đăng ký Dùng thử 30 ngày', 'Biểu mẫu đăng ký trial trên landing page giải pháp CRM',
 '<!-- Frostline CRM Web Form ID: 2 -->\n<iframe src="http://localhost:8080/CRM/leads/public-form?formId=2" width="100%" height="520" frameborder="0"></iframe>',
 '*, landing.frostlinecrm.com, localhost', 'http://localhost:8080/CRM/welcome.html', 1, 1,
 '[{"name":"fullName","label":"Họ và tên","required":true},{"name":"email","label":"Email","required":true},{"name":"company","label":"Tên công ty","required":true}]', 1, 8)
ON DUPLICATE KEY UPDATE
    form_name = VALUES(form_name),
    description = VALUES(description),
    lead_source_id = VALUES(lead_source_id),
    is_active = VALUES(is_active);

-- =============================================================================
-- 19. BẢNG KHÁCH HÀNG / DOANH NGHIỆP (customers) - CHÍNH XÁC 78 KHÁCH HÀNG
-- IDs: 101 -> 178 tương ứng danh tính 23 -> 100 trong danh sách 100 người
-- =============================================================================
INSERT INTO customers (customer_id, customer_name, phone, tax_code, email, status, industry, company_size, size, website, address, region, owner_id, created_at, updated_at) VALUES
(101, 'Công ty Cổ phần Mai Ngọc Phúc', '0900000101', '0000000101', 'maingocphuc@gmail.com', 'Chính thức', 'Công nghệ thông tin', 'ENTERPRISE', '1000+', 'https://maingocphuc.vn', 'Số 101 Phố Hoàng Cầu, Đống Đa, Hà Nội', 'Miền Bắc', 6, DATE_SUB(NOW(), INTERVAL 120 DAY), NOW()),
(102, 'Công ty Cổ phần Lương Bảo Hùng', '0900000102', '0000000102', 'luongbaohung@gmail.com', 'Chính thức', 'Tài chính - Ngân hàng', 'LARGE', '500-1000', 'https://luongbaohung.vn', 'Số 102 Phố Hoàng Cầu, Đống Đa, Hà Nội', 'Miền Bắc', 7, DATE_SUB(NOW(), INTERVAL 119 DAY), NOW()),
(103, 'Công ty Cổ phần Mai Khánh Thảo', '0900000103', '0000000103', 'maikhanhthao@gmail.com', 'Chính thức', 'Bất động sản', 'MEDIUM', '100-500', 'https://maikhanhthao.vn', 'Số 103 Phố Hoàng Cầu, Đống Đa, Hà Nội', 'Miền Bắc', 11, DATE_SUB(NOW(), INTERVAL 118 DAY), NOW()),
(104, 'Công ty Cổ phần Chu Công Tú', '0900000104', '0000000104', 'chucongtu@gmail.com', 'Chính thức', 'Bán lẻ - Tiêu dùng', 'SMALL', '10-50', 'https://chucongtu.vn', 'Số 104 Phố Hoàng Cầu, Đống Đa, Hà Nội', 'Miền Bắc', 12, DATE_SUB(NOW(), INTERVAL 117 DAY), NOW()),
(105, 'Công ty Cổ phần Nông Hoài Thủy', '0900000105', '0000000105', 'nonghoaithuy@gmail.com', 'Chính thức', 'Y tế - Dược phẩm', 'ENTERPRISE', '1000+', 'https://nonghoaithuy.vn', 'Số 105 Phố Hoàng Cầu, Đống Đa, Hà Nội', 'Miền Bắc', 6, DATE_SUB(NOW(), INTERVAL 116 DAY), NOW()),
(106, 'Công ty Cổ phần Đoàn Văn Bách', '0900000106', '0000000106', 'doanvanbach@gmail.com', 'Chính thức', 'Sản xuất - Công nghiệp', 'LARGE', '500-1000', 'https://doanvanbach.vn', 'Số 106 Phố Hoàng Cầu, Đống Đa, Hà Nội', 'Miền Bắc', 7, DATE_SUB(NOW(), INTERVAL 115 DAY), NOW()),
(107, 'Công ty Cổ phần Hoàng Văn Thảo', '0900000107', '0000000107', 'hoangvanthao@gmail.com', 'Chính thức', 'Vận tải - Lữ hành', 'MEDIUM', '100-500', 'https://hoangvanthao.vn', 'Số 107 Phố Hoàng Cầu, Đống Đa, Hà Nội', 'Miền Bắc', 11, DATE_SUB(NOW(), INTERVAL 114 DAY), NOW()),
(108, 'Công ty Cổ phần Hồ Thanh Trí', '0900000108', '0000000108', 'hothanhtri@gmail.com', 'Chính thức', 'Giáo dục & Đào tạo', 'SMALL', '10-50', 'https://hothanhtri.vn', 'Số 108 Phố Hoàng Cầu, Đống Đa, Hà Nội', 'Miền Bắc', 12, DATE_SUB(NOW(), INTERVAL 113 DAY), NOW()),
(109, 'Công ty Cổ phần Lý Văn Minh', '0900000109', '0000000109', 'lyvanminh@gmail.com', 'Chính thức', 'Công nghệ thông tin', 'ENTERPRISE', '1000+', 'https://lyvanminh.vn', 'Số 109 Phố Hoàng Cầu, Đống Đa, Hà Nội', 'Miền Bắc', 6, DATE_SUB(NOW(), INTERVAL 112 DAY), NOW()),
(110, 'Công ty Cổ phần Lường Phương Linh', '0900000110', '0000000110', 'luongphuonglinh@gmail.com', 'Chính thức', 'Tài chính - Ngân hàng', 'LARGE', '500-1000', 'https://luongphuonglinh.vn', 'Số 110 Phố Hoàng Cầu, Đống Đa, Hà Nội', 'Miền Bắc', 7, DATE_SUB(NOW(), INTERVAL 111 DAY), NOW()),
(111, 'Công ty Cổ phần Trịnh Đức Hoa', '0900000111', '0000000111', 'trinhduchoa@gmail.com', 'Chính thức', 'Bất động sản', 'MEDIUM', '100-500', 'https://trinhduchoa.vn', 'Số 111 Phố Hoàng Cầu, Đống Đa, Hà Nội', 'Miền Bắc', 11, DATE_SUB(NOW(), INTERVAL 110 DAY), NOW()),
(112, 'Công ty Cổ phần Hà Minh Vy', '0900000112', '0000000112', 'haminhvy@gmail.com', 'Chính thức', 'Bán lẻ - Tiêu dùng', 'SMALL', '10-50', 'https://haminhvy.vn', 'Số 112 Phố Hoàng Cầu, Đống Đa, Hà Nội', 'Miền Bắc', 12, DATE_SUB(NOW(), INTERVAL 109 DAY), NOW()),
(113, 'Công ty Cổ phần Lương Văn Hương', '0900000113', '0000000113', 'luongvanhuong@gmail.com', 'Chính thức', 'Y tế - Dược phẩm', 'ENTERPRISE', '1000+', 'https://luongvanhuong.vn', 'Số 113 Phố Hoàng Cầu, Đống Đa, Hà Nội', 'Miền Bắc', 6, DATE_SUB(NOW(), INTERVAL 108 DAY), NOW()),
(114, 'Công ty Cổ phần Trần Hoài Thu', '0900000114', '0000000114', 'tranhoaithu@gmail.com', 'Chính thức', 'Sản xuất - Công nghiệp', 'LARGE', '500-1000', 'https://tranhoaithu.vn', 'Số 114 Phố Hoàng Cầu, Đống Đa, Hà Nội', 'Miền Bắc', 7, DATE_SUB(NOW(), INTERVAL 107 DAY), NOW()),
(115, 'Công ty Cổ phần Tạ Ngọc Liên', '0900000115', '0000000115', 'tangoclien@gmail.com', 'Chính thức', 'Vận tải - Lữ hành', 'MEDIUM', '100-500', 'https://tangoclien.vn', 'Số 115 Phố Hoàng Cầu, Đống Đa, Hà Nội', 'Miền Bắc', 11, DATE_SUB(NOW(), INTERVAL 106 DAY), NOW()),
(116, 'Công ty Cổ phần Ngô Quang Lộc', '0900000116', '0000000116', 'ngoquangloc@gmail.com', 'Chính thức', 'Giáo dục & Đào tạo', 'SMALL', '10-50', 'https://ngoquangloc.vn', 'Số 116 Phố Hoàng Cầu, Đống Đa, Hà Nội', 'Miền Bắc', 12, DATE_SUB(NOW(), INTERVAL 105 DAY), NOW()),
(117, 'Công ty Cổ phần Trần Công Nga', '0900000117', '0000000117', 'trancongnga@gmail.com', 'Chính thức', 'Công nghệ thông tin', 'ENTERPRISE', '1000+', 'https://trancongnga.vn', 'Số 117 Phố Hoàng Cầu, Đống Đa, Hà Nội', 'Miền Bắc', 6, DATE_SUB(NOW(), INTERVAL 104 DAY), NOW()),
(118, 'Công ty Cổ phần Đỗ Thị Bình', '0900000118', '0000000118', 'dothibinh@gmail.com', 'Chính thức', 'Tài chính - Ngân hàng', 'LARGE', '500-1000', 'https://dothibinh.vn', 'Số 118 Phố Hoàng Cầu, Đống Đa, Hà Nội', 'Miền Bắc', 7, DATE_SUB(NOW(), INTERVAL 103 DAY), NOW()),
(119, 'Công ty Cổ phần Dương Thanh Linh', '0900000119', '0000000119', 'duongthanhlinh@gmail.com', 'Chính thức', 'Bất động sản', 'MEDIUM', '100-500', 'https://duongthanhlinh.vn', 'Số 119 Phố Hoàng Cầu, Đống Đa, Hà Nội', 'Miền Bắc', 11, DATE_SUB(NOW(), INTERVAL 102 DAY), NOW()),
(120, 'Công ty Cổ phần Chu Ngọc Vy', '0900000120', '0000000120', 'chungocvy@gmail.com', 'Chính thức', 'Bán lẻ - Tiêu dùng', 'SMALL', '10-50', 'https://chungocvy.vn', 'Số 120 Phố Hoàng Cầu, Đống Đa, Hà Nội', 'Miền Bắc', 12, DATE_SUB(NOW(), INTERVAL 101 DAY), NOW()),
(121, 'Công ty Cổ phần Trịnh Anh Thắng', '0900000121', '0000000121', 'trinhanhthang@gmail.com', 'Chính thức', 'Y tế - Dược phẩm', 'ENTERPRISE', '1000+', 'https://trinhanhthang.vn', 'Số 121 Phố Hoàng Cầu, Đống Đa, Hà Nội', 'Miền Bắc', 6, DATE_SUB(NOW(), INTERVAL 100 DAY), NOW()),
(122, 'Công ty Cổ phần Chu Minh Khang', '0900000122', '0000000122', 'chuminhkhang@gmail.com', 'Chính thức', 'Sản xuất - Công nghiệp', 'LARGE', '500-1000', 'https://chuminhkhang.vn', 'Số 122 Phố Hoàng Cầu, Đống Đa, Hà Nội', 'Miền Bắc', 7, DATE_SUB(NOW(), INTERVAL 99 DAY), NOW()),
(123, 'Công ty Cổ phần Phạm Công Liên', '0900000123', '0000000123', 'phamconglien@gmail.com', 'Chính thức', 'Vận tải - Lữ hành', 'MEDIUM', '100-500', 'https://phamconglien.vn', 'Số 123 Phố Hoàng Cầu, Đống Đa, Hà Nội', 'Miền Bắc', 11, DATE_SUB(NOW(), INTERVAL 98 DAY), NOW()),
(124, 'Công ty Cổ phần Hồ Tuấn Phương', '0900000124', '0000000124', 'hotuanphuong@gmail.com', 'Chính thức', 'Giáo dục & Đào tạo', 'SMALL', '10-50', 'https://hotuanphuong.vn', 'Số 124 Phố Hoàng Cầu, Đống Đa, Hà Nội', 'Miền Bắc', 12, DATE_SUB(NOW(), INTERVAL 97 DAY), NOW()),
(125, 'Công ty Cổ phần Cao Văn Long', '0900000125', '0000000125', 'caovanlong@gmail.com', 'Chính thức', 'Công nghệ thông tin', 'ENTERPRISE', '1000+', 'https://caovanlong.vn', 'Số 125 Phố Hoàng Cầu, Đống Đa, Hà Nội', 'Miền Bắc', 6, DATE_SUB(NOW(), INTERVAL 96 DAY), NOW()),
(126, 'Công ty Cổ phần Phan Tuấn Khôi', '0900000126', '0000000126', 'phantuankhoi@gmail.com', 'Chính thức', 'Tài chính - Ngân hàng', 'LARGE', '500-1000', 'https://phantuankhoi.vn', 'Số 126 Phố Hoàng Cầu, Đống Đa, Hà Nội', 'Miền Bắc', 7, DATE_SUB(NOW(), INTERVAL 95 DAY), NOW()),
(127, 'Công ty Cổ phần Nguyễn Hữu Trinh', '0900000127', '0000000127', 'nguyenhuutrinh@gmail.com', 'Chính thức', 'Bất động sản', 'MEDIUM', '100-500', 'https://nguyenhuutrinh.vn', 'Số 127 Phố Hoàng Cầu, Đống Đa, Hà Nội', 'Miền Bắc', 11, DATE_SUB(NOW(), INTERVAL 94 DAY), NOW()),
(128, 'Công ty Cổ phần Chu Hữu Liên', '0900000128', '0000000128', 'chuhuulien@gmail.com', 'Chính thức', 'Bán lẻ - Tiêu dùng', 'SMALL', '10-50', 'https://chuhuulien.vn', 'Số 128 Phố Hoàng Cầu, Đống Đa, Hà Nội', 'Miền Bắc', 12, DATE_SUB(NOW(), INTERVAL 93 DAY), NOW()),
(129, 'Công ty Cổ phần Phan Xuân Ngân', '0900000129', '0000000129', 'phanxuanngan@gmail.com', 'Chính thức', 'Y tế - Dược phẩm', 'ENTERPRISE', '1000+', 'https://phanxuanngan.vn', 'Số 129 Phố Hoàng Cầu, Đống Đa, Hà Nội', 'Miền Bắc', 6, DATE_SUB(NOW(), INTERVAL 92 DAY), NOW()),
(130, 'Công ty Cổ phần Lường Hoài Thắng', '0900000130', '0000000130', 'luonghoaithang@gmail.com', 'Chính thức', 'Sản xuất - Công nghiệp', 'LARGE', '500-1000', 'https://luonghoaithang.vn', 'Số 130 Phố Hoàng Cầu, Đống Đa, Hà Nội', 'Miền Bắc', 7, DATE_SUB(NOW(), INTERVAL 91 DAY), NOW()),
(131, 'Công ty Cổ phần Hồ Xuân Huy', '0900000131', '0000000131', 'hoxuanhuy@gmail.com', 'Chính thức', 'Vận tải - Lữ hành', 'MEDIUM', '100-500', 'https://hoxuanhuy.vn', 'Số 131 Phố Hoàng Cầu, Đống Đa, Hà Nội', 'Miền Bắc', 11, DATE_SUB(NOW(), INTERVAL 90 DAY), NOW()),
(132, 'Công ty Cổ phần Hồ Khánh Vy', '0900000132', '0000000132', 'hokhanhvy@gmail.com', 'Chính thức', 'Giáo dục & Đào tạo', 'SMALL', '10-50', 'https://hokhanhvy.vn', 'Số 132 Phố Hoàng Cầu, Đống Đa, Hà Nội', 'Miền Bắc', 12, DATE_SUB(NOW(), INTERVAL 89 DAY), NOW()),
(133, 'Công ty Cổ phần Nguyễn Công Tâm', '0900000133', '0000000133', 'nguyencongtam@gmail.com', 'Chính thức', 'Công nghệ thông tin', 'ENTERPRISE', '1000+', 'https://nguyencongtam.vn', 'Số 133 Đường Nguyễn Văn Linh, Hải Châu, Đà Nẵng', 'Miền Trung', 13, DATE_SUB(NOW(), INTERVAL 88 DAY), NOW()),
(134, 'Công ty Cổ phần Hoàng Hữu Hoa', '0900000134', '0000000134', 'hoanghuuhoa@gmail.com', 'Chính thức', 'Tài chính - Ngân hàng', 'LARGE', '500-1000', 'https://hoanghuuhoa.vn', 'Số 134 Đường Nguyễn Văn Linh, Hải Châu, Đà Nẵng', 'Miền Trung', 14, DATE_SUB(NOW(), INTERVAL 87 DAY), NOW()),
(135, 'Công ty Cổ phần Đinh Gia Yến', '0900000135', '0000000135', 'dinhgiayen@gmail.com', 'Chính thức', 'Bất động sản', 'MEDIUM', '100-500', 'https://dinhgiayen.vn', 'Số 135 Đường Nguyễn Văn Linh, Hải Châu, Đà Nẵng', 'Miền Trung', 15, DATE_SUB(NOW(), INTERVAL 86 DAY), NOW()),
(136, 'Công ty Cổ phần Dương Đức Bình', '0900000136', '0000000136', 'duongducbinh@gmail.com', 'Chính thức', 'Bán lẻ - Tiêu dùng', 'SMALL', '10-50', 'https://duongducbinh.vn', 'Số 136 Đường Nguyễn Văn Linh, Hải Châu, Đà Nẵng', 'Miền Trung', 13, DATE_SUB(NOW(), INTERVAL 85 DAY), NOW()),
(137, 'Công ty Cổ phần Nông Tuấn Tiến', '0900000137', '0000000137', 'nongtuantien@gmail.com', 'Chính thức', 'Y tế - Dược phẩm', 'ENTERPRISE', '1000+', 'https://nongtuantien.vn', 'Số 137 Đường Nguyễn Văn Linh, Hải Châu, Đà Nẵng', 'Miền Trung', 14, DATE_SUB(NOW(), INTERVAL 84 DAY), NOW()),
(138, 'Công ty Cổ phần Phạm Thị Bách', '0900000138', '0000000138', 'phamthibach@gmail.com', 'Chính thức', 'Sản xuất - Công nghiệp', 'LARGE', '500-1000', 'https://phamthibach.vn', 'Số 138 Đường Nguyễn Văn Linh, Hải Châu, Đà Nẵng', 'Miền Trung', 15, DATE_SUB(NOW(), INTERVAL 83 DAY), NOW()),
(139, 'Công ty Cổ phần Hoàng Tuấn Lan', '0900000139', '0000000139', 'hoangtuanlan@gmail.com', 'Chính thức', 'Vận tải - Lữ hành', 'MEDIUM', '100-500', 'https://hoangtuanlan.vn', 'Số 139 Đường Nguyễn Văn Linh, Hải Châu, Đà Nẵng', 'Miền Trung', 13, DATE_SUB(NOW(), INTERVAL 82 DAY), NOW()),
(140, 'Công ty Cổ phần Đoàn Minh Tiến', '0900000140', '0000000140', 'doanminhtien@gmail.com', 'Chính thức', 'Giáo dục & Đào tạo', 'SMALL', '10-50', 'https://doanminhtien.vn', 'Số 140 Đường Nguyễn Văn Linh, Hải Châu, Đà Nẵng', 'Miền Trung', 14, DATE_SUB(NOW(), INTERVAL 81 DAY), NOW()),
(141, 'Công ty Cổ phần Lương Văn Châu', '0900000141', '0000000141', 'luongvanchau@gmail.com', 'Chính thức', 'Công nghệ thông tin', 'ENTERPRISE', '1000+', 'https://luongvanchau.vn', 'Số 141 Đường Nguyễn Văn Linh, Hải Châu, Đà Nẵng', 'Miền Trung', 15, DATE_SUB(NOW(), INTERVAL 80 DAY), NOW()),
(142, 'Công ty Cổ phần Lường Anh Tiến', '0900000142', '0000000142', 'luonganhtien@gmail.com', 'Chính thức', 'Tài chính - Ngân hàng', 'LARGE', '500-1000', 'https://luonganhtien.vn', 'Số 142 Đường Nguyễn Văn Linh, Hải Châu, Đà Nẵng', 'Miền Trung', 13, DATE_SUB(NOW(), INTERVAL 79 DAY), NOW()),
(143, 'Công ty Cổ phần Đoàn Văn Kiên', '0900000143', '0000000143', 'doanvankien@gmail.com', 'Chính thức', 'Bất động sản', 'MEDIUM', '100-500', 'https://doanvankien.vn', 'Số 143 Đường Nguyễn Văn Linh, Hải Châu, Đà Nẵng', 'Miền Trung', 14, DATE_SUB(NOW(), INTERVAL 78 DAY), NOW()),
(144, 'Công ty Cổ phần Tạ Hoài Yến', '0900000144', '0000000144', 'tahoaiyen@gmail.com', 'Chính thức', 'Bán lẻ - Tiêu dùng', 'SMALL', '10-50', 'https://tahoaiyen.vn', 'Số 144 Đường Nguyễn Văn Linh, Hải Châu, Đà Nẵng', 'Miền Trung', 15, DATE_SUB(NOW(), INTERVAL 77 DAY), NOW()),
(145, 'Công ty Cổ phần Cao Thị Thảo', '0900000145', '0000000145', 'caothithao@gmail.com', 'Chính thức', 'Y tế - Dược phẩm', 'ENTERPRISE', '1000+', 'https://caothithao.vn', 'Số 145 Đường Nguyễn Văn Linh, Hải Châu, Đà Nẵng', 'Miền Trung', 13, DATE_SUB(NOW(), INTERVAL 76 DAY), NOW()),
(146, 'Công ty Cổ phần Chu Phương Yến', '0900000146', '0000000146', 'chuphuongyen@gmail.com', 'Tiềm năng', 'Sản xuất - Công nghiệp', 'LARGE', '500-1000', 'https://chuphuongyen.vn', 'Số 146 Đường Nguyễn Văn Linh, Hải Châu, Đà Nẵng', 'Miền Trung', 14, DATE_SUB(NOW(), INTERVAL 75 DAY), NOW()),
(147, 'Công ty Cổ phần Lương Đình Tú', '0900000147', '0000000147', 'luongdinhtu@gmail.com', 'Tiềm năng', 'Vận tải - Lữ hành', 'MEDIUM', '100-500', 'https://luongdinhtu.vn', 'Số 147 Đường Nguyễn Văn Linh, Hải Châu, Đà Nẵng', 'Miền Trung', 15, DATE_SUB(NOW(), INTERVAL 74 DAY), NOW()),
(148, 'Công ty Cổ phần Hà Đình Bình', '0900000148', '0000000148', 'hadinhbinh@gmail.com', 'Tiềm năng', 'Giáo dục & Đào tạo', 'SMALL', '10-50', 'https://hadinhbinh.vn', 'Số 148 Đường Nguyễn Văn Linh, Hải Châu, Đà Nẵng', 'Miền Trung', 13, DATE_SUB(NOW(), INTERVAL 73 DAY), NOW()),
(149, 'Công ty Cổ phần Lý Bảo Duy', '0900000149', '0000000149', 'lybaoduy@gmail.com', 'Tiềm năng', 'Công nghệ thông tin', 'ENTERPRISE', '1000+', 'https://lybaoduy.vn', 'Số 149 Đường Nguyễn Văn Linh, Hải Châu, Đà Nẵng', 'Miền Trung', 14, DATE_SUB(NOW(), INTERVAL 72 DAY), NOW()),
(150, 'Công ty Cổ phần Vũ Công Nhi', '0900000150', '0000000150', 'vucongnhi@gmail.com', 'Tiềm năng', 'Tài chính - Ngân hàng', 'LARGE', '500-1000', 'https://vucongnhi.vn', 'Số 150 Đường Nguyễn Văn Linh, Hải Châu, Đà Nẵng', 'Miền Trung', 15, DATE_SUB(NOW(), INTERVAL 71 DAY), NOW()),
(151, 'Công ty Cổ phần Đặng Ngọc Bách', '0900000151', '0000000151', 'dangngocbach@gmail.com', 'Tiềm năng', 'Bất động sản', 'MEDIUM', '100-500', 'https://dangngocbach.vn', 'Số 151 Đường Nguyễn Văn Linh, Hải Châu, Đà Nẵng', 'Miền Trung', 13, DATE_SUB(NOW(), INTERVAL 70 DAY), NOW()),
(152, 'Công ty Cổ phần Mai Bảo Vinh', '0900000152', '0000000152', 'maibaovinh@gmail.com', 'Tiềm năng', 'Bán lẻ - Tiêu dùng', 'SMALL', '10-50', 'https://maibaovinh.vn', 'Số 152 Đường Nguyễn Văn Linh, Hải Châu, Đà Nẵng', 'Miền Trung', 14, DATE_SUB(NOW(), INTERVAL 69 DAY), NOW()),
(153, 'Công ty Cổ phần Hồ Xuân Thắng', '0900000153', '0000000153', 'hoxuanthang@gmail.com', 'Tiềm năng', 'Y tế - Dược phẩm', 'ENTERPRISE', '1000+', 'https://hoxuanthang.vn', 'Số 153 Đường Nguyễn Văn Linh, Hải Châu, Đà Nẵng', 'Miền Trung', 15, DATE_SUB(NOW(), INTERVAL 68 DAY), NOW()),
(154, 'Công ty Cổ phần Hồ Anh Nhật', '0900000154', '0000000154', 'hoanhnhat@gmail.com', 'Tiềm năng', 'Sản xuất - Công nghiệp', 'LARGE', '500-1000', 'https://hoanhnhat.vn', 'Số 154 Đường Nguyễn Văn Linh, Hải Châu, Đà Nẵng', 'Miền Trung', 13, DATE_SUB(NOW(), INTERVAL 67 DAY), NOW()),
(155, 'Công ty Cổ phần Phạm Tuấn Tùng', '0900000155', '0000000155', 'phamtuantung@gmail.com', 'Tiềm năng', 'Vận tải - Lữ hành', 'MEDIUM', '100-500', 'https://phamtuantung.vn', 'Số 155 Đường Nguyễn Văn Linh, Hải Châu, Đà Nẵng', 'Miền Trung', 14, DATE_SUB(NOW(), INTERVAL 66 DAY), NOW()),
(156, 'Công ty Cổ phần Chu Hữu Ngân', '0900000156', '0000000156', 'chuhuungan@gmail.com', 'Tiềm năng', 'Giáo dục & Đào tạo', 'SMALL', '10-50', 'https://chuhuungan.vn', 'Số 156 Đại lộ Nguyễn Huệ, Quận 1, TP. Hồ Chí Minh', 'Miền Nam', 16, DATE_SUB(NOW(), INTERVAL 65 DAY), NOW()),
(157, 'Công ty Cổ phần Đặng Đức Việt', '0900000157', '0000000157', 'dangducviet@gmail.com', 'Tiềm năng', 'Công nghệ thông tin', 'ENTERPRISE', '1000+', 'https://dangducviet.vn', 'Số 157 Đại lộ Nguyễn Huệ, Quận 1, TP. Hồ Chí Minh', 'Miền Nam', 17, DATE_SUB(NOW(), INTERVAL 64 DAY), NOW()),
(158, 'Công ty Cổ phần Hoàng Phương Lâm', '0900000158', '0000000158', 'hoangphuonglam@gmail.com', 'Tiềm năng', 'Tài chính - Ngân hàng', 'LARGE', '500-1000', 'https://hoangphuonglam.vn', 'Số 158 Đại lộ Nguyễn Huệ, Quận 1, TP. Hồ Chí Minh', 'Miền Nam', 18, DATE_SUB(NOW(), INTERVAL 63 DAY), NOW()),
(159, 'Công ty Cổ phần Mai Minh Duy', '0900000159', '0000000159', 'maiminhduy@gmail.com', 'Tiềm năng', 'Bất động sản', 'MEDIUM', '100-500', 'https://maiminhduy.vn', 'Số 159 Đại lộ Nguyễn Huệ, Quận 1, TP. Hồ Chí Minh', 'Miền Nam', 16, DATE_SUB(NOW(), INTERVAL 62 DAY), NOW()),
(160, 'Công ty Cổ phần Ngô Ngọc Minh', '0900000160', '0000000160', 'ngongocminh@gmail.com', 'Tiềm năng', 'Bán lẻ - Tiêu dùng', 'SMALL', '10-50', 'https://ngongocminh.vn', 'Số 160 Đại lộ Nguyễn Huệ, Quận 1, TP. Hồ Chí Minh', 'Miền Nam', 17, DATE_SUB(NOW(), INTERVAL 61 DAY), NOW()),
(161, 'Công ty Cổ phần Nông Xuân Trinh', '0900000161', '0000000161', 'nongxuantrinh@gmail.com', 'Tiềm năng', 'Y tế - Dược phẩm', 'ENTERPRISE', '1000+', 'https://nongxuantrinh.vn', 'Số 161 Đại lộ Nguyễn Huệ, Quận 1, TP. Hồ Chí Minh', 'Miền Nam', 18, DATE_SUB(NOW(), INTERVAL 60 DAY), NOW()),
(162, 'Công ty Cổ phần Phan Đình Hương', '0900000162', '0000000162', 'phandinhhuong@gmail.com', 'Tiềm năng', 'Sản xuất - Công nghiệp', 'LARGE', '500-1000', 'https://phandinhhuong.vn', 'Số 162 Đại lộ Nguyễn Huệ, Quận 1, TP. Hồ Chí Minh', 'Miền Nam', 16, DATE_SUB(NOW(), INTERVAL 59 DAY), NOW()),
(163, 'Công ty Cổ phần Hà Bảo Nam', '0900000163', '0000000163', 'habaonam@gmail.com', 'Tiềm năng', 'Vận tải - Lữ hành', 'MEDIUM', '100-500', 'https://habaonam.vn', 'Số 163 Đại lộ Nguyễn Huệ, Quận 1, TP. Hồ Chí Minh', 'Miền Nam', 17, DATE_SUB(NOW(), INTERVAL 58 DAY), NOW()),
(164, 'Công ty Cổ phần Phạm Minh Hiếu', '0900000164', '0000000164', 'phamminhhieu@gmail.com', 'Tiềm năng', 'Giáo dục & Đào tạo', 'SMALL', '10-50', 'https://phamminhhieu.vn', 'Số 164 Đại lộ Nguyễn Huệ, Quận 1, TP. Hồ Chí Minh', 'Miền Nam', 18, DATE_SUB(NOW(), INTERVAL 57 DAY), NOW()),
(165, 'Công ty Cổ phần Đoàn Văn Hoa', '0900000165', '0000000165', 'doanvanhoa@gmail.com', 'Tiềm năng', 'Công nghệ thông tin', 'ENTERPRISE', '1000+', 'https://doanvanhoa.vn', 'Số 165 Đại lộ Nguyễn Huệ, Quận 1, TP. Hồ Chí Minh', 'Miền Nam', 16, DATE_SUB(NOW(), INTERVAL 56 DAY), NOW()),
(166, 'Công ty Cổ phần Lường Ngọc Linh', '0900000166', '0000000166', 'luongngoclinh@gmail.com', 'Tiềm năng', 'Tài chính - Ngân hàng', 'LARGE', '500-1000', 'https://luongngoclinh.vn', 'Số 166 Đại lộ Nguyễn Huệ, Quận 1, TP. Hồ Chí Minh', 'Miền Nam', 17, DATE_SUB(NOW(), INTERVAL 55 DAY), NOW()),
(167, 'Công ty Cổ phần Đỗ Minh Bách', '0900000167', '0000000167', 'dominhbach@gmail.com', 'Tiềm năng', 'Bất động sản', 'MEDIUM', '100-500', 'https://dominhbach.vn', 'Số 167 Đại lộ Nguyễn Huệ, Quận 1, TP. Hồ Chí Minh', 'Miền Nam', 18, DATE_SUB(NOW(), INTERVAL 54 DAY), NOW()),
(168, 'Công ty Cổ phần Ngô Đình Lâm', '0900000168', '0000000168', 'ngodinhlam@gmail.com', 'Tiềm năng', 'Bán lẻ - Tiêu dùng', 'SMALL', '10-50', 'https://ngodinhlam.vn', 'Số 168 Đại lộ Nguyễn Huệ, Quận 1, TP. Hồ Chí Minh', 'Miền Nam', 16, DATE_SUB(NOW(), INTERVAL 53 DAY), NOW()),
(169, 'Công ty Cổ phần Phạm Hữu Vy', '0900000169', '0000000169', 'phamhuuvy@gmail.com', 'Tiềm năng', 'Y tế - Dược phẩm', 'ENTERPRISE', '1000+', 'https://phamhuuvy.vn', 'Số 169 Đại lộ Nguyễn Huệ, Quận 1, TP. Hồ Chí Minh', 'Miền Nam', 17, DATE_SUB(NOW(), INTERVAL 52 DAY), NOW()),
(170, 'Công ty Cổ phần Trịnh Thị Hùng', '0900000170', '0000000170', 'trinhthihung@gmail.com', 'Tiềm năng', 'Sản xuất - Công nghiệp', 'LARGE', '500-1000', 'https://trinhthihung.vn', 'Số 170 Đại lộ Nguyễn Huệ, Quận 1, TP. Hồ Chí Minh', 'Miền Nam', 18, DATE_SUB(NOW(), INTERVAL 51 DAY), NOW()),
(171, 'Công ty Cổ phần Đinh Phương Trí', '0900000171', '0000000171', 'dinhphuongtri@gmail.com', 'Ngừng hợp tác', 'Vận tải - Lữ hành', 'MEDIUM', '100-500', 'https://dinhphuongtri.vn', 'Số 171 Đại lộ Nguyễn Huệ, Quận 1, TP. Hồ Chí Minh', 'Miền Nam', 16, DATE_SUB(NOW(), INTERVAL 50 DAY), NOW()),
(172, 'Công ty Cổ phần Phan Phương Lâm', '0900000172', '0000000172', 'phanphuonglam@gmail.com', 'Ngừng hợp tác', 'Giáo dục & Đào tạo', 'SMALL', '10-50', 'https://phanphuonglam.vn', 'Số 172 Đại lộ Nguyễn Huệ, Quận 1, TP. Hồ Chí Minh', 'Miền Nam', 17, DATE_SUB(NOW(), INTERVAL 49 DAY), NOW()),
(173, 'Công ty Cổ phần Dương Thị Nhân', '0900000173', '0000000173', 'duongthinhan@gmail.com', 'Ngừng hợp tác', 'Công nghệ thông tin', 'ENTERPRISE', '1000+', 'https://duongthinhan.vn', 'Số 173 Đại lộ Nguyễn Huệ, Quận 1, TP. Hồ Chí Minh', 'Miền Nam', 18, DATE_SUB(NOW(), INTERVAL 48 DAY), NOW()),
(174, 'Công ty Cổ phần Đỗ Văn Quỳnh', '0900000174', '0000000174', 'dovanquynh@gmail.com', 'Ngừng hợp tác', 'Tài chính - Ngân hàng', 'LARGE', '500-1000', 'https://dovanquynh.vn', 'Số 174 Đại lộ Nguyễn Huệ, Quận 1, TP. Hồ Chí Minh', 'Miền Nam', 16, DATE_SUB(NOW(), INTERVAL 47 DAY), NOW()),
(175, 'Công ty Cổ phần Nguyễn Đức Liên', '0900000175', '0000000175', 'nguyenduclien@gmail.com', 'Ngừng hợp tác', 'Bất động sản', 'MEDIUM', '100-500', 'https://nguyenduclien.vn', 'Số 175 Đại lộ Nguyễn Huệ, Quận 1, TP. Hồ Chí Minh', 'Miền Nam', 17, DATE_SUB(NOW(), INTERVAL 46 DAY), NOW()),
(176, 'Công ty Cổ phần Nguyễn Minh Lộc', '0900000176', '0000000176', 'nguyenminhloc@gmail.com', 'Ngừng hợp tác', 'Bán lẻ - Tiêu dùng', 'SMALL', '10-50', 'https://nguyenminhloc.vn', 'Số 176 Đại lộ Nguyễn Huệ, Quận 1, TP. Hồ Chí Minh', 'Miền Nam', 18, DATE_SUB(NOW(), INTERVAL 45 DAY), NOW()),
(177, 'Công ty Cổ phần Chu Văn My', '0900000177', '0000000177', 'chuvanmy@gmail.com', 'Ngừng hợp tác', 'Y tế - Dược phẩm', 'ENTERPRISE', '1000+', 'https://chuvanmy.vn', 'Số 177 Đại lộ Nguyễn Huệ, Quận 1, TP. Hồ Chí Minh', 'Miền Nam', 16, DATE_SUB(NOW(), INTERVAL 44 DAY), NOW()),
(178, 'Công ty Cổ phần Lê Thị Huy', '0900000178', '0000000178', 'lethihuy@gmail.com', 'Ngừng hợp tác', 'Sản xuất - Công nghiệp', 'LARGE', '500-1000', 'https://lethihuy.vn', 'Số 178 Đại lộ Nguyễn Huệ, Quận 1, TP. Hồ Chí Minh', 'Miền Nam', 17, DATE_SUB(NOW(), INTERVAL 43 DAY), NOW())
ON DUPLICATE KEY UPDATE
    customer_name = VALUES(customer_name),
    phone = VALUES(phone),
    tax_code = VALUES(tax_code),
    email = VALUES(email),
    status = VALUES(status),
    industry = VALUES(industry),
    website = VALUES(website),
    owner_id = VALUES(owner_id);

-- =============================================================================
-- 20. BẢNG NGƯỜI LIÊN HỆ (contacts) - 78 ĐẦU MỐI CHÍNH & VAI TRÒ QUYẾT ĐỊNH MUA
-- Toàn bộ danh tính người liên hệ lấy CHÍNH XÁC từ 78 khách hàng (không có người thứ 101)
-- =============================================================================
INSERT INTO contacts (contact_id, customer_id, full_name, position, title, email, phone, buying_role, is_primary, created_at) VALUES
(8001, 101, 'Mai Ngọc Phúc', 'Tổng Giám đốc', 'CEO', 'maingocphuc@gmail.com', '0900000101', 'DECIDER', 1, DATE_SUB(NOW(), INTERVAL 90 DAY)),
(8002, 102, 'Lương Bảo Hùng', 'Giám đốc Điều hành', 'COO', 'luongbaohung@gmail.com', '0900000102', 'DECIDER', 1, DATE_SUB(NOW(), INTERVAL 90 DAY)),
(8003, 103, 'Mai Khánh Thảo', 'Giám đốc Công nghệ', 'CTO', 'maikhanhthao@gmail.com', '0900000103', 'INFLUENCER', 1, DATE_SUB(NOW(), INTERVAL 90 DAY)),
(8004, 104, 'Chu Công Tú', 'Giám đốc Tài chính', 'CFO', 'chucongtu@gmail.com', '0900000104', 'END_USER', 1, DATE_SUB(NOW(), INTERVAL 90 DAY)),
(8005, 105, 'Nông Hoài Thủy', 'Trưởng phòng Mua sắm', 'TP Mua hàng', 'nonghoaithuy@gmail.com', '0900000105', 'BLOCKER', 1, DATE_SUB(NOW(), INTERVAL 90 DAY)),
(8006, 106, 'Đoàn Văn Bách', 'Trưởng phòng CNTT', 'TP CNTT', 'doanvanbach@gmail.com', '0900000106', 'DECIDER', 1, DATE_SUB(NOW(), INTERVAL 90 DAY)),
(8007, 107, 'Hoàng Văn Thảo', 'Trưởng phòng Kinh doanh', 'TP Kinh doanh', 'hoangvanthao@gmail.com', '0900000107', 'DECIDER', 1, DATE_SUB(NOW(), INTERVAL 90 DAY)),
(8008, 108, 'Hồ Thanh Trí', 'Tổng Giám đốc', 'CEO', 'hothanhtri@gmail.com', '0900000108', 'INFLUENCER', 1, DATE_SUB(NOW(), INTERVAL 90 DAY)),
(8009, 109, 'Lý Văn Minh', 'Giám đốc Điều hành', 'COO', 'lyvanminh@gmail.com', '0900000109', 'END_USER', 1, DATE_SUB(NOW(), INTERVAL 90 DAY)),
(8010, 110, 'Lường Phương Linh', 'Giám đốc Công nghệ', 'CTO', 'luongphuonglinh@gmail.com', '0900000110', 'BLOCKER', 1, DATE_SUB(NOW(), INTERVAL 90 DAY)),
(8011, 111, 'Trịnh Đức Hoa', 'Giám đốc Tài chính', 'CFO', 'trinhduchoa@gmail.com', '0900000111', 'DECIDER', 1, DATE_SUB(NOW(), INTERVAL 90 DAY)),
(8012, 112, 'Hà Minh Vy', 'Trưởng phòng Mua sắm', 'TP Mua hàng', 'haminhvy@gmail.com', '0900000112', 'DECIDER', 1, DATE_SUB(NOW(), INTERVAL 90 DAY)),
(8013, 113, 'Lương Văn Hương', 'Trưởng phòng CNTT', 'TP CNTT', 'luongvanhuong@gmail.com', '0900000113', 'INFLUENCER', 1, DATE_SUB(NOW(), INTERVAL 90 DAY)),
(8014, 114, 'Trần Hoài Thu', 'Trưởng phòng Kinh doanh', 'TP Kinh doanh', 'tranhoaithu@gmail.com', '0900000114', 'END_USER', 1, DATE_SUB(NOW(), INTERVAL 90 DAY)),
(8015, 115, 'Tạ Ngọc Liên', 'Tổng Giám đốc', 'CEO', 'tangoclien@gmail.com', '0900000115', 'BLOCKER', 1, DATE_SUB(NOW(), INTERVAL 90 DAY)),
(8016, 116, 'Ngô Quang Lộc', 'Giám đốc Điều hành', 'COO', 'ngoquangloc@gmail.com', '0900000116', 'DECIDER', 1, DATE_SUB(NOW(), INTERVAL 90 DAY)),
(8017, 117, 'Trần Công Nga', 'Giám đốc Công nghệ', 'CTO', 'trancongnga@gmail.com', '0900000117', 'DECIDER', 1, DATE_SUB(NOW(), INTERVAL 90 DAY)),
(8018, 118, 'Đỗ Thị Bình', 'Giám đốc Tài chính', 'CFO', 'dothibinh@gmail.com', '0900000118', 'INFLUENCER', 1, DATE_SUB(NOW(), INTERVAL 90 DAY)),
(8019, 119, 'Dương Thanh Linh', 'Trưởng phòng Mua sắm', 'TP Mua hàng', 'duongthanhlinh@gmail.com', '0900000119', 'END_USER', 1, DATE_SUB(NOW(), INTERVAL 90 DAY)),
(8020, 120, 'Chu Ngọc Vy', 'Trưởng phòng CNTT', 'TP CNTT', 'chungocvy@gmail.com', '0900000120', 'BLOCKER', 1, DATE_SUB(NOW(), INTERVAL 90 DAY)),
(8021, 121, 'Trịnh Anh Thắng', 'Trưởng phòng Kinh doanh', 'TP Kinh doanh', 'trinhanhthang@gmail.com', '0900000121', 'DECIDER', 1, DATE_SUB(NOW(), INTERVAL 90 DAY)),
(8022, 122, 'Chu Minh Khang', 'Tổng Giám đốc', 'CEO', 'chuminhkhang@gmail.com', '0900000122', 'DECIDER', 1, DATE_SUB(NOW(), INTERVAL 90 DAY)),
(8023, 123, 'Phạm Công Liên', 'Giám đốc Điều hành', 'COO', 'phamconglien@gmail.com', '0900000123', 'INFLUENCER', 1, DATE_SUB(NOW(), INTERVAL 90 DAY)),
(8024, 124, 'Hồ Tuấn Phương', 'Giám đốc Công nghệ', 'CTO', 'hotuanphuong@gmail.com', '0900000124', 'END_USER', 1, DATE_SUB(NOW(), INTERVAL 90 DAY)),
(8025, 125, 'Cao Văn Long', 'Giám đốc Tài chính', 'CFO', 'caovanlong@gmail.com', '0900000125', 'BLOCKER', 1, DATE_SUB(NOW(), INTERVAL 90 DAY)),
(8026, 126, 'Phan Tuấn Khôi', 'Trưởng phòng Mua sắm', 'TP Mua hàng', 'phantuankhoi@gmail.com', '0900000126', 'DECIDER', 1, DATE_SUB(NOW(), INTERVAL 90 DAY)),
(8027, 127, 'Nguyễn Hữu Trinh', 'Trưởng phòng CNTT', 'TP CNTT', 'nguyenhuutrinh@gmail.com', '0900000127', 'DECIDER', 1, DATE_SUB(NOW(), INTERVAL 90 DAY)),
(8028, 128, 'Chu Hữu Liên', 'Trưởng phòng Kinh doanh', 'TP Kinh doanh', 'chuhuulien@gmail.com', '0900000128', 'INFLUENCER', 1, DATE_SUB(NOW(), INTERVAL 90 DAY)),
(8029, 129, 'Phan Xuân Ngân', 'Tổng Giám đốc', 'CEO', 'phanxuanngan@gmail.com', '0900000129', 'END_USER', 1, DATE_SUB(NOW(), INTERVAL 90 DAY)),
(8030, 130, 'Lường Hoài Thắng', 'Giám đốc Điều hành', 'COO', 'luonghoaithang@gmail.com', '0900000130', 'BLOCKER', 1, DATE_SUB(NOW(), INTERVAL 90 DAY)),
(8031, 131, 'Hồ Xuân Huy', 'Giám đốc Công nghệ', 'CTO', 'hoxuanhuy@gmail.com', '0900000131', 'DECIDER', 1, DATE_SUB(NOW(), INTERVAL 90 DAY)),
(8032, 132, 'Hồ Khánh Vy', 'Giám đốc Tài chính', 'CFO', 'hokhanhvy@gmail.com', '0900000132', 'DECIDER', 1, DATE_SUB(NOW(), INTERVAL 90 DAY)),
(8033, 133, 'Nguyễn Công Tâm', 'Trưởng phòng Mua sắm', 'TP Mua hàng', 'nguyencongtam@gmail.com', '0900000133', 'INFLUENCER', 1, DATE_SUB(NOW(), INTERVAL 90 DAY)),
(8034, 134, 'Hoàng Hữu Hoa', 'Trưởng phòng CNTT', 'TP CNTT', 'hoanghuuhoa@gmail.com', '0900000134', 'END_USER', 1, DATE_SUB(NOW(), INTERVAL 90 DAY)),
(8035, 135, 'Đinh Gia Yến', 'Trưởng phòng Kinh doanh', 'TP Kinh doanh', 'dinhgiayen@gmail.com', '0900000135', 'BLOCKER', 1, DATE_SUB(NOW(), INTERVAL 90 DAY)),
(8036, 136, 'Dương Đức Bình', 'Tổng Giám đốc', 'CEO', 'duongducbinh@gmail.com', '0900000136', 'DECIDER', 1, DATE_SUB(NOW(), INTERVAL 90 DAY)),
(8037, 137, 'Nông Tuấn Tiến', 'Giám đốc Điều hành', 'COO', 'nongtuantien@gmail.com', '0900000137', 'DECIDER', 1, DATE_SUB(NOW(), INTERVAL 90 DAY)),
(8038, 138, 'Phạm Thị Bách', 'Giám đốc Công nghệ', 'CTO', 'phamthibach@gmail.com', '0900000138', 'INFLUENCER', 1, DATE_SUB(NOW(), INTERVAL 90 DAY)),
(8039, 139, 'Hoàng Tuấn Lan', 'Giám đốc Tài chính', 'CFO', 'hoangtuanlan@gmail.com', '0900000139', 'END_USER', 1, DATE_SUB(NOW(), INTERVAL 90 DAY)),
(8040, 140, 'Đoàn Minh Tiến', 'Trưởng phòng Mua sắm', 'TP Mua hàng', 'doanminhtien@gmail.com', '0900000140', 'BLOCKER', 1, DATE_SUB(NOW(), INTERVAL 90 DAY)),
(8041, 141, 'Lương Văn Châu', 'Trưởng phòng CNTT', 'TP CNTT', 'luongvanchau@gmail.com', '0900000141', 'DECIDER', 1, DATE_SUB(NOW(), INTERVAL 90 DAY)),
(8042, 142, 'Lường Anh Tiến', 'Trưởng phòng Kinh doanh', 'TP Kinh doanh', 'luonganhtien@gmail.com', '0900000142', 'DECIDER', 1, DATE_SUB(NOW(), INTERVAL 90 DAY)),
(8043, 143, 'Đoàn Văn Kiên', 'Tổng Giám đốc', 'CEO', 'doanvankien@gmail.com', '0900000143', 'INFLUENCER', 1, DATE_SUB(NOW(), INTERVAL 90 DAY)),
(8044, 144, 'Tạ Hoài Yến', 'Giám đốc Điều hành', 'COO', 'tahoaiyen@gmail.com', '0900000144', 'END_USER', 1, DATE_SUB(NOW(), INTERVAL 90 DAY)),
(8045, 145, 'Cao Thị Thảo', 'Giám đốc Công nghệ', 'CTO', 'caothithao@gmail.com', '0900000145', 'BLOCKER', 1, DATE_SUB(NOW(), INTERVAL 90 DAY)),
(8046, 146, 'Chu Phương Yến', 'Giám đốc Tài chính', 'CFO', 'chuphuongyen@gmail.com', '0900000146', 'DECIDER', 1, DATE_SUB(NOW(), INTERVAL 90 DAY)),
(8047, 147, 'Lương Đình Tú', 'Trưởng phòng Mua sắm', 'TP Mua hàng', 'luongdinhtu@gmail.com', '0900000147', 'DECIDER', 1, DATE_SUB(NOW(), INTERVAL 90 DAY)),
(8048, 148, 'Hà Đình Bình', 'Trưởng phòng CNTT', 'TP CNTT', 'hadinhbinh@gmail.com', '0900000148', 'INFLUENCER', 1, DATE_SUB(NOW(), INTERVAL 90 DAY)),
(8049, 149, 'Lý Bảo Duy', 'Trưởng phòng Kinh doanh', 'TP Kinh doanh', 'lybaoduy@gmail.com', '0900000149', 'END_USER', 1, DATE_SUB(NOW(), INTERVAL 90 DAY)),
(8050, 150, 'Vũ Công Nhi', 'Tổng Giám đốc', 'CEO', 'vucongnhi@gmail.com', '0900000150', 'BLOCKER', 1, DATE_SUB(NOW(), INTERVAL 90 DAY)),
(8051, 151, 'Đặng Ngọc Bách', 'Giám đốc Điều hành', 'COO', 'dangngocbach@gmail.com', '0900000151', 'DECIDER', 1, DATE_SUB(NOW(), INTERVAL 90 DAY)),
(8052, 152, 'Mai Bảo Vinh', 'Giám đốc Công nghệ', 'CTO', 'maibaovinh@gmail.com', '0900000152', 'DECIDER', 1, DATE_SUB(NOW(), INTERVAL 90 DAY)),
(8053, 153, 'Hồ Xuân Thắng', 'Giám đốc Tài chính', 'CFO', 'hoxuanthang@gmail.com', '0900000153', 'INFLUENCER', 1, DATE_SUB(NOW(), INTERVAL 90 DAY)),
(8054, 154, 'Hồ Anh Nhật', 'Trưởng phòng Mua sắm', 'TP Mua hàng', 'hoanhnhat@gmail.com', '0900000154', 'END_USER', 1, DATE_SUB(NOW(), INTERVAL 90 DAY)),
(8055, 155, 'Phạm Tuấn Tùng', 'Trưởng phòng CNTT', 'TP CNTT', 'phamtuantung@gmail.com', '0900000155', 'BLOCKER', 1, DATE_SUB(NOW(), INTERVAL 90 DAY)),
(8056, 156, 'Chu Hữu Ngân', 'Trưởng phòng Kinh doanh', 'TP Kinh doanh', 'chuhuungan@gmail.com', '0900000156', 'DECIDER', 1, DATE_SUB(NOW(), INTERVAL 90 DAY)),
(8057, 157, 'Đặng Đức Việt', 'Tổng Giám đốc', 'CEO', 'dangducviet@gmail.com', '0900000157', 'DECIDER', 1, DATE_SUB(NOW(), INTERVAL 90 DAY)),
(8058, 158, 'Hoàng Phương Lâm', 'Giám đốc Điều hành', 'COO', 'hoangphuonglam@gmail.com', '0900000158', 'INFLUENCER', 1, DATE_SUB(NOW(), INTERVAL 90 DAY)),
(8059, 159, 'Mai Minh Duy', 'Giám đốc Công nghệ', 'CTO', 'maiminhduy@gmail.com', '0900000159', 'END_USER', 1, DATE_SUB(NOW(), INTERVAL 90 DAY)),
(8060, 160, 'Ngô Ngọc Minh', 'Giám đốc Tài chính', 'CFO', 'ngongocminh@gmail.com', '0900000160', 'BLOCKER', 1, DATE_SUB(NOW(), INTERVAL 90 DAY)),
(8061, 161, 'Nông Xuân Trinh', 'Trưởng phòng Mua sắm', 'TP Mua hàng', 'nongxuantrinh@gmail.com', '0900000161', 'DECIDER', 1, DATE_SUB(NOW(), INTERVAL 90 DAY)),
(8062, 162, 'Phan Đình Hương', 'Trưởng phòng CNTT', 'TP CNTT', 'phandinhhuong@gmail.com', '0900000162', 'DECIDER', 1, DATE_SUB(NOW(), INTERVAL 90 DAY)),
(8063, 163, 'Hà Bảo Nam', 'Trưởng phòng Kinh doanh', 'TP Kinh doanh', 'habaonam@gmail.com', '0900000163', 'INFLUENCER', 1, DATE_SUB(NOW(), INTERVAL 90 DAY)),
(8064, 164, 'Phạm Minh Hiếu', 'Tổng Giám đốc', 'CEO', 'phamminhhieu@gmail.com', '0900000164', 'END_USER', 1, DATE_SUB(NOW(), INTERVAL 90 DAY)),
(8065, 165, 'Đoàn Văn Hoa', 'Giám đốc Điều hành', 'COO', 'doanvanhoa@gmail.com', '0900000165', 'BLOCKER', 1, DATE_SUB(NOW(), INTERVAL 90 DAY)),
(8066, 166, 'Lường Ngọc Linh', 'Giám đốc Công nghệ', 'CTO', 'luongngoclinh@gmail.com', '0900000166', 'DECIDER', 1, DATE_SUB(NOW(), INTERVAL 90 DAY)),
(8067, 167, 'Đỗ Minh Bách', 'Giám đốc Tài chính', 'CFO', 'dominhbach@gmail.com', '0900000167', 'DECIDER', 1, DATE_SUB(NOW(), INTERVAL 90 DAY)),
(8068, 168, 'Ngô Đình Lâm', 'Trưởng phòng Mua sắm', 'TP Mua hàng', 'ngodinhlam@gmail.com', '0900000168', 'INFLUENCER', 1, DATE_SUB(NOW(), INTERVAL 90 DAY)),
(8069, 169, 'Phạm Hữu Vy', 'Trưởng phòng CNTT', 'TP CNTT', 'phamhuuvy@gmail.com', '0900000169', 'END_USER', 1, DATE_SUB(NOW(), INTERVAL 90 DAY)),
(8070, 170, 'Trịnh Thị Hùng', 'Trưởng phòng Kinh doanh', 'TP Kinh doanh', 'trinhthihung@gmail.com', '0900000170', 'BLOCKER', 1, DATE_SUB(NOW(), INTERVAL 90 DAY)),
(8071, 171, 'Đinh Phương Trí', 'Tổng Giám đốc', 'CEO', 'dinhphuongtri@gmail.com', '0900000171', 'DECIDER', 1, DATE_SUB(NOW(), INTERVAL 90 DAY)),
(8072, 172, 'Phan Phương Lâm', 'Giám đốc Điều hành', 'COO', 'phanphuonglam@gmail.com', '0900000172', 'DECIDER', 1, DATE_SUB(NOW(), INTERVAL 90 DAY)),
(8073, 173, 'Dương Thị Nhân', 'Giám đốc Công nghệ', 'CTO', 'duongthinhan@gmail.com', '0900000173', 'INFLUENCER', 1, DATE_SUB(NOW(), INTERVAL 90 DAY)),
(8074, 174, 'Đỗ Văn Quỳnh', 'Giám đốc Tài chính', 'CFO', 'dovanquynh@gmail.com', '0900000174', 'END_USER', 1, DATE_SUB(NOW(), INTERVAL 90 DAY)),
(8075, 175, 'Nguyễn Đức Liên', 'Trưởng phòng Mua sắm', 'TP Mua hàng', 'nguyenduclien@gmail.com', '0900000175', 'BLOCKER', 1, DATE_SUB(NOW(), INTERVAL 90 DAY)),
(8076, 176, 'Nguyễn Minh Lộc', 'Trưởng phòng CNTT', 'TP CNTT', 'nguyenminhloc@gmail.com', '0900000176', 'DECIDER', 1, DATE_SUB(NOW(), INTERVAL 90 DAY)),
(8077, 177, 'Chu Văn My', 'Trưởng phòng Kinh doanh', 'TP Kinh doanh', 'chuvanmy@gmail.com', '0900000177', 'DECIDER', 1, DATE_SUB(NOW(), INTERVAL 90 DAY)),
(8078, 178, 'Lê Thị Huy', 'Tổng Giám đốc', 'CEO', 'lethihuy@gmail.com', '0900000178', 'INFLUENCER', 1, DATE_SUB(NOW(), INTERVAL 90 DAY))
ON DUPLICATE KEY UPDATE
    full_name = VALUES(full_name),
    position = VALUES(position),
    title = VALUES(title),
    email = VALUES(email),
    phone = VALUES(phone),
    buying_role = VALUES(buying_role),
    is_primary = VALUES(is_primary);

-- =============================================================================
-- 21. BẢNG LỊCH SỬ CHUYỂN CÔNG TY (contact_company_history)
-- =============================================================================
INSERT INTO contact_company_history (history_id, contact_id, from_customer_id, to_customer_id, transferred_at, reason, transferred_by) VALUES
(1, 8001, 101, 102, DATE_SUB(NOW(), INTERVAL 30 DAY), 'Chuyển công tác từ Tập đoàn sang công ty con theo quyết định bổ nhiệm nhân sự cấp cao', 6),
(2, 8002, 102, 103, DATE_SUB(NOW(), INTERVAL 45 DAY), 'Điều động tăng cường quản lý khối tài chính cho đơn vị thành viên', 6),
(3, 8033, 133, 134, DATE_SUB(NOW(), INTERVAL 60 DAY), 'Chuyển công tác từ chi nhánh Đà Nẵng sang chi nhánh Huế', 13),
(4, 8056, 156, 157, DATE_SUB(NOW(), INTERVAL 20 DAY), 'Điều chuyển nhân sự quản lý cấp cao khu vực TP.HCM', 16)
ON DUPLICATE KEY UPDATE
    reason = VALUES(reason),
    transferred_at = VALUES(transferred_at);

-- =============================================================================
-- 22. BẢNG QUAN HỆ TẬP ĐOÀN CÔNG TY MẸ - CON (customer_relationships)
-- =============================================================================
INSERT INTO customer_relationships (relationship_id, parent_customer_id, child_customer_id, relationship_type, created_at) VALUES
(1, 101, 102, 'SUBSIDIARY', NOW()),
(2, 101, 103, 'SUBSIDIARY', NOW()),
(3, 101, 104, 'BRANCH',     NOW()),
(4, 133, 134, 'SUBSIDIARY', NOW()),
(5, 133, 135, 'BRANCH',     NOW()),
(6, 156, 157, 'SUBSIDIARY', NOW()),
(7, 156, 158, 'MEMBER',     NOW())
ON DUPLICATE KEY UPDATE relationship_type = VALUES(relationship_type);

-- =============================================================================
-- 23. BẢNG LỊCH SỬ GỘP KHÁCH HÀNG (customer_merges)
-- =============================================================================
INSERT INTO customer_merges (merge_id, primary_customer_id, secondary_customer_id, merged_data, merged_by, created_at) VALUES
(1, 101, 102, '{"old_name":"Công ty Cổ phần Lương Bảo Hùng Holding","old_phone":"0901000102","note":"Gộp hồ sơ doanh nghiệp thành viên vào tập đoàn mẹ"}', 1, DATE_SUB(NOW(), INTERVAL 15 DAY)),
(2, 133, 134, '{"old_name":"Công ty Cổ phần Hà Minh Vy","old_phone":"0901000134","note":"Gộp hồ sơ khách hàng trùng lặp số điện thoại"}', 1, DATE_SUB(NOW(), INTERVAL 10 DAY))
ON DUPLICATE KEY UPDATE merged_data = VALUES(merged_data);

-- =============================================================================
-- 24. BẢNG GIÁ TRỊ TRƯỜNG TÙY CHỈNH (custom_field_values)
-- =============================================================================
INSERT INTO custom_field_values (value_id, field_id, entity_type, entity_id, field_value) VALUES
(1, 1, 'CUSTOMER', 101, 'Doanh nghiệp lớn (Hạng A)'),
(2, 2, 'CUSTOMER', 101, 'https://facebook.com/maingocphuctech'),
(3, 3, 'CUSTOMER', 101, '25000000'),
(4, 4, 'CUSTOMER', 101, 'SAP S/4HANA ERP'),
(5, 1, 'CUSTOMER', 133, 'Doanh nghiệp vừa (Hạng B)'),
(6, 3, 'CUSTOMER', 133, '8000000'),
(7, 4, 'CUSTOMER', 133, 'Oracle NetSuite'),
(8, 1, 'CUSTOMER', 156, 'Doanh nghiệp lớn (Hạng A)'),
(9, 3, 'CUSTOMER', 156, '15000000')
ON DUPLICATE KEY UPDATE field_value = VALUES(field_value);

-- =============================================================================
-- 25. BẢNG BÁO GIÁ (quotes) - ĐA DẠNG NGƯỜI SỞ HỮU THEO TEAM
-- =============================================================================
INSERT INTO quotes (quote_id, quote_number, owner_id) VALUES
(1,  'BG-2026-BAC-01', 6),
(2,  'BG-2026-BAC-02', 6),
(3,  'BG-2026-BAC-03', 7),
(4,  'BG-2026-BAC-04', 11),
(5,  'BG-2026-TRUNG-01', 13),
(6,  'BG-2026-TRUNG-02', 14),
(7,  'BG-2026-NAM-01', 16),
(8,  'BG-2026-NAM-02', 17),
(9,  'BG-2026-LEAD-01', 3),
(10, 'BG-2026-LEAD-02', 5)
ON DUPLICATE KEY UPDATE quote_number = VALUES(quote_number);

-- =============================================================================
-- 26. BẢNG YÊU CẦU HỖ TRỢ SAU BÁN (support_requests) - ĐỦ 4 TRẠNG THÁI & 4 MỨC ĐỘ
-- =============================================================================
INSERT INTO support_requests (request_id, customer_id, title, description, priority, status, assignee_id, created_by, created_at, updated_at) VALUES
(1,  101, 'Hướng dẫn cấu hình phân quyền dữ liệu My/Team/All', 'Khách hàng Mai Ngọc Phúc cần hỗ trợ thiết lập phân quyền dữ liệu cho 50 tài khoản kinh doanh.', 'LOW',    'RESOLVED',    9,  6,  DATE_SUB(NOW(), INTERVAL 15 DAY), NOW()),
(2,  101, 'Khẩn cấp: Gián đoạn kết nối cổng thanh toán trực tuyến', 'Cổng thanh toán điện tử của khách hàng 101 gặp sự cố timeout trong giờ cao điểm.',         'URGENT', 'RESOLVED',    9,  6,  DATE_SUB(NOW(), INTERVAL 5 DAY),  NOW()),
(3,  102, 'Tối ưu hóa tốc độ xuất báo cáo doanh số Excel',          'Khách hàng 102 phản ánh xuất báo cáo 10.000 dòng mất hơn 2 phút.',                         'MEDIUM', 'IN_PROGRESS', 21, 6,  DATE_SUB(NOW(), INTERVAL 3 DAY),  NOW()),
(4,  103, 'Yêu cầu tích hợp Webhook đồng bộ Lead từ Website',       'Cần bàn giao tài liệu API và hướng dẫn dev phía khách hàng tích hợp webhook nhận lead.',   'MEDIUM', 'OPEN',        21, 6,  DATE_SUB(NOW(), INTERVAL 1 DAY),  NOW()),
(5,  133, 'Lỗi hiển thị biểu đồ Dashboard hiệu suất bán hàng',      'Biểu đồ hình cột tại Dashboard không cập nhật số liệu của quý hiện tại.',                   'HIGH',   'OPEN',        22, 13, DATE_SUB(NOW(), INTERVAL 2 DAY),  NOW()),
(6,  134, 'Tư vấn mở rộng gói bản quyền thêm 20 người dùng',        'Khách hàng mở thêm chi nhánh mới tại Quảng Nam, cần nâng cấp gói Enterprise.',               'LOW',    'RESOLVED',    22, 13, DATE_SUB(NOW(), INTERVAL 10 DAY), NOW()),
(7,  156, 'Cảnh báo bảo mật: Phát hiện nhiều lần đăng nhập sai',    'Hệ thống ghi nhận 5 lần thử mật khẩu không chính xác liên tiếp từ IP lạ.',                  'HIGH',   'CLOSED',      9,  16, DATE_SUB(NOW(), INTERVAL 20 DAY), NOW()),
(8,  157, 'Hỗ trợ đồng bộ danh bạ người liên hệ từ file CSV',       'Khách hàng cần import 200 danh thiếp đối tác sau sự kiện triển lãm xúc tiến thương mại.',   'LOW',    'RESOLVED',    21, 16, DATE_SUB(NOW(), INTERVAL 8 DAY),  NOW()),
(9,  104, 'Hỏi đáp điều khoản bảo hành và cập nhật phiên bản',       'Làm rõ quyền lợi nâng cấp lên CRM v2.0 có tính phí bảo trì không.',                        'LOW',    'CLOSED',      9,  7,  DATE_SUB(NOW(), INTERVAL 25 DAY), NOW()),
(10, 158, 'Khắc phục lỗi định dạng ngày tháng trên giao diện Mobile', 'Giao diện điện thoại hiển thị ngày sinh và ngày tạo sai định dạng dd/MM/yyyy.',           'MEDIUM', 'IN_PROGRESS', 22, 17, DATE_SUB(NOW(), INTERVAL 4 DAY),  NOW())
ON DUPLICATE KEY UPDATE
    title = VALUES(title),
    status = VALUES(status),
    priority = VALUES(priority);

-- =============================================================================
-- 27. BẢNG CHĂM SÓC KHÁCH HÀNG ĐỊNH KỲ (customer_care)
-- Bao phủ: Khách được chăm sóc định kỳ, khách quá hạn chăm sóc, khách chưa từng liên hệ
-- =============================================================================
INSERT INTO customer_care (care_id, customer_id, last_contacted_at, last_contacted_by, inactive_threshold_days, note, created_at, updated_at) VALUES
(1, 101, DATE_SUB(NOW(), INTERVAL 5 DAY),  9,  30, 'Khách hàng Mai Ngọc Phúc rất hài lòng với gói Enterprise, định kỳ tương tác hàng tuần.', DATE_SUB(NOW(), INTERVAL 120 DAY), NOW()),
(2, 102, DATE_SUB(NOW(), INTERVAL 45 DAY), 9,  30, 'CẢNH BÁO: Đã quá hạn chăm sóc 15 ngày, cần lên lịch hẹn gặp giám đốc tài chính.',       DATE_SUB(NOW(), INTERVAL 100 DAY), NOW()),
(3, 103, DATE_SUB(NOW(), INTERVAL 10 DAY), 21, 30, 'Khách hàng Mai Khánh Thảo đang mở rộng chi nhánh mới, phản hồi tích cực.',               DATE_SUB(NOW(), INTERVAL 90 DAY),  NOW()),
(4, 104, DATE_SUB(NOW(), INTERVAL 60 DAY), 21, 30, 'CẢNH BÁO: Đã 2 tháng chưa tương tác, nguy cơ khách hàng giảm mức độ sử dụng CRM.',     DATE_SUB(NOW(), INTERVAL 80 DAY),  NOW()),
(5, 133, DATE_SUB(NOW(), INTERVAL 3 DAY),  22, 30, 'Họp online hỗ trợ kỹ thuật định kỳ với đại diện công nghệ Trịnh Đức Hoa.',             DATE_SUB(NOW(), INTERVAL 60 DAY),  NOW()),
(6, 134, NULL,                             NULL, 30, 'KHÁCH MỚI: Chưa có lượt tương tác chăm sóc nào từ khi ký hợp đồng, cần phân công gọi.',DATE_SUB(NOW(), INTERVAL 40 DAY),  NOW()),
(7, 156, DATE_SUB(NOW(), INTERVAL 12 DAY), 9,  30, 'Đã gửi thư chúc mừng sinh nhật doanh nghiệp và phiếu giảm giá 20% gói đào tạo.',        DATE_SUB(NOW(), INTERVAL 50 DAY),  NOW()),
(8, 157, DATE_SUB(NOW(), INTERVAL 50 DAY), 22, 30, 'CẢNH BÁO: Khách hàng miền Nam sắp đến hạn gia hạn hợp đồng năm 2, cần trao đổi sớm.',  DATE_SUB(NOW(), INTERVAL 70 DAY),  NOW())
ON DUPLICATE KEY UPDATE
    last_contacted_at = VALUES(last_contacted_at),
    note = VALUES(note);

-- =============================================================================
-- 28. BẢNG BỘ LỌC ĐÃ LƯU (saved_filters)
-- =============================================================================
INSERT INTO saved_filters (filter_id, user_id, filter_name, module, keyword, status, industry, company_size, region, owner_id, filter_query, is_default, created_at) VALUES
(1, 6,  'Khách hàng Miền Bắc - IT',    'CUSTOMER', '', 'Chính thức', 'Công nghệ thông tin', '',           'Miền Bắc', 6,  'status=Chính thức&industry=Công nghệ thông tin&region=Miền Bắc', 1, NOW()),
(2, 6,  'Khách hàng Doanh nghiệp lớn', 'CUSTOMER', '', 'Chính thức', '',                   'ENTERPRISE', '',         6,  'status=Chính thức&company_size=ENTERPRISE',                        0, NOW()),
(3, 13, 'Khách hàng Miền Trung - Y tế', 'CUSTOMER', '', 'Tiềm năng',  'Y tế - Dược phẩm',   '',           'Miền Trung', 13, 'status=Tiềm năng&industry=Y tế - Dược phẩm&region=Miền Trung',   1, NOW()),
(4, 16, 'Khách hàng Tiềm năng Miền Nam','CUSTOMER', '', 'Tiềm năng',  '',                   '',           'Miền Nam', 16, 'status=Tiềm năng&region=Miền Nam',                                1, NOW())
ON DUPLICATE KEY UPDATE filter_name = VALUES(filter_name);

-- =============================================================================
-- 29. BẢNG TỆP ĐÍNH KÈM HỒ SƠ KHÁCH HÀNG (attachments)
-- =============================================================================
INSERT INTO attachments (attachment_id, customer_id, file_name, file_path, file_size, uploaded_at) VALUES
(1, 101, 'Hop_dong_kinh_te_MaiNgocPhuc_2026.pdf', '/uploads/customers/101/Hop_dong_kinh_te_MaiNgocPhuc_2026.pdf', 3450000, DATE_SUB(NOW(), INTERVAL 90 DAY)),
(2, 101, 'Bien_ban_nghiem_thu_MaiNgocPhuc.pdf',   '/uploads/customers/101/Bien_ban_nghiem_thu_MaiNgocPhuc.pdf',   2100000, DATE_SUB(NOW(), INTERVAL 45 DAY)),
(3, 102, 'Thoa_thuan_bao_mat_NDA_LuongBaoHung.pdf','/uploads/customers/102/Thoa_thuan_bao_mat_NDA_LuongBaoHung.pdf',1500000, DATE_SUB(NOW(), INTERVAL 60 DAY)),
(4, 133, 'Hop_dong_trien_khai_TrinhDucHoa.pdf',    '/uploads/customers/133/Hop_dong_trien_khai_TrinhDucHoa.pdf',    4200000, DATE_SUB(NOW(), INTERVAL 30 DAY)),
(5, 156, 'Phu_luc_hop_dong_DangDucViet.pdf',       '/uploads/customers/156/Phu_luc_hop_dong_DangDucViet.pdf',       1800000, DATE_SUB(NOW(), INTERVAL 15 DAY))
ON DUPLICATE KEY UPDATE file_name = VALUES(file_name);

-- =============================================================================
-- 30. BẢNG NHẬT KÝ THAO TÁC / AUDIT TRAIL (audit_logs)
-- Ghi nhận đầy đủ thao tác của Admin, Director, Trưởng nhóm và Nhân viên
-- =============================================================================
INSERT INTO audit_logs (log_id, action_type, performed_by, target_user_id, description, old_value, new_value, created_at) VALUES
(1, 'ASSIGN_ROLE',       1, 6,  'Quản trị viên gán vai trò Nhân viên kinh doanh và Nhóm Miền Bắc cho Bùi Đức Minh', 'Không có vai trò', 'Vai trò: [Nhân viên kinh doanh], Nhóm: [Team Kinh Doanh Miền Bắc]', DATE_SUB(NOW(), INTERVAL 120 DAY)),
(2, 'CREATE_CUSTOMER',   6, 6,  'Khởi tạo hồ sơ khách hàng doanh nghiệp Tập đoàn Công nghệ Mai Ngọc Phúc',          NULL, 'customer_id=101, customer_name=Tập đoàn Công nghệ Mai Ngọc Phúc',                  DATE_SUB(NOW(), INTERVAL 115 DAY)),
(3, 'CREATE_OPPORTUNITY',6, 6,  'Tạo cơ hội bán hàng ERP Enterprise giá trị 1.200.000.000 VNĐ cho khách hàng 101',  NULL, 'opportunity_id=8001, customer_id=101, amount=1200000000',                            DATE_SUB(NOW(), INTERVAL 110 DAY)),
(4, 'CREATE_ACTIVITY',   6, 6,  'Ghi nhận lịch hẹn demo giải pháp phần mềm CRM cho ban giám đốc Mai Ngọc Phúc',     NULL, 'activity_id=1, customer_id=101, type=MEETING',                                      DATE_SUB(NOW(), INTERVAL 105 DAY)),
(5, 'TRANSFER_CONTACT',  6, 6,  'Chuyển công tác người liên hệ Mai Ngọc Phúc từ công ty 101 sang công ty con 102',  'customer_id=101', 'customer_id=102',                                                        DATE_SUB(NOW(), INTERVAL 30 DAY)),
(6, 'MERGE_CUSTOMER',    1, 1,  'Gộp hồ sơ khách hàng thành viên #102 vào hồ sơ tập đoàn mẹ #101',                  'secondary_id=102', 'primary_id=101',                                                        DATE_SUB(NOW(), INTERVAL 15 DAY))
ON DUPLICATE KEY UPDATE description = VALUES(description);

-- =============================================================================
-- 31. BẢNG QUY TẮC PHÂN BỔ LEAD (lead_assignment_rules) - S4-06
-- =============================================================================
INSERT INTO lead_assignment_rules (rule_id, rule_name, priority, criterion, criterion_value, assignee_id, team_id, is_active) VALUES
(1, 'Phân bổ khu vực Miền Nam cho Sales Hà Thanh Long', 1, 'REGION', 'Miền Nam', 16, 2, 1),
(2, 'Phân bổ khách hàng ngành CNTT cho Bùi Đức Minh',   2, 'INDUSTRY', 'Công nghệ thông tin', 6, 1, 1),
(3, 'Phân bổ xoay vòng Round-Robin cho Team Miền Bắc',   99, 'ROUND_ROBIN', NULL, NULL, 1, 1)
ON DUPLICATE KEY UPDATE
    rule_name = VALUES(rule_name),
    priority = VALUES(priority),
    is_active = VALUES(is_active);

-- =============================================================================
-- 32. BẢNG KHÁCH HÀNG TIỀM NĂNG (leads) - BAO PHỦ 100% CÁC TRẠNG THÁI & 14 NGUỒN
-- Danh tính Lead sử dụng CHÍNH XÁC từ tập 78 khách hàng (không sinh người ngoài)
-- =============================================================================
INSERT INTO leads (lead_id, full_name, first_name, last_name, title, company, company_name, contact_name, email, phone,
                   lead_source_id, web_form_id, campaign_id, customer_id, converted_customer_id, converted_contact_id, converted_opportunity_id,
                   source, status, rating, score, industry, address, city, state, country, zip_code, owner_id, notes,
                   assigned_at, rejection_reason, sla_due_at, sla_due_date, sla_status, is_overdue, sla_breached, created_at, updated_at) VALUES
(1, 'Mai Ngọc Phúc', 'Phúc', 'Mai Ngọc', 'Tổng Giám đốc', 'Công ty Cổ phần Mai Ngọc Phúc', 'Công ty Cổ phần Mai Ngọc Phúc', 'Mai Ngọc Phúc', 'maingocphuc@gmail.com', '0901000101', 1, 1, 1, NULL, NULL, NULL, NULL, 'WEB_FORM', 'NEW', 'HOT', 85, 'Công nghệ thông tin', '12 Duy Tân, Cầu Giấy', 'Hà Nội', 'Hà Nội', 'Việt Nam', '100000', NULL, 'Đăng ký tư vấn giải pháp CRM qua Web Form trang chủ', NULL, NULL, DATE_ADD(NOW(), INTERVAL 24 HOUR), DATE_ADD(NOW(), INTERVAL 24 HOUR), 'ON_TRACK', 0, 0, NOW(), NOW()),
(2, 'Lương Bảo Hùng', 'Hùng', 'Lương Bảo', 'Giám đốc Tài chính', 'Tổng Công ty Lương Bảo Hùng Holding', 'Tổng Công ty Lương Bảo Hùng Holding', 'Lương Bảo Hùng', 'luongbaohung@gmail.com', '0901000102', 2, NULL, 1, NULL, NULL, NULL, NULL, 'MANUAL', 'ASSIGNED', 'HOT', 75, 'Tài chính - Ngân hàng', '88 Hai Bà Trưng', 'Hà Nội', 'Hà Nội', 'Việt Nam', '100000', 6, 'Khách hàng có kế hoạch đầu tư CRM trong tháng này, cần liên hệ sớm', NOW(), NULL, DATE_ADD(NOW(), INTERVAL 20 HOUR), DATE_ADD(NOW(), INTERVAL 20 HOUR), 'ON_TRACK', 0, 0, DATE_SUB(NOW(), INTERVAL 4 HOUR), NOW()),
(3, 'Mai Khánh Thảo', 'Thảo', 'Mai Khánh', 'Giám đốc Vận hành', 'Công ty Cổ phần Mai Khánh Thảo Tech', 'Công ty Cổ phần Mai Khánh Thảo Tech', 'Mai Khánh Thảo', 'maikhanhthao@gmail.com', '0901000103', 4, NULL, 2, NULL, NULL, NULL, NULL, 'FACEBOOK', 'ASSIGNED', 'WARM', 60, 'Công nghệ thông tin', 'Khu CNC Hòa Lạc', 'Hà Nội', 'Hà Nội', 'Việt Nam', '100000', 6, 'Lead từ chiến dịch Facebook Ads B2B, đã quá hạn phản hồi SLA 24h', DATE_SUB(NOW(), INTERVAL 28 HOUR), NULL, DATE_SUB(NOW(), INTERVAL 4 HOUR), DATE_SUB(NOW(), INTERVAL 4 HOUR), 'BREACHED', 1, 1, DATE_SUB(NOW(), INTERVAL 29 HOUR), NOW()),
(4, 'Chu Công Tú', 'Tú', 'Chu Công', 'Phó Tổng Giám Đốc', 'Tập đoàn Chu Công Tú Logistics', 'Tập đoàn Chu Công Tú Logistics', 'Chu Công Tú', 'chucongtu@gmail.com', '0901000104', 5, NULL, 1, NULL, NULL, NULL, NULL, 'GOOGLE_ADS', 'IN_PROGRESS', 'HOT', 90, 'Vận tải - Lữ hành', '25 Lý Thường Kiệt', 'Hà Nội', 'Hà Nội', 'Việt Nam', '100000', 6, 'Đã trao đổi tư vấn lần 1, khách hàng rất quan tâm và hẹn họp demo trực tiếp', DATE_SUB(NOW(), INTERVAL 2 DAY), NULL, DATE_SUB(NOW(), INTERVAL 1 DAY), DATE_SUB(NOW(), INTERVAL 1 DAY), 'RESOLVED', 0, 0, DATE_SUB(NOW(), INTERVAL 3 DAY), NOW()),
(5, 'Nông Hoài Thủy', 'Thủy', 'Nông Hoài', 'Trưởng phòng Mua sắm', 'Tập đoàn Công nghệ Mai Ngọc Phúc', 'Tập đoàn Công nghệ Mai Ngọc Phúc', 'Nông Hoài Thủy', 'nonghoaithuy@gmail.com', '0901000105', 1, 1, 1, 101, 101, 8001, 8001, 'WEB_FORM', 'CONVERTED', 'HOT', 95, 'Công nghệ thông tin', '12 Duy Tân, Cầu Giấy', 'Hà Nội', 'Hà Nội', 'Việt Nam', '100000', 6, 'Chuyển đổi thành công sang khách hàng doanh nghiệp chính thức #101', DATE_SUB(NOW(), INTERVAL 10 DAY), NULL, DATE_SUB(NOW(), INTERVAL 9 DAY), DATE_SUB(NOW(), INTERVAL 9 DAY), 'RESOLVED', 0, 0, DATE_SUB(NOW(), INTERVAL 15 DAY), NOW()),
(6, 'Mai Ngọc Phúc (Bản ghi trùng)', 'Phúc', 'Mai Ngọc', 'CEO', 'Mai Ngọc Phúc JSC', 'Mai Ngọc Phúc JSC', 'Mai Ngọc Phúc', 'maingocphuc@gmail.com', '0901000101', 3, NULL, NULL, NULL, NULL, NULL, NULL, 'EXCEL', 'NEW', 'WARM', 50, 'Công nghệ thông tin', '12 Duy Tân', 'Hà Nội', 'Hà Nội', 'Việt Nam', '100000', NULL, 'Bản ghi import từ Excel, trùng số điện thoại và email với Lead #1', NULL, NULL, DATE_ADD(NOW(), INTERVAL 24 HOUR), DATE_ADD(NOW(), INTERVAL 24 HOUR), 'ON_TRACK', 0, 0, DATE_SUB(NOW(), INTERVAL 1 DAY), NOW()),
(7, 'Hoàng Văn Thảo', 'Thảo', 'Hoàng Văn', 'Trưởng phòng IT', 'Tập đoàn Công nghệ Mai Ngọc Phúc', 'Tập đoàn Công nghệ Mai Ngọc Phúc', 'Hoàng Văn Thảo', 'hoangvanthao@gmail.com', '0901000107', 6, NULL, NULL, NULL, NULL, NULL, NULL, 'HOTLINE', 'NEW', 'WARM', 65, 'Công nghệ thông tin', 'Tòa nhà Mai Ngọc Phúc', 'Hà Nội', 'Hà Nội', 'Việt Nam', '100000', NULL, 'Gọi qua tổng đài hotline, trùng tên doanh nghiệp với Khách hàng #101', NULL, NULL, DATE_ADD(NOW(), INTERVAL 24 HOUR), DATE_ADD(NOW(), INTERVAL 24 HOUR), 'ON_TRACK', 0, 0, DATE_SUB(NOW(), INTERVAL 2 HOUR), NOW()),
(8, 'Hồ Thanh Trí', 'Trí', 'Hồ Thanh', 'Phó GĐ', 'Chu Công Tú Logistics', 'Chu Công Tú Logistics', 'Hồ Thanh Trí', 'hothanhtri@gmail.com', '0901000108', 2, NULL, NULL, NULL, NULL, NULL, NULL, 'MANUAL', 'MERGED', 'WARM', 40, 'Vận tải - Lữ hành', '25 Lý Thường Kiệt', 'Hà Nội', 'Hà Nội', 'Việt Nam', '100000', 6, 'Đã gộp vào Lead chính #4 theo quyết định của nhân viên kinh doanh', DATE_SUB(NOW(), INTERVAL 5 DAY), NULL, DATE_SUB(NOW(), INTERVAL 4 DAY), DATE_SUB(NOW(), INTERVAL 4 DAY), 'RESOLVED', 0, 0, DATE_SUB(NOW(), INTERVAL 6 DAY), NOW()),
(9, 'Lý Văn Minh', 'Minh', 'Lý Văn', 'Cá nhân', 'Khách hàng cá nhân', 'Khách hàng cá nhân', 'Lý Văn Minh', 'lyvanminh@gmail.com', '0901000109', 4, NULL, 2, NULL, NULL, NULL, NULL, 'FACEBOOK', 'REJECTED', 'COLD', 20, 'Khác', 'Quận 7', 'TP. Hồ Chí Minh', 'TP.HCM', 'Việt Nam', '700000', NULL, 'Từ chối tiếp nhận Lead do sai số điện thoại và không thuộc chân dung mục tiêu', DATE_SUB(NOW(), INTERVAL 3 DAY), 'Sai số điện thoại / Không liên lạc được', DATE_SUB(NOW(), INTERVAL 2 DAY), DATE_SUB(NOW(), INTERVAL 2 DAY), 'RESOLVED', 0, 0, DATE_SUB(NOW(), INTERVAL 4 DAY), NOW()),
(10, 'Lường Phương Linh', 'Linh', 'Lường Phương', 'Giám đốc Nhân sự', 'Công ty TNHH Lường Phương Linh Edu', 'Công ty TNHH Lường Phương Linh Edu', 'Lường Phương Linh', 'luongphuonglinh@gmail.com', '0901000110', 9, NULL, NULL, NULL, NULL, NULL, NULL, 'IMPORT_EXCEL', 'QUALIFIED', 'WARM', 65, 'Giáo dục & Đào tạo', '120 Hoàng Quốc Việt', 'Hà Nội', 'Hà Nội', 'Việt Nam', '100000', 13, 'Nhập từ file Excel hội thảo EdTech 2026, thông tin doanh nghiệp đủ điều kiện', DATE_SUB(NOW(), INTERVAL 1 DAY), NULL, DATE_ADD(NOW(), INTERVAL 12 HOUR), DATE_ADD(NOW(), INTERVAL 12 HOUR), 'ON_TRACK', 0, 0, DATE_SUB(NOW(), INTERVAL 2 DAY), NOW()),
(11, 'Trịnh Đức Hoa', 'Hoa', 'Trịnh Đức', 'Giám đốc Kinh doanh', 'Chuỗi Cửa Hàng Trịnh Đức Hoa Retail', 'Chuỗi Cửa Hàng Trịnh Đức Hoa Retail', 'Trịnh Đức Hoa', 'trinhduchoa@gmail.com', '0901000111', 7, NULL, 3, NULL, NULL, NULL, NULL, 'EVENT', 'CONTACTED', 'WARM', 55, 'Bán lẻ - Tiêu dùng', 'Khu Đô Thị Ecopark', 'Hưng Yên', 'Hưng Yên', 'Việt Nam', '160000', 13, 'Thu thập danh thiếp tại hội thảo bán lẻ, đã gọi trao đổi sơ bộ nhu cầu', DATE_SUB(NOW(), INTERVAL 2 DAY), NULL, DATE_ADD(NOW(), INTERVAL 24 HOUR), DATE_ADD(NOW(), INTERVAL 24 HOUR), 'ON_TRACK', 0, 0, DATE_SUB(NOW(), INTERVAL 3 DAY), NOW()),
(12, 'Hà Minh Vy', 'Vy', 'Hà Minh', 'Chủ hộ kinh doanh', 'Cửa hàng tạp hóa Hà Minh Vy', 'Cửa hàng tạp hóa Hà Minh Vy', 'Hà Minh Vy', 'haminhvy@gmail.com', '0901000112', 12, NULL, NULL, NULL, NULL, NULL, NULL, 'COLD_CALL', 'UNQUALIFIED', 'COLD', 15, 'Bán lẻ - Tiêu dùng', 'Thị trấn Phùng, Đan Phượng', 'Hà Nội', 'Hà Nội', 'Việt Nam', '100000', 13, 'Quy mô kinh doanh quá nhỏ, chưa có nhu cầu sử dụng phần mềm CRM', DATE_SUB(NOW(), INTERVAL 4 DAY), NULL, DATE_SUB(NOW(), INTERVAL 3 DAY), DATE_SUB(NOW(), INTERVAL 3 DAY), 'RESOLVED', 0, 0, DATE_SUB(NOW(), INTERVAL 5 DAY), NOW()),
(13, 'Lương Văn Hương', 'Hương', 'Lương Văn', 'Phó Giám Đốc', 'Công ty Cổ phần Vận Tải Lương Văn Hương', 'Công ty Cổ phần Vận Tải Lương Văn Hương', 'Lương Văn Hương', 'luongvanhuong@gmail.com', '0901000113', 8, NULL, NULL, NULL, NULL, NULL, NULL, 'PARTNER', 'ASSIGNED', 'WARM', 50, 'Vận tải - Lữ hành', 'Tòa nhà Landmark 81', 'TP. Hồ Chí Minh', 'TP.HCM', 'Việt Nam', '700000', 16, 'Đối tác ngân hàng giới thiệu khách hàng doanh nghiệp vận tải đang tìm giải pháp CRM', NOW(), NULL, DATE_ADD(NOW(), INTERVAL 48 HOUR), DATE_ADD(NOW(), INTERVAL 48 HOUR), 'ON_TRACK', 0, 0, DATE_SUB(NOW(), INTERVAL 2 HOUR), NOW()),
(14, 'Trần Hoài Thu', 'Thu', 'Trần Hoài', 'Tổng Giám Đốc', 'Tập đoàn Dược Phẩm Trần Hoài Thu', 'Tập đoàn Dược Phẩm Trần Hoài Thu', 'Trần Hoài Thu', 'tranhoaithu@gmail.com', '0901000114', 10, NULL, NULL, NULL, NULL, NULL, NULL, 'DIRECT', 'IN_PROGRESS', 'HOT', 80, 'Y tế - Dược phẩm', 'Phố Nguyễn Đình Chiểu, Quận 3', 'TP. Hồ Chí Minh', 'TP.HCM', 'Việt Nam', '700000', 16, 'Khách hàng tự liên hệ trực tiếp đến văn phòng, đã hoàn thành bản khảo sát yêu cầu', DATE_SUB(NOW(), INTERVAL 3 DAY), NULL, DATE_SUB(NOW(), INTERVAL 2 DAY), DATE_SUB(NOW(), INTERVAL 2 DAY), 'RESOLVED', 0, 0, DATE_SUB(NOW(), INTERVAL 4 DAY), NOW()),
(15, 'Tạ Ngọc Liên', 'Liên', 'Tạ Ngọc', 'Trưởng phòng Kỹ thuật', 'Công ty CP Giải Pháp Tạ Ngọc Liên', 'Công ty CP Giải Pháp Tạ Ngọc Liên', 'Tạ Ngọc Liên', 'tangoclien@gmail.com', '0901000115', 11, NULL, NULL, NULL, NULL, NULL, NULL, 'REFERRAL', 'NEW', 'WARM', 45, 'Công nghệ thông tin', 'Đường 3 Tháng 2, Quận 10', 'TP. Hồ Chí Minh', 'TP.HCM', 'Việt Nam', '700000', NULL, 'Khách hàng cũ giới thiệu đồng nghiệp tìm hiểu gói CRM Standard', NULL, NULL, DATE_ADD(NOW(), INTERVAL 48 HOUR), DATE_ADD(NOW(), INTERVAL 48 HOUR), 'ON_TRACK', 0, 0, NOW(), NOW()),
(16, 'Ngô Quang Lộc', 'Lộc', 'Ngô Quang', 'Chủ tịch HĐQT', 'Công ty Cổ phần Xây Dựng Ngô Quang Lộc', 'Công ty Cổ phần Xây Dựng Ngô Quang Lộc', 'Ngô Quang Lộc', 'ngoquangloc@gmail.com', '0901000116', 13, NULL, 4, NULL, NULL, NULL, NULL, 'EMAIL_CAMPAIGN', 'NEW', 'WARM', 50, 'Bất động sản', 'Đường Nguyễn Thị Minh Khai', 'Đà Nẵng', 'Đà Nẵng', 'Việt Nam', '550000', NULL, 'Bấm vào liên kết đăng ký dùng thử từ email marketing ưu đãi mùa thu', NULL, NULL, DATE_ADD(NOW(), INTERVAL 48 HOUR), DATE_ADD(NOW(), INTERVAL 48 HOUR), 'ON_TRACK', 0, 0, DATE_SUB(NOW(), INTERVAL 1 DAY), NOW()),
(17, 'Trần Công Nga', 'Nga', 'Trần Công', 'Giám đốc Marketing', 'Công ty TNHH Quảng Cáo Trần Công Nga', 'Công ty TNHH Quảng Cáo Trần Công Nga', 'Trần Công Nga', 'trancongnga@gmail.com', '0901000117', 14, NULL, 2, NULL, NULL, NULL, NULL, 'SOCIAL_MEDIA', 'NEW', 'WARM', 40, 'Bán lẻ - Tiêu dùng', 'Đường Lê Duẩn, Hải Châu', 'Đà Nẵng', 'Đà Nẵng', 'Việt Nam', '550000', NULL, 'Nhắn tin qua Fanpage LinkedIn bày tỏ sự quan tâm đến tính năng quản lý chiến dịch', NULL, NULL, DATE_ADD(NOW(), INTERVAL 48 HOUR), DATE_ADD(NOW(), INTERVAL 48 HOUR), 'ON_TRACK', 0, 0, DATE_SUB(NOW(), INTERVAL 6 HOUR), NOW()),
(18, 'Đỗ Thị Bình', 'Bình', 'Đỗ Thị', 'Giám đốc Chiến lược', 'Tập đoàn Đầu Tư Đỗ Thị Bình', 'Tập đoàn Đầu Tư Đỗ Thị Bình', 'Đỗ Thị Bình', 'dothibinh@gmail.com', '0901000118', 1, 2, 1, NULL, NULL, NULL, NULL, 'WEB_FORM', 'OVERDUE', 'HOT', 75, 'Tài chính - Ngân hàng', 'Phố Huế, Hai Bà Trưng', 'Hà Nội', 'Hà Nội', 'Việt Nam', '100000', 7, 'Lead đăng ký dùng thử qua Web Form, bị quá hạn phản hồi SLA chưa kịp liên hệ', DATE_SUB(NOW(), INTERVAL 30 HOUR), NULL, DATE_SUB(NOW(), INTERVAL 6 HOUR), DATE_SUB(NOW(), INTERVAL 6 HOUR), 'BREACHED', 1, 1, DATE_SUB(NOW(), INTERVAL 31 HOUR), NOW()),
(19, 'Dương Thanh Linh', 'Linh', 'Dương Thanh', 'Trưởng ban Công nghệ', 'Công ty Cổ phần Công Nghệ Dương Thanh Linh', 'Công ty Cổ phần Công Nghệ Dương Thanh Linh', 'Dương Thanh Linh', 'duongthanhlinh@gmail.com', '0901000119', 5, NULL, 1, NULL, NULL, NULL, NULL, 'GOOGLE_ADS', 'ASSIGNED', 'HOT', 85, 'Công nghệ thông tin', 'Đường Bạch Đằng', 'Đà Nẵng', 'Đà Nẵng', 'Việt Nam', '550000', 14, 'Tìm kiếm từ khóa CRM Enterprise trên Google, đã phân bổ cho chuyên viên IT miền Trung', NOW(), NULL, DATE_ADD(NOW(), INTERVAL 24 HOUR), DATE_ADD(NOW(), INTERVAL 24 HOUR), 'ON_TRACK', 0, 0, DATE_SUB(NOW(), INTERVAL 1 HOUR), NOW()),
(20, 'Chu Ngọc Vy', 'Vy', 'Chu Ngọc', 'Giám đốc Mua hàng', 'Công ty Cổ phần Chu Ngọc Vy Tech', 'Công ty Cổ phần Chu Ngọc Vy Tech', 'Chu Ngọc Vy', 'chungocvy@gmail.com', '0901000120', 7, NULL, 3, 156, 156, 8056, 8011, 'EVENT', 'CONVERTED', 'HOT', 90, 'Sản xuất - Công nghiệp', 'KCN Tân Bình, Tân Phú', 'TP. Hồ Chí Minh', 'TP.HCM', 'Việt Nam', '700000', 17, 'Gặp gỡ tại hội thảo xúc tiến thương mại, đã ký hợp đồng chuyển đổi thành công', DATE_SUB(NOW(), INTERVAL 20 DAY), NULL, DATE_SUB(NOW(), INTERVAL 19 DAY), DATE_SUB(NOW(), INTERVAL 19 DAY), 'RESOLVED', 0, 0, DATE_SUB(NOW(), INTERVAL 25 DAY), NOW())
ON DUPLICATE KEY UPDATE
    full_name = VALUES(full_name),
    email = VALUES(email),
    phone = VALUES(phone),
    status = VALUES(status),
    score = VALUES(score),
    rating = VALUES(rating),
    lead_source_id = VALUES(lead_source_id),
    campaign_id = VALUES(campaign_id),
    owner_id = VALUES(owner_id);

-- =============================================================================
-- 33. BẢNG LỊCH SỬ PHÂN BỔ LEAD (lead_assignment_history) - S4-06, S4-07
-- =============================================================================
INSERT INTO lead_assignment_history (history_id, lead_id, rule_id, assigned_to, performed_by, status, reject_reason, assigned_at) VALUES
(1, 2,  2, 6,  3, 'ASSIGNED', NULL, DATE_SUB(NOW(), INTERVAL 4 HOUR)),
(2, 3,  2, 6,  3, 'ASSIGNED', NULL, DATE_SUB(NOW(), INTERVAL 28 HOUR)),
(3, 4,  2, 6,  3, 'ASSIGNED', NULL, DATE_SUB(NOW(), INTERVAL 2 DAY)),
(4, 9,  1, 16, 5, 'REJECTED', 'Sai số điện thoại / Không liên lạc được', DATE_SUB(NOW(), INTERVAL 3 DAY)),
(5, 10, 3, 13, 4, 'ASSIGNED', NULL, DATE_SUB(NOW(), INTERVAL 1 DAY)),
(6, 13, 1, 16, 5, 'ASSIGNED', NULL, NOW()),
(7, 18, 3, 7,  3, 'ASSIGNED', NULL, DATE_SUB(NOW(), INTERVAL 30 HOUR)),
(8, 19, 2, 14, 4, 'ASSIGNED', NULL, NOW())
ON DUPLICATE KEY UPDATE status = VALUES(status);

-- =============================================================================
-- 34. BẢNG LỊCH SỬ GỘP LEAD (lead_merge_history) - S4-04
-- =============================================================================
INSERT INTO lead_merge_history (merge_id, primary_lead_id, duplicate_lead_id, merged_by, merged_at, retained_fields, note) VALUES
(1, 4, 8, 6, DATE_SUB(NOW(), INTERVAL 2 DAY),
 '{"mergedLeadId":8,"retainedName":"Chu Công Tú","retainedEmail":"chucongtu@gmail.com","retainedPhone":"0901000104"}',
 'Gộp tự động phát hiện trùng lặp SĐT giữa hai Lead cùng công ty Logistics')
ON DUPLICATE KEY UPDATE note = VALUES(note);

-- =============================================================================
-- 35. BẢNG THÔNG BÁO QUÁ HẠN LEAD SLA CHO TRƯỞNG NHÓM (lead_sla_notifications)
-- =============================================================================
INSERT INTO lead_sla_notifications (notification_id, lead_id, sales_rep_id, team_id, leader_id, message, sla_due_date, is_read, created_at) VALUES
(1, 3, 6, 1, 3, 'CẢNH BÁO QUÁ HẠN SLA: Lead #3 (Mai Khánh Thảo) chưa được phản hồi trong 24h quy định.', DATE_SUB(NOW(), INTERVAL 4 HOUR), 0, DATE_SUB(NOW(), INTERVAL 4 HOUR)),
(2, 18, 7, 1, 3, 'CẢNH BÁO QUÁ HẠN SLA: Lead #18 (Đỗ Thị Bình) quá hạn phản hồi đăng ký dùng thử.', DATE_SUB(NOW(), INTERVAL 6 HOUR), 0, DATE_SUB(NOW(), INTERVAL 6 HOUR))
ON DUPLICATE KEY UPDATE message = VALUES(message);

-- =============================================================================
-- 36. BẢNG CƠ HỘI BÁN HÀNG (opportunities) - BAO PHỦ 6 GIAI ĐOẠN PIPELINE
-- =============================================================================
INSERT INTO opportunities (opportunity_id, customer_id, campaign_id, title, amount, owner_id, pipeline_stage_id, probability, stage, status, win_loss_reason_id, competitor_id, close_date, created_at) VALUES
(8001, 101, 1,    'Hợp đồng CRM Bản Enterprise Tập đoàn Mai Ngọc Phúc',        1200000000.00, 6,  5, 100.00, 'CLOSED_WON',  'ACTIVE', 1,    NULL, DATE_SUB(NOW(), INTERVAL 60 DAY), DATE_SUB(NOW(), INTERVAL 90 DAY)),
(8002, 101, NULL, 'Gói Nâng cấp Hệ thống Tích hợp ERP Mai Ngọc Phúc',          500000000.00,  6,  5, 100.00, 'CLOSED_WON',  'ACTIVE', 2,    NULL, DATE_SUB(NOW(), INTERVAL 30 DAY), DATE_SUB(NOW(), INTERVAL 60 DAY)),
(8003, 101, NULL, 'Gói Bảo trì & Nâng cấp Hạ tầng Cloud Mai Ngọc Phúc',        300000000.00,  6,  3,  50.00, 'OPEN',        'ACTIVE', NULL, NULL, DATE_ADD(NOW(), INTERVAL 30 DAY), DATE_SUB(NOW(), INTERVAL 15 DAY)),
(8004, 102, 1,    'Hợp đồng Phần mềm CRM Chuẩn hóa Lương Bảo Hùng',            800000000.00,  6,  5, 100.00, 'CLOSED_WON',  'ACTIVE', 1,    NULL, DATE_SUB(NOW(), INTERVAL 45 DAY), DATE_SUB(NOW(), INTERVAL 80 DAY)),
(8005, 103, 2,    'Triển khai Nền tảng Tự động hóa Bán hàng Mai Khánh Thảo',    450000000.00,  6,  4,  80.00, 'OPEN',        'ACTIVE', NULL, NULL, DATE_ADD(NOW(), INTERVAL 15 DAY), DATE_SUB(NOW(), INTERVAL 20 DAY)),
(8006, 104, NULL, 'Tư vấn Thiết lập Quy trình Kinh doanh Chu Công Tú',         150000000.00,  6,  2,  30.00, 'OPEN',        'ACTIVE', NULL, NULL, DATE_ADD(NOW(), INTERVAL 45 DAY), DATE_SUB(NOW(), INTERVAL 10 DAY)),
(8007, 105, NULL, 'Cung cấp Thiết bị Quản lý Điểm bán Nông Hoài Thủy',         80000000.00,   7,  1,  10.00, 'OPEN',        'ACTIVE', NULL, NULL, DATE_ADD(NOW(), INTERVAL 60 DAY), DATE_SUB(NOW(), INTERVAL 5 DAY)),
(8008, 106, 2,    'Dự án CRM Bất động sản Đoàn Văn Bách (Thất bại)',           600000000.00,  7,  6,   0.00, 'CLOSED_LOST', 'ACTIVE', 4,    1,    DATE_SUB(NOW(), INTERVAL 10 DAY), DATE_SUB(NOW(), INTERVAL 30 DAY)),
(8009, 133, 3,    'Hợp đồng Chuyển đổi số Bán lẻ Trịnh Đức Hoa Core',          650000000.00,  13, 5, 100.00, 'CLOSED_WON',  'ACTIVE', 3,    NULL, DATE_SUB(NOW(), INTERVAL 20 DAY), DATE_SUB(NOW(), INTERVAL 40 DAY)),
(8010, 134, NULL, 'Bản quyền Phần mềm CRM Standard Hà Minh Vy',                240000000.00,  13, 5, 100.00, 'CLOSED_WON',  'ACTIVE', 2,    NULL, DATE_SUB(NOW(), INTERVAL 15 DAY), DATE_SUB(NOW(), INTERVAL 30 DAY)),
(8011, 156, 3,    'Triển khai CRM Nhà máy Sản xuất Đặng Đức Việt',              900000000.00,  16, 5, 100.00, 'CLOSED_WON',  'ACTIVE', 1,    NULL, DATE_SUB(NOW(), INTERVAL 25 DAY), DATE_SUB(NOW(), INTERVAL 50 DAY)),
(8012, 157, NULL, 'Dự án CRM Quản lý Logistics Hoàng Phương Lâm',              350000000.00,  16, 4,  80.00, 'OPEN',        'ACTIVE', NULL, NULL, DATE_ADD(NOW(), INTERVAL 20 DAY), DATE_SUB(NOW(), INTERVAL 10 DAY)),
(8013, 107, NULL, 'Hợp đồng CRM Doanh nghiệp Hoàng Văn Thảo',                  300000000.00,  7,  5, 100.00, 'CLOSED_WON',  'ACTIVE', 2,    NULL, DATE_SUB(NOW(), INTERVAL 35 DAY), DATE_SUB(NOW(), INTERVAL 70 DAY)),
(8014, 108, NULL, 'Dịch vụ Đào tạo Nhân sự Quản lý Hồ Thanh Trí',               50000000.00,   11, 5, 100.00, 'CLOSED_WON',  'ACTIVE', 3,    NULL, DATE_SUB(NOW(), INTERVAL 10 DAY), DATE_SUB(NOW(), INTERVAL 25 DAY)),
(8015, 109, 1,    'Triển khai CRM Giai đoạn 1 Lý Văn Minh',                     400000000.00,  11, 3,  50.00, 'OPEN',        'ACTIVE', NULL, NULL, DATE_ADD(NOW(), INTERVAL 30 DAY), DATE_SUB(NOW(), INTERVAL 15 DAY)),
(8016, 110, NULL, 'Gói Nâng cấp Tính năng Đa ngôn ngữ Lường Phương Linh',      120000000.00,  12, 2,  30.00, 'OPEN',        'ACTIVE', NULL, NULL, DATE_ADD(NOW(), INTERVAL 40 DAY), DATE_SUB(NOW(), INTERVAL 10 DAY)),
(8017, 135, NULL, 'Gói CRM Chuẩn hóa Khách hàng Lương Văn Hương',              200000000.00,  14, 5, 100.00, 'CLOSED_WON',  'ACTIVE', 1,    NULL, DATE_SUB(NOW(), INTERVAL 15 DAY), DATE_SUB(NOW(), INTERVAL 35 DAY)),
(8018, 136, 4,    'Dự án CRM Giáo dục Trần Hoài Thu (Thất bại)',               300000000.00,  15, 6,   0.00, 'CLOSED_LOST', 'ACTIVE', 5,    2,    DATE_SUB(NOW(), INTERVAL 5 DAY),  DATE_SUB(NOW(), INTERVAL 20 DAY)),
(8019, 158, NULL, 'Gói Dịch vụ CRM Cloud Tạ Ngọc Liên',                        180000000.00,  17, 5, 100.00, 'CLOSED_WON',  'ACTIVE', 2,    NULL, DATE_SUB(NOW(), INTERVAL 10 DAY), DATE_SUB(NOW(), INTERVAL 30 DAY)),
(8020, 159, NULL, 'Khảo sát Yêu cầu Số hóa Quy trình Ngô Quang Lộc',            70000000.00,   18, 1,  10.00, 'OPEN',        'ACTIVE', NULL, NULL, DATE_ADD(NOW(), INTERVAL 50 DAY), DATE_SUB(NOW(), INTERVAL 5 DAY))
ON DUPLICATE KEY UPDATE
    title = VALUES(title),
    amount = VALUES(amount),
    stage = VALUES(stage),
    probability = VALUES(probability);

-- =============================================================================
-- 37. BẢNG HOẠT ĐỘNG & TƯƠNG TÁC (activities) - 4 LOẠI: CALL, MEETING, EMAIL, NOTE
-- =============================================================================
INSERT INTO activities (activity_id, customer_id, lead_id, title, description, activity_type, owner_id, created_at) VALUES
(1,  101, NULL, 'Cuộc gọi tư vấn giải pháp CRM Enterprise',  'Đã trao đổi với anh Mai Ngọc Phúc CEO về lộ trình chuyển đổi số toàn diện.',          'CALL',    6,  DATE_SUB(NOW(), INTERVAL 45 DAY)),
(2,  101, NULL, 'Họp trực tiếp ký kết phụ lục triển khai',    'Họp tại văn phòng tòa nhà Mai Ngọc Phúc chốt danh sách tính năng triển khai Giai đoạn 2.',  'MEETING', 6,  DATE_SUB(NOW(), INTERVAL 40 DAY)),
(3,  101, NULL, 'Gửi file PDF báo giá chi tiết qua email',    'Đã gửi bảng tính giá chi tiết bao gồm phí bản quyền và gói đào tạo người dùng.',          'EMAIL',   6,  DATE_SUB(NOW(), INTERVAL 50 DAY)),
(4,  102, NULL, 'Cuộc gọi kiểm tra tiến độ thanh toán đợt 2', 'Đã liên hệ phòng kế toán Lương Bảo Hùng xác nhận chứng từ chuyển khoản hợp lệ.',        'CALL',    6,  DATE_SUB(NOW(), INTERVAL 35 DAY)),
(5,  102, NULL, 'Gửi email đề xuất gia hạn gói bảo trì',     'Đã gửi email nhắc hạn hợp đồng năm tiếp theo kèm chính sách ưu đãi 15%.',                   'EMAIL',   6,  DATE_SUB(NOW(), INTERVAL 30 DAY)),
(6,  103, NULL, 'Họp online khảo sát yêu cầu chi nhánh mới',  'Họp trực tuyến qua Google Meet với giám đốc công nghệ Mai Khánh Thảo.',                    'MEETING', 6,  DATE_SUB(NOW(), INTERVAL 15 DAY)),
(7,  104, NULL, 'Ghi chú nội bộ về lịch tái ký hợp đồng',    'Khách hàng Chu Công Tú dự kiến mở rộng quy mô kinh doanh vào đầu quý 1 năm tới.',           'NOTE',    6,  DATE_SUB(NOW(), INTERVAL 10 DAY)),
(8,  133, NULL, 'Gặp mặt đối tác tại triển lãm bán lẻ Đà Nẵng','Trao đổi trực tiếp với đại diện Trịnh Đức Hoa về tích hợp hóa đơn điện tử.',            'MEETING', 13, DATE_SUB(NOW(), INTERVAL 25 DAY)),
(9,  133, NULL, 'Gửi hợp đồng kinh tế chính thức qua bưu điện', 'Đã chuyển phát nhanh 02 bản hợp đồng gốc có đóng dấu đỏ cho Trịnh Đức Hoa.',           'EMAIL',   13, DATE_SUB(NOW(), INTERVAL 20 DAY)),
(10, 134, NULL, 'Cuộc gọi xác nhận nghiệm thu phần mềm',      'Đã chốt ngày ký biên bản bàn giao phần mềm và kích hoạt tài khoản sử dụng.',               'CALL',    13, DATE_SUB(NOW(), INTERVAL 12 DAY)),
(11, 156, NULL, 'Cuộc họp khởi động dự án CRM miền Nam',      'Thống nhất kế hoạch triển khai và mốc tiến độ bàn giao cho công ty Đặng Đức Việt.',        'MEETING', 16, DATE_SUB(NOW(), INTERVAL 22 DAY)),
(12, 157, NULL, 'Demo phân hệ quản lý kho và báo cáo',        'Trình diễn tính năng tùy biến bộ lọc và xuất dữ liệu báo cáo cho ban điều hành.',         'MEETING', 16, DATE_SUB(NOW(), INTERVAL 8 DAY)),
(13, NULL, 1,   'Cuộc gọi liên hệ đầu tiên tiếp nhận Lead #1', 'Nhân viên kinh doanh gọi xác nhận thông tin đăng ký tư vấn giải pháp qua web form.',      'CALL',    6,  NOW()),
(14, NULL, 2,   'Gửi email tài liệu giới thiệu sản phẩm',      'Đã gửi catalogue và bảng tính năng chi tiết cho khách hàng tiềm năng Lương Bảo Hùng.',     'EMAIL',   6,  DATE_SUB(NOW(), INTERVAL 2 HOUR)),
(15, NULL, 4,   'Ghi chú cập nhật tiến độ tư vấn Lead #4',    'Khách hàng Chu Công Tú đánh giá cao tính năng phân quyền dữ liệu My/Team/All.',            'NOTE',    6,  DATE_SUB(NOW(), INTERVAL 1 DAY)),
(16, 105, NULL, 'Cuộc gọi chăm sóc khách hàng định kỳ',       'Hỏi thăm tình hình vận hành hệ thống của công ty Nông Hoài Thủy.',                          'CALL',    9,  DATE_SUB(NOW(), INTERVAL 5 DAY)),
(17, 106, NULL, 'Email khảo sát mức độ hài lòng khách hàng',   'Gửi link khảo sát dịch vụ hỗ trợ kỹ thuật CSKH cho Đoàn Văn Bách.',                       'EMAIL',   21, DATE_SUB(NOW(), INTERVAL 7 DAY)),
(18, 135, NULL, 'Cuộc gọi hỗ trợ xử lý thắc mắc hóa đơn',     'Giải thích chi tiết các khoản phí triển khai ban đầu và chi phí đào tạo người dùng.',       'CALL',    22, DATE_SUB(NOW(), INTERVAL 4 DAY)),
(19, 158, NULL, 'Họp bàn giao hồ sơ bảo hành kỹ thuật',       'Bàn giao tài liệu hướng dẫn khắc phục sự cố cho đội ngũ IT Tạ Ngọc Liên.',                 'MEETING', 9,  DATE_SUB(NOW(), INTERVAL 6 DAY)),
(20, 101, NULL, 'Ghi chú tổng kết đánh giá dự án thành công',  'Hệ thống vận hành trơn tru đạt 100% mục tiêu ban giám đốc Mai Ngọc Phúc đề ra.',           'NOTE',    2,  DATE_SUB(NOW(), INTERVAL 2 DAY))
ON DUPLICATE KEY UPDATE
    title = VALUES(title),
    description = VALUES(description);

COMMIT;
SET FOREIGN_KEY_CHECKS = 1;

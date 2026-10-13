-- =============================================================================
-- CSDL HỆ THỐNG QUẢN LÝ KHÁCH HÀNG (CRM SYSTEM) - MASTER TEST DATA & SEED SCRIPT
-- File: test_data.sql
-- Thư mục: Backend/src/main/resources/sql/
-- Bộ ký tự: UTF-8 / utf8mb4
-- Mô tả: File dữ liệu thử nghiệm duy nhất, cung cấp đầy đủ dữ liệu mẫu cho
--       toàn bộ 27 bảng dữ liệu để kiểm thử mọi tính năng và kịch bản nghiệp vụ.
-- =============================================================================

USE crm_db;
SET NAMES utf8mb4;
SET CHARACTER SET utf8mb4;

SET FOREIGN_KEY_CHECKS = 0;
START TRANSACTION;

-- =============================================================================
-- 1. BẢNG PHÒNG BAN / NHÓM KINH DOANH (teams)
-- =============================================================================
INSERT INTO teams (team_id, team_name, description, region) VALUES
(1, 'Team Kinh Doanh Miền Bắc', 'Phụ trách thị trường Hà Nội và các tỉnh phía Bắc', 'Miền Bắc'),
(2, 'Team Kinh Doanh Miền Nam', 'Phụ trách thị trường TP.HCM và các tỉnh phía Nam', 'Miền Nam'),
(3, 'Team Kinh Doanh Miền Trung', 'Phụ trách thị trường Đà Nẵng và khu vực miền Trung', 'Miền Trung')
ON DUPLICATE KEY UPDATE 
    team_name = VALUES(team_name), 
    description = VALUES(description), 
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
-- 4. BẢNG GÁN QUYỀN CHO VAI TRÒ (role_permissions) - 87 LIÊN KẾT CHUẨN
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
-- 6. BẢNG NGƯỜI DÙNG / TÀI KHOẢN (users)
-- Mật khẩu mặc định đồng bộ cho TẤT CẢ các tài khoản: Admin12345
-- Hash BCrypt chuẩn: $2a$12$dUD9NdjA/XqMNErHhR3WJuTzoyo4mT2oXuPBDb6QPaPGPKiBzkrBe
-- =============================================================================
INSERT INTO users (user_id, email, password_hash, full_name, phone, team_id, is_active, failed_attempts, lockout_until) VALUES
(1,   'admin@company.com',              '$2a$12$dUD9NdjA/XqMNErHhR3WJuTzoyo4mT2oXuPBDb6QPaPGPKiBzkrBe', 'Quản Trị Viên Hệ Thống',    '0900000001', 1, 1, 0, NULL),
(2,   'director.test@example.com',       '$2a$12$dUD9NdjA/XqMNErHhR3WJuTzoyo4mT2oXuPBDb6QPaPGPKiBzkrBe', 'Vũ Văn Giám Đốc',           '0906789012', 1, 1, 0, NULL),
(3,   'teamlead.test@example.com',       '$2a$12$dUD9NdjA/XqMNErHhR3WJuTzoyo4mT2oXuPBDb6QPaPGPKiBzkrBe', 'Hoàng Văn Trưởng Nhóm',      '0905678901', 1, 1, 0, NULL),
(4,   'salesrep.test@example.com',       '$2a$12$dUD9NdjA/XqMNErHhR3WJuTzoyo4mT2oXuPBDb6QPaPGPKiBzkrBe', 'Nguyễn Văn Kinh Doanh',      '0901234567', 1, 1, 0, NULL),
(5,   'salesrep2.test@example.com',      '$2a$12$dUD9NdjA/XqMNErHhR3WJuTzoyo4mT2oXuPBDb6QPaPGPKiBzkrBe', 'Lê Văn Kinh Doanh Nam',     '0901234568', 2, 1, 0, NULL),
(6,   'marketing.test@example.com',      '$2a$12$dUD9NdjA/XqMNErHhR3WJuTzoyo4mT2oXuPBDb6QPaPGPKiBzkrBe', 'Trần Thị Marketing',         '0902345678', 1, 1, 0, NULL),
(7,   'customersuccess.test@example.com','$2a$12$dUD9NdjA/XqMNErHhR3WJuTzoyo4mT2oXuPBDb6QPaPGPKiBzkrBe', 'Lê Văn Chăm Sóc Khách Hàng', '0903456789', 1, 1, 0, NULL),
(8,   'accountant.test@example.com',     '$2a$12$dUD9NdjA/XqMNErHhR3WJuTzoyo4mT2oXuPBDb6QPaPGPKiBzkrBe', 'Phạm Thị Kế Toán',          '0904567890', 1, 1, 0, NULL),
(801, 'test.admin@crm.com',              '$2a$12$dUD9NdjA/XqMNErHhR3WJuTzoyo4mT2oXuPBDb6QPaPGPKiBzkrBe', 'Test System Admin',         '0900000801', 1, 1, 0, NULL),
(802, 'test.manager@crm.com',            '$2a$12$dUD9NdjA/XqMNErHhR3WJuTzoyo4mT2oXuPBDb6QPaPGPKiBzkrBe', 'Test Sales Manager',        '0900000802', 1, 1, 0, NULL),
(803, 'test.sales@crm.com',              '$2a$12$dUD9NdjA/XqMNErHhR3WJuTzoyo4mT2oXuPBDb6QPaPGPKiBzkrBe', 'Test Sales Rep',            '0900000803', 1, 1, 0, NULL),
(804, 'test.care@crm.com',               '$2a$12$dUD9NdjA/XqMNErHhR3WJuTzoyo4mT2oXuPBDb6QPaPGPKiBzkrBe', 'Test Customer Care',        '0900000804', 2, 1, 0, NULL)
ON DUPLICATE KEY UPDATE
    email = VALUES(email),
    password_hash = VALUES(password_hash),
    full_name = VALUES(full_name),
    phone = VALUES(phone),
    team_id = VALUES(team_id),
    is_active = VALUES(is_active);

-- =============================================================================
-- 7. BẢNG GÁN VAI TRÒ NGƯỜI DÙNG (user_roles)
-- =============================================================================
INSERT IGNORE INTO user_roles (user_id, role_id) VALUES
(1, 1),   -- Admin -> ADMIN
(2, 4),   -- Director -> DIRECTOR
(3, 3),   -- Teamlead -> TEAM_LEAD
(4, 2),   -- Salesrep -> SALES_REP
(5, 2),   -- Salesrep2 -> SALES_REP
(6, 5),   -- Marketing -> MARKETING
(7, 6),   -- CustSuccess -> CUST_SUCCESS
(8, 7),   -- Accountant -> ACCOUNTANT
(801, 1), -- Test Admin -> ADMIN
(802, 3), -- Test Manager -> TEAM_LEAD
(803, 2), -- Test Sales -> SALES_REP
(804, 6); -- Test Care -> CUST_SUCCESS

-- =============================================================================
-- 8. BẢNG DANH MỤC DÙNG CHUNG (categories)
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
-- 9. BẢNG SẢN PHẨM & DỊCH VỤ (products)
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
-- 10. BẢNG GIAI ĐOẠN BÁN HÀNG PIPELINE (pipeline_stages)
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
-- 11. BẢNG LÝ DO THẮNG / THUA (win_loss_reasons)
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
-- 12. BẢNG ĐỐI THỦ CẠNH TRANH (competitors)
-- =============================================================================
INSERT INTO competitors (competitor_id, competitor_name, status) VALUES
(1, 'Công ty Giải pháp Phần mềm Alpha', 'ACTIVE'),
(2, 'Công ty Công nghệ CRM Beta',       'ACTIVE'),
(3, 'Tập đoàn Hệ thống Thông tin Gamma', 'ACTIVE')
ON DUPLICATE KEY UPDATE status = VALUES(status);

-- =============================================================================
-- 13. BẢNG KHÁCH HÀNG / DOANH NGHIỆP (customers)
-- =============================================================================
INSERT INTO customers (customer_id, customer_name, phone, tax_code, email, status, industry, company_size, size, website, address, region, owner_id, created_at, updated_at) VALUES
-- Khách hàng mẫu chính thức (101 - 110)
(101, 'Tập đoàn Công nghệ FPT Global',                 '02437689001', '0101234567', 'contact@fpt.com.vn',        'Chính thức',     'Công nghệ thông tin', 'ENTERPRISE', '1000+',    'https://fpt.com.vn',        'Tòa nhà FPT, Cầu Giấy, Hà Nội',          'Miền Bắc', 4, DATE_SUB(NOW(), INTERVAL 120 DAY), NOW()),
(102, 'Công ty Cổ phần Đầu tư Bất động sản Vinhomes',   '02439749999', '0101234568', 'sales@vinhomes.vn',         'Chính thức',     'Bất động sản',        'ENTERPRISE', '1000+',    'https://vinhomes.vn',       'KĐT Times City, Hai Bà Trưng, Hà Nội',   'Miền Bắc', 4, DATE_SUB(NOW(), INTERVAL 100 DAY), NOW()),
(103, 'Ngân hàng TMCP Kỹ Thương Việt Nam (Techcombank)','02439446368', '0101234569', 'hotro@techcombank.com.vn', 'Chính thức',     'Tài chính - Ngân hàng','ENTERPRISE','1000+',    'https://techcombank.com.vn','Số 6 Quang Trung, Hoàn Kiếm, Hà Nội',    'Miền Bắc', 4, DATE_SUB(NOW(), INTERVAL 90 DAY),  NOW()),
(104, 'Công ty TNHH Bán lẻ Masan Retail',             '02854161234', '0301234570', 'info@masangroup.com',      'Chính thức',     'Bán lẻ - Tiêu dùng',  'LARGE',      '500-1000', 'https://masangroup.com',    'Tòa nhà MPlaza, Quận 1, TP.HCM',         'Miền Nam', 4, DATE_SUB(NOW(), INTERVAL 80 DAY),  NOW()),
(105, 'Tổng Công ty Dược phẩm Hậu Giang',              '02923891433', '0401234571', 'dhgpharma@dhgpharma.com.vn','Chính thức',     'Y tế - Dược phẩm',    'LARGE',      '500-1000', 'https://dhgpharma.com.vn',  '288 Bis Nguyễn Văn Cừ, Cần Thơ',         'Miền Nam', 4, DATE_SUB(NOW(), INTERVAL 70 DAY),  NOW()),
(106, 'Công ty Cổ phần Sữa Việt Nam (Vinamilk)',        '02854155555', '0301234572', 'vinamilk@vinamilk.com.vn',  'Chính thức',     'Sản xuất - Tiêu dùng','ENTERPRISE', '1000+',    'https://vinamilk.com.vn',   'Số 10 Tân Trào, Quận 7, TP.HCM',         'Miền Nam', 5, DATE_SUB(NOW(), INTERVAL 60 DAY),  NOW()),
(107, 'Tập đoàn Hòa Phát Group',                       '02462820700', '0101234573', 'contact@hoaphat.com.vn',   'Chính thức',     'Sản xuất - Công nghiệp','ENTERPRISE','1000+',    'https://hoaphat.com.vn',    '66 Nguyễn Du, Hai Bà Trưng, Hà Nội',     'Miền Bắc', 5, DATE_SUB(NOW(), INTERVAL 50 DAY),  NOW()),
(108, 'Công ty Cổ phần MISA',                          '02437959595', '0101234574', 'contact@misa.com.vn',      'Chính thức',     'Công nghệ thông tin', 'LARGE',      '500-1000', 'https://misa.com.vn',       'Tòa nhà MISA, Cầu Giấy, Hà Nội',         'Miền Bắc', 5, DATE_SUB(NOW(), INTERVAL 40 DAY),  NOW()),
(109, 'Tổng Công ty Hàng không Việt Nam (Vietnam Airlines)','02438732732','0101234575','support@vietnamairlines.com','Chính thức',   'Vận tải - Lữ hành',   'ENTERPRISE', '1000+',    'https://vietnamairlines.com','200 Nguyễn Sơn, Long Biên, Hà Nội',      'Miền Bắc', 5, DATE_SUB(NOW(), INTERVAL 30 DAY),  NOW()),
(110, 'Công ty Cổ phần Đầu tư Thế Giới Di Động',        '02838125960', '0301234576', 'investor@thegioididong.com','Chính thức',     'Bán lẻ - Tiêu dùng',  'ENTERPRISE', '1000+',    'https://mwg.vn',            'Khu CNC, TP. Thủ Đức, TP.HCM',           'Miền Nam', 5, DATE_SUB(NOW(), INTERVAL 20 DAY),  NOW()),

-- Nhóm khách hàng E2E & Kiểm thử cấu trúc Tập đoàn / Trùng lặp (801 - 817)
(801, 'TEST - Công ty A (Tập đoàn An Phát)',           '02438880001', '0108888001', 'contact@anphat-test.com',    'Chính thức',     'Công nghệ thông tin', 'ENTERPRISE', '500-1000', 'https://anphat-test.com',  'Tòa nhà An Phát, Nam Từ Liêm, Hà Nội',   'Miền Bắc', 803, DATE_SUB(NOW(), INTERVAL 90 DAY), NOW()),
(802, 'TEST - Công ty B (Tổng Công ty Bảo An)',         '02438880002', '0108888002', 'info@baoan-test.com',       'Chính thức',     'Tài chính - Ngân hàng','ENTERPRISE','1000+',    'https://baoan-test.com',   'Số 10 Lý Thường Kiệt, Hoàn Kiếm, Hà Nội', 'Miền Bắc', 803, DATE_SUB(NOW(), INTERVAL 120 DAY), NOW()),
(803, 'TEST - Công ty C (Công ty Cổ phần Cường Thịnh)', '02838880003', '0308888003', 'sales@cuongthinh-test.com', 'Chính thức',     'Sản xuất - Công nghiệp','MEDIUM',   '100-500',  'https://cuongthinh-test.com','KCN Tân Bình, Tân Phú, TP.HCM',          'Miền Nam', 803, DATE_SUB(NOW(), INTERVAL 80 DAY), NOW()),
(804, 'TEST - Công ty D (Tập đoàn Đại Nam)',            '02438880004', '0108888004', 'support@dainam-test.com',    'Chính thức',     'Bất động sản',        'LARGE',      '500-1000', 'https://dainam-test.com',   'Tòa nhà Đại Nam, Cầu Giấy, Hà Nội',      'Miền Bắc', 803, DATE_SUB(NOW(), INTERVAL 60 DAY), NOW()),
(805, 'TEST - Công ty E (Công ty TNHH E-Commerce)',     '02838880005', '0308888005', 'contact@ecom-test.com',      'Chính thức',     'Bán lẻ - Tiêu dùng',  'MEDIUM',     '50-100',   'https://ecom-test.com',     'Tầng 5 Bitexco, Quận 1, TP.HCM',          'Miền Nam', 803, DATE_SUB(NOW(), INTERVAL 45 DAY), NOW()),
(806, 'TEST - Công ty F (Công ty Dịch vụ Phong Nam)',   '02438880006', '0108888006', 'info@phongnam-test.com',    'Tiềm năng',      'Y tế - Dược phẩm',    'SMALL',      '10-50',    'https://phongnam-test.com', 'Phố Đội Cấn, Ba Đình, Hà Nội',           'Miền Bắc', 803, DATE_SUB(NOW(), INTERVAL 30 DAY), NOW()),
(807, 'TEST - Tập đoàn ABC (Parent Holding)',          '02438880007', '0108888007', 'group@abc-corp-test.com',   'Chính thức',     'Tài chính - Ngân hàng','ENTERPRISE','1000+',    'https://abc-corp-test.com', 'Tòa nhà ABC Tower, Ba Đình, Hà Nội',     'Miền Bắc', 803, DATE_SUB(NOW(), INTERVAL 150 DAY), NOW()),
(808, 'TEST - ABC Công ty con 1 (Công nghệ)',           '02438880008', '0108888008', 'sub1@abc-corp-test.com',    'Chính thức',     'Công nghệ thông tin', 'LARGE',      '100-500',  'https://sub1.abc-corp-test.com','Khu CNC Hòa Lạc, Hà Nội',             'Miền Bắc', 803, DATE_SUB(NOW(), INTERVAL 100 DAY), NOW()),
(809, 'TEST - ABC Công ty con 2 (Bán lẻ)',              '02838880009', '0308888009', 'sub2@abc-corp-test.com',    'Chính thức',     'Bán lẻ - Tiêu dùng',  'MEDIUM',     '50-100',   'https://sub2.abc-corp-test.com','Quận 3, TP.HCM',                         'Miền Nam', 803, DATE_SUB(NOW(), INTERVAL 90 DAY), NOW()),
(810, 'TEST - ABC Chi nhánh 3 Đà Nẵng',                 '02438880010', '0108888010', 'sub3@abc-corp-test.com',    'Chính thức',     'Dịch vụ',             'SMALL',      '10-50',    'https://sub3.abc-corp-test.com','Quận Hải Châu, Đà Nẵng',                 'Miền Nam', 803, DATE_SUB(NOW(), INTERVAL 80 DAY), NOW()),
(811, 'TEST - Công ty ABC Việt Nam (Primary)',          '0988111222',  '0109999111', 'contact@abcvietnam-test.com','Chính thức',     'Công nghệ thông tin', 'MEDIUM',     '50-100',   'https://abcvietnam-test.com','Số 88 Nguyễn Chí Thanh, Hà Nội',          'Miền Bắc', 801, DATE_SUB(NOW(), INTERVAL 40 DAY), NOW()),
(812, 'TEST - Công ty ABC Việt Nam Technology (Sec)',   '0988111222',  '0109999112', 'sec@abcvietnam-test.com',    'Tiềm năng',      'Công nghệ thông tin', 'MEDIUM',     '50-100',   'https://abcvietnam-test.com','Số 88 Nguyễn Chí Thanh, Hà Nội',          'Miền Bắc', 801, DATE_SUB(NOW(), INTERVAL 35 DAY), NOW()),
(813, 'TEST - Công ty Gia Định (Tour & Du lịch)',       '02838880013', '0308888013', 'contact@giadinh-test.com',   'Chính thức',     'Vận tải - Lữ hành',   'MEDIUM',     '100-500',  'https://giadinh-test.com',  'Quận Bình Thạnh, TP.HCM',                 'Miền Nam', 803, DATE_SUB(NOW(), INTERVAL 90 DAY), NOW()),
(814, 'TEST - Công ty Hải Hà (Thực phẩm)',              '02438880014', '0108888014', 'info@haiha-test.com',        'Chính thức',     'Thực phẩm - Đồ uống', 'SMALL',      '10-50',    'https://haiha-test.com',    'Quận Long Biên, Hà Nội',                  'Miền Bắc', 803, DATE_SUB(NOW(), INTERVAL 70 DAY), NOW()),
(815, 'TEST - Công ty Hoàng Kim (Dịch vụ)',             '02438880015', '0108888015', 'sales@hoangkim-test.com',   'Tiềm năng',      'Dịch vụ',             'SMALL',      '10-50',    'https://hoangkim-test.com', 'Quận Thanh Xuân, Hà Nội',                 'Miền Bắc', 803, DATE_SUB(NOW(), INTERVAL 60 DAY), NOW()),
(816, 'TEST - Công ty Khánh Hòa (Logistics)',           '02583880016', '0408888016', 'contact@khanhhoa-test.com',  'Chính thức',     'Vận tải - Lữ hành',   'LARGE',      '500-1000', 'https://khanhhoa-test.com', 'TP. Nha Trang, Khánh Hòa',                'Miền Nam', 803, DATE_SUB(NOW(), INTERVAL 50 DAY), NOW()),
(817, 'TEST - Công ty Nông sản Lâm Đồng',               '02633888999', '0318888777', 'info@lamdong-test.com',     'Ngừng hợp tác',  'Nông nghiệp',         'SMALL',      '10-50',    'https://lamdong-test.com',  'TP. Đà Lạt, Lâm Đồng',                    'Miền Nam', 803, DATE_SUB(NOW(), INTERVAL 100 DAY), NOW()),

-- Nhóm khách hàng kiểm thử phân quyền & chuyển công ty (981 - 983)
(981, 'Tập đoàn Công nghệ Sao Mai',                    '0243999981',  '0109999981', 'contact@saomai-test.vn',     'Chính thức',     'Công nghệ thông tin', 'ENTERPRISE', '500-1000', 'https://saomai-test.vn',   'Tòa nhà Sao Mai, Cầu Giấy, Hà Nội',       'Miền Bắc', 4,   DATE_SUB(NOW(), INTERVAL 30 DAY), NOW()),
(982, 'Công ty Cổ phần Giải pháp Thiên Hà',            '0243999982',  '0109999982', 'info@thienha-test.vn',      'Chính thức',     'Tài chính - Ngân hàng','LARGE',      '100-500',  'https://thienha-test.vn',   'Số 88 Phố Huế, Hai Bà Trưng, Hà Nội',    'Miền Bắc', 4,   DATE_SUB(NOW(), INTERVAL 30 DAY), NOW()),
(983, 'Tổng Công ty Đầu tư Phương Nam',                 '0283999983',  '0309999983', 'sales@phuongnam-test.vn',   'Tiềm năng',      'Bất động sản',        'MEDIUM',     '50-100',   'https://phuongnam-test.vn', '200 Nguyễn Thị Minh Khai, Quận 3, TP.HCM','Miền Nam', 5,   DATE_SUB(NOW(), INTERVAL 30 DAY), NOW())
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
-- 14. BẢNG NGƯỜI LIÊN HỆ (contacts) - ĐỦ 4 VAI TRÒ MUA & ĐẦU MỐI CHÍNH
-- =============================================================================
INSERT INTO contacts (contact_id, customer_id, full_name, position, title, email, phone, buying_role, is_primary, created_at) VALUES
-- Khách 801 (An Phát)
(8001, 801, 'Nguyễn Văn An',     'Giám đốc Công nghệ (CTO)', 'CTO',               'an.nguyen@anphat-test.com',   '0901118001', 'DECIDER',    1, NOW()),
(8002, 801, 'Trần Thị Bích',     'Trưởng phòng IT',           'Trưởng phòng IT',   'bich.tran@anphat-test.com',   '0901118002', 'INFLUENCER', 0, NOW()),
-- Khách 802 (Bảo An)
(8003, 802, 'Bảo Văn Nam',       'Tổng Giám đốc (CEO)',       'CEO',               'nam.bao@baoan-test.com',      '0901118003', 'DECIDER',    1, NOW()),
(8004, 802, 'Phạm Thị Hoa',      'Giám đốc Tài chính (CFO)',  'CFO',               'hoa.pham@baoan-test.com',     '0901118004', 'INFLUENCER', 0, NOW()),
-- Khách 803 (Cường Thịnh)
(8005, 803, 'Cường Văn Thịnh',   'Giám đốc Nhà máy',          'GĐ Nhà máy',        'thinh.cuong@cuongthinh-test.com','0901118005','DECIDER',    1, NOW()),
-- Khách 804 (Đại Nam)
(8006, 804, 'Đặng Văn Dũng',     'Phó Tổng Giám đốc',         'Phó TGĐ',           'dung.dang@dainam-test.com',   '0901118006', 'DECIDER',    1, NOW()),
(8007, 804, 'Vũ Thị Em',         'Trưởng phòng CSKH',         'Trưởng phòng CSKH', 'em.vu@dainam-test.com',       '0901118007', 'END_USER',   0, NOW()),
-- Khách 805 (E-Commerce)
(8008, 805, 'Hồ Văn Giang',      'Trưởng phòng Mua hàng',     'Trưởng phòng Mua',  'giang.ho@ecom-test.com',      '0901118008', 'DECIDER',    1, NOW()),
-- Khách 806 (Phong Nam)
(8009, 806, 'Lê Văn Hải',        'Giám đốc Điều hành (COO)',  'COO',               'hai.le@phongnam-test.com',    '0901118009', 'DECIDER',    1, NOW()),
-- Khách 807 - 810 (Tập đoàn ABC)
(8010, 807, 'Đỗ Văn Hùng',       'Chủ tịch HĐQT',             'Chủ tịch',          'hung.do@abc-corp-test.com',   '0901118010', 'DECIDER',    1, NOW()),
(8011, 808, 'Ngô Thị Mai',       'Giám đốc Chi nhánh 1',      'GĐ Chi nhánh',      'mai.ngo@sub1.abc-corp-test.com','0901118011','DECIDER',   1, NOW()),
(8012, 809, 'Phan Văn Phong',    'Giám đốc Chi nhánh 2',      'GĐ Chi nhánh',      'phong.phan@sub2.abc-corp-test.com','0901118012','DECIDER',1, NOW()),
(8013, 810, 'Bùi Văn Quảng',     'Trưởng đại diện Đà Nẵng',   'Trưởng đại diện',   'quang.bui@sub3.abc-corp-test.com','0901118013','DECIDER', 1, NOW()),
-- Khách 811 - 812 (Trùng lặp)
(8014, 811, 'Nguyễn Văn Primary','Trưởng phòng Kinh doanh',   'TP Kinh doanh',     'pri@abcvietnam-test.com',     '0988111222', 'DECIDER',    1, NOW()),
(8015, 812, 'Nguyễn Văn Secondary','Trưởng phòng Kỹ thuật',   'TP Kỹ thuật',       'sec@abcvietnam-test.com',     '0988111222', 'DECIDER',    1, NOW()),
-- Khách 816 (Đủ 4 vai trò mua DECIDER, INFLUENCER, END_USER, BLOCKER)
(8019, 816, 'Nguyễn Thị Vinh',   'Tổng Giám đốc',             'TGĐ',               'vinh.nguyen@khanhhoa-test.com','0901118019', 'DECIDER',    1, NOW()),
(8020, 816, 'Trần Văn Xuân',     'Trưởng phòng CNTT',         'TP CNTT',           'xuan.tran@khanhhoa-test.com', '0901118020', 'INFLUENCER', 0, NOW()),
(8021, 816, 'Lê Thị Yến',        'Nhân viên Vận hành',        'Vận hành',          'yen.le@khanhhoa-test.com',    '0901118021', 'END_USER',   0, NOW()),
(8022, 816, 'Phạm Văn Zuy',      'Trưởng phòng Pháp chế',     'TP Pháp chế',       'zuy.pham@khanhhoa-test.com',  '0901118022', 'BLOCKER',    0, NOW()),
-- Khách 981 - 983
(9801, 981, 'Đào Văn Quyết',     'Chủ tịch HĐQT',             'Chủ tịch',          'quyet.dao@saomai-test.vn',    '0912999801', 'DECIDER',    1, NOW()),
(9802, 981, 'Lý Thị Hằng',       'Kế toán trưởng',            'KTT',               'hang.ly@saomai-test.vn',      '0912999802', 'INFLUENCER', 0, NOW()),
(9803, 981, 'Chu Văn Trọng',     'Trưởng ban Kiểm soát',      'Kiểm soát',         'trong.chu@saomai-test.vn',    '0912999803', 'BLOCKER',    0, NOW()),
(9804, 982, 'Vương Thị Thảo',    'Chuyên viên Mua sắm',       'Chuyên viên Mua',   'thao.vuong@thienha-test.vn',  '0912999804', 'END_USER',   0, NOW()),
(9805, 982, 'Mai Văn Tiến',      'Giám đốc Chiến lược',       'GĐ Chiến lược',     'tien.mai@thienha-test.vn',    '0912999805', 'DECIDER',    1, NOW()),
(9806, 982, 'Phùng Văn Đức',     'Kỹ sư Triển khai',          'Kỹ sư',             'duc.phung@thienha-test.vn',   '0912999806', 'END_USER',   0, NOW()),
(9807, 983, 'Lâm Thị Ngọc',      'Phó Giám đốc Kỹ thuật',     'Phó GĐ',            'ngoc.lam@phuongnam-test.vn',  '0912999807', 'INFLUENCER', 1, NOW())
ON DUPLICATE KEY UPDATE
    full_name = VALUES(full_name),
    position = VALUES(position),
    title = VALUES(title),
    email = VALUES(email),
    phone = VALUES(phone),
    buying_role = VALUES(buying_role),
    is_primary = VALUES(is_primary);

-- =============================================================================
-- 15. BẢNG LỊCH SỬ CHUYỂN CÔNG TY (contact_company_history)
-- =============================================================================
INSERT INTO contact_company_history (history_id, contact_id, from_customer_id, to_customer_id, transferred_at, reason, transferred_by) VALUES
(1, 9804, 981, 982, DATE_SUB(NOW(), INTERVAL 15 DAY), 'Chuyển công tác từ Tập đoàn Sao Mai sang Thiên Hà theo quyết định nhân sự', 4),
(2, 9805, 981, 982, DATE_SUB(NOW(), INTERVAL 45 DAY), 'Điều động tăng cường quản lý cấp cao cho Thiên Hà Solutions', 4),
(3, 8004, 801, 802, DATE_SUB(NOW(), INTERVAL 60 DAY), 'Chuyển công tác từ An Phát sang làm Giám đốc tài chính Tổng Công ty Bảo An', 803),
(4, 8005, 802, 803, DATE_SUB(NOW(), INTERVAL 90 DAY), 'Bổ nhiệm sang làm Giám đốc nhà máy Công ty Cường Thịnh', 803)
ON DUPLICATE KEY UPDATE 
    reason = VALUES(reason), 
    transferred_at = VALUES(transferred_at);

-- =============================================================================
-- 16. BẢNG CƠ HỘI BÁN HÀNG (opportunities)
-- =============================================================================
INSERT INTO opportunities (opportunity_id, customer_id, title, amount, owner_id, pipeline_stage_id, probability, stage, win_loss_reason_id, competitor_id, close_date, created_at) VALUES
-- Doanh số đã ký và cơ hội lớn
(8001, 801, 'Hợp đồng ERP Doanh nghiệp An Phát - Giai đoạn 1', 1000000000.00, 803, 5, 100.00, 'CLOSED_WON',  1, NULL, DATE_SUB(NOW(), INTERVAL 60 DAY), DATE_SUB(NOW(), INTERVAL 90 DAY)),
(8002, 801, 'Bản quyền Phần mềm CRM An Phát - Giai đoạn 2',    500000000.00, 803, 5, 100.00, 'CLOSED_WON',  2, NULL, DATE_SUB(NOW(), INTERVAL 30 DAY), DATE_SUB(NOW(), INTERVAL 60 DAY)),
(8003, 801, 'Gói Bảo trì & Nâng cấp Hệ thống An Phát',         300000000.00, 803, 3,  50.00, 'OPEN',        NULL, NULL, DATE_ADD(NOW(), INTERVAL 30 DAY), DATE_SUB(NOW(), INTERVAL 15 DAY)),
(8004, 802, 'Hợp đồng Chuyển đổi số Toàn diện Bảo An',      2000000000.00, 803, 5, 100.00, 'CLOSED_WON',  1, NULL, DATE_SUB(NOW(), INTERVAL 90 DAY), DATE_SUB(NOW(), INTERVAL 120 DAY)),
(8005, 803, 'Gói CRM Tự động hóa Bán hàng Cường Thịnh',      100000000.00, 803, 5, 100.00, 'CLOSED_WON',  3, NULL, DATE_SUB(NOW(), INTERVAL 45 DAY), DATE_SUB(NOW(), INTERVAL 80 DAY)),
(8006, 804, 'Số hóa Quản lý Dự án Bất động sản Đại Nam',       800000000.00, 803, 5, 100.00, 'CLOSED_WON',  2, NULL, DATE_SUB(NOW(), INTERVAL 15 DAY), DATE_SUB(NOW(), INTERVAL 60 DAY)),
(8007, 805, 'Hệ thống Quản lý Đơn hàng E-Commerce',          450000000.00, 803, 5, 100.00, 'CLOSED_WON',  2, NULL, DATE_SUB(NOW(), INTERVAL 20 DAY), DATE_SUB(NOW(), INTERVAL 45 DAY)),
(8008, 806, 'Tư vấn Giải pháp Quản lý Y tế Phong Nam',       150000000.00, 803, 2,  30.00, 'OPEN',        NULL, NULL, DATE_ADD(NOW(), INTERVAL 45 DAY), DATE_SUB(NOW(), INTERVAL 20 DAY)),
(8009, 806, 'Cung cấp Thiết bị Công nghệ Phong Nam',           80000000.00, 803, 1,  10.00, 'OPEN',        NULL, NULL, DATE_ADD(NOW(), INTERVAL 60 DAY), DATE_SUB(NOW(), INTERVAL 10 DAY)),
(8010, 806, 'Gói Đào tạo Nhân sự Y tế (Thất bại)',           200000000.00, 803, 6,   0.00, 'CLOSED_LOST', 4, 1,    DATE_SUB(NOW(), INTERVAL 10 DAY), DATE_SUB(NOW(), INTERVAL 30 DAY)),
-- Cụm Tập đoàn ABC (Doanh số công ty mẹ và 3 công ty con)
(8011, 807, 'Triển khai CRM Core Tập đoàn ABC (Mẹ)',        3000000000.00, 803, 5, 100.00, 'CLOSED_WON',  1, NULL, DATE_SUB(NOW(), INTERVAL 100 DAY), DATE_SUB(NOW(), INTERVAL 150 DAY)),
(8012, 808, 'Triển khai CRM Chi nhánh 1 ABC (Con 1)',       1000000000.00, 803, 5, 100.00, 'CLOSED_WON',  2, NULL, DATE_SUB(NOW(), INTERVAL 70 DAY), DATE_SUB(NOW(), INTERVAL 100 DAY)),
(8013, 809, 'Triển khai CRM Chi nhánh 2 ABC (Con 2)',        500000000.00, 803, 5, 100.00, 'CLOSED_WON',  3, NULL, DATE_SUB(NOW(), INTERVAL 60 DAY), DATE_SUB(NOW(), INTERVAL 90 DAY)),
(8014, 810, 'Triển khai CRM Chi nhánh 3 ABC (Chi nhánh)',    200000000.00, 803, 5, 100.00, 'CLOSED_WON',  1, NULL, DATE_SUB(NOW(), INTERVAL 40 DAY), DATE_SUB(NOW(), INTERVAL 80 DAY)),
-- Nhóm khách 981 - 982
(9801, 981, 'Hợp đồng Nền tảng Đám mây Sao Mai Cloud',       650000000.00, 4,   5, 100.00, 'CLOSED_WON',  2, NULL, DATE_SUB(NOW(), INTERVAL 25 DAY), DATE_SUB(NOW(), INTERVAL 40 DAY)),
(9802, 982, 'Hệ thống Quản lý Giao dịch Thiên Hà Core',      350000000.00, 4,   5, 100.00, 'CLOSED_WON',  1, NULL, DATE_SUB(NOW(), INTERVAL 15 DAY), DATE_SUB(NOW(), INTERVAL 30 DAY))
ON DUPLICATE KEY UPDATE 
    title = VALUES(title), 
    amount = VALUES(amount), 
    stage = VALUES(stage), 
    probability = VALUES(probability);

-- =============================================================================
-- 17. BẢNG QUAN HỆ TẬP ĐOÀN CÔNG TY MẸ - CON (customer_relationships)
-- =============================================================================
INSERT INTO customer_relationships (relationship_id, parent_customer_id, child_customer_id, relationship_type, created_at) VALUES
(1, 807, 808, 'SUBSIDIARY', NOW()), -- Tập đoàn ABC -> Công ty con 1
(2, 807, 809, 'SUBSIDIARY', NOW()), -- Tập đoàn ABC -> Công ty con 2
(3, 807, 810, 'BRANCH',     NOW()), -- Tập đoàn ABC -> Chi nhánh 3
(4, 981, 982, 'SUBSIDIARY', NOW())  -- Sao Mai -> Thiên Hà
ON DUPLICATE KEY UPDATE relationship_type = VALUES(relationship_type);

-- =============================================================================
-- 18. BẢNG LỊCH SỬ GỘP KHÁCH HÀNG (customer_merges)
-- =============================================================================
INSERT INTO customer_merges (merge_id, primary_customer_id, secondary_customer_id, merged_data, merged_by, created_at) VALUES
(1, 801, 812, '{"old_name":"TEST - Công ty ABC Việt Nam Technology","old_phone":"0988111222","note":"Gộp trùng mã số thuế"}', 801, DATE_SUB(NOW(), INTERVAL 10 DAY)),
(2, 802, 811, '{"old_name":"TEST - Công ty ABC Việt Nam","old_phone":"0988111222","note":"Gộp hồ sơ trùng lặp"}', 801, DATE_SUB(NOW(), INTERVAL 5 DAY))
ON DUPLICATE KEY UPDATE merged_data = VALUES(merged_data);

-- =============================================================================
-- 19. BẢNG ĐỊNH NGHĨA TRƯỜNG TÙY CHỈNH (custom_field_definitions)
-- =============================================================================
INSERT INTO custom_field_definitions (field_id, entity_type, field_key, field_label, field_type, options, is_required, default_value, display_order, status) VALUES
(1, 'CUSTOMER', 'tax_bracket',       'Phân nhóm Doanh nghiệp', 'SELECT', 'Doanh nghiệp lớn (Hạng A),Doanh nghiệp vừa (Hạng B),Doanh nghiệp nhỏ (Hạng C)', 0, 'Doanh nghiệp lớn (Hạng A)', 1, 'ACTIVE'),
(2, 'CUSTOMER', 'facebook_fanpage',  'Trang Fanpage Doanh nghiệp', 'TEXT',   NULL, 0, NULL, 2, 'ACTIVE'),
(3, 'CUSTOMER', 'annual_revenue_usd','Doanh thu Ước tính (USD)','NUMBER', NULL, 0, '0', 3, 'ACTIVE'),
(4, 'CUSTOMER', 'erp_system',        'Hệ thống ERP đang dùng', 'TEXT',   NULL, 0, 'Chưa có', 4, 'ACTIVE'),
(5, 'CUSTOMER', 'contract_renewal_date', 'Hạn gia hạn hợp đồng', 'DATE', NULL, 0, NULL, 5, 'ACTIVE'),
(6, 'OPPORTUNITY', 'deploy_deadline', 'Hạn hoàn thành triển khai', 'DATE', NULL, 0, NULL, 1, 'ACTIVE'),
(7, 'OPPORTUNITY', 'software_edition', 'Phiên bản phần mềm dự kiến', 'SELECT', 'Standard Cloud,Enterprise Dedicated,On-Premise Custom', 1, 'Enterprise Dedicated', 2, 'ACTIVE'),
(8, 'OPPORTUNITY', 'user_licenses', 'Số lượng tài khoản dự kiến', 'NUMBER', NULL, 0, '50', 3, 'ACTIVE'),
(9, 'OPPORTUNITY', 'procurement_poc', 'Đầu mối mua sắm phía khách hàng', 'TEXT', NULL, 0, NULL, 4, 'ACTIVE')
ON DUPLICATE KEY UPDATE 
    field_label = VALUES(field_label), 
    field_type = VALUES(field_type), 
    options = VALUES(options),
    is_required = VALUES(is_required);

-- =============================================================================
-- 20. BẢNG GIÁ TRỊ TRƯỜNG TÙY CHỈNH (custom_field_values)
-- =============================================================================
INSERT INTO custom_field_values (value_id, field_id, entity_type, entity_id, field_value) VALUES
(1, 1, 'CUSTOMER', 101, 'Doanh nghiệp lớn (Hạng A)'),
(2, 2, 'CUSTOMER', 101, 'https://facebook.com/fptglobal'),
(3, 3, 'CUSTOMER', 101, '15000000'),
(4, 4, 'CUSTOMER', 101, 'SAP ERP'),
(5, 1, 'CUSTOMER', 801, 'Doanh nghiệp lớn (Hạng A)'),
(6, 2, 'CUSTOMER', 801, 'https://facebook.com/anphatgroup'),
(7, 3, 'CUSTOMER', 801, '8000000'),
(8, 4, 'CUSTOMER', 801, 'Oracle NetSuite')
ON DUPLICATE KEY UPDATE field_value = VALUES(field_value);

-- =============================================================================
-- 21. BẢNG HOẠT ĐỘNG & TƯƠNG TÁC (activities)
-- =============================================================================
INSERT INTO activities (activity_id, customer_id, title, description, activity_type, owner_id, created_at) VALUES
(1,  801, 'Cuộc gọi tư vấn giải pháp CRM',        'Đã trao đổi với anh An CTO về kế hoạch nâng cấp giai đoạn 2.', 'CALL',    803, DATE_SUB(NOW(), INTERVAL 45 DAY)),
(2,  801, 'Họp trực tiếp thống nhất yêu cầu',     'Họp tại văn phòng An Phát chốt danh sách tính năng triển khai.', 'MEETING', 803, DATE_SUB(NOW(), INTERVAL 50 DAY)),
(3,  801, 'Gửi báo giá nâng cấp hệ thống',       'Đã gửi file PDF báo giá chi tiết qua email cho ban giám đốc.',  'EMAIL',   803, DATE_SUB(NOW(), INTERVAL 55 DAY)),
(4,  802, 'Cuộc gọi kiểm tra định kỳ Bảo An',     'Đã liên hệ chị Hoa CFO trao đổi kế hoạch thanh toán đợt 2.',    'CALL',    803, DATE_SUB(NOW(), INTERVAL 60 DAY)),
(5,  802, 'Gửi email đề xuất gia hạn dịch vụ',   'Đã gửi email nhắc hạn hợp đồng năm tiếp theo kèm ưu đãi.',      'EMAIL',   803, DATE_SUB(NOW(), INTERVAL 65 DAY)),
(6,  804, 'Họp online xử lý sự cố BĐS Đại Nam',   'Họp khẩn làm rõ nguyên nhân lỗi kết nối CSDL và khắc phục.',    'MEETING', 804, DATE_SUB(NOW(), INTERVAL 2 DAY)),
(7,  805, 'Tiếp nhận cuộc gọi báo lỗi E-Commerce','Đã ghi nhận sự cố gián đoạn cổng thanh toán và chuyển kỹ thuật','CALL',   804, DATE_SUB(NOW(), INTERVAL 3 HOUR)),
(8,  816, 'Gặp mặt ban giám đốc Khánh Hòa',       'Thảo luận hợp đồng dịch vụ vận tải du lịch.',                  'MEETING', 803, DATE_SUB(NOW(), INTERVAL 25 DAY)),
(9,  816, 'Gửi hợp đồng nguyên tắc qua email',    'Đã gửi dự thảo hợp đồng chính thức có chữ ký số.',             'EMAIL',   803, DATE_SUB(NOW(), INTERVAL 20 DAY)),
(10, 816, 'Cuộc gọi xác nhận ký kết',            'Đã chốt ngày ký hợp đồng và bàn giao thiết bị.',               'CALL',    803, DATE_SUB(NOW(), INTERVAL 15 DAY)),
(11, 981, 'Cuộc họp khởi động dự án Sao Mai',    'Thống nhất kế hoạch di chuyển dữ liệu lên đám mây.',           'MEETING', 4,   DATE_SUB(NOW(), INTERVAL 25 DAY)),
(12, 982, 'Demo tính năng CRM cho Thiên Hà',     'Trình diễn phân hệ quản lý người liên hệ và vai trò mua.',     'MEETING', 4,   DATE_SUB(NOW(), INTERVAL 15 DAY))
ON DUPLICATE KEY UPDATE 
    title = VALUES(title), 
    description = VALUES(description);

-- =============================================================================
-- 22. BẢNG BÁO GIÁ (quotes)
-- =============================================================================
INSERT INTO quotes (quote_id, quote_number, owner_id) VALUES
(1,  'BG-2026-FPT-01',     4),
(2,  'BG-2026-VHM-02',     4),
(3,  'BG-2026-TCB-03',     4),
(4,  'BG-2026-MSN-04',     4),
(5,  'BG-2026-DHG-05',     4),
(6,  'BG-2026-VNM-06',     5),
(7,  'BG-2026-HPG-07',     5),
(8,  'BG-2026-ANPHAT-08',  803),
(9,  'BG-2026-BAOAN-09',   803),
(10, 'BG-2026-SAOMAI-10',  4)
ON DUPLICATE KEY UPDATE quote_number = VALUES(quote_number);

-- =============================================================================
-- 23. BẢNG YÊU CẦU HỖ TRỢ SAU BÁN (support_requests)
-- =============================================================================
INSERT INTO support_requests (request_id, customer_id, title, description, priority, status, assignee_id, created_by, created_at, updated_at) VALUES
(1, 801, 'Hướng dẫn xuất báo cáo doanh thu Excel',     'Khách hàng cần hỗ trợ xuất báo cáo định dạng Excel theo mẫu riêng.', 'LOW',    'RESOLVED',    804, 803, DATE_SUB(NOW(), INTERVAL 5 DAY), NOW()),
(2, 804, 'Lỗi kết nối cơ sở dữ liệu hệ thống BĐS',     'Hệ thống báo lỗi mất kết nối máy chủ dữ liệu từ đầu giờ sáng.',    'HIGH',   'IN_PROGRESS', 804, 803, DATE_SUB(NOW(), INTERVAL 2 DAY), NOW()),
(3, 804, 'Không đồng bộ được danh sách căn hộ mới',    'Dữ liệu căn hộ mới thêm không hiển thị trên giao diện CRM.',        'MEDIUM', 'OPEN',        804, 803, DATE_SUB(NOW(), INTERVAL 1 DAY), NOW()),
(4, 805, 'SỰ CỐ KHẨN CẤP: Gián đoạn cổng thanh toán',  'Khách hàng phản ánh cổng thanh toán đơn hàng bị ngưng hoạt động.', 'URGENT', 'RESOLVED',    804, 803, DATE_SUB(NOW(), INTERVAL 3 HOUR), NOW()),
(5, 806, 'Hỏi đáp về quy trình bảo hành phần mềm',     'Khách hàng thắc mắc điều khoản gia hạn bảo hành năm thứ hai.',      'MEDIUM', 'CLOSED',      804, 803, DATE_SUB(NOW(), INTERVAL 20 DAY), NOW()),
(6, 981, 'Hỗ trợ thiết lập email tên miền riêng',       'Cần hướng dẫn cấu hình SMTP gửi email thông báo từ CRM.',           'LOW',    'OPEN',        804, 4,   DATE_SUB(NOW(), INTERVAL 3 DAY), NOW()),
(7, 982, 'Yêu cầu mở rộng phân quyền xem báo cáo',     'Giám đốc chiến lược cần quyền truy cập dashboard toàn diện.',       'MEDIUM', 'RESOLVED',    804, 4,   DATE_SUB(NOW(), INTERVAL 7 DAY), NOW())
ON DUPLICATE KEY UPDATE 
    title = VALUES(title), 
    status = VALUES(status), 
    priority = VALUES(priority);

-- =============================================================================
-- 24. BẢNG CHĂM SÓC KHÁCH HÀNG ĐỊNH KỲ (customer_care)
-- =============================================================================
INSERT INTO customer_care (care_id, customer_id, last_contacted_at, last_contacted_by, inactive_threshold_days, note, created_at, updated_at) VALUES
(1, 801, DATE_SUB(NOW(), INTERVAL 45 DAY), 803, 30, 'Khách hàng chưa liên hệ lại từ tháng trước, cần gọi hỏi thăm.', DATE_SUB(NOW(), INTERVAL 90 DAY), NOW()),
(2, 802, DATE_SUB(NOW(), INTERVAL 60 DAY), 803, 30, 'Cần lên lịch gọi điện chăm sóc gia hạn hợp đồng năm tới.',      DATE_SUB(NOW(), INTERVAL 120 DAY), NOW()),
(3, 803, DATE_SUB(NOW(), INTERVAL 40 DAY), 803, 30, 'Khách hàng hài lòng nhưng cần hỏi thăm định kỳ.',               DATE_SUB(NOW(), INTERVAL 80 DAY), NOW()),
(4, 804, DATE_SUB(NOW(), INTERVAL 2 DAY),  804, 30, 'Vừa trao đổi xử lý sự cố kỹ thuật, tình trạng ổn định.',        DATE_SUB(NOW(), INTERVAL 60 DAY), NOW()),
(5, 805, DATE_SUB(NOW(), INTERVAL 10 DAY), 804, 30, 'Đã xác nhận sự cố thanh toán và khắc phục triệt để.',          DATE_SUB(NOW(), INTERVAL 45 DAY), NOW()),
(6, 807, DATE_SUB(NOW(), INTERVAL 50 DAY), 803, 30, 'Tập đoàn mẹ lâu chưa tương tác, cần sắp xếp lịch hẹn VIP.',    DATE_SUB(NOW(), INTERVAL 150 DAY), NOW()),
(7, 813, NULL,                             NULL, 30, 'Khách mới ký hợp đồng nhưng chưa từng có lượt chăm sóc.',      DATE_SUB(NOW(), INTERVAL 90 DAY), NOW()),
(8, 814, DATE_SUB(NOW(), INTERVAL 50 DAY), 803, 30, 'Giá trị hợp đồng nhỏ, lâu chưa tương tác chăm sóc.',            DATE_SUB(NOW(), INTERVAL 70 DAY), NOW()),
(9, 981, DATE_SUB(NOW(), INTERVAL 5 DAY),  4,   30, 'Khách hàng Sao Mai hoạt động tích cực sau khi triển khai.',     DATE_SUB(NOW(), INTERVAL 30 DAY), NOW())
ON DUPLICATE KEY UPDATE 
    last_contacted_at = VALUES(last_contacted_at), 
    note = VALUES(note);

-- =============================================================================
-- 25. BẢNG BỘ LỌC ĐÃ LƯU (saved_filters)
-- =============================================================================
INSERT INTO saved_filters (filter_id, user_id, filter_name, module, keyword, status, industry, company_size, region, owner_id, filter_query, is_default, created_at) VALUES
(1, 803, 'Khách hàng Miền Bắc - IT',    'CUSTOMER', '', 'Chính thức', 'Công nghệ thông tin', '',           'Miền Bắc', 803, 'status=Chính thức&industry=Công nghệ thông tin&region=Miền Bắc', 1, NOW()),
(2, 803, 'Khách hàng Doanh nghiệp lớn', 'CUSTOMER', '', 'Chính thức', '',                   'ENTERPRISE', '',         803, 'status=Chính thức&company_size=ENTERPRISE',                        0, NOW()),
(3, 804, 'Khách hàng Tiềm năng Miền Nam','CUSTOMER', '', 'Tiềm năng',  '',                   '',           'Miền Nam', 804, 'status=Tiềm năng&region=Miền Nam',                                0, NOW())
ON DUPLICATE KEY UPDATE filter_name = VALUES(filter_name);

-- =============================================================================
-- 26. BẢNG TỆP ĐÍNH KÈM HỒ SƠ KHÁCH HÀNG (attachments)
-- =============================================================================
INSERT INTO attachments (attachment_id, customer_id, file_name, file_path, file_size, uploaded_at) VALUES
(1, 801, 'Bien_ban_nghiem_thu_AnPhat.pdf',      '/uploads/customers/801/Bien_ban_nghiem_thu_AnPhat.pdf',      3120000, DATE_SUB(NOW(), INTERVAL 40 DAY)),
(2, 802, 'Hop_dong_kinh_te_BaoAn_2026.pdf',     '/uploads/customers/802/Hop_dong_kinh_te_BaoAn_2026.pdf',     4500000, DATE_SUB(NOW(), INTERVAL 70 DAY)),
(3, 816, 'Hop_dong_nguyen_tac_KhanhHoa.pdf',    '/uploads/customers/816/Hop_dong_nguyen_tac_KhanhHoa.pdf',    2458000, DATE_SUB(NOW(), INTERVAL 20 DAY)),
(4, 981, 'Giay_phep_kinh_doanh_SaoMai.pdf',     '/uploads/customers/981/Giay_phep_kinh_doanh_SaoMai.pdf',     1850000, DATE_SUB(NOW(), INTERVAL 25 DAY))
ON DUPLICATE KEY UPDATE file_name = VALUES(file_name);

-- =============================================================================
-- 27. BẢNG NHẬT KÝ THAO TÁC / AUDIT TRAIL (audit_logs)
-- =============================================================================
INSERT INTO audit_logs (log_id, action_type, performed_by, target_user_id, description, old_value, new_value, created_at) VALUES
(1, 'CREATE_CUSTOMER',    4, 4, 'Khởi tạo hồ sơ khách hàng doanh nghiệp FPT Global', NULL, 'customer_id=101', DATE_SUB(NOW(), INTERVAL 120 DAY)),
(2, 'CREATE_OPPORTUNITY', 4, 4, 'Tạo cơ hội bán hàng FPT Global giá trị 170.000.000 VNĐ', NULL, 'opportunity_id=201', DATE_SUB(NOW(), INTERVAL 115 DAY)),
(3, 'CREATE_ACTIVITY',    4, 4, 'Tạo lịch hẹn cuộc họp trao đổi với FPT Global', NULL, 'activity_id=1', DATE_SUB(NOW(), INTERVAL 110 DAY)),
(4, 'CREATE_CUSTOMER',    5, 5, 'Khởi tạo hồ sơ khách hàng Vinamilk Miền Nam', NULL, 'customer_id=106', DATE_SUB(NOW(), INTERVAL 60 DAY)),
(5, 'TRANSFER_CONTACT',   4, 4, 'Chuyển công tác người liên hệ Vương Thị Thảo từ Sao Mai sang Thiên Hà', 'customer_id=981', 'customer_id=982', DATE_SUB(NOW(), INTERVAL 15 DAY)),
(6, 'MERGE_CUSTOMER',     801, 801, 'Gộp hồ sơ khách hàng trùng lặp #812 vào #801', 'secondary_id=812', 'primary_id=801', DATE_SUB(NOW(), INTERVAL 10 DAY))
ON DUPLICATE KEY UPDATE description = VALUES(description);

COMMIT;
SET FOREIGN_KEY_CHECKS = 1;

-- ====================================================================
-- SCRIPT KHÔI PHỤC & CHUẨN HÓA DỮ LIỆU PHÂN QUYỀN VÀ TÀI KHOẢN ADMIN
-- Dự án: TTCS_K1S2_N4_HeThongQuanLyKhachHang
-- 
-- HƯỚNG DẪN THỰC THI THỦ CÔNG TRÊN MYSQL WORKBENCH:
-- 1. Mở MySQL Workbench và kết nối tới database server của ứng dụng CRM.
-- 2. Chọn schema 'crm_db': USE crm_db;
-- 3. Mở file này và thực thi toàn bộ script (Ctrl + Shift + Enter).
-- 4. Kiểm tra kết quả ở các câu SELECT ở cuối script.
-- 
-- AN TOÀN DỮ LIỆU & TÁC VỤ THỰC HIỆN:
-- - KHÔNG DROP DATABASE, KHÔNG DROP TABLE, KHÔNG TRUNCATE.
-- - KHÔNG xóa bất kỳ dữ liệu nghiệp vụ nào (khách hàng, cơ hội, báo giá, tài khoản người dùng,...).
-- - Khử trùng lặp bảng permissions và loại bỏ các liên kết role_permissions ngoài ma trận 87 quyền chuẩn.
-- - Tự động bổ sung chỉ mục UNIQUE (uk_permission_code) cho bảng permissions để ngăn trùng lặp về sau.
-- - Chuẩn hóa chính xác 87 liên kết phân quyền cho 7 vai trò (ADMIN:23, DIRECTOR:20, TEAM_LEAD:14, SALES_REP:10, MARKETING:7, CUST_SUCCESS:8, ACCOUNTANT:5).
-- - Khôi phục tài khoản Admin (admin@company.com / Admin12345) chỉ khi email chưa tồn tại, KHÔNG ghi đè mật khẩu/họ tên tài khoản có sẵn.
-- ====================================================================

USE crm_db;

-- ====================================================================
-- A. KIỂM TRA MÔI TRƯỜNG DATABASE HIỆN TẠI
-- ====================================================================
SELECT DATABASE() AS current_database;

-- ====================================================================
-- B. BÁO CÁO KIỂM TRA CHI TIẾT TRƯỚC KHI SỬA
-- ====================================================================
SELECT 'USERS_BEFORE' AS check_type, COUNT(*) AS total FROM users;
SELECT 'USER_ROLES_BEFORE' AS check_type, COUNT(*) AS total FROM user_roles;
SELECT 'ROLES_COUNT' AS check_type, COUNT(*) AS total FROM roles;
SELECT 'PERMISSIONS_BEFORE' AS check_type, COUNT(*) AS total FROM permissions;
SELECT 'ROLE_PERMISSIONS_BEFORE' AS check_type, COUNT(*) AS total FROM role_permissions;

-- Kiểm tra danh sách các permission_code bị trùng lặp (nếu có)
SELECT permission_code, COUNT(*) AS duplicate_count, GROUP_CONCAT(permission_id ORDER BY permission_id) AS permission_ids
FROM permissions
GROUP BY permission_code
HAVING COUNT(*) > 1;

-- Kiểm tra các liên kết ngoài ma trận chuẩn (nếu có)
SELECT rp.role_id, r.role_code, p.permission_code, rp.data_scope
FROM role_permissions rp
JOIN roles r ON rp.role_id = r.role_id
JOIN permissions p ON rp.permission_id = p.permission_id
WHERE NOT (
   (r.role_code = 'ADMIN') OR
   (r.role_code = 'DIRECTOR' AND p.permission_code NOT IN ('USER_CREATE', 'USER_EDIT', 'USER_DELETE')) OR
   (r.role_code = 'TEAM_LEAD' AND p.permission_code IN ('ACCOUNT_VIEW','ACCOUNT_CREATE','ACCOUNT_EDIT','ACCOUNT_DELETE','ACCOUNT_EXPORT','DEAL_VIEW','DEAL_CREATE','DEAL_EDIT','ACTIVITY_VIEW','QUOTE_VIEW','IMPORT_DATA','CATEGORY_VIEW','PRODUCT_VIEW','ORG_VIEW')) OR
   (r.role_code = 'SALES_REP' AND p.permission_code IN ('ACCOUNT_VIEW','ACCOUNT_CREATE','ACCOUNT_EDIT','DEAL_VIEW','DEAL_CREATE','DEAL_EDIT','ACTIVITY_VIEW','QUOTE_VIEW','CATEGORY_VIEW','PRODUCT_VIEW')) OR
   (r.role_code = 'MARKETING' AND p.permission_code IN ('ACCOUNT_VIEW','ACCOUNT_CREATE','ACCOUNT_EDIT','DEAL_VIEW','ACTIVITY_VIEW','CATEGORY_VIEW','PRODUCT_VIEW')) OR
   (r.role_code = 'CUST_SUCCESS' AND p.permission_code IN ('ACCOUNT_VIEW','ACCOUNT_CREATE','ACCOUNT_EDIT','DEAL_VIEW','ACTIVITY_VIEW','QUOTE_VIEW','CATEGORY_VIEW','PRODUCT_VIEW')) OR
   (r.role_code = 'ACCOUNTANT' AND p.permission_code IN ('ACCOUNT_VIEW','DEAL_VIEW','QUOTE_VIEW','CATEGORY_VIEW','PRODUCT_VIEW'))
);

-- ====================================================================
-- C. KHỬ TRÙNG VÀ LOẠI BỎ LIÊN KẾT NGOÀI MA TRẬN CHUẨN
-- ====================================================================

-- 1. Xóa các liên kết trong role_permissions trỏ tới permission_id phụ (permission_id > min_id)
DELETE rp
FROM role_permissions rp
JOIN permissions p ON rp.permission_id = p.permission_id
JOIN (
    SELECT permission_code, MIN(permission_id) AS min_id
    FROM permissions
    GROUP BY permission_code
) canon ON p.permission_code = canon.permission_code
WHERE p.permission_id > canon.min_id;

-- 2. Xóa các liên kết role_permissions KHÔNG NẰM TRONG MA TRẬN 87 QUYỀN CHUẨN của 7 vai trò
DELETE rp
FROM role_permissions rp
JOIN roles r ON rp.role_id = r.role_id
JOIN permissions p ON rp.permission_id = p.permission_id
WHERE NOT (
   (r.role_code = 'ADMIN') OR
   (r.role_code = 'DIRECTOR' AND p.permission_code NOT IN ('USER_CREATE', 'USER_EDIT', 'USER_DELETE')) OR
   (r.role_code = 'TEAM_LEAD' AND p.permission_code IN ('ACCOUNT_VIEW','ACCOUNT_CREATE','ACCOUNT_EDIT','ACCOUNT_DELETE','ACCOUNT_EXPORT','DEAL_VIEW','DEAL_CREATE','DEAL_EDIT','ACTIVITY_VIEW','QUOTE_VIEW','IMPORT_DATA','CATEGORY_VIEW','PRODUCT_VIEW','ORG_VIEW')) OR
   (r.role_code = 'SALES_REP' AND p.permission_code IN ('ACCOUNT_VIEW','ACCOUNT_CREATE','ACCOUNT_EDIT','DEAL_VIEW','DEAL_CREATE','DEAL_EDIT','ACTIVITY_VIEW','QUOTE_VIEW','CATEGORY_VIEW','PRODUCT_VIEW')) OR
   (r.role_code = 'MARKETING' AND p.permission_code IN ('ACCOUNT_VIEW','ACCOUNT_CREATE','ACCOUNT_EDIT','DEAL_VIEW','ACTIVITY_VIEW','CATEGORY_VIEW','PRODUCT_VIEW')) OR
   (r.role_code = 'CUST_SUCCESS' AND p.permission_code IN ('ACCOUNT_VIEW','ACCOUNT_CREATE','ACCOUNT_EDIT','DEAL_VIEW','ACTIVITY_VIEW','QUOTE_VIEW','CATEGORY_VIEW','PRODUCT_VIEW')) OR
   (r.role_code = 'ACCOUNTANT' AND p.permission_code IN ('ACCOUNT_VIEW','DEAL_VIEW','QUOTE_VIEW','CATEGORY_VIEW','PRODUCT_VIEW'))
);

-- 3. Xóa các bản ghi quyền bị trùng lặp trong bảng permissions (chỉ giữ lại min permission_id cho từng permission_code)
DELETE p
FROM permissions p
JOIN (
    SELECT permission_code, MIN(permission_id) AS min_id
    FROM permissions
    GROUP BY permission_code
) canon ON p.permission_code = canon.permission_code
WHERE p.permission_id > canon.min_id;

-- 4. Kiểm tra và tạo chỉ mục UNIQUE độc lập cho permission_code nếu chưa có
SET @perm_unique_idx = (
    SELECT COUNT(*) 
    FROM information_schema.statistics 
    WHERE table_schema = DATABASE() 
      AND table_name = 'permissions' 
      AND non_unique = 0 
      AND column_name = 'permission_code'
);

SET @add_perm_unique_sql = IF(
    @perm_unique_idx = 0,
    'ALTER TABLE permissions ADD UNIQUE KEY uk_permission_code (permission_code);',
    'SELECT "Chỉ mục UNIQUE trên cột permission_code đã tồn tại" AS status;'
);

PREPARE add_perm_unique_stmt FROM @add_perm_unique_sql;
EXECUTE add_perm_unique_stmt;
DEALLOCATE PREPARE add_perm_unique_stmt;

-- ====================================================================
-- D. NẠP / CẬP NHẬT 23 QUYỀN CHUẨN NẾU THIẾU
-- ====================================================================
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

-- ====================================================================
-- E. KHÔI PHỤC MA TRẬN PHÂN QUYỀN 87 LIÊN KẾT CHUẨN CHO 7 VAI TRÒ
-- ====================================================================

-- 1. ADMIN: Đầy đủ 23 quyền (Phạm vi dữ liệu: ALL)
INSERT INTO role_permissions (role_id, permission_id, data_scope)
SELECT r.role_id, p.permission_id, 'ALL'
FROM roles r CROSS JOIN permissions p
WHERE r.role_code = 'ADMIN'
ON DUPLICATE KEY UPDATE data_scope = VALUES(data_scope);

-- 2. DIRECTOR: 20 quyền (Có USER_VIEW, loại trừ USER_CREATE, USER_EDIT, USER_DELETE - Phạm vi dữ liệu: ALL)
INSERT INTO role_permissions (role_id, permission_id, data_scope)
SELECT r.role_id, p.permission_id, 'ALL'
FROM roles r JOIN permissions p
  ON p.permission_code NOT IN ('USER_CREATE', 'USER_EDIT', 'USER_DELETE')
WHERE r.role_code = 'DIRECTOR'
ON DUPLICATE KEY UPDATE data_scope = VALUES(data_scope);

-- 3. TEAM_LEAD: 14 quyền (11 quyền nghiệp vụ phạm vi TEAM, 3 quyền danh mục/sản phẩm/tổ chức phạm vi ALL)
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

-- 4. SALES_REP: 10 quyền (8 quyền nghiệp vụ cá nhân phạm vi MY, 2 quyền danh mục/sản phẩm phạm vi ALL)
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

-- 5. MARKETING: 7 quyền (Phạm vi dữ liệu: ALL)
INSERT INTO role_permissions (role_id, permission_id, data_scope)
SELECT r.role_id, p.permission_id, 'ALL'
FROM roles r JOIN permissions p
  ON p.permission_code IN ('ACCOUNT_VIEW','ACCOUNT_CREATE','ACCOUNT_EDIT','DEAL_VIEW','ACTIVITY_VIEW','CATEGORY_VIEW','PRODUCT_VIEW')
WHERE r.role_code = 'MARKETING'
ON DUPLICATE KEY UPDATE data_scope = VALUES(data_scope);

-- 6. CUST_SUCCESS: 8 quyền (6 quyền nghiệp vụ cá nhân phạm vi MY, 2 quyền danh mục/sản phẩm phạm vi ALL)
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

-- 7. ACCOUNTANT: 5 quyền (Phạm vi dữ liệu: ALL)
INSERT INTO role_permissions (role_id, permission_id, data_scope)
SELECT r.role_id, p.permission_id, 'ALL'
FROM roles r JOIN permissions p
  ON p.permission_code IN ('ACCOUNT_VIEW','DEAL_VIEW','QUOTE_VIEW','CATEGORY_VIEW','PRODUCT_VIEW')
WHERE r.role_code = 'ACCOUNTANT'
ON DUPLICATE KEY UPDATE data_scope = VALUES(data_scope);

-- ====================================================================
-- E1. NẠP VÀ CHUẨN HÓA DANH SÁCH MENU ĐIỀU HƯỚNG (MENU_ITEMS)
-- ====================================================================
DELETE newer
FROM menu_items AS newer
JOIN menu_items AS older
  ON newer.url = older.url
 AND newer.permission_code = older.permission_code
 AND newer.id > older.id;

DELETE FROM menu_items WHERE url = '/audit/list' AND permission_code = 'USER_VIEW';

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
title = VALUES(title), icon = VALUES(icon), display_order = VALUES(display_order);

-- ====================================================================
-- F. KHÔI PHỤC TÀI KHOẢN ADMIN (CHỈ TẠO KHI EMAIL CHƯA TỒN TẠI, KHÔNG GHI ĐỀ TÀI KHOẢN CÓ SẴN)
-- ====================================================================
INSERT IGNORE INTO users (email, password_hash, full_name, is_active) VALUES
('admin@company.com', '$2a$12$dUD9NdjA/XqMNErHhR3WJuTzoyo4mT2oXuPBDb6QPaPGPKiBzkrBe', 'Quản Trị Viên', 1);

INSERT IGNORE INTO user_roles (user_id, role_id)
SELECT u.user_id, r.role_id
FROM users u 
JOIN roles r ON r.role_code = 'ADMIN'
WHERE u.email = 'admin@company.com';

-- ====================================================================
-- G. KIỂM TRA VÀ XÁC MINH KẾT QUẢ BÁO CÁO SAU KHI THỰC THI
-- ====================================================================

-- 1. Tổng số quyền duy nhất (Mong đợi: 23)
SELECT 'PERMISSIONS_AFTER' AS check_type, COUNT(*) AS total,
       CASE WHEN COUNT(*) = 23 THEN 'DAT_YEU_CAU (23 QUYEN DUY NHAT)' ELSE 'KHONG_DAT' END AS test_result
FROM permissions;

-- 2. Tổng số liên kết phân quyền (Mong đợi: 87)
SELECT 'ROLE_PERMISSIONS_AFTER' AS check_type, COUNT(*) AS total,
       CASE WHEN COUNT(*) = 87 THEN 'DAT_YEU_CAU (DUNG 87 LIEN KET)' ELSE 'KHONG_DAT' END AS test_result
FROM role_permissions;

-- 3. Phân bổ số quyền chuẩn theo từng vai trò (ADMIN:23, DIRECTOR:20, TEAM_LEAD:14, SALES_REP:10, CUST_SUCCESS:8, MARKETING:7, ACCOUNTANT:5)
SELECT r.role_code, r.role_name, COUNT(rp.permission_id) AS restored_permission_count,
       CASE 
         WHEN r.role_code = 'ADMIN' AND COUNT(rp.permission_id) = 23 THEN 'DAT_YEU_CAU (23)'
         WHEN r.role_code = 'DIRECTOR' AND COUNT(rp.permission_id) = 20 THEN 'DAT_YEU_CAU (20)'
         WHEN r.role_code = 'TEAM_LEAD' AND COUNT(rp.permission_id) = 14 THEN 'DAT_YEU_CAU (14)'
         WHEN r.role_code = 'SALES_REP' AND COUNT(rp.permission_id) = 10 THEN 'DAT_YEU_CAU (10)'
         WHEN r.role_code = 'CUST_SUCCESS' AND COUNT(rp.permission_id) = 8 THEN 'DAT_YEU_CAU (8)'
         WHEN r.role_code = 'MARKETING' AND COUNT(rp.permission_id) = 7 THEN 'DAT_YEU_CAU (7)'
         WHEN r.role_code = 'ACCOUNTANT' AND COUNT(rp.permission_id) = 5 THEN 'DAT_YEU_CAU (5)'
         ELSE 'KHONG_DAT'
       END AS role_test_result
FROM roles r
LEFT JOIN role_permissions rp ON r.role_id = rp.role_id
GROUP BY r.role_code, r.role_name
ORDER BY restored_permission_count DESC;

-- 4. Kiểm tra DIRECTOR có USER_VIEW
SELECT 
    r.role_code,
    p.permission_code,
    CASE WHEN p.permission_code IS NOT NULL THEN 'DAT_YEU_CAU (CO USER_VIEW)' ELSE 'KHONG_DAT' END AS test_result
FROM roles r
JOIN role_permissions rp ON r.role_id = rp.role_id
JOIN permissions p ON rp.permission_id = p.permission_id
WHERE r.role_code = 'DIRECTOR' AND p.permission_code = 'USER_VIEW';

-- 5. Kiểm tra DIRECTOR KHÔNG có 3 quyền quản trị User (Mong đợi: 0)
SELECT 
    r.role_code,
    COUNT(p.permission_id) AS forbidden_user_permissions_count,
    CASE WHEN COUNT(p.permission_id) = 0 THEN 'DAT_YEU_CAU (0 QUYEN CAM)' ELSE 'KHONG_DAT' END AS test_result
FROM roles r
JOIN role_permissions rp ON r.role_id = rp.role_id
JOIN permissions p ON rp.permission_id = p.permission_id
WHERE r.role_code = 'DIRECTOR' 
  AND p.permission_code IN ('USER_CREATE', 'USER_EDIT', 'USER_DELETE')
GROUP BY r.role_code;

-- 6. Kiểm tra trùng lặp sau khi sửa (Mong đợi: 0 hàng)
SELECT permission_code, COUNT(*) AS remaining_duplicates
FROM permissions
GROUP BY permission_code
HAVING COUNT(*) > 1;

-- 7. Trạng thái tài khoản Admin
SELECT u.user_id, u.email, u.full_name, u.is_active, r.role_code, r.role_name 
FROM users u
JOIN user_roles ur ON u.user_id = ur.user_id
JOIN roles r ON ur.role_id = r.role_id
WHERE u.email = 'admin@company.com';

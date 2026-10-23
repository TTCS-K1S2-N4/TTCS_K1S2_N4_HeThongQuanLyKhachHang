-- ====================================================================================
-- DỮ LIỆU KIỂM THỬ SPRINT 2: DANH MỤC BÁN HÀNG, CƠ CẤU TỔ CHỨC & CẤU HÌNH PIPELINE
-- Story bao phủ: S2-01 -> S2-10 (Sản phẩm, Cây nhóm phân cấp, Custom Fields, Audit Log, Đối thủ)
-- Dải ID quy hoạch: 2001 -> 2099
-- ====================================================================================

USE `crm_db`;

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- 1. DANH MỤC SẢN PHẨM & DỊCH VỤ (S2-05)
INSERT INTO `products` (`product_id`, `product_code`, `product_name`, `product_type`, `unit`, `list_price`, `floor_price`, `cost_price`, `status`)
VALUES
-- Product 2001: Đã phát sinh báo giá (phục vụ test AC chặn xóa khi đã dùng)
(2001, 'TEST-S2-PROD-LOCKED', 'Gói CRM Tích Hợp Đã Có Báo Giá (Chặn Xóa)', 'SUBSCRIPTION', 'Gói', 45000000.00, 38000000.00, 15000000.00, 'ACTIVE'),
-- Product 2002: Chưa từng phát sinh báo giá (phục vụ test AC xóa thành công)
(2002, 'TEST-S2-PROD-DELETABLE', 'Dịch Vụ Khảo Sát Chưa Dùng (Cho Phép Xóa)', 'ONE_TIME', 'Lần', 10000000.00, 8000000.00, 4000000.00, 'ACTIVE'),
-- Product 2003: Sản phẩm ngừng kinh doanh (INACTIVE)
(2003, 'TEST-S2-PROD-INACTIVE', 'Phần Mềm Đóng Gói Phiên Bản Cũ (Ngừng KD)', 'ONE_TIME', 'Bản quyền', 20000000.00, 15000000.00, 8000000.00, 'INACTIVE'),
-- Product 2004: Dịch vụ đào tạo On-site chuẩn
(2004, 'TEST-S2-SRV-TRAINING', 'Khóa Đào Tạo Vận Hành CRM Chuyên Sâu', 'ONE_TIME', 'Khóa', 15000000.00, 12000000.00, 5000000.00, 'ACTIVE')
ON DUPLICATE KEY UPDATE
    `product_name` = VALUES(`product_name`),
    `list_price` = VALUES(`list_price`),
    `floor_price` = VALUES(`floor_price`),
    `status` = VALUES(`status`);

-- 2. CƠ CẤU TỔ CHỨC CÂY NHÓM KINH DOANH (S2-06 - Phục vụ test vòng lặp A -> B -> C -> A)
INSERT INTO `teams` (`team_id`, `team_name`, `description`, `parent_team_id`, `leader_id`, `region`)
VALUES
(2001, 'Khối Khách Hàng Doanh Nghiệp S2 (Nhóm Cấp 1)', 'Khối kinh doanh cấp chiến lược', NULL, 1001, 'Toàn Quốc'),
(2002, 'Phòng Kinh Doanh Dự Án S2 (Nhóm Cấp 2)', 'Trực thuộc Khối KHDN', 2001, 1002, 'Miền Bắc'),
(2003, 'Tổ Giải Pháp Phần Mềm S2 (Nhóm Cấp 3)', 'Trực thuộc Phòng KD Dự Án', 2002, 1005, 'Miền Bắc')
ON DUPLICATE KEY UPDATE
    `team_name` = VALUES(`team_name`),
    `parent_team_id` = VALUES(`parent_team_id`),
    `region` = VALUES(`region`);

-- 3. ĐỐI THỦ CẠNH TRANH (S2-10 - Phục vụ kiểm thử chọn đối thủ khi chốt Lost)
INSERT INTO `competitors` (`competitor_id`, `competitor_name`, `status`, `created_at`)
VALUES
(2001, 'Công ty Phần Mềm Competitor Alpha', 'ACTIVE', NOW()),
(2002, 'Tập đoàn Quốc tế Competitor Beta', 'ACTIVE', NOW())
ON DUPLICATE KEY UPDATE
    `competitor_name` = VALUES(`competitor_name`),
    `status` = VALUES(`status`);

-- 4. ĐỊNH NGHĨA TRƯỜNG TÙY CHỈNH (CUSTOM FIELDS - S2-08)
INSERT INTO `custom_field_definitions` (`field_id`, `entity_type`, `field_key`, `field_label`, `field_type`, `is_required`, `options`)
VALUES
(2001, 'CUSTOMER', 'cf_erp_system', 'Hệ Thống ERP Đang Sử Dụng', 'TEXT', 0, NULL),
(2002, 'CUSTOMER', 'cf_user_licenses', 'Số Lượng Giấy Phép Dự Kiến', 'NUMBER', 0, NULL),
(2003, 'LEAD', 'cf_preferred_contact_time', 'Khung Giờ Tiện Liên Hệ', 'SELECT', 0, '["Sáng (8h-11h30)","Chiều (13h30-17h)","Ngoài giờ hành chính"]')
ON DUPLICATE KEY UPDATE
    `field_label` = VALUES(`field_label`),
    `field_type` = VALUES(`field_type`);

-- 5. GIÁ TRỊ TRƯỜNG TÙY CHỈNH MẪU (S2-08)
INSERT INTO `custom_field_values` (`value_id`, `entity_type`, `entity_id`, `field_id`, `field_value`)
VALUES
(2001, 'CUSTOMER', 1, 2001, 'SAP S/4HANA Cloud'),
(2002, 'CUSTOMER', 1, 2002, '250')
ON DUPLICATE KEY UPDATE `field_value` = VALUES(`field_value`);

-- 6. BÁO GIÁ LIÊN KẾT ĐỂ KHÓA SẢN PHẨM 2001 (S2-05 AC2)
INSERT INTO `quotes` (`quote_id`, `quote_number`, `owner_id`)
VALUES
(2001, 'BG-S2-TEST-LOCKED', 1005)
ON DUPLICATE KEY UPDATE `quote_number` = VALUES(`quote_number`);

SET FOREIGN_KEY_CHECKS = 1;

SELECT 'NẠP DỮ LIỆU KIỂM THỬ SPRINT 2 THÀNH CÔNG!' AS `Message`;

-- ====================================================================================
-- DỮ LIỆU KIỂM THỬ SPRINT 1: TÀI KHOẢN, XÁC THỰC VÀ PHÂN QUYỀN THEO DỮ LIỆU SỞ HỮU
-- Story bao phủ: S1-01 -> S1-10 (Đăng nhập, Sai pass, Khóa tạm, Reset pass, DataScope MY/TEAM/ALL)
-- Dải ID quy hoạch: 1001 -> 1099
-- Mật khẩu mặc định: Admin12345@ ($2a$12$6gKjgW6z0OQl1rQVFPrsO.2zvupgODGTauCGdp5PoDCSe2wzBQJfO)
-- ====================================================================================

USE `crm_db`;

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- 1. TẠO CÁC TÀI KHOẢN PHỤC VỤ TỪNG ACCEPTANCE CRITERIA CỦA SPRINT 1
INSERT INTO `users` (`user_id`, `email`, `password_hash`, `full_name`, `phone`, `team_id`, `is_active`, `failed_attempts`, `lockout_until`, `reset_token`, `reset_token_expiry`)
VALUES
-- S1-01 AC1: Đăng nhập thành công chuẩn
(1001, 'test.s1.director@crm.vn', '$2a$12$6gKjgW6z0OQl1rQVFPrsO.2zvupgODGTauCGdp5PoDCSe2wzBQJfO', 'Kiểm thử S1 - Giám Đốc Toàn Quyền', '0901001001', 1, 1, 0, NULL, NULL, NULL),
-- S1-05 AC2: Trưởng nhóm Miền Bắc (Team 2)
(1002, 'test.s1.leadernorth@crm.vn', '$2a$12$6gKjgW6z0OQl1rQVFPrsO.2zvupgODGTauCGdp5PoDCSe2wzBQJfO', 'Kiểm thử S1 - Trưởng Nhóm Miền Bắc', '0901001002', 2, 1, 0, NULL, NULL, NULL),
-- S1-05 AC2: Trưởng nhóm Miền Nam (Team 3)
(1003, 'test.s1.leadersouth@crm.vn', '$2a$12$6gKjgW6z0OQl1rQVFPrsO.2zvupgODGTauCGdp5PoDCSe2wzBQJfO', 'Kiểm thử S1 - Trưởng Nhóm Miền Nam', '0901001003', 3, 1, 0, NULL, NULL, NULL),
-- S1-05 AC1: Nhân viên Sales A (Nhóm Miền Bắc)
(1005, 'test.s1.sales_a@crm.vn', '$2a$12$6gKjgW6z0OQl1rQVFPrsO.2zvupgODGTauCGdp5PoDCSe2wzBQJfO', 'Kiểm thử S1 - Sales A (Miền Bắc)', '0901001005', 2, 1, 0, NULL, NULL, NULL),
-- S1-05 AC1: Nhân viên Sales B (Nhóm Miền Bắc - cùng nhóm A)
(1006, 'test.s1.sales_b@crm.vn', '$2a$12$6gKjgW6z0OQl1rQVFPrsO.2zvupgODGTauCGdp5PoDCSe2wzBQJfO', 'Kiểm thử S1 - Sales B (Miền Bắc)', '0901001006', 2, 1, 0, NULL, NULL, NULL),
-- S1-05 AC1 & AC2: Nhân viên Sales C (Nhóm Miền Nam - khác nhóm A và B)
(1007, 'test.s1.sales_c@crm.vn', '$2a$12$6gKjgW6z0OQl1rQVFPrsO.2zvupgODGTauCGdp5PoDCSe2wzBQJfO', 'Kiểm thử S1 - Sales C (Miền Nam)', '0901001007', 3, 1, 0, NULL, NULL, NULL),
-- S1-01 AC2: Kiểm thử cảnh báo sai mật khẩu nhiều lần (failed_attempts = 3)
(1008, 'test.s1.wrongpass@crm.vn', '$2a$12$6gKjgW6z0OQl1rQVFPrsO.2zvupgODGTauCGdp5PoDCSe2wzBQJfO', 'Kiểm thử S1 - User Đã Sai 3 Lần', '0901001008', 2, 1, 3, NULL, NULL, NULL),
-- S1-01 AC3: Kiểm thử tài khoản bị khóa tạm 15 phút (failed_attempts = 5, lockout_until trong tương lai)
(1009, 'test.s1.locked@crm.vn', '$2a$12$6gKjgW6z0OQl1rQVFPrsO.2zvupgODGTauCGdp5PoDCSe2wzBQJfO', 'Kiểm thử S1 - Tài Khoản Bị Khóa Tạm', '0901001009', 2, 1, 5, DATE_ADD(NOW(), INTERVAL 15 MINUTE), NULL, NULL),
-- S1-03 AC2: Kiểm thử Token đặt lại mật khẩu đã hết hạn
(1010, 'test.s1.expiredtoken@crm.vn', '$2a$12$6gKjgW6z0OQl1rQVFPrsO.2zvupgODGTauCGdp5PoDCSe2wzBQJfO', 'Kiểm thử S1 - Token Hết Hạn', '0901001010', 2, 1, 0, NULL, 'TOKEN_S1_EXPIRED_123456', DATE_SUB(NOW(), INTERVAL 2 HOUR)),
-- S1-03 AC1: Kiểm thử Token đặt lại mật khẩu còn hạn 24 giờ
(1011, 'test.s1.validtoken@crm.vn', '$2a$12$6gKjgW6z0OQl1rQVFPrsO.2zvupgODGTauCGdp5PoDCSe2wzBQJfO', 'Kiểm thử S1 - Token Hợp Lệ 24h', '0901001011', 2, 1, 0, NULL, 'TOKEN_S1_VALID_987654', DATE_ADD(NOW(), INTERVAL 24 HOUR)),
-- S1-09 AC1: Tài khoản bị vô hiệu hóa (is_active = 0) phục vụ kiểm thử bàn giao dữ liệu
(1012, 'test.s1.deactivated@crm.vn', '$2a$12$6gKjgW6z0OQl1rQVFPrsO.2zvupgODGTauCGdp5PoDCSe2wzBQJfO', 'Kiểm thử S1 - Tài Khoản Bị Vô Hiệu', '0901001012', 2, 0, 0, NULL, NULL, NULL)
ON DUPLICATE KEY UPDATE
    `password_hash` = VALUES(`password_hash`),
    `full_name` = VALUES(`full_name`),
    `is_active` = VALUES(`is_active`),
    `failed_attempts` = VALUES(`failed_attempts`),
    `lockout_until` = VALUES(`lockout_until`),
    `reset_token` = VALUES(`reset_token`),
    `reset_token_expiry` = VALUES(`reset_token_expiry`);

-- 2. GÁN VAI TRÒ CHUẨN XÁC CHO CÁC TÀI KHOẢN KIỂM THỬ SPRINT 1
INSERT INTO `user_roles` (`user_id`, `role_id`)
VALUES
(1001, 1), -- Director: ADMIN
(1001, 4), -- DIRECTOR
(1002, 3), -- Leader North: TEAM_LEAD
(1003, 3), -- Leader South: TEAM_LEAD
(1005, 2), -- Sales A: SALES_REP
(1006, 2), -- Sales B: SALES_REP
(1007, 2), -- Sales C: SALES_REP
(1008, 2), -- SALES_REP
(1009, 2), -- SALES_REP
(1010, 2), -- SALES_REP
(1011, 2), -- SALES_REP
(1012, 2)  -- SALES_REP
ON DUPLICATE KEY UPDATE `role_id` = VALUES(`role_id`);

-- 3. DỮ LIỆU ĐỐI CHỨNG ĐỂ KIỂM THỬ PHÂN QUYỀN PHẠM VI SỞ HỮU (DATASCOPE MY/TEAM/ALL - S1-05)
-- Khách hàng do Sales A sở hữu (ID: 1005)
INSERT INTO `customers` (`customer_id`, `customer_name`, `tax_code`, `status`, `owner_id`, `industry`, `region`)
VALUES
(1001, 'Doanh Nghiệp A (Sở hữu bởi Sales A)', '0109991001', 'Khách hàng tiềm năng', 1005, 'Công nghệ thông tin', 'Miền Bắc'),
-- Khách hàng do Sales B sở hữu (ID: 1006 - cùng nhóm Miền Bắc với A)
(1002, 'Doanh Nghiệp B (Sở hữu bởi Sales B)', '0109991002', 'Khách hàng tiềm năng', 1006, 'Bất động sản', 'Miền Bắc'),
-- Khách hàng do Sales C sở hữu (ID: 1007 - thuộc nhóm Miền Nam khác A và B)
(1003, 'Doanh Nghiệp C (Sở hữu bởi Sales C)', '0109991003', 'Khách hàng tiềm năng', 1007, 'Sản xuất', 'Miền Nam')
ON DUPLICATE KEY UPDATE `customer_name` = VALUES(`customer_name`), `owner_id` = VALUES(`owner_id`);

-- Cơ hội bán hàng đối chứng phạm vi sở hữu
INSERT INTO `opportunities` (`opportunity_id`, `title`, `amount`, `owner_id`, `customer_id`, `pipeline_stage_id`, `stage`, `status`)
VALUES
(1001, 'Deal Kiểm Thử Scope MY của Sales A', 100000000.00, 1005, 1001, 2, 'Xác định nhu cầu', 'ACTIVE'),
(1002, 'Deal Kiểm Thử Scope TEAM của Sales B', 150000000.00, 1006, 1002, 3, 'Đề xuất giải pháp & Báo giá', 'ACTIVE'),
(1003, 'Deal Kiểm Thử Scope Ngoài Nhóm của Sales C', 200000000.00, 1007, 1003, 4, 'Thương lượng hợp đồng', 'ACTIVE')
ON DUPLICATE KEY UPDATE `title` = VALUES(`title`), `owner_id` = VALUES(`owner_id`);

SET FOREIGN_KEY_CHECKS = 1;

SELECT 'NẠP DỮ LIỆU KIỂM THỬ SPRINT 1 THÀNH CÔNG!' AS `Message`;

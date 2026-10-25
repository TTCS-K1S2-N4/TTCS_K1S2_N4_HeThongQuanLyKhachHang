-- ====================================================================================
-- DỮ LIỆU KIỂM THỬ SPRINT 5: CƠ HỘI BÁN HÀNG, BÁO GIÁ & DỰ BÁO DOANH SỐ PIPELINE
-- Story bao phủ: S5-01 -> S5-06 (Deals, Kanban Pipeline Stages, Quotes, Win/Loss Reasons, Forecast)
-- Dải ID quy hoạch: 5001 -> 5099
-- ====================================================================================

USE `crm_db`;

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- 1. CƠ HỘI BÁN HÀNG KIỂM THỬ SPRINT 5 (OPPORTUNITIES)
INSERT INTO `opportunities` (`opportunity_id`, `title`, `amount`, `owner_id`, `customer_id`, `pipeline_stage_id`, `stage`, `status`, `probability`, `win_loss_reason_id`, `competitor_id`, `close_date`, `created_at`)
VALUES
-- Deal 5001: Giai đoạn 1 (Khởi tạo / Tiếp cận - 10% xác suất)
(5001, 'Gói CRM Khởi Nghiệp Công Nghệ S5', 80000000.00, 105, 3001, 1, 'Khởi tạo / Tiếp cận', 'ACTIVE', 10.00, NULL, NULL, '2027-01-31 00:00:00', NOW()),

-- Deal 5002: Giai đoạn 2 (Xác định nhu cầu - 30% xác suất)
(5002, 'Dự Án Tích Hợp Zalo OA & Call Center S5', 150000000.00, 105, 3001, 2, 'Xác định nhu cầu', 'ACTIVE', 30.00, NULL, NULL, '2026-12-15 00:00:00', NOW()),

-- Deal 5003: Giai đoạn 3 (Đề xuất giải pháp & Báo giá - 50% xác suất)
(5003, 'Triển Khai Phân Hệ Quản Trị Chuỗi Phân Phối S5', 250000000.00, 106, 3002, 3, 'Đề xuất giải pháp & Báo giá', 'ACTIVE', 50.00, NULL, NULL, '2026-12-30 00:00:00', NOW()),

-- Deal 5004: Giai đoạn 4 (Thương lượng hợp đồng - 80% xác suất)
(5004, 'Gói Bản Quyền Cloud Doanh Nghiệp 3 Năm S5', 400000000.00, 106, 3004, 4, 'Thương lượng hợp đồng', 'ACTIVE', 80.00, NULL, NULL, '2026-11-30 00:00:00', NOW()),

-- Deal 5005: Giai đoạn 5 (Chốt thành công - WON 100%, có lý do thắng)
(5005, 'Hợp Đồng Tổng Thể Chuyển Đổi Số Á Châu S5', 500000000.00, 108, 3004, 5, 'Chốt thành công (Won)', 'WON', 100.00, 2, NULL, '2026-10-15 00:00:00', DATE_SUB(NOW(), INTERVAL 30 DAY)),

-- Deal 5006: Giai đoạn 6 (Thất bại - LOST 0%, có lý do thua và đối thủ)
(5006, 'Dự Án Đấu Thầu Phần Mềm Bệnh Viện S5', 300000000.00, 107, 3007, 6, 'Thất bại (Lost)', 'LOST', 0.00, 5, 2001, '2026-09-30 00:00:00', DATE_SUB(NOW(), INTERVAL 45 DAY))
ON DUPLICATE KEY UPDATE
    `title` = VALUES(`title`),
    `amount` = VALUES(`amount`),
    `pipeline_stage_id` = VALUES(`pipeline_stage_id`),
    `probability` = VALUES(`probability`),
    `status` = VALUES(`status`),
    `win_loss_reason_id` = VALUES(`win_loss_reason_id`),
    `competitor_id` = VALUES(`competitor_id`);

-- 2. BÁO GIÁ KINH DOANH GẮN VỚI CƠ HỘI SPRINT 5 (QUOTES - S5-03)
INSERT INTO `quotes` (`quote_id`, `quote_number`, `owner_id`)
VALUES
(5001, 'BG-S5-OPP-5003', 106),
(5002, 'BG-S5-OPP-5004', 106),
(5003, 'BG-S5-OPP-5005', 108)
ON DUPLICATE KEY UPDATE `quote_number` = VALUES(`quote_number`);

-- 3. HOẠT ĐỘNG TƯƠNG TÁC THƯƠNG LƯỢNG BÁN HÀNG SPRINT 5 (ACTIVITIES)
INSERT INTO `activities` (`activity_id`, `title`, `description`, `owner_id`, `customer_id`, `activity_type`, `created_at`)
VALUES
(5001, 'Họp thương thảo điều khoản hợp đồng S5', 'Thống nhất tiến độ thanh toán chia làm 3 đợt và thời hạn bảo hành 24 tháng cho Hợp đồng 5005', 108, 3004, 'MEETING', '2026-10-10 14:00:00'),
(5002, 'Gửi bản chào giá chính thức gói Cloud 3 năm', 'Đã đính kèm bảng so sánh tính năng và chiết khấu thanh toán trước 100%', 106, 3004, 'EMAIL', '2026-11-05 09:30:00')
ON DUPLICATE KEY UPDATE `title` = VALUES(`title`), `description` = VALUES(`description`);

SET FOREIGN_KEY_CHECKS = 1;

SELECT 'NẠP DỮ LIỆU KIỂM THỬ SPRINT 5 THÀNH CÔNG!' AS `Message`;

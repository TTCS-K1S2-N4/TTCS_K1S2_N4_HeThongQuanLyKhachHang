-- ====================================================================================
-- DỮ LIỆU KIỂM THỬ SPRINT 4: LEAD - THU THẬP, CHẤM ĐIỂM, PHÂN BỔ & CHUYỂN ĐỔI
-- Story bao phủ: S4-01 -> S4-09 (Web Form, Scoring Rules, Phân bổ Round-Robin, SLA Overdue, Merge, Convert)
-- Dải ID quy hoạch: 4001 -> 4099
-- ====================================================================================

USE `crm_db`;

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- 1. BIỂU MẪU THU THẬP LEAD TRÊN WEBSITE (LEAD_WEB_FORMS - S4-01)
INSERT INTO `lead_web_forms` (`form_id`, `form_name`, `description`, `is_active`, `created_by`, `created_at`)
VALUES
(4001, 'Biểu Mẫu Nhận Báo Giá Cloud CRM S4', 'Form nhúng tại trang landing page bảng giá', 1, 101, NOW()),
(4002, 'Biểu Mẫu Đăng Ký Hội Thảo Khách Hàng S4', 'Form nhúng đăng ký tham gia sự kiện công nghệ', 1, 101, NOW())
ON DUPLICATE KEY UPDATE `form_name` = VALUES(`form_name`), `is_active` = VALUES(`is_active`);

-- 2. QUY TẮC CHẤM ĐIỂM LEAD MẪU (LEAD_SCORING_RULES - S4-05)
INSERT INTO `lead_scoring_rules` (`rule_id`, `criterion`, `operator`, `condition_value`, `score`, `is_active`)
VALUES
(4001, 'INDUSTRY', 'EQUALS', 'Công nghệ thông tin', 30, 1),
(4002, 'INDUSTRY', 'EQUALS', 'Tài chính - Ngân hàng', 30, 1),
(4003, 'COMPANY_SIZE', 'EQUALS', '500+ nhân sự', 25, 1),
(4004, 'SOURCE', 'EQUALS', 'Biểu mẫu Website', 20, 1),
(4005, 'TITLE', 'CONTAINS', 'Sinh viên', -40, 1)
ON DUPLICATE KEY UPDATE `score` = VALUES(`score`), `is_active` = VALUES(`is_active`);

-- 3. QUY TẮC PHÂN BỔ LEAD TỰ ĐỘNG (LEAD_ASSIGNMENT_RULES - S4-06)
INSERT INTO `lead_assignment_rules` (`rule_id`, `rule_name`, `priority`, `criterion`, `criterion_value`, `team_id`, `assignee_id`, `is_active`)
VALUES
-- Ưu tiên 1: Lead khu vực Miền Bắc phân bổ cho Phòng KD Miền Bắc (Team 2)
(4001, 'Phân bổ Lead Miền Bắc cho Team 2', 1, 'REGION', 'Miền Bắc', 2, NULL, 1),
-- Ưu tiên 2: Lead khu vực Miền Nam phân bổ cho Phòng KD Miền Nam (Team 3)
(4002, 'Phân bổ Lead Miền Nam cho Team 3', 2, 'REGION', 'Miền Nam', 3, NULL, 1)
ON DUPLICATE KEY UPDATE `rule_name` = VALUES(`rule_name`), `priority` = VALUES(`priority`);

-- 4. DANH SÁCH LEAD KIỂM THỬ SPRINT 4 (LEADS)
INSERT INTO `leads` (`lead_id`, `full_name`, `title`, `company_name`, `email`, `phone`, `lead_source_id`, `web_form_id`, `status`, `rating`, `score`, `industry`, `city`, `region`, `owner_id`, `notes`, `sla_due_date`, `is_overdue`, `sla_breached`, `converted_customer_id`, `converted_contact_id`, `converted_opportunity_id`)
VALUES
-- Lead 4001: Lead chính phục vụ test gộp Lead trùng lặp (Merge Primary)
(4001, 'Trần Quốc Tuấn', 'Giám Đốc Kỹ Thuật', 'Công ty Cổ phần Phần Mềm Thăng Long S4', 'tuantq@thanglongsoft-s4.vn', '0948884001', 1, 4001, 'NEW', 'WARM', 60, 'Công nghệ thông tin', 'Hà Nội', 'Miền Bắc', 105, 'Lead đăng ký từ Form báo giá Web', DATE_ADD(NOW(), INTERVAL 24 HOUR), 0, 0, NULL, NULL, NULL),
-- Lead 4002: Lead phụ trùng email với 4001 để test thuật toán gộp Lead
(4002, 'Trần Quốc Tuấn (Bản Đăng Ký Lại)', 'CTO', 'Công ty Thăng Long Soft', 'tuantq@thanglongsoft-s4.vn', '0948884001', 1, 4001, 'NEW', 'WARM', 60, 'Công nghệ thông tin', 'Hà Nội', 'Miền Bắc', 105, 'Khách bấm gửi lại form lần 2', DATE_ADD(NOW(), INTERVAL 24 HOUR), 0, 0, NULL, NULL, NULL),
-- Lead 4003: Lead HOT điểm cao (90 điểm, đủ tiêu chí HOT)
(4003, 'Lê Hoàng Nam', 'Tổng Giám Đốc', 'Tập đoàn Bán Lẻ Tân Việt S4', 'namlh@tanvietretail-s4.vn', '0948884003', 1, 4001, 'NEW', 'HOT', 90, 'Bán lẻ & Chuỗi cửa hàng', 'Hà Nội', 'Miền Bắc', 105, 'Nhu cầu triển khai ngay trong tháng tới cho chuỗi 50 cửa hàng', DATE_ADD(NOW(), INTERVAL 12 HOUR), 0, 0, NULL, NULL, NULL),
-- Lead 4004: Lead WARM điểm trung bình (65 điểm)
(4004, 'Nguyễn Thị Bích', 'Trưởng Phòng Mua Hàng', 'Công ty TNHH Bao Bì Đại Nam S4', 'bichnt@dainampack-s4.vn', '0948884004', 4, NULL, 'CONTACTED', 'WARM', 65, 'Sản xuất bao bì', 'TP. Hồ Chí Minh', 'Miền Nam', 108, 'Lead từ Facebook Ads, đang tư vấn báo giá sơ bộ', DATE_ADD(NOW(), INTERVAL 36 HOUR), 0, 0, NULL, NULL, NULL),
-- Lead 4005: Lead COLD điểm thấp (25 điểm)
(4005, 'Đỗ Văn Khoa', 'Quản Lý Cửa Hàng', 'Cửa Hàng Tạp Hóa Khoa Mai S4', 'khoamai@gmail.com', '0948884005', 2, NULL, 'NEW', 'COLD', 25, 'Bán lẻ nhỏ lẻ', 'Hà Nội', 'Miền Bắc', 105, 'Hộ kinh doanh cá thể, xin bảng giá tham khảo', DATE_ADD(NOW(), INTERVAL 48 HOUR), 0, 0, NULL, NULL, NULL),
-- Lead 4006: Lead vi phạm thời hạn phản hồi SLA (Quá hạn 48 giờ chưa liên hệ)
(4006, 'Bùi Văn Hùng (Vi Phạm SLA)', 'Giám Đốc Dự Án', 'Công ty Xây Dựng Số 9 S4', 'hungbv@xaydung9-s4.vn', '0948884006', 1, 4001, 'NEW', 'HOT', 85, 'Xây dựng', 'Hà Nội', 'Miền Bắc', 105, 'Lead HOT bị trễ hạn xử lý của Sales', DATE_SUB(NOW(), INTERVAL 48 HOUR), 1, 1, NULL, NULL, NULL),
-- Lead 4007: Lead chuyển đổi thành công (CONVERTED) đầy đủ liên kết
(4007, 'Vũ Đình Cường', 'Tổng Giám Đốc', 'Công ty Cổ phần Công nghệ Tiên Phong S3', 'cuongvd@tienphong-s3.vn', '0918883001', 1, 4001, 'CONVERTED', 'HOT', 100, 'Công nghệ thông tin', 'Hà Nội', 'Miền Bắc', 105, 'Đã chuyển đổi hoàn tất sang Khách hàng 3001 và Cơ hội 3001', NOW(), 0, 0, 3001, 3001, 3001)
ON DUPLICATE KEY UPDATE
    `full_name` = VALUES(`full_name`),
    `score` = VALUES(`score`),
    `rating` = VALUES(`rating`),
    `status` = VALUES(`status`),
    `is_overdue` = VALUES(`is_overdue`),
    `sla_breached` = VALUES(`sla_breached`),
    `converted_customer_id` = VALUES(`converted_customer_id`),
    `converted_contact_id` = VALUES(`converted_contact_id`),
    `converted_opportunity_id` = VALUES(`converted_opportunity_id`);

-- 5. BẢN GHI THÔNG BÁO QUÁ HẠN SLA CHO TRƯỞNG NHÓM (LEAD_SLA_NOTIFICATIONS - S4-07 AC2)
INSERT INTO `lead_sla_notifications` (`notification_id`, `lead_id`, `sales_rep_id`, `team_id`, `leader_id`, `message`, `sla_due_date`, `is_read`, `created_at`)
VALUES
(4001, 4006, 105, 2, 102, 'CẢNH BÁO: Lead HOT "Bùi Văn Hùng" của nhân viên Vũ Tuấn Kiệt đã quá hạn phản hồi SLA 48 giờ!', DATE_SUB(NOW(), INTERVAL 48 HOUR), 0, NOW())
ON DUPLICATE KEY UPDATE `message` = VALUES(`message`), `is_read` = VALUES(`is_read`);

-- 6. LỊCH SỬ GỘP LEAD MẪU (LEAD_MERGE_HISTORY - S4-04 AC2)
INSERT INTO `lead_merge_history` (`merge_id`, `primary_lead_id`, `duplicate_lead_id`, `merged_by`, `merged_at`, `retained_fields`, `note`)
VALUES
(4001, 4001, 4002, 105, NOW(), '{"email":"tuantq@thanglongsoft-s4.vn","phone":"0948884001"}', 'Gộp do khách hàng gửi lại form báo giá 2 lần liên tiếp')
ON DUPLICATE KEY UPDATE `note` = VALUES(`note`);

SET FOREIGN_KEY_CHECKS = 1;

SELECT 'NẠP DỮ LIỆU KIỂM THỬ SPRINT 4 THÀNH CÔNG!' AS `Message`;

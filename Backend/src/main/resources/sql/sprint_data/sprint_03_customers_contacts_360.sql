-- ====================================================================================
-- DỮ LIỆU KIỂM THỬ SPRINT 3: KHÁCH HÀNG DOANH NGHIỆP, LIÊN HỆ & TRANG 360
-- Story bao phủ: S3-01 -> S3-09 (Trùng MST, Buying Center, Chuyển Cty, Gộp KH, Mẹ-Con, Churn Risk, Care)
-- Dải ID quy hoạch: 3001 -> 3099
-- ====================================================================================

USE `crm_db`;

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- 1. DOANH NGHIỆP KIỂM THỬ SPRINT 3 (CUSTOMERS)
INSERT INTO `customers` (`customer_id`, `customer_name`, `phone`, `email`, `tax_code`, `status`, `industry`, `company_size`, `website`, `address`, `region`, `owner_id`)
VALUES
-- Customer 3001: Khách hàng chuẩn phục vụ Customer 360 và Buying Center
(3001, 'Công ty Cổ phần Công nghệ Tiên Phong S3', '02438883001', 'contact@tienphong-s3.vn', '0108883001', 'Khách hàng hiện hữu', 'Công nghệ thông tin', '200-500 nhân sự', 'https://tienphong-s3.vn', 'Tòa nhà Tiên Phong, Cầu Giấy, Hà Nội', 'Miền Bắc', 105),
-- Customer 3002: Khách hàng trùng lặp để kiểm thử thuật toán phát hiện và gộp (Merge A)
(3002, 'Công ty TNHH Cơ Khí Tân Á S3', '02438883002', 'info@tana-s3.com', '0108883002', 'Khách hàng tiềm năng', 'Sản xuất', '50-200 nhân sự', 'https://tana-s3.com', 'KCN Quang Minh, Mê Linh, Hà Nội', 'Miền Bắc', 105),
-- Customer 3003: Bản ghi trùng tên gần giống với 3002 (Merge B)
(3003, 'Công ty Cơ Khí Tân Á (Chi nhánh Hà Nội)', '02438883003', 'info.hn@tana-s3.com', '0108883003', 'Khách hàng tiềm năng', 'Sản xuất', '50-200 nhân sự', 'https://tana-s3.com', 'Quang Minh, Hà Nội', 'Miền Bắc', 105),
-- Customer 3004: Công ty Mẹ phục vụ kiểm thử phân cấp Tập đoàn (Corporate Hierarchy)
(3004, 'Tập đoàn Đầu Tư Bất Động Sản Á Châu S3 (Công Ty Mẹ)', '02838883004', 'holdings@achau-s3.vn', '0308883004', 'Khách hàng VIP', 'Bất động sản', '1000+ nhân sự', 'https://achau-s3.vn', 'Quận 1, TP. Hồ Chí Minh', 'Miền Nam', 108),
-- Customer 3005: Công ty Con cấp 1 của 3004
(3005, 'Công ty CP Xây Dựng Á Châu Cons S3 (Công Ty Con)', '02838883005', 'cons@achau-s3.vn', '0308883005', 'Khách hàng hiện hữu', 'Xây dựng', '200-500 nhân sự', 'https://cons.achau-s3.vn', 'Quận 7, TP. Hồ Chí Minh', 'Miền Nam', 108),
-- Customer 3006: Khách hàng có nguy cơ rời bỏ cao (Churn Risk) do có ticket URGENT và nhiều ticket tồn
(3006, 'Công ty Cổ phần Vận Tải Quốc Tế Hải An S3 (Rủi Ro Cao)', '02253883006', 'support@haian-s3.vn', '0208883006', 'Khách hàng hiện hữu', 'Logistics', '200-500 nhân sự', 'https://haian-s3.vn', 'Ngô Quyền, Hải Phòng', 'Miền Bắc', 106),
-- Customer 3007: Khách hàng cần chăm sóc định kỳ (Quá 45 ngày chưa liên hệ, hợp đồng lớn)
(3007, 'Tập đoàn Dược Phẩm Việt Khang S3 (Cần Chăm Sóc)', '02438883007', 'contact@vietkhang-s3.vn', '0108883007', 'Khách hàng VIP', 'Dược phẩm & Y tế', '500+ nhân sự', 'https://vietkhang-s3.vn', 'Hai Bà Trưng, Hà Nội', 'Miền Bắc', 107)
ON DUPLICATE KEY UPDATE
    `customer_name` = VALUES(`customer_name`),
    `tax_code` = VALUES(`tax_code`),
    `owner_id` = VALUES(`owner_id`);

-- 2. QUAN HỆ CÔNG TY MẸ - CON (CUSTOMER_RELATIONSHIPS - S3-05)
INSERT INTO `customer_relationships` (`parent_customer_id`, `child_customer_id`, `relationship_type`, `created_at`)
VALUES
(3004, 3005, 'SUBSIDIARY', NOW())
ON DUPLICATE KEY UPDATE `relationship_type` = VALUES(`relationship_type`);

-- 3. NGƯỜI LIÊN HỆ ĐẦY ĐỦ 4 VAI TRÒ MUA HÀNG B2B (CONTACTS - S3-02)
INSERT INTO `contacts` (`contact_id`, `customer_id`, `contact_name`, `phone`, `email`, `position`, `is_primary`, `title`, `buying_role`)
VALUES
-- Người ra quyết định mua (DECISION_MAKER)
(3001, 3001, 'Vũ Đình Cường', '0918883001', 'cuongvd@tienphong-s3.vn', 'Tổng Giám Đốc', 1, 'Ông', 'DECISION_MAKER'),
-- Người có ảnh hưởng (INFLUENCER)
(3002, 3001, 'Phạm Thu Nga', '0918883002', 'ngapt@tienphong-s3.vn', 'Giám Đốc Kỹ Thuật', 0, 'Bà', 'INFLUENCER'),
-- Người đánh giá giải pháp (EVALUATOR)
(3003, 3001, 'Đặng Minh Đức', '0918883003', 'ducdm@tienphong-s3.vn', 'Trưởng Nhóm Khảo Sát', 0, 'Ông', 'EVALUATOR'),
-- Người sử dụng cuối (END_USER)
(3004, 3001, 'Nguyễn Mai Lan', '0918883004', 'lan.nm@tienphong-s3.vn', 'Chuyên viên Vận Hành', 0, 'Bà', 'END_USER'),
-- Người liên hệ của khách hàng phụ 3002 (phục vụ test gộp sang 3001)
(3005, 3002, 'Trịnh Văn Bách', '0918883005', 'bachtv@tana-s3.com', 'Phó Giám Đốc', 1, 'Ông', 'DECISION_MAKER')
ON DUPLICATE KEY UPDATE
    `contact_name` = VALUES(`contact_name`),
    `buying_role` = VALUES(`buying_role`),
    `customer_id` = VALUES(`customer_id`);

-- 4. LỊCH SỬ CHUYỂN CÔNG TY CỦA NGƯỜI LIÊN HỆ (CONTACT_COMPANY_HISTORY - S3-02 AC2)
INSERT INTO `contact_company_history` (`contact_id`, `from_customer_id`, `to_customer_id`, `transferred_at`, `reason`, `transferred_by`)
VALUES
(3001, 3002, 3001, DATE_SUB(NOW(), INTERVAL 60 DAY), 'Bổ nhiệm sang làm Tổng Giám Đốc tại Công ty Tiên Phong', 101)
ON DUPLICATE KEY UPDATE `reason` = VALUES(`reason`);

-- 5. CƠ HỘI BÁN HÀNG PHỤC VỤ TRANG 360 VÀ CHĂM SÓC KHÁCH HÀNG (S3-03, S3-09)
INSERT INTO `opportunities` (`opportunity_id`, `title`, `amount`, `owner_id`, `customer_id`, `pipeline_stage_id`, `stage`, `status`, `win_loss_reason_id`)
VALUES
-- Cơ hội Won của 3001 (Doanh số ký kết)
(3001, 'Hợp Đồng ERP & CRM Triển Khai Giai Đoạn 1', 650000000.00, 105, 3001, 5, 'Chốt thành công (Won)', 'WON', 2),
-- Cơ hội đang mở của 3001 (Pipeline mở)
(3002, 'Nâng Cấp Hệ Thống Call Center Đa Kênh', 200000000.00, 105, 3001, 3, 'Đề xuất giải pháp & Báo giá', 'ACTIVE', NULL),
-- Cơ hội lớn của 3007 (Phục vụ ưu tiên chăm sóc định kỳ)
(3003, 'Dự Án Phần Mềm Quản Trị Chuỗi Nhà Thuốc Việt Khang', 800000000.00, 107, 3007, 5, 'Chốt thành công (Won)', 'WON', 3)
ON DUPLICATE KEY UPDATE `title` = VALUES(`title`), `amount` = VALUES(`amount`);

-- 6. TICKET HỖ TRỢ KỸ THUẬT PHỤC VỤ CẢNH BÁO RỦI RO (SUPPORT_REQUESTS - S3-08)
INSERT INTO `support_requests` (`request_id`, `customer_id`, `title`, `description`, `priority`, `status`, `assignee_id`, `created_by`, `created_at`)
VALUES
-- Khách hàng 3006 có 1 ticket URGENT (Kích hoạt cảnh báo Churn Risk đỏ)
(3001, 3006, 'Sự cố tê liệt máy chủ đồng bộ dữ liệu nội bộ', 'Khách hàng không thể xuất hóa đơn điện tử trong 3 giờ', 'URGENT', 'OPEN', 110, 106, DATE_SUB(NOW(), INTERVAL 2 DAY)),
-- Khách hàng 3006 có thêm 2 ticket OPEN
(3002, 3006, 'Lỗi giao diện màn hình thống kê doanh số', 'Không hiển thị biểu đồ tròn trên trình duyệt Firefox', 'MEDIUM', 'OPEN', 111, 106, DATE_SUB(NOW(), INTERVAL 4 DAY)),
(3003, 3006, 'Yêu cầu mở thêm cổng kết nối API ngân hàng', 'Cần hỗ trợ cấu hình webhook', 'HIGH', 'IN_PROGRESS', 110, 106, DATE_SUB(NOW(), INTERVAL 5 DAY))
ON DUPLICATE KEY UPDATE `priority` = VALUES(`priority`), `status` = VALUES(`status`);

-- 7. CHĂM SÓC KHÁCH HÀNG ĐỊNH KỲ (CUSTOMER_CARE - S3-09)
INSERT INTO `customer_care` (`care_id`, `customer_id`, `last_contacted_at`, `last_contacted_by`, `inactive_threshold_days`, `note`)
VALUES
-- Khách hàng 3007: Lần liên hệ cuối cách đây 45 ngày (vượt ngưỡng 30 ngày)
(3001, 3007, DATE_SUB(NOW(), INTERVAL 45 DAY), 107, 30, 'Khách hàng VIP lâu chưa gọi điện hỏi thăm sau nghiệm thu giai đoạn 1'),
-- Khách hàng 3001: Mới liên hệ cách đây 5 ngày (chưa đến hạn)
(3002, 3001, DATE_SUB(NOW(), INTERVAL 5 DAY), 105, 30, 'Khách hàng phản hồi hệ thống chạy tốt')
ON DUPLICATE KEY UPDATE `last_contacted_at` = VALUES(`last_contacted_at`);

-- 8. BỘ LỌC ĐÃ LƯU MẪU (SAVED_FILTERS - S3-07)
INSERT INTO `saved_filters` (`filter_id`, `user_id`, `filter_name`, `module`, `industry`, `region`, `is_default`, `created_at`)
VALUES
(3001, 105, 'KH Doanh Nghiệp Lớn Miền Bắc', 'CUSTOMER', 'Công nghệ thông tin', 'Miền Bắc', 1, NOW()),
(3002, 105, 'KH Có Rủi Ro Vé Khẩn Cấp', 'CUSTOMER', NULL, NULL, 0, NOW())
ON DUPLICATE KEY UPDATE `filter_name` = VALUES(`filter_name`);

SET FOREIGN_KEY_CHECKS = 1;

SELECT 'NẠP DỮ LIỆU KIỂM THỬ SPRINT 3 THÀNH CÔNG!' AS `Message`;

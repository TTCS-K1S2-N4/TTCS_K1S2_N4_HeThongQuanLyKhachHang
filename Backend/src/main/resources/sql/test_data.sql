-- =========================================================================
-- BỘ DỮ LIỆU MẪU DỰ ÁN CRM (TEST DATA SCRIPT - CRM_DB)
-- Chạy an toàn, không xóa dữ liệu cũ, không sửa tài khoản/phân quyền hiện có
-- =========================================================================

USE crm_db;

-- 0. TÀI KHOẢN MẪU KIỂM THỬ (users & user_roles)
-- Mật khẩu mặc định của tất cả tài khoản test: TestPassword123@ (được băm bằng BCrypt từ PasswordUtil.hash())
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

-- Gán vai trò tương ứng cho từng tài khoản test
INSERT IGNORE INTO user_roles (user_id, role_id)
SELECT u.user_id, r.role_id
FROM users u JOIN roles r ON r.role_code = 'DIRECTOR'
WHERE u.email = 'director.test@example.com';

INSERT IGNORE INTO user_roles (user_id, role_id)
SELECT u.user_id, r.role_id
FROM users u JOIN roles r ON r.role_code = 'TEAM_LEAD'
WHERE u.email = 'teamlead.test@example.com';

INSERT IGNORE INTO user_roles (user_id, role_id)
SELECT u.user_id, r.role_id
FROM users u JOIN roles r ON r.role_code = 'SALES_REP'
WHERE u.email IN ('salesrep.test@example.com', 'salesrep2.test@example.com');

INSERT IGNORE INTO user_roles (user_id, role_id)
SELECT u.user_id, r.role_id
FROM users u JOIN roles r ON r.role_code = 'MARKETING'
WHERE u.email = 'marketing.test@example.com';

INSERT IGNORE INTO user_roles (user_id, role_id)
SELECT u.user_id, r.role_id
FROM users u JOIN roles r ON r.role_code = 'CUST_SUCCESS'
WHERE u.email = 'customersuccess.test@example.com';

INSERT IGNORE INTO user_roles (user_id, role_id)
SELECT u.user_id, r.role_id
FROM users u JOIN roles r ON r.role_code = 'ACCOUNTANT'
WHERE u.email = 'accountant.test@example.com';

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

-- 6. KHÁCH HÀNG (customers) - Phân bổ cho user_id 4 (Team 1) và user_id 5 (Team 2)
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

-- 7. CƠ HỘI BÁN HÀNG (opportunities) - Phân bổ cho user_id 4 và user_id 5
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

-- 8. HOẠT ĐỘNG (activities) - Phân bổ cho user_id 4 và user_id 5
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

-- 9. BÁO GIÁ (quotes) - Phân bổ cho user_id 4 và user_id 5
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

-- 10. NHẬT KÝ THAO TÁC (audit_logs)
INSERT INTO audit_logs (action_type, performed_by, target_user_id, description, old_value, new_value) VALUES
('CREATE_CUSTOMER', 4, 4, 'Khởi tạo hồ sơ khách hàng doanh nghiệp FPT Global', NULL, 'customer_id=101'),
('CREATE_OPPORTUNITY', 4, 4, 'Tạo cơ hội bán hàng FPT Global giá trị 170.000.000 VNĐ', NULL, 'opportunity_id=201'),
('CREATE_ACTIVITY', 4, 4, 'Tạo lịch hẹn cuộc họp trao đổi với FPT Global', NULL, 'activity_id=301'),
('CREATE_CUSTOMER', 5, 5, 'Khởi tạo hồ sơ khách hàng Vinamilk Miền Nam', NULL, 'customer_id=106'),
('CREATE_OPPORTUNITY', 5, 5, 'Tạo cơ hội bán hàng Vinamilk Miền Nam giá trị 200.000.000 VNĐ', NULL, 'opportunity_id=206'),
('CREATE_ACTIVITY', 5, 5, 'Tạo lịch hẹn cuộc họp khởi động dự án Vinamilk Miền Nam', NULL, 'activity_id=306');

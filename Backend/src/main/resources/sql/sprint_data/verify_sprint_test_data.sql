-- ====================================================================================
-- TRUY VẤN XÁC MINH TOÀN VẸN VÀ ĐỘ BAO PHỦ DỮ LIỆU KIỂM THỬ TỪNG SPRINT
-- ====================================================================================

USE `crm_db`;

SELECT '=== 1. THỐNG KÊ SỐ LƯỢNG BẢN GHI KIỂM THỬ THEO TỪNG SPRINT ===' AS `Section`;

SELECT 'Sprint 1 (Users 1001-1099)' AS `Sprint_Module`, COUNT(*) AS `Total_Test_Records`
FROM `users` WHERE `user_id` BETWEEN 1001 AND 1099
UNION ALL
SELECT 'Sprint 1 (Customers Scope 1001-1003)', COUNT(*)
FROM `customers` WHERE `customer_id` BETWEEN 1001 AND 1003
UNION ALL
SELECT 'Sprint 2 (Products 2001-2099)', COUNT(*)
FROM `products` WHERE `product_id` BETWEEN 2001 AND 2099
UNION ALL
SELECT 'Sprint 2 (Teams 2001-2099)', COUNT(*)
FROM `teams` WHERE `team_id` BETWEEN 2001 AND 2099
UNION ALL
SELECT 'Sprint 2 (Competitors 2001-2099)', COUNT(*)
FROM `competitors` WHERE `competitor_id` BETWEEN 2001 AND 2099
UNION ALL
SELECT 'Sprint 3 (Customers 3001-3099)', COUNT(*)
FROM `customers` WHERE `customer_id` BETWEEN 3001 AND 3099
UNION ALL
SELECT 'Sprint 3 (Contacts 3001-3099)', COUNT(*)
FROM `contacts` WHERE `contact_id` BETWEEN 3001 AND 3099
UNION ALL
SELECT 'Sprint 3 (Relationships 3004->3005)', COUNT(*)
FROM `customer_relationships` WHERE `parent_customer_id` = 3004 AND `child_customer_id` = 3005
UNION ALL
SELECT 'Sprint 3 (Support Requests 3001-3099)', COUNT(*)
FROM `support_requests` WHERE `request_id` BETWEEN 3001 AND 3099
UNION ALL
SELECT 'Sprint 4 (Lead Web Forms 4001-4099)', COUNT(*)
FROM `lead_web_forms` WHERE `form_id` BETWEEN 4001 AND 4099
UNION ALL
SELECT 'Sprint 4 (Leads 4001-4099)', COUNT(*)
FROM `leads` WHERE `lead_id` BETWEEN 4001 AND 4099
UNION ALL
SELECT 'Sprint 4 (SLA Notifications 4001-4099)', COUNT(*)
FROM `lead_sla_notifications` WHERE `notification_id` BETWEEN 4001 AND 4099
UNION ALL
SELECT 'Sprint 5 (Opportunities 5001-5099)', COUNT(*)
FROM `opportunities` WHERE `opportunity_id` BETWEEN 5001 AND 5099
UNION ALL
SELECT 'Sprint 5 (Quotes 5001-5099)', COUNT(*)
FROM `quotes` WHERE `quote_id` BETWEEN 5001 AND 5099;

SELECT '=== 2. KIỂM TRA BẢN GHI MỒ CÔI TRONG DỮ LIỆU KIỂM THỬ SPRINT ===' AS `Section`;

-- 2.1 Kiểm tra Contacts của Sprint 3 không mồ côi
SELECT 'Sprint 3 - Orphaned Contacts' AS `Check`, COUNT(*) AS `Violations`
FROM `contacts` c
LEFT JOIN `customers` cust ON c.customer_id = cust.customer_id
WHERE c.contact_id BETWEEN 3001 AND 3099 AND cust.customer_id IS NULL;

-- 2.2 Kiểm tra Opportunities của Sprint 5 không mồ côi
SELECT 'Sprint 5 - Orphaned Opportunities' AS `Check`, COUNT(*) AS `Violations`
FROM `opportunities` o
LEFT JOIN `customers` cust ON o.customer_id = cust.customer_id
WHERE o.opportunity_id BETWEEN 5001 AND 5099 AND cust.customer_id IS NULL;

-- 2.3 Kiểm tra Quotes của Sprint 5 không mồ côi
SELECT 'Sprint 5 - Orphaned Quotes' AS `Check`, COUNT(*) AS `Violations`
FROM `quotes` q
LEFT JOIN `users` u ON q.owner_id = u.user_id
WHERE q.quote_id BETWEEN 5001 AND 5099 AND u.user_id IS NULL;

SELECT '=== 3. XÁC MINH CÁC TÌNH HUỐNG BIÊN ĐẶC THÙ THEO SPRINT ===' AS `Section`;

-- 3.1 Sprint 1: Có tài khoản bị khóa tạm và tài khoản có token hết hạn
SELECT 'S1 - Locked User Count' AS `Check_Item`, COUNT(*) AS `Result`
FROM `users` WHERE `user_id` = 1009 AND `lockout_until` > NOW();

SELECT 'S1 - Expired Token User Count', COUNT(*)
FROM `users` WHERE `user_id` = 1010 AND `reset_token_expiry` < NOW();

-- 3.2 Sprint 3: Khách hàng rủi ro Churn Risk (có ticket URGENT)
SELECT 'S3 - Churn Risk Customers', COUNT(DISTINCT customer_id)
FROM `support_requests` WHERE priority = 'URGENT' AND status = 'OPEN';

-- 3.3 Sprint 4: Lead vi phạm SLA quá hạn phản hồi
SELECT 'S4 - Overdue SLA Leads', COUNT(*)
FROM `leads` WHERE is_overdue = 1;

-- 3.4 Sprint 5: Toàn bộ Deal Won và Lost có lý do đầy đủ
SELECT 'S5 - Closed Deals Without Reason', COUNT(*)
FROM `opportunities`
WHERE `opportunity_id` BETWEEN 5001 AND 5099
  AND pipeline_stage_id IN (5, 6)
  AND win_loss_reason_id IS NULL;

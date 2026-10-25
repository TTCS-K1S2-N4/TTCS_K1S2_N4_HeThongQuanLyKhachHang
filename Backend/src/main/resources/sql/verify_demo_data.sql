-- ====================================================================================
-- KIỂM TRA TÍNH TOÀN VẸN VÀ THỐNG KÊ DỮ LIỆU HỆ THỐNG CRM SAU SEED
-- ====================================================================================

USE `crm_db`;

SELECT '=== 1. THỐNG KÊ SỐ LƯỢNG BẢN GHI THEO BẢNG ===' AS `Section`;

SELECT 'users' AS `Table`, COUNT(*) AS `Total_Records` FROM `users`
UNION ALL
SELECT 'teams', COUNT(*) FROM `teams`
UNION ALL
SELECT 'campaigns', COUNT(*) FROM `campaigns`
UNION ALL
SELECT 'products', COUNT(*) FROM `products`
UNION ALL
SELECT 'customers', COUNT(*) FROM `customers`
UNION ALL
SELECT 'contacts', COUNT(*) FROM `contacts`
UNION ALL
SELECT 'leads', COUNT(*) FROM `leads`
UNION ALL
SELECT 'opportunities', COUNT(*) FROM `opportunities`
UNION ALL
SELECT 'quotes', COUNT(*) FROM `quotes`
UNION ALL
SELECT 'activities', COUNT(*) FROM `activities`
UNION ALL
SELECT 'support_requests', COUNT(*) FROM `support_requests`
UNION ALL
SELECT 'customer_care', COUNT(*) FROM `customer_care`;

SELECT '=== 2. KIỂM TRA DỮ LIỆU MỒ CÔI (ORPHANED RECORDS) ===' AS `Section`;

-- 2.1 Contacts không có customer_id hợp lệ
SELECT 'Orphaned Contacts' AS `Check`, COUNT(*) AS `Violations`
FROM `contacts` c
LEFT JOIN `customers` cust ON c.customer_id = cust.customer_id
WHERE c.customer_id IS NOT NULL AND cust.customer_id IS NULL;

-- 2.2 Leads có owner_id không tồn tại trong users
SELECT 'Orphaned Leads (Owner ID)' AS `Check`, COUNT(*) AS `Violations`
FROM `leads` l
LEFT JOIN `users` u ON l.owner_id = u.user_id
WHERE l.owner_id IS NOT NULL AND u.user_id IS NULL;

-- 2.3 Opportunities có customer_id không tồn tại
SELECT 'Orphaned Opportunities (Customer)' AS `Check`, COUNT(*) AS `Violations`
FROM `opportunities` o
LEFT JOIN `customers` c ON o.customer_id = c.customer_id
WHERE o.customer_id IS NOT NULL AND c.customer_id IS NULL;

-- 2.4 Opportunities có pipeline_stage_id không tồn tại
SELECT 'Orphaned Opportunities (Pipeline Stage)' AS `Check`, COUNT(*) AS `Violations`
FROM `opportunities` o
LEFT JOIN `pipeline_stages` ps ON o.pipeline_stage_id = ps.pipeline_stage_id
WHERE o.pipeline_stage_id IS NOT NULL AND ps.pipeline_stage_id IS NULL;

-- 2.5 Quotes có owner_id không tồn tại
SELECT 'Orphaned Quotes' AS `Check`, COUNT(*) AS `Violations`
FROM `quotes` q
LEFT JOIN `users` u ON q.owner_id = u.user_id
WHERE q.owner_id IS NOT NULL AND u.user_id IS NULL;

-- 2.6 Activities có owner_id không tồn tại
SELECT 'Orphaned Activities (Owner ID)' AS `Check`, COUNT(*) AS `Violations`
FROM `activities` a
LEFT JOIN `users` u ON a.owner_id = u.user_id
WHERE a.owner_id IS NOT NULL AND u.user_id IS NULL;

-- 2.7 Support Requests có customer_id không tồn tại
SELECT 'Orphaned Support Requests' AS `Check`, COUNT(*) AS `Violations`
FROM `support_requests` sr
LEFT JOIN `customers` c ON sr.customer_id = c.customer_id
WHERE sr.customer_id IS NOT NULL AND c.customer_id IS NULL;

-- 2.8 Customer Care có customer_id không tồn tại
SELECT 'Orphaned Customer Care' AS `Check`, COUNT(*) AS `Violations`
FROM `customer_care` cc
LEFT JOIN `customers` c ON cc.customer_id = c.customer_id
WHERE cc.customer_id IS NOT NULL AND c.customer_id IS NULL;

SELECT '=== 3. KIỂM TRA PHÂN PHỐI LEAD THEO TRẠNG THÁI ===' AS `Section`;
SELECT status, COUNT(*) AS count_leads FROM `leads` GROUP BY status;

SELECT '=== 4. KIỂM TRA PHÂN PHỐI CƠ HỘI THEO GIAI ĐOẠN PIPELINE ===' AS `Section`;
SELECT ps.stage_name, COUNT(o.opportunity_id) AS count_opportunities, COALESCE(SUM(o.amount), 0) AS total_pipeline_value
FROM `pipeline_stages` ps
LEFT JOIN `opportunities` o ON ps.pipeline_stage_id = o.pipeline_stage_id
GROUP BY ps.pipeline_stage_id, ps.stage_name, ps.display_order
ORDER BY ps.display_order;

SELECT '=== 5. KIỂM TRA CƠ CẤU VAI TRÒ NGƯỜI DÙNG ===' AS `Section`;
SELECT r.role_name, COUNT(DISTINCT ur.user_id) AS user_count
FROM `roles` r
LEFT JOIN `user_roles` ur ON r.role_id = ur.role_id
GROUP BY r.role_id, r.role_name;

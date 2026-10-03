-- =========================================================================
-- B盻・D盻ｮ LI盻・ M蘯ｪU D盻ｰ ﾃ¨ CRM (TEST DATA SCRIPT - CRM_DB)
-- Ch蘯｡y an toﾃn, khﾃｴng xﾃｳa d盻ｯ li盻㎡ cﾅｩ, khﾃｴng s盻ｭa tﾃi kho蘯｣n/phﾃ｢n quy盻］ hi盻㌻ cﾃｳ
-- =========================================================================

USE crm_db;

-- 1. DANH M盻､C Dﾃ儂G CHUNG (categories)
INSERT INTO categories (category_type, category_name, display_order, status) VALUES
('INDUSTRY', 'Cﾃｴng ngh盻・thﾃｴng tin & Ph蘯ｧn m盻［', 1, 'ACTIVE'),
('INDUSTRY', 'Tﾃi chﾃｭnh - Ngﾃ｢n hﾃng', 2, 'ACTIVE'),
('INDUSTRY', 'B蘯･t ﾄ黛ｻ冢g s蘯｣n & Xﾃ｢y d盻ｱng', 3, 'ACTIVE'),
('INDUSTRY', 'Bﾃ｡n l蘯ｻ & Thﾆｰ盻｣ng m蘯｡i ﾄ訴盻㌻ t盻ｭ', 4, 'ACTIVE'),
('INDUSTRY', 'Y t蘯ｿ & Dﾆｰ盻｣c ph蘯ｩm', 5, 'ACTIVE'),
('SOURCE', 'Website / Gi盻嬖 thi盻㎡ t盻ｫ Web', 1, 'ACTIVE'),
('SOURCE', 'Gi盻嬖 thi盻㎡ t盻ｫ ﾄ黛ｻ訴 tﾃ｡c', 2, 'ACTIVE'),
('SOURCE', 'H盻冓 th蘯｣o / S盻ｱ ki盻㌻', 3, 'ACTIVE'),
('SOURCE', 'Cold Call / G盻絞 ﾄ訴盻㌻ ti蘯ｿp c蘯ｭn', 4, 'ACTIVE'),
('LEAD_STATUS', 'M盻嬖 t蘯｡o', 1, 'ACTIVE'),
('LEAD_STATUS', 'ﾄ紳ng liﾃｪn h盻・, 2, 'ACTIVE'),
('LEAD_STATUS', 'ﾄ静｣ xﾃ｡c ﾄ黛ｻ杵h nhu c蘯ｧu', 3, 'ACTIVE'),
('LEAD_STATUS', 'Khﾃｴng ti盻［ nﾄハg', 4, 'ACTIVE')
ON DUPLICATE KEY UPDATE display_order = VALUES(display_order), status = VALUES(status);

-- 2. S蘯｢N PH蘯ｨM & D盻海H V盻､ (products)
INSERT INTO products (product_code, product_name, product_type, unit, list_price, floor_price, cost_price, status) VALUES
('PROD-CRM-ENT', 'Ph蘯ｧn m盻［ CRM B蘯｣n Enterprise (Gﾃｳi nﾄノ)', 'SUBSCRIPTION', 'Gﾃｳi/Nﾄノ', 120000000.00, 100000000.00, 60000000.00, 'ACTIVE'),
('PROD-CRM-STD', 'Ph蘯ｧn m盻［ CRM B蘯｣n Standard (Gﾃｳi nﾄノ)', 'SUBSCRIPTION', 'Gﾃｳi/Nﾄノ', 48000000.00, 40000000.00, 24000000.00, 'ACTIVE'),
('PROD-IMP-SVC', 'D盻議h v盻･ Tﾆｰ v蘯･n & Tri盻ハ khai H盻・th盻創g', 'ONE_TIME', 'D盻ｱ ﾃ｡n', 50000000.00, 40000000.00, 20000000.00, 'ACTIVE'),
('PROD-TRN-SVC', 'D盻議h v盻･ ﾄ静o t蘯｡o Nhﾃ｢n s盻ｱ S盻ｭ d盻･ng CRM', 'ONE_TIME', 'Khﾃｳa', 15000000.00, 12000000.00, 5000000.00, 'ACTIVE'),
('PROD-SUP-247', 'Gﾃｳi H盻・tr盻｣ K盻ｹ thu蘯ｭt ﾆｯu tiﾃｪn 24/7', 'SUBSCRIPTION', 'Nﾄノ', 30000000.00, 25000000.00, 10000000.00, 'ACTIVE')
ON DUPLICATE KEY UPDATE product_name = VALUES(product_name), list_price = VALUES(list_price), status = VALUES(status);

-- 3. GIAI ﾄ唇蘯N PIPELINE (pipeline_stages)
INSERT INTO pipeline_stages (stage_name, display_order, default_probability, exit_condition, status) VALUES
('Kh盻殃 t蘯｡o / Ti蘯ｿp c蘯ｭn', 1, 10.00, 'ﾄ静｣ xﾃ｡c ﾄ黛ｻ杵h ngﾆｰ盻拱 liﾃｪn h盻・chﾃｭnh', 'ACTIVE'),
('Xﾃ｡c ﾄ黛ｻ杵h nhu c蘯ｧu', 2, 30.00, 'ﾄ静｣ hoﾃn thﾃnh kh蘯｣o sﾃ｡t yﾃｪu c蘯ｧu', 'ACTIVE'),
('ﾄ雪ｻ・xu蘯･t gi蘯｣i phﾃ｡p & Bﾃ｡o giﾃ｡', 3, 50.00, 'ﾄ静｣ g盻ｭi bﾃ｡o giﾃ｡ chﾃｭnh th盻ｩc', 'ACTIVE'),
('Thﾆｰﾆ｡ng lﾆｰ盻｣ng h盻｣p ﾄ黛ｻ渡g', 4, 80.00, 'ﾄ静｣ ﾄ黛ｻ渡g ﾃｽ ﾄ訴盻「 kho蘯｣n chﾃｭnh', 'ACTIVE'),
('Ch盻奏 thﾃnh cﾃｴng (Won)', 5, 100.00, 'H盻｣p ﾄ黛ｻ渡g ﾄ妥｣ kﾃｽ vﾃ thanh toﾃ｡n', 'ACTIVE'),
('Th蘯･t b蘯｡i (Lost)', 6, 0.00, 'Khﾃ｡ch hﾃng t盻ｫ ch盻訴 ho蘯ｷc ch盻肱 ﾄ黛ｻ訴 th盻ｧ', 'ACTIVE')
ON DUPLICATE KEY UPDATE display_order = VALUES(display_order), default_probability = VALUES(default_probability);

-- 4. Lﾃ・DO TH蘯ｮNG / THUA (win_loss_reasons)
INSERT INTO win_loss_reasons (reason_type, reason_name, display_order, status) VALUES
('WIN', 'Giﾃ｡ c蘯｣ c蘯｡nh tranh & H盻｣p lﾃｽ', 1, 'ACTIVE'),
('WIN', 'Tﾃｭnh nﾄハg ﾄ妥｡p 盻ｩng hoﾃn h蘯｣o yﾃｪu c蘯ｧu', 2, 'ACTIVE'),
('WIN', 'D盻議h v盻･ h盻・tr盻｣ & ﾄ静o t蘯｡o chuyﾃｪn nghi盻㎝', 3, 'ACTIVE'),
('LOSS', 'Giﾃ｡ thﾃnh cao hﾆ｡n ngﾃ｢n sﾃ｡ch', 1, 'ACTIVE'),
('LOSS', 'Khﾃ｡ch hﾃng ch盻肱 ﾄ黛ｻ訴 th盻ｧ c蘯｡nh tranh', 2, 'ACTIVE'),
('LOSS', 'T蘯｡m d盻ｫng d盻ｱ ﾃ｡n do thay ﾄ黛ｻ品 k蘯ｿ ho蘯｡ch', 3, 'ACTIVE')
ON DUPLICATE KEY UPDATE display_order = VALUES(display_order);

-- 5. ﾄ雪ｻ蝕 TH盻ｦ C蘯NH TRANH (competitors)
INSERT INTO competitors (competitor_name, status) VALUES
('Cﾃｴng ty Gi蘯｣i phﾃ｡p Ph蘯ｧn m盻［ Alpha', 'ACTIVE'),
('Cﾃｴng ty Cﾃｴng ngh盻・CRM Beta', 'ACTIVE'),
('T蘯ｭp ﾄ双ﾃn H盻・th盻創g Thﾃｴng tin Gamma', 'ACTIVE')
ON DUPLICATE KEY UPDATE status = VALUES(status);

-- 6. KHﾃ，H HﾃNG (customers) - Phﾃ｢n b盻・cho user_id 4 (Team 1) vﾃ user_id 5 (Team 2)
INSERT INTO customers (customer_id, customer_name, phone, owner_id) VALUES
(101, 'T蘯ｭp ﾄ双ﾃn Cﾃｴng ngh盻・FPT Global', '02437689001', 4),
(102, 'Cﾃｴng ty C盻・ph蘯ｧn ﾄ雪ｺｧu tﾆｰ B蘯･t ﾄ黛ｻ冢g s蘯｣n Vinhomes', '02439749999', 4),
(103, 'Ngﾃ｢n hﾃng TMCP K盻ｹ Thﾆｰﾆ｡ng Vi盻㏄ Nam (Techcombank)', '02439446368', 4),
(104, 'Cﾃｴng ty TNHH Bﾃ｡n l蘯ｻ Masan Retail', '02854161234', 4),
(105, 'T盻貧g Cﾃｴng ty Dﾆｰ盻｣c ph蘯ｩm H蘯ｭu Giang', '02923891433', 4),
(106, 'Cﾃｴng ty C盻・ph蘯ｧn S盻ｯa Vi盻㏄ Nam (Vinamilk)', '02854155555', 5),
(107, 'T蘯ｭp ﾄ双ﾃn Hﾃｲa Phﾃ｡t Group', '02462820700', 5),
(108, 'Cﾃｴng ty TNHH Ph蘯ｧn m盻［ MISA', '02437959595', 5),
(109, 'T盻貧g Cﾃｴng ty Hﾃng khﾃｴng Vi盻㏄ Nam (Vietnam Airlines)', '02438732732', 5),
(110, 'Cﾃｴng ty C盻・ph蘯ｧn Th蘯ｿ Gi盻嬖 Di ﾄ雪ｻ冢g', '02838125960', 5)
ON DUPLICATE KEY UPDATE customer_name = VALUES(customer_name), phone = VALUES(phone), owner_id = VALUES(owner_id);

-- 7. Cﾆ H盻露 Bﾃ¨ HﾃNG (opportunities) - Phﾃ｢n b盻・cho user_id 4 vﾃ user_id 5
INSERT INTO opportunities (opportunity_id, title, amount, owner_id) VALUES
(201, 'Tri盻ハ khai CRM Enterprise cho FPT Global', 170000000.00, 4),
(202, 'Nﾃ｢ng c蘯･p H盻・th盻創g Qu蘯｣n lﾃｽ Khﾃ｡ch hﾃng Vinhomes', 120000000.00, 4),
(203, 'Tﾆｰ v蘯･n gi蘯｣i phﾃ｡p Chﾄノ sﾃｳc Khﾃ｡ch hﾃng Techcombank', 98000000.00, 4),
(204, 'Gﾃｳi CRM Standard cho Masan Retail', 48000000.00, 4),
(205, 'ﾄ静o t蘯｡o & Chuy盻ハ giao H盻・th盻創g Dﾆｰ盻｣c H蘯ｭu Giang', 15000000.00, 4),
(206, 'S盻・hﾃｳa quy trﾃｬnh Sales Vinamilk Mi盻］ Nam', 200000000.00, 5),
(207, 'Tri盻ハ khai CRM cho T蘯ｭp ﾄ双ﾃn Hﾃｲa Phﾃ｡t', 150000000.00, 5),
(208, 'H盻｣p ﾄ黛ｻ渡g Gﾃｳi H盻・tr盻｣ K盻ｹ thu蘯ｭt 24/7 MISA', 30000000.00, 5),
(209, 'Tﾆｰ v蘯･n CRM Qu蘯｣n lﾃｽ ﾄ雪ｺｷt ch盻・Vietnam Airlines', 250000000.00, 5),
(210, 'Trang b盻・Ph蘯ｧn m盻［ CRM cho Th蘯ｿ Gi盻嬖 Di ﾄ雪ｻ冢g', 180000000.00, 5)
ON DUPLICATE KEY UPDATE title = VALUES(title), amount = VALUES(amount), owner_id = VALUES(owner_id);

-- 8. HO蘯T ﾄ雪ｻ朗G (activities) - Phﾃ｢n b盻・cho user_id 4 vﾃ user_id 5
INSERT INTO activities (activity_id, title, description, owner_id) VALUES
(301, 'Cu盻冂 h盻膏 trao ﾄ黛ｻ品 yﾃｪu c蘯ｧu v盻嬖 FPT Global', 'G蘯ｷp tr盻ｱc ti蘯ｿp Ban Giﾃ｡m ﾄ黛ｻ祖 FPT ﾄ黛ｻ・kh蘯｣o sﾃ｡t quy trﾃｬnh bﾃ｡n hﾃng hi盻㌻ t蘯｡i.', 4),
(302, 'G盻絞 ﾄ訴盻㌻ demo tﾃｭnh nﾄハg CRM cho Vinhomes', 'Trﾃｬnh bﾃy tﾃｭnh nﾄハg phﾃ｢n quy盻］ ph蘯｡m vi d盻ｯ li盻㎡ vﾃ bﾃ｡o cﾃ｡o doanh thu.', 4),
(303, 'G盻ｭi h盻・sﾆ｡ nﾄハg l盻ｱc & ﾄ雪ｻ・xu蘯･t d盻議h v盻･ Techcombank', 'ﾄ静｣ g盻ｭi file PDF ﾄ黛ｻ・xu蘯･t gi蘯｣i phﾃ｡p qua email cho Trﾆｰ盻殤g phﾃｲng IT.', 4),
(304, 'Tﾆｰ v蘯･n tr盻ｱc ti蘯ｿp gﾃｳi Standard Masan Retail', 'Gi蘯｣i ﾄ妥｡p th蘯ｯc m蘯ｯc v盻・chi phﾃｭ duy trﾃｬ hﾃng nﾄノ vﾃ kh蘯｣ nﾄハg m盻・r盻冢g.', 4),
(305, 'Kh蘯｣o sﾃ｡t nhu c蘯ｧu ﾄ妥o t蘯｡o Dﾆｰ盻｣c H蘯ｭu Giang', 'Th盻創g nh蘯･t l盻議h ﾄ妥o t蘯｡o 3 bu盻品 cho 20 nhﾃ｢n viﾃｪn phﾃｲng kinh doanh.', 4),
(306, 'Cu盻冂 h盻膏 kh盻殃 ﾄ黛ｻ冢g d盻ｱ ﾃ｡n Vinamilk Mi盻］ Nam', 'Th盻創g nh蘯･t m盻祖 th盻拱 gian tri盻ハ khai giai ﾄ双蘯｡n 1 v盻嬖 Team Mi盻］ Nam.', 5),
(307, 'Thﾆｰﾆ｡ng lﾆｰ盻｣ng ﾄ訴盻「 kho蘯｣n h盻｣p ﾄ黛ｻ渡g Hﾃｲa Phﾃ｡t', 'ﾄ静m phﾃ｡n chi蘯ｿt kh蘯･u cho h盻｣p ﾄ黛ｻ渡g tri盻ハ khai quy mﾃｴ l盻嬾.', 5),
(308, 'Ki盻ノ tra k盻ｹ thu蘯ｭt gﾃｳi 24/7 cho MISA', 'Xﾃ｡c nh蘯ｭn h蘯｡ t蘯ｧng mﾃ｡y ch盻ｧ vﾃ thﾃｴng s盻・k蘯ｿt n盻訴 API.', 5),
(309, 'Demo tﾃｭnh nﾄハg bﾃ｡o cﾃ｡o Qu蘯｣n tr盻・Vietnam Airlines', 'Trﾃｬnh bﾃy dashboard phﾃ｢n tﾃｭch doanh s盻・theo t盻ｫng nhﾃｳm bﾃ｡n hﾃng.', 5),
(310, 'G盻絞 ﾄ訴盻㌻ chﾄノ sﾃｳc ﾄ黛ｻ杵h k盻ｳ Th蘯ｿ Gi盻嬖 Di ﾄ雪ｻ冢g', 'Ghi nh蘯ｭn ph蘯｣n h盻妬 v盻・tr蘯｣i nghi盻㍊ s盻ｭ d盻･ng th盻ｭ b蘯｣n demo.', 5)
ON DUPLICATE KEY UPDATE title = VALUES(title), description = VALUES(description), owner_id = VALUES(owner_id);

-- 9. Bﾃ＾ GIﾃ・(quotes) - Phﾃ｢n b盻・cho user_id 4 vﾃ user_id 5
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

-- 10. NH蘯ｬT Kﾃ・THAO Tﾃ， (audit_logs)
INSERT INTO audit_logs (action_type, performed_by, target_user_id, description, old_value, new_value) VALUES
('CREATE_CUSTOMER', 4, 4, 'Kh盻殃 t蘯｡o h盻・sﾆ｡ khﾃ｡ch hﾃng doanh nghi盻㎝ FPT Global', NULL, 'customer_id=101'),
('CREATE_OPPORTUNITY', 4, 4, 'T蘯｡o cﾆ｡ h盻冓 bﾃ｡n hﾃng FPT Global giﾃ｡ tr盻・170.000.000 VNﾄ・, NULL, 'opportunity_id=201'),
('CREATE_ACTIVITY', 4, 4, 'T蘯｡o l盻議h h蘯ｹn cu盻冂 h盻膏 trao ﾄ黛ｻ品 v盻嬖 FPT Global', NULL, 'activity_id=301'),
('CREATE_CUSTOMER', 5, 5, 'Kh盻殃 t蘯｡o h盻・sﾆ｡ khﾃ｡ch hﾃng Vinamilk Mi盻］ Nam', NULL, 'customer_id=106'),
('CREATE_OPPORTUNITY', 5, 5, 'T蘯｡o cﾆ｡ h盻冓 bﾃ｡n hﾃng Vinamilk Mi盻］ Nam giﾃ｡ tr盻・200.000.000 VNﾄ・, NULL, 'opportunity_id=206'),
('CREATE_ACTIVITY', 5, 5, 'T蘯｡o l盻議h h蘯ｹn cu盻冂 h盻膏 kh盻殃 ﾄ黛ｻ冢g d盻ｱ ﾃ｡n Vinamilk Mi盻］ Nam', NULL, 'activity_id=306');

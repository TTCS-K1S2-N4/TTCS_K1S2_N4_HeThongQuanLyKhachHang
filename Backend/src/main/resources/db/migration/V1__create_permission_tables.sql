-- =====================================================================
-- S1-05 Phân quyền dữ liệu + S1-06 Menu theo quyền
-- =====================================================================

-- Vai trò (Role). data_scope quyết định phạm vi dữ liệu mặc định của vai trò:
--   MY   = chỉ thấy dữ liệu do chính mình sở hữu
--   TEAM = thấy dữ liệu của cả nhóm kinh doanh mình phụ trách (kể cả nhóm con)
--   ALL  = thấy toàn bộ dữ liệu (vd: Giám đốc kinh doanh, Quản trị hệ thống)
CREATE TABLE roles (
    id          BIGINT AUTO_INCREMENT PRIMARY KEY,
    code        VARCHAR(50)  NOT NULL UNIQUE,   -- SALES_STAFF, TEAM_LEADER, SALES_DIRECTOR, ADMIN...
    name        VARCHAR(100) NOT NULL,          -- Nhân viên kinh doanh, Trưởng nhóm, Giám đốc kinh doanh...
    data_scope  ENUM('MY','TEAM','ALL') NOT NULL DEFAULT 'MY',
    created_at  DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at  DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Nhóm kinh doanh, có cấu trúc cây (S2-06) — parent_id NULL = nhóm gốc
CREATE TABLE teams (
    id          BIGINT AUTO_INCREMENT PRIMARY KEY,
    name        VARCHAR(150) NOT NULL,
    parent_id   BIGINT NULL,
    leader_id   BIGINT NULL,                    -- user_id của trưởng nhóm, set sau khi tạo user
    created_at  DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_team_parent FOREIGN KEY (parent_id) REFERENCES teams(id)
);

-- Người dùng hệ thống
CREATE TABLE users (
    id            BIGINT AUTO_INCREMENT PRIMARY KEY,
    email         VARCHAR(150) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    full_name     VARCHAR(150) NOT NULL,
    role_id       BIGINT NOT NULL,
    team_id       BIGINT NULL,
    active        TINYINT(1) NOT NULL DEFAULT 1,
    created_at    DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at    DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_user_role FOREIGN KEY (role_id) REFERENCES roles(id),
    CONSTRAINT fk_user_team FOREIGN KEY (team_id) REFERENCES teams(id)
);

ALTER TABLE teams ADD CONSTRAINT fk_team_leader FOREIGN KEY (leader_id) REFERENCES users(id);

-- Danh mục menu điều hướng (S1-06)
CREATE TABLE menu_items (
    id          BIGINT AUTO_INCREMENT PRIMARY KEY,
    code        VARCHAR(50)  NOT NULL UNIQUE,   -- CUSTOMER_LIST, OPPORTUNITY, REPORT, USER_MGMT...
    name        VARCHAR(150) NOT NULL,
    url         VARCHAR(255) NOT NULL,
    icon        VARCHAR(100) NULL,
    parent_id   BIGINT NULL,
    order_index INT NOT NULL DEFAULT 0,
    CONSTRAINT fk_menu_parent FOREIGN KEY (parent_id) REFERENCES menu_items(id)
);

-- Ánh xạ: vai trò nào được thấy menu nào
CREATE TABLE role_menu_permissions (
    role_id BIGINT NOT NULL,
    menu_id BIGINT NOT NULL,
    PRIMARY KEY (role_id, menu_id),
    CONSTRAINT fk_rmp_role FOREIGN KEY (role_id) REFERENCES roles(id),
    CONSTRAINT fk_rmp_menu FOREIGN KEY (menu_id) REFERENCES menu_items(id)
);

-- ---------------------------------------------------------------------
-- Dữ liệu mẫu để dev/test
-- ---------------------------------------------------------------------
INSERT INTO roles (code, name, data_scope) VALUES
 ('SALES_STAFF',    'Nhân viên kinh doanh', 'MY'),
 ('TEAM_LEADER',     'Trưởng nhóm kinh doanh', 'TEAM'),
 ('SALES_DIRECTOR',  'Giám đốc kinh doanh', 'ALL'),
 ('ADMIN',           'Quản trị hệ thống', 'ALL');

INSERT INTO menu_items (code, name, url, icon, order_index) VALUES
 ('DASHBOARD',      'Trang chủ',            '/dashboard',        'home',    1),
 ('CUSTOMER_LIST',  'Danh mục khách hàng',  '/customers',        'users',   2),
 ('OPPORTUNITY',    'Cơ hội bán hàng',      '/opportunities',    'target',  3),
 ('REPORT',         'Báo cáo',              '/reports',          'chart',   4),
 ('USER_MGMT',      'Quản trị tài khoản',   '/admin/users',      'settings',5),
 ('TEAM_MGMT',      'Quản trị nhóm',        '/admin/teams',      'sitemap', 6);

-- SALES_STAFF: chỉ thấy Dashboard, Danh mục KH, Cơ hội
INSERT INTO role_menu_permissions (role_id, menu_id)
SELECT r.id, m.id FROM roles r, menu_items m
WHERE r.code = 'SALES_STAFF' AND m.code IN ('DASHBOARD','CUSTOMER_LIST','OPPORTUNITY');

-- TEAM_LEADER: thêm Báo cáo
INSERT INTO role_menu_permissions (role_id, menu_id)
SELECT r.id, m.id FROM roles r, menu_items m
WHERE r.code = 'TEAM_LEADER' AND m.code IN ('DASHBOARD','CUSTOMER_LIST','OPPORTUNITY','REPORT');

-- SALES_DIRECTOR: tất cả trừ quản trị tài khoản/nhóm
INSERT INTO role_menu_permissions (role_id, menu_id)
SELECT r.id, m.id FROM roles r, menu_items m
WHERE r.code = 'SALES_DIRECTOR' AND m.code IN ('DASHBOARD','CUSTOMER_LIST','OPPORTUNITY','REPORT');

-- ADMIN: toàn bộ menu
INSERT INTO role_menu_permissions (role_id, menu_id)
SELECT r.id, m.id FROM roles r, menu_items m WHERE r.code = 'ADMIN';

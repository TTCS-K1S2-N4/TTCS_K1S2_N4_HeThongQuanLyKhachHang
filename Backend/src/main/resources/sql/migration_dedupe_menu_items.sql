USE crm_db;

DELETE newer
FROM menu_items AS newer
JOIN menu_items AS older
  ON newer.url = older.url
 AND newer.permission_code = older.permission_code
 AND newer.id > older.id;

ALTER TABLE menu_items
ADD UNIQUE KEY uk_menu_url_permission (url, permission_code);
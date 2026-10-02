USE crm_db;

SET @menu_permission_unique_index = (
  SELECT MIN(index_name)
  FROM (
    SELECT index_name
    FROM information_schema.statistics
    WHERE table_schema = DATABASE()
      AND table_name = 'menu_items'
      AND non_unique = 0
      AND column_name = 'permission_code'
    GROUP BY index_name
    HAVING COUNT(*) = 1
  ) AS permission_indexes
);

SET @drop_menu_permission_unique_sql = IF(
  @menu_permission_unique_index IS NULL,
  'SELECT 1',
  CONCAT('ALTER TABLE menu_items DROP INDEX `', @menu_permission_unique_index, '`')
);
PREPARE drop_menu_permission_unique_stmt FROM @drop_menu_permission_unique_sql;
EXECUTE drop_menu_permission_unique_stmt;
DEALLOCATE PREPARE drop_menu_permission_unique_stmt;

DELETE newer
FROM menu_items AS newer
JOIN menu_items AS older
  ON newer.url = older.url
 AND newer.permission_code = older.permission_code
 AND newer.id > older.id;

ALTER TABLE menu_items
ADD UNIQUE KEY uk_menu_url_permission (url, permission_code);
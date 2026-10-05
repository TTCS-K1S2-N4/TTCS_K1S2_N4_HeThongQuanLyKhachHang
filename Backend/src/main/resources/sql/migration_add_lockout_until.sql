-- Migration script: Add lockout_until column to users table idempotently
USE crm_db;

SET @col_exists = (
    SELECT COUNT(*) 
    FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE TABLE_SCHEMA = DATABASE() 
      AND TABLE_NAME = 'users' 
      AND COLUMN_NAME = 'lockout_until'
);

SET @sql_cmd = IF(@col_exists = 0, 
    'ALTER TABLE users ADD COLUMN lockout_until TIMESTAMP NULL DEFAULT NULL;', 
    'SELECT "Column lockout_until already exists" AS status;'
);

PREPARE stmt FROM @sql_cmd;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

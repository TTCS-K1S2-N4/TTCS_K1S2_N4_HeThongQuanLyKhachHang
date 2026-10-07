-- Migration: Add customer fields (tax_code, industry, size, website, address, status)
ALTER TABLE customers 
    ADD COLUMN tax_code VARCHAR(50) UNIQUE AFTER phone,
    ADD COLUMN industry VARCHAR(100) AFTER tax_code,
    ADD COLUMN size VARCHAR(50) AFTER industry,
    ADD COLUMN website VARCHAR(255) AFTER size,
    ADD COLUMN address VARCHAR(255) AFTER website,
    ADD COLUMN status VARCHAR(50) DEFAULT 'Tiềm năng' AFTER address;

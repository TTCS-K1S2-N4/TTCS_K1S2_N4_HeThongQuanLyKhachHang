-- CRM | SHARED LEAD DATABASE | Sprint 04
-- File: lead_management.sql
-- STATUS: DRAFT FOR DB OWNER REVIEW. DO NOT RUN ON PRODUCTION.
-- Source: Backend/src/main/resources/sql/schema.sql from project ZIP (2026-10-09).
-- Purpose: shared baseline for S4-01..S4-09, particularly S4-06/S4-07/S4-08.
-- IMPORTANT: The ZIP predates BE04 V2; recheck its latest SQL before approval.
-- This is NOT a replacement for schema.sql. After approval, synchronize the canonical schema.
-- Back up crm_db and test on a clone before applying. Use InnoDB / utf8mb4.

-- 1. CORE LEADS: shared by all Lead features.
-- Column choices below are a proposed minimum, NOT an approved Lead contract.
CREATE TABLE IF NOT EXISTS leads (
    lead_id INT AUTO_INCREMENT PRIMARY KEY,
    company_name VARCHAR(200) NULL,
    contact_name VARCHAR(150) NOT NULL,
    email VARCHAR(150) NULL,
    phone VARCHAR(20) NULL,
    status VARCHAR(30) NOT NULL DEFAULT 'NEW',
    owner_id INT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_leads_status (status),
    INDEX idx_leads_owner (owner_id),
    CONSTRAINT fk_leads_owner FOREIGN KEY (owner_id) REFERENCES users(user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 2. S4-06: proposed lead assignment configuration.
-- Do not create lead_assignment_rules until the rule/priority/team model is approved.
-- 3. S4-06/07: proposed assignment history.
-- Do not create lead_assignment_history until the event model is approved.
-- 4. S4-07: SLA configuration/state.
-- Do not create tables until ownership, timing, and status semantics are approved.
-- 5. S4-08: lead_conversion_links.
-- Do not create until deciding whether linkage is already represented elsewhere.
-- 6. S4-01/02/04/05/09: lead_sources, lead_web_forms, lead_merge_history,
-- lead_scoring_rules/config, saved_filters: verify reuse and approve independently.

-- 7. SHARED RELATIONSHIPS NEEDED BY S4-08
-- The current source schema has no activities.lead_id / activities.customer_id
-- or opportunities.customer_id. Add only after confirming the live database
-- and all existing migrations. Statements below are intentionally commented
-- to avoid duplicate-column errors and unintended changes.
-- ALTER TABLE activities ADD COLUMN lead_id INT NULL;
-- ALTER TABLE activities ADD COLUMN customer_id INT NULL;
-- ALTER TABLE opportunities ADD COLUMN customer_id INT NULL;
-- ALTER TABLE activities ADD CONSTRAINT fk_activities_lead
--     FOREIGN KEY (lead_id) REFERENCES leads(lead_id);
-- ALTER TABLE activities ADD CONSTRAINT fk_activities_customer
--     FOREIGN KEY (customer_id) REFERENCES customers(customer_id);
-- ALTER TABLE opportunities ADD CONSTRAINT fk_opportunities_customer
--     FOREIGN KEY (customer_id) REFERENCES customers(customer_id);

-- 8. REQUIRED RECONCILIATION BEFORE EXECUTION
-- contacts: canonical schema uses full_name and title (NOT contact_name/position).
-- pipeline_stages: canonical PK is pipeline_stage_id (NOT stage_id).
-- Verify actual LeadConversionService SQL against these names.
-- Verify S4-08 activity provenance requirements before setting lead_id=NULL.
-- Verify authorization/data scope, indexes, FKs, status values, and migrations.
-- Verify no other Lead schema/migration exists before applying this file.

-- 9. READ-ONLY VERIFICATION QUERIES
SELECT TABLE_NAME FROM information_schema.TABLES
 WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME LIKE 'lead%'
 ORDER BY TABLE_NAME;
SELECT TABLE_NAME, COLUMN_NAME, COLUMN_TYPE, IS_NULLABLE
 FROM information_schema.COLUMNS
 WHERE TABLE_SCHEMA = DATABASE()
   AND TABLE_NAME IN ('leads','activities','opportunities','contacts','pipeline_stages')
 ORDER BY TABLE_NAME, ORDINAL_POSITION;

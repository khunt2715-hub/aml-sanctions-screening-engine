-- Initial Database Setup

CREATE DATABASE aml_screening;

USE aml_screening;

-- Core Tables
-- Creating the 5 Core tables to be used for the screening project - Customers, Sanctions Entities, Screening Rules, Screening Matches, Alerts
-- Also added - Field Level Explainations for matches and Indexes for Performance Optimization

-- =========================
-- 1. Customers
-- =========================
CREATE TABLE customers (
    customer_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    customer_type ENUM('INDIVIDUAL','BUSINESS') DEFAULT 'INDIVIDUAL',
    customer_subtype ENUM('PEP','NON-PEP') DEFAULT 'NON-PEP', -- For Individuals
    company_type ENUM('BANK','TRADING','NGO','OTHER') DEFAULT NULL, -- For Businesses
    date_of_birth DATE,
    nationality VARCHAR(100),
    country_of_residence VARCHAR(100),
    soundex_name VARCHAR(10),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- =========================
-- 2. Sanctions Entities
-- =========================
CREATE TABLE sanctions_entities (
    entity_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(255) NOT NULL,
    entity_type ENUM('INDIVIDUAL','COMPANY','GOVERNMENT','OTHER') DEFAULT 'INDIVIDUAL',
    company_type ENUM('BANK','TRADING','NGO','OTHER') DEFAULT NULL,
    date_of_birth DATE,
    nationality VARCHAR(100),
    source_list VARCHAR(100),           -- OFAC, UN, EU
    source_risk_weight DECIMAL(3,2),   -- 1.00 = highest risk
    soundex_name VARCHAR(10),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- =========================
-- 3. Screening Runs (Audit + Failure Monitoring)
-- =========================
CREATE TABLE screening_runs (
    run_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    run_type ENUM('INITIAL','RESCREEN','MANUAL'),
    run_reason VARCHAR(255),                 -- e.g., Daily OFAC refresh
    started_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    completed_at DATETIME,
    status ENUM('RUNNING','COMPLETED','FAILED'),
    failure_reason VARCHAR(255) DEFAULT NULL
);

-- =========================
-- 4. Screening Matches
-- =========================
CREATE TABLE screening_matches (
    match_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    run_id BIGINT NOT NULL,                  -- links to screening_runs
    customer_id BIGINT NOT NULL,             -- customer being screened
    entity_id BIGINT NOT NULL,               -- sanctions entity matched
    name_score DECIMAL(5,2),
    dob_score DECIMAL(5,2),
    nationality_score DECIMAL(5,2),
    total_score DECIMAL(6,2),
    match_status ENUM('PENDING','CONFIRMED','FALSE_POSITIVE'),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (run_id) REFERENCES screening_runs(run_id),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (entity_id) REFERENCES sanctions_entities(entity_id)
);

-- =========================
-- 5. Alerts
-- =========================
CREATE TABLE alerts (
    alert_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    match_id BIGINT,
    risk_score DECIMAL(6,2),
    risk_level ENUM('LOW','MEDIUM','HIGH','CRITICAL'),
    alert_status ENUM('OPEN','UNDER_REVIEW','ESCALATED','CLOSED'),
    assigned_to VARCHAR(100),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (match_id) REFERENCES screening_matches(match_id)
);

-- =========================
-- 6. Field-Level Explanations
-- =========================
CREATE TABLE match_explanations (
    explanation_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    match_id BIGINT NOT NULL,
    field_name VARCHAR(50),                 -- name, dob, nationality
    matching_method VARCHAR(50),            -- exact, soundex, levenshtein
    field_score DECIMAL(5,2),
    explanation_text TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (match_id) REFERENCES screening_matches(match_id)
);

-- =========================
-- 7. Indexes for Performance
-- =========================
CREATE INDEX idx_customer_name ON customers(last_name, first_name);
CREATE INDEX idx_customer_soundex ON customers(soundex_name);
CREATE INDEX idx_sanctions_soundex ON sanctions_entities(soundex_name);
CREATE INDEX idx_matches_run ON screening_matches(run_id);

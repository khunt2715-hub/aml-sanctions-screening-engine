-- Generating a Large Sample set with synthetic data
-- Intentional matches are being generated for testing purposes

-- ====================================
-- 1. Generate 950 Random Individuals
-- ====================================
DELIMITER $$

CREATE PROCEDURE generate_individuals()
BEGIN
    DECLARE i INT DEFAULT 1;
    WHILE i <= 950 DO
        INSERT INTO customers (
            first_name, last_name, customer_type, customer_subtype, company_type,
            date_of_birth, nationality, country_of_residence, soundex_name
        )
        VALUES (
            CONCAT('First', i),
            CONCAT('Last', i),
            'INDIVIDUAL',
            IF(i % 20 = 0, 'PEP', 'NON-PEP'),  -- every 20th individual is a PEP
            NULL,
            DATE_ADD('1960-01-01', INTERVAL FLOOR(RAND()*20000) DAY),
            CONCAT('Country', FLOOR(RAND()*50)+1),
            CONCAT('Country', FLOOR(RAND()*50)+1),
            SOUNDEX(CONCAT('First', i, ' Last', i))
        );
        SET i = i + 1;
    END WHILE;
END$$

DELIMITER ;

CALL generate_individuals();
DROP PROCEDURE generate_individuals;

-- ====================================
-- 2. Generate 50 Random Companies
-- ====================================
DELIMITER $$

CREATE PROCEDURE generate_companies()
BEGIN
    DECLARE i INT DEFAULT 1;
    WHILE i <= 50 DO
        INSERT INTO customers (
            first_name, last_name, customer_type, customer_subtype, company_type,
            date_of_birth, nationality, country_of_residence, soundex_name
        )
        VALUES (
            CONCAT('Company', i),     -- company name in first_name
            NULL,                     -- no last name
            'BUSINESS',               -- customer type
            NULL,                     -- no individual subtype
            ELT(FLOOR(1 + RAND()*4), 'BANK','TRADING','NGO','OTHER'), -- random company type
            NULL,                     -- no DOB
            CONCAT('Country', FLOOR(RAND()*50)+1),  -- random nationality
            CONCAT('Country', FLOOR(RAND()*50)+1),  -- random country of residence
            SOUNDEX(CONCAT('Company', i))           -- precompute soundex
        );
        SET i = i + 1;
    END WHILE;
END$$

DELIMITER ;

CALL generate_companies();
DROP PROCEDURE generate_companies;

-- ====================================
-- 3. Insert 50 Sanctions Entities (with intentional matches)
-- ====================================
INSERT INTO sanctions_entities (full_name, entity_type, company_type, date_of_birth, nationality, source_list, source_risk_weight, soundex_name)
VALUES
-- Exact Individual Match
('First1 Last1', 'INDIVIDUAL', NULL, NULL, 'Country1', 'OFAC', 1.00, SOUNDEX('First1 Last1')),
-- Fuzzy Individual Match
('First20 Last20', 'INDIVIDUAL', NULL, NULL, 'Country20', 'UN', 0.90, SOUNDEX('First20 Last20')),
-- Partial Individual Match
('First100 Last100', 'INDIVIDUAL', NULL, NULL, 'Country5', 'EU', 0.95, SOUNDEX('First100 Last100')),
-- Exact Company Match
('Company1', 'COMPANY', 'BANK', NULL, 'Country1', 'OFAC', 1.00, SOUNDEX('Company1')),
-- Partial Company Match
('Company10', 'COMPANY', 'TRADING', NULL, 'Country10', 'UN', 0.95, SOUNDEX('Company10'));

-- Add 45 more random sanctions entities
DELIMITER $$

CREATE PROCEDURE generate_sanctions()
BEGIN
    DECLARE i INT DEFAULT 1;
    WHILE i <= 45 DO
        INSERT INTO sanctions_entities (
            full_name, entity_type, company_type, date_of_birth, nationality, source_list, source_risk_weight, soundex_name
        )
        VALUES (
            CONCAT('SanctionEntity', i),
            ELT(FLOOR(1 + RAND()*2), 'INDIVIDUAL','COMPANY'),
            ELT(FLOOR(1 + RAND()*4), 'BANK','TRADING','NGO','OTHER'),
            DATE_ADD('1960-01-01', INTERVAL FLOOR(RAND()*20000) DAY),
            CONCAT('Country', FLOOR(RAND()*50)+1),
            ELT(FLOOR(1 + RAND()*3), 'OFAC','UN','EU'),
            ROUND(RAND(),2),
            SOUNDEX(CONCAT('SanctionEntity', i))
        );
        SET i = i + 1;
    END WHILE;
END$$

DELIMITER ;

CALL generate_sanctions();
DROP PROCEDURE generate_sanctions;

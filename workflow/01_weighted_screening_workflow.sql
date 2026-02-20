-- ======================================
-- Weighted Sanctions Screening Workflow
-- ======================================

-- 1. Create Screen Run

INSERT INTO screening_runs (
    run_type,
    run_reason,
    status
)
VALUES (
    'INITIAL',
    'Initial weighted sanctions screening',
    'RUNNING'
);

-- 2. Capture Run ID

SET @current_run_id = LAST_INSERT_ID();

-- 3. Prepare Temporary Table

DROP TEMPORARY TABLE temp_field_scores;

CREATE TEMPORARY TABLE temp_field_scores (
    customer_id INT,
    entity_id INT,
    name_score DECIMAL(5,2),
    dob_score DECIMAL(5,2),
    nationality_score DECIMAL(5,2),
    pep_score DECIMAL(5,2),
    entity_source_score DECIMAL(5,2)
);

-- 4. Populate Temporary Table with Field Level Scores

INSERT INTO temp_field_scores (
    customer_id,
    entity_id,
    name_score,
    dob_score,
    nationality_score,
    pep_score,
    entity_source_score
)
SELECT
    c.customer_id,
    s.entity_id,

    CASE
        WHEN CONCAT(c.first_name,' ',c.last_name) = s.full_name THEN 100
        WHEN SOUNDEX(CONCAT(c.first_name,' ',c.last_name)) = s.soundex_name THEN 80
        ELSE 0
    END,

    CASE
        WHEN c.date_of_birth IS NOT NULL
             AND c.date_of_birth = s.date_of_birth THEN 100
        ELSE 0
    END,

    CASE
        WHEN c.nationality = s.nationality THEN 100
        ELSE 0
    END,

    CASE
        WHEN c.customer_subtype = 'PEP' THEN 100
        ELSE 0
    END,

    s.source_risk_weight * 100

FROM customers c
CROSS JOIN sanctions_entities s;

-- 5. Insert Weighted Matches

INSERT INTO screening_matches (
    customer_id,
    entity_id,
    weighted_name,
    weighted_dob,
    weighted_nationality,
    weighted_pep,
    weighted_source,
    total_score,
    match_status,
    run_id
)
SELECT
    fs.customer_id,
    fs.entity_id,
    fs.name_score * w_name.weight,
    fs.dob_score * w_dob.weight,
    fs.nationality_score * w_nat.weight,
    fs.pep_score * w_pep.weight,
    fs.entity_source_score * w_src.weight,
    (
        fs.name_score * w_name.weight +
        fs.dob_score * w_dob.weight +
        fs.nationality_score * w_nat.weight +
        fs.pep_score * w_pep.weight +
        fs.entity_source_score * w_src.weight
    ),
    'PENDING',
    1
FROM temp_field_scores fs
JOIN screening_weights w_name  ON w_name.field_name = 'name'
JOIN screening_weights w_dob   ON w_dob.field_name  = 'dob'
JOIN screening_weights w_nat   ON w_nat.field_name  = 'nationality'
JOIN screening_weights w_pep   ON w_pep.field_name  = 'customer_type_pep'
JOIN screening_weights w_src   ON w_src.field_name  = 'entity_source'
WHERE (
    fs.name_score > 0
    OR fs.dob_score > 0
    OR fs.nationality_score > 0
);

-- 6. Mark Run Complete

UPDATE screening_runs
SET
    status = 'COMPLETED',
    completed_at = NOW()
WHERE run_id = 1;

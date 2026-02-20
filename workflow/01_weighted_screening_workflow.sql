-- =================================================
-- Weighted Sanctions Screening Workflow with Alerts
-- =================================================

-- 1. Create a new screening run

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

-- 2. Capture the auto-generated Run ID

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

-- 5. Scoring Explanations - For Audit Purposes

INSERT INTO match_explanations (
    run_id,
    customer_id,
    entity_id,
    explanation_text
)
SELECT
    sm.run_id,
    sm.customer_id,
    sm.entity_id,
    CONCAT_WS('; ',
        IF(sm.weighted_name > 0, CONCAT('Name(', sm.weighted_name, ')'), NULL),
        IF(sm.weighted_dob > 0, CONCAT('DOB(', sm.weighted_dob, ')'), NULL),
        IF(sm.weighted_nationality > 0, CONCAT('Nationality(', sm.weighted_nationality, ')'), NULL),
        IF(sm.weighted_pep > 0, CONCAT('PEP(', sm.weighted_pep, ')'), NULL),
        IF(sm.weighted_source > 0, CONCAT('Entity Source(', sm.weighted_source, ')'), NULL)
    ) AS explanation_text
FROM screening_matches sm
WHERE sm.run_id = @current_run_id;


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
    @current_run_id
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

-- 6. Assign risk levels based on total_score thresholds

UPDATE screening_matches
SET risk_level = CASE
	WHEN total_score >=50 THEN 'HIGH_RISK'
    WHEN total_score >=30 THEN 'MEDIUM_RISK'
    ELSE 'LOW_RISK'
END
WHERE run_id = @current_run_id;

-- 7. Generate Alerts for HIGH_RISK Matches in the Alerts Table

INSERT INTO alerts (run_id, customer_id, entity_id, risk_level)
SELECT run_id, customer_id, entity_id, risk_level
FROM screening_matches sm
WHERE run_id = @current_run_id
AND risk_level = 'HIGH_RISK'
AND NOT EXISTS (
    SELECT 1
    FROM alerts a
    WHERE a.run_id = sm.run_id
      AND a.customer_id = sm.customer_id
      AND a.entity_id = sm.entity_id
);

-- 8. Mark alert_generated flag in screening_matches

UPDATE screening_matches
SET alert_generated = TRUE
WHERE run_id = @current_run_id
AND risk_level = 'HIGH_RISK';

-- 6. Mark Run Complete

UPDATE screening_runs
SET
    status = 'COMPLETED',
    completed_at = NOW()
WHERE run_id = @current_run_id;

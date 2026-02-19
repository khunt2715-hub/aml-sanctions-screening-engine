-- Populating Temporary Table for Scoring

INSERT INTO temp_field_scores (customer_id, entity_id, name_score, dob_score, nationality_score, pep_score, entity_source_score)
SELECT
    c.customer_id,
    s.entity_id,
    CASE
        WHEN CONCAT(c.first_name,' ',c.last_name) = s.full_name THEN 100
        WHEN SOUNDEX(CONCAT(c.first_name,' ',c.last_name)) = s.soundex_name THEN 80
        ELSE 0
    END AS name_score,
    CASE
        WHEN c.date_of_birth IS NOT NULL AND c.date_of_birth = s.date_of_birth THEN 100
        ELSE 0
    END AS dob_score,
    CASE
        WHEN c.nationality = s.nationality THEN 100
        ELSE 0
    END AS nationality_score,
    CASE
        WHEN c.customer_subtype = 'PEP' THEN 100
        ELSE 0
    END AS pep_score,
    s.source_risk_weight * 100 AS entity_source_score
FROM customers c
CROSS JOIN sanctions_entities s;

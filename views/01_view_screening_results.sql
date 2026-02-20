-- ======================================================
-- Creating a View for the All Alerts
-- ======================================================

CREATE OR REPLACE VIEW vw_screening_results AS
SELECT
    sm.run_id,
    sr.run_type,
    sr.run_reason,
    sr.started_at,
    sr.completed_at,
    sm.customer_id,
    c.first_name,
    c.last_name,
    c.customer_subtype,
    sm.entity_id,
    se.full_name AS entity_name,
    sm.total_score,
    sm.risk_level,
    me.explanation_text,
    CASE WHEN a.alert_id IS NOT NULL THEN 'YES' ELSE 'NO' END AS alert_generated
FROM screening_matches sm
JOIN customers c 
    ON sm.customer_id = c.customer_id
JOIN sanctions_entities se 
    ON sm.entity_id = se.entity_id
JOIN screening_runs sr 
    ON sm.run_id = sr.run_id
LEFT JOIN match_explanations me
    ON sm.run_id = me.run_id
   AND sm.customer_id = me.customer_id
   AND sm.entity_id = me.entity_id
LEFT JOIN alerts a
    ON sm.run_id = a.run_id
   AND sm.customer_id = a.customer_id
   AND sm.entity_id = a.entity_id;

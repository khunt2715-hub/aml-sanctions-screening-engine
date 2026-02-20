-- ======================================================
-- Creating a Summary View for the Alerts
-- ======================================================

CREATE OR REPLACE VIEW vw_screening_summary AS
SELECT
    sr.run_id,
    sr.run_type,
    sr.run_reason,
    COUNT(sm.customer_id) AS total_matches,
    SUM(CASE WHEN sm.risk_level = 'HIGH_RISK' THEN 1 ELSE 0 END) AS high_risk_count,
    SUM(CASE WHEN sm.risk_level = 'MEDIUM_RISK' THEN 1 ELSE 0 END) AS medium_risk_count,
    SUM(CASE WHEN sm.risk_level = 'LOW_RISK' THEN 1 ELSE 0 END) AS low_risk_count,
    COUNT(DISTINCT a.alert_id) AS alerts_generated  -- DISTINCT prevents duplicates
FROM screening_runs sr
LEFT JOIN screening_matches sm
       ON sr.run_id = sm.run_id
LEFT JOIN alerts a
       ON sm.run_id = a.run_id
      AND sm.customer_id = a.customer_id
      AND sm.entity_id = a.entity_id
GROUP BY sr.run_id, sr.run_type, sr.run_reason;

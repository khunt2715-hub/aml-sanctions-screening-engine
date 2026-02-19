-- Temporary Table for Field-Level Scores

-- =========================================
-- 0. Ensure clean temporary table
-- =========================================

-- Try dropping the table (will error if it doesn't exist, safe to ignore)

DROP TEMPORARY TABLE temp_field_scores;

-- Create a fresh temporary table for field-level scores
CREATE TEMPORARY TABLE temp_field_scores (
    customer_id INT,
    entity_id INT,
    name_score DECIMAL(5,2),
    dob_score DECIMAL(5,2),
    nationality_score DECIMAL(5,2),
    pep_score DECIMAL(5,2),
    entity_source_score DECIMAL(5,2)
);

-- Optional: truncate if you are re-running in the same session
TRUNCATE TABLE temp_field_scores;

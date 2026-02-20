-- =============================================
-- Creating Revised Matching Explanations Table
-- =============================================

-- 1. Dropping the original Matching Explanations table that was created

DROP TABLE  match_explanations;

-- 2. Recreate with the columns needed for workflow

CREATE TABLE match_explanations (
    explanation_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    run_id BIGINT NOT NULL,          -- match type with screening_runs.run_id
    customer_id BIGINT NOT NULL,        -- match type with customers.customer_id
    entity_id BIGINT NOT NULL,          -- match type with sanctions_entities.entity_id
    explanation_text VARCHAR(255) NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_expl_run FOREIGN KEY (run_id) REFERENCES screening_runs(run_id),
    CONSTRAINT fk_expl_customer FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    CONSTRAINT fk_expl_entity FOREIGN KEY (entity_id) REFERENCES sanctions_entities(entity_id)
);


-- =========================================
-- Creating Revised Alerts Table
-- =========================================

-- 1. Dropping the original alerts table that was created

DROP TABLE alerts;

-- 2. Creating New Alerts Table

CREATE TABLE alerts (
    alert_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    run_id BIGINT NOT NULL,
    customer_id INT NOT NULL,
    entity_id INT NOT NULL,
    risk_level ENUM('LOW_RISK','MEDIUM_RISK','HIGH_RISK') NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (run_id) REFERENCES screening_runs(run_id)
);


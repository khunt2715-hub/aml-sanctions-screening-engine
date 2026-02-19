-- schema/02_screening_weights.sql
-- Adding Screening Weights Table to allow for dynamic changes

CREATE TABLE screening_weights (
    field_name VARCHAR(50) PRIMARY KEY,
    weight DECIMAL(5,2) NOT NULL
);

INSERT INTO screening_weights (field_name, weight) VALUES
('name', 0.50),
('dob', 0.20),
('nationality', 0.10),
('customer_type_pep', 0.10),
('entity_source', 0.10);

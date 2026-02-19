-- Modifying the Screening Matches with weighted columns

ALTER TABLE screening_matches
ADD COLUMN weighted_name DECIMAL(5,2) DEFAULT 0,
ADD COLUMN weighted_dob DECIMAL(5,2) DEFAULT 0,
ADD COLUMN weighted_nationality DECIMAL(5,2) DEFAULT 0,
ADD COLUMN weighted_pep DECIMAL(5,2) DEFAULT 0,
ADD COLUMN weighted_source DECIMAL(5,2) DEFAULT 0;

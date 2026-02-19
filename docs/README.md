**# AML / Compliance Screening Demo**



This repository contains a demo \*\*AML / sanctions screening system\*\* built with MySQL.  

It demonstrates a realistic approach to screening customers against sanctions lists with \*\*weighted risk scoring, explainable matches, and audit trails\*\*.



---



**## Project Structure**



aml-sanctions-screening-engine/

├─ schema/

│ ├─ 01\_tables.sql # Database schema for customers, sanctions, runs, matches, alerts

├─ sample\_data/

│ ├─ 01\_sample\_data.sql # Small demo dataset with intentional matches

│ ├─ 02\_generate\_full\_sample.sql # Larger dataset (~1000 customers + sanctions entities)

├─ README.md





---



**## Weighted Risk Scoring**



This system calculates a \*\*weighted risk score\*\* for each potential match between a customer and a sanctions entity.  

Each field contributes differently to the total risk score, allowing more important factors to have higher influence.



**### Scoring Factors**



| Field / Factor        | Weight | Notes |

|----------------------|--------|-------|

| Name match            | 50%    | Exact match = 100, Fuzzy/Soundex match = 80 |

| Date of Birth match   | 20%    | Exact match only |

| Nationality match     | 10%    | Exact match only |

| Customer Type / PEP   | 10%    | PEP status increases risk |

| Entity Source Weight  | 10%    | Based on OFAC / UN / EU list |



**### Total Score Formula**



total\_score =

(name\_score \* 0.5) +

(dob\_score \* 0.2) +

(nationality\_score \* 0.1) +

(pep\_score \* 0.1) +

(entity\_source\_score \* 0.1)





\- `total\_score` is scaled 0–100  

\- Matches with `total\_score >= 70` are flagged as \*\*PENDING\*\*  

\- Field-level scores are stored in `match\_explanations` for \*\*auditability\*\* and explainability  



---



**## Screening Process Overview**



1\. \*\*Screening Run\*\*  

&nbsp;  - Each run has a unique `run\_id` and status (`RUNNING`, `COMPLETED`, `FAILED`)  

&nbsp;  - Tracks start/end timestamps and failure reasons



2\. \*\*Matching\*\*  

&nbsp;  - Each customer is screened against all sanctions entities  

&nbsp;  - Exact + Soundex (fuzzy) matching applied on names  

&nbsp;  - Additional fields (DOB, nationality, PEP, entity source) scored individually



3\. \*\*Weighted Scoring\*\*  

&nbsp;  - Field scores are multiplied by weights to calculate `total\_score`  

&nbsp;  - High-risk matches are inserted into `screening\_matches`  



4\. \*\*Explainability \& Audit Trail\*\*  

&nbsp;  - Field-level scores stored in `match\_explanations`  

&nbsp;  - Alerts can be escalated based on `risk\_level`  



---



**## Sample Data**



\- \*\*Small dataset:\*\* 10–20 customers and 5 sanctions entities (for quick testing)  

\- \*\*Large dataset:\*\* ~1000 customers + 50 sanctions entities  

\- Includes intentional matches for demo purposes  



---



**## Running the Demo**



1\. Load schema:



```sql

SOURCE schema/01\_tables.sql;



2\. Load sample data:



SOURCE sample\_data/02\_generate\_full\_sample.sql; -- full dataset (~1000)



3\. Run weighted scoring query to populate screening\_matches



4\. Review match\_explanations for field-level details




\# AML Sanctions Screening Demo (MySQL)



This repository demonstrates a \*\*weighted AML/compliance sanctions screening workflow\*\* built in MySQL.  

It is designed as a portfolio project for data and compliance roles, showing reproducible workflows, risk scoring, and audit-trail tracking.



---



\## 📂 Repository Structure



aml-sanctions-screening-engine



|--README.md

|--schema/ #Table Definitions

|--sample\_data

|--workflow

|--docs





---



\## 🛠 Setup Instructions



1\. \*\*Create tables\*\*  

&nbsp;  Run 01\_tables script in `schema/` to create tables:

&nbsp;  - `customers`

&nbsp;  - `sanctions\_entities`

&nbsp;  - `screening\_matches`

&nbsp;  - `screening\_runs`

&nbsp;  - `screening\_weights`



2\. \*\*Populate sample data\*\*  

&nbsp;  Run 01 \_sample-data script in `data/` to load customers and sanctions list.



3\. \*\*Run the weighted screening workflow\*\*  

&nbsp;  Run the workflow script in `workflow/weighted\_screening\_workflow.sql`:

&nbsp;  - Creates a new `screening\_run`

&nbsp;  - Populates a temporary field-level score table

&nbsp;  - Calculates weighted scores based on configurable weights

&nbsp;  - Inserts potential matches into `screening\_matches`

&nbsp;  - Marks the run as `COMPLETED`



---



\## ⚖ Weighted Scoring



\- \*\*Name\*\*: exact match = 100, SOUNDEX/fuzzy match = 80  

\- \*\*Date of Birth\*\*: exact match = 100  

\- \*\*Nationality\*\*: exact match = 100  

\- \*\*PEP\*\*: customer subtype = 100  

\- \*\*Entity Source\*\*: weighted based on `screening\_weights`  



\*\*Total Score\*\* = sum of all weighted field scores.



---



\## 📝 Example Workflow



1\. Run `INSERT` to create a screening run (auto-generates `run\_id`)  

2\. Populate `temp\_field\_scores` using all customers × sanctions entities  

3\. Insert weighted matches into `screening\_matches`  

4\. Mark the run as `COMPLETED`  



This produces a reproducible batch screening run with full audit trail.



---



\## ✅ Notes



\- `run\_id` ties all matches to a specific screening batch  

\- `screening\_weights` allows flexible adjustments of scoring  

\- Temporary tables (`temp\_field\_scores`) enable explainable scoring  

\- Designed for easy extension: thresholds, match explanations, performance optimization










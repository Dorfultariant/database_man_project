-- Start transaction
BEGIN;
-- Test for employee contract update trigger
UPDATE Employee SET contract_type = 'Temporary' WHERE e_id = 4000;
UPDATE Employee SET contract_type = 'Määräaikainen' WHERE e_id = 4002;
UPDATE Employee SET contract_type = 'Temporary' WHERE e_id = 4001;

SELECT e_id, contract_type, contract_start, contract_end FROM Employee WHERE e_id = 4000;
SELECT e_id, contract_type, contract_start, contract_end FROM Employee WHERE e_id = 4001;
SELECT e_id, contract_type, contract_start, contract_end FROM Employee WHERE e_id = 4002;

ROLLBACK;
-- End transaction


-- New Skill addition trigger test
SELECT skill FROM Skills LIMIT 10;
INSERT INTO Skills (skill, salary_benefit) VALUES ('C', False);
INSERT INTO Skills (skill, salary_benefit) VALUES ('C', False);

BEGIN;
SELECT * FROM customer WHERE c_id = 1 or c_id = 8;
-- New project after insert rolesetup test
INSERT INTO project (project_name, budget, commission_percentage, p_start_date, c_id)
    VALUES('Project For The Company', 1000000, 20, NOW()::date, 1);

INSERT INTO project (project_name, budget, commission_percentage, p_start_date, c_id)
    VALUES('Kukkahattu projekti', 100000, 50, NOW()::date, 8);

ROLLBACK;


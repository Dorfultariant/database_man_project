-- Test for employee contract update trigger
UPDATE Employee SET contract_type = 'Temporary' WHERE e_id = 4000;
UPDATE Employee SET contract_type = 'Määräaikainen' WHERE e_id = 4002;
UPDATE Employee SET contract_type = 'Temporary' WHERE e_id = 4001;

SELECT e_id, contract_type, contract_start, contract_end FROM Employee WHERE e_id = 4000;
SELECT e_id, contract_type, contract_start, contract_end FROM Employee WHERE e_id = 4001;
SELECT e_id, contract_type, contract_start, contract_end FROM Employee WHERE e_id = 4002;

-- New Skill addition trigger test
SELECT skill FROM Skills LIMIT 10;
INSERT INTO Skills (skill, salary_benefit) VALUES ('C', False);
INSERT INTO Skills (skill, salary_benefit) VALUES ('C', False);

-- New project after insert rolesetup test
INSERT INTO project (project_name, budget, commission_percentage, p_start_date, c_id)
    VALUES('Project For The Company', 1000000, 20, NOW()::date, 1);

INSERT INTO project (project_name, budget, commission_percentage, p_start_date, c_id)
    VALUES('Kukkahattu projekti', 100000, 50, NOW()::date, 8);

SELECT * FROM view_customers WHERE c_id = 1 OR c_id = 8;
SELECT * FROM view_employees WHERE e_id = 1984 OR e_id = 605;


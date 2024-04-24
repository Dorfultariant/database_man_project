
-- Test updating salary lower than or equal to 1000
BEGIN;
UPDATE Employee SET salary = 999 WHERE e_id = 1;
COMMIT;

-- Test trying to set project start_date to NULL
BEGIN;
UPDATE project SET p_start_date = NULL WHERE p_id = 1;
COMMIT;

-- Test trying to set customer email to NULL
BEGIN;
UPDATE customer SET email = NULL WHERE c_id = 1;
COMMIT;

-- Test trying to set zip_code for geo_location
BEGIN;
UPDATE geo_location SET zip_code = '24244' WHERE l_id = 1;
COMMIT;

SELECT zip_code FROM geo_location WHERE l_id = 1;



-- View some skills to determine if the skillbased salary addition is correct
SELECT skill, salary_benefit_value FROM skills ORDER BY skill ASC LIMIT 20;

-- Before
SELECT * FROM skillsOfEmployees LIMIT 10;

-- Procedure call to be tested
CALL skillBasedSalaryCalculation();

-- After to see the difference
SELECT * FROM skillsOfEmployees LIMIT 10;

-- Start transaction
BEGIN;
-- BEFORE
SELECT e.e_id, e.emp_name, e.contract_start, ug.group_title
    FROM Employee e
    JOIN employee_user_group eug ON eug.e_id = e.e_id
    JOIN user_group ug ON ug.u_id = eug.u_id
    ORDER BY e_id DESC
    LIMIT 10;

-- Initial testing of inserting to different groups via different job titles
INSERT INTO employee (e_id, emp_name, email, contract_type, contract_start, salary, j_id) VALUES (10000, 'Teppo The Database Admin',    'wizard@wizards.org', 'Full-Time', '2024-04-20', 5000, 5);
INSERT INTO employee (e_id, emp_name, email, contract_type, contract_start, salary, j_id) VALUES (10001, 'Data Admin Taalasmaa',        'wizard@wizards.org', 'Full-Time', '2024-04-20', 5000, 6);
INSERT INTO employee (e_id, emp_name, email, contract_type, contract_start, salary, j_id) VALUES (10002, 'System Admin Aino',           'wizard@wizards.org', 'Full-Time', '2024-04-20', 5000, 7);
INSERT INTO employee (e_id, emp_name, email, contract_type, contract_start, salary, j_id) VALUES (10003, 'Heikki HR Hemmo',             'wizard@wizards.org', 'Full-Time', '2024-04-20', 5000, 12);
INSERT INTO employee (e_id, emp_name, email, contract_type, contract_start, salary, j_id) VALUES (10004, 'Employee Elmeri',             'wizard@wizards.org', 'Full-Time', '2024-04-20', 5000, 2);

-- AFTER
SELECT e.e_id, e.emp_name, e.contract_start, ug.group_title FROM Employee e JOIN employee_user_group eug ON eug.e_id = e.e_id JOIN user_group ug ON ug.u_id = eug.u_id ORDER BY e_id DESC LIMIT 10;

ROLLBACK;
-- End transaction

-- TEST: for get_running_projects(date DATE) function
SELECT * from get_running_projects('1900-10-10') LIMIT 5;
SELECT * from get_running_projects('2000-10-10') LIMIT 5;
SELECT * from get_running_projects('2010-10-12') LIMIT 5;
SELECT * from get_running_projects('2000-11-30') LIMIT 5;
SELECT * from get_running_projects('2030-11-30') LIMIT 5;



/*
Test increasing salary to baseline
*/
SELECT salary FROM Employee LIMIT 10;
CALL salaryChecking();
SELECT salary FROM Employee LIMIT 10;

/*
Test increasing the temperary contract end date by 3 months
*/
SELECT e_id, contract_type, contract_end FROM Employee WHERE e_id = 4944;
CALL tempContractAddition();
SELECT e_id, contract_type, contract_end FROM Employee WHERE e_id = 4944;

/*
Testing the salary raise by percentage PROCEDURE
*/
-- WITH LIMIT
SELECT e_id, salary FROM Employee ORDER BY e_id ASC LIMIT 10;
CALL increaseSalariesByPrecentage(raisePercentage => 10, lim => 4000);
SELECT e_id, salary FROM Employee ORDER BY e_id ASC LIMIT 10;

-- WITH NULL LIMIT
SELECT e_id, salary FROM Employee ORDER BY e_id ASC LIMIT 10;
CALL increaseSalariesByPrecentage(raisePercentage => 50, lim => NULL);
SELECT e_id, salary FROM Employee ORDER BY e_id ASC LIMIT 10;

-- WITH 0 LIMIT
SELECT e_id, salary FROM Employee ORDER BY e_id ASC LIMIT 10;
CALL increaseSalariesByPrecentage(raisePercentage => 10, lim => 0);
SELECT e_id, salary FROM Employee ORDER BY e_id ASC LIMIT 10;



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
INSERT INTO project (p_id, project_name, budget, commission_percentage, p_start_date, c_id)
    VALUES(202400,'Project For The Company', 1000000, 20, NOW()::date, 1);

INSERT INTO project (p_id, project_name, budget, commission_percentage, p_start_date, c_id)
    VALUES(202401,'Kukkahattu projekti', 100000, 50, NOW()::date, 8);

ROLLBACK;


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

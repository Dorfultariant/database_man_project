-- -- View some skills to determine if the skillbased salary addition is correct
-- SELECT skill, salary_benefit_value FROM skills ORDER BY skill ASC LIMIT 20;
--
-- -- Before
-- SELECT * FROM skillsOfEmployees LIMIT 20;
--
-- -- Procedure call to be tested
-- CALL skillBasedSalaryCalculation();
--
-- -- After to see the difference
-- SELECT * FROM skillsOfEmployees LIMIT 20;


SELECT e_id, emp_name, contract_start FROM Employee ORDER BY e_id DESC LIMIT 10;

INSERT INTO Employee (emp_name, email, contract_type, contract_start, salary, j_id)
    VALUES ('HR Leikola', 'assets@sees.org', 'Full-Time', '14.04.2024', 4500,12);

INSERT INTO Employee (emp_name, email, contract_type, contract_start, salary, j_id)
    VALUES ('Seppo The System Admin', 'sset@sss.org', 'Full-Time', '14.04.2024',5000,7);

INSERT INTO Employee (emp_name, email, contract_type, contract_start, salary, j_id)
    VALUES ('Teppo The Database Admin', 'sset@sek.org', 'Full-Time', '14.04.2024',5200,5);

INSERT INTO Employee (emp_name, email, contract_type, contract_start, salary, j_id)
    VALUES ('Data Admin Taalasmaa', 'adminmaster@wizards.org', 'Eternal', '14.04.1954',100000,6);

INSERT INTO Employee (emp_name, email, contract_type, contract_start, salary, j_id)
    VALUES ('Employee Elomaa', 'sset@sss.org', 'Full-Time', '14.04.2024',3400,3);

SELECT e_id, emp_name, contract_start FROM Employee ORDER BY e_id DESC LIMIT 10;

--ROLLBACK;

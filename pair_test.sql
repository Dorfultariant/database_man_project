-- View some skills to determine if the skillbased salary addition is correct
SELECT skill, salary_benefit_value FROM skills ORDER BY skill ASC LIMIT 20;

-- Before
SELECT * FROM skillsOfEmployees LIMIT 20;

-- Procedure call to be tested
CALL skillBasedSalaryCalculation();

-- After to see the difference
SELECT * FROM skillsOfEmployees LIMIT 20;


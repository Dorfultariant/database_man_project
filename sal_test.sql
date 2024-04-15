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


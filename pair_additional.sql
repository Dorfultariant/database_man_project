-- Additional view to showcase the skills of each employee and different dates they worked for the company
CREATE OR REPLACE VIEW skillsOfEmployees AS
SELECT DISTINCT e.emp_name "Name", e.salary "Salary", STRING_AGG(DISTINCT s.skill, ' ') "Skills", e.contract_start "Started", e.contract_end "Ended"
    FROM employee e
    JOIN employee_skills es ON e.e_id = es.e_id
    JOIN skills s ON s.s_id = es.s_id
    GROUP BY e.emp_name, e.salary, e.contract_start, e.contract_end
    ORDER BY e.emp_name, e.contract_start;


-- Procedure to calculate the skill based salary for all Employees
CREATE OR REPLACE PROCEDURE skillBasedSalaryCalculation() LANGUAGE plpgsql AS $$
DECLARE
    total_benefit numeric;
    EMP record;
BEGIN
    FOR EMP IN SELECT * FROM Employee LOOP
        SELECT SUM(salary_benefit_value) INTO total_benefit FROM skills
            WHERE salary_benefit = True AND s_id IN (
                SELECT s_id FROM employee_skills WHERE e_id = EMP.e_id);
        IF total_benefit > 0
            THEN
                UPDATE Employee SET salary = salary::numeric + total_benefit::numeric WHERE EMP.e_id = e_id;
        END IF;
    END LOOP;
    COMMIT;
END;
$$;


/*
 trigger after insert on employee.

    If employee's job title is HR secretary, add them to the HR user group.
    If employee's job title is any of the admin related, add them to the Administration group.
    Everyone else is added to the employee group
*/


CREATE OR REPLACE PROCEDURE employeeGrouping() LANGUAGE plpgsql AS $$

BEGIN
    UPDATE (SELECT )

END;
$$;


CREATE OR REPLACE TRIGGER newEmployeeGrouping
    AFTER INSERT ON Employee
    FOR EACH ROW EXECUTE FUNCTION employeeGrouping();




CREATE OR REPLACE FUNCTION get_running_projects(dateIN date)
RETURNS TABLE (
	p_id INTEGER,
	project_name VARCHAR,
	budget NUMERIC,
	comission_percentage NUMERIC,
	p_start_date DATE,
	p_end_date DATE,
	c_id INTEGER)
LANGUAGE plpgsql as
$$
DECLARE
    
BEGIN
    RETURN query SELECT * FROM project p
		where 
			dateIN <= p.p_end_date
			;
END;
$$;

-- to test
-- SELECT * from get_running_projects('2030-10-10')

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




DROP FUNCTION get_running_projects(date);
CREATE OR REPLACE FUNCTION get_running_projects(dateIN date)
RETURNS TABLE (
	p_id INTEGER,
	project_name VARCHAR,
	budget NUMERIC,
	commission_percentage NUMERIC,
	p_start_date DATE,
	p_end_date DATE,
	
	c_id INTEGER,
	c_name VARCHAR,
	c_type VARCHAR,
	phone VARCHAR,
	email VARCHAR,
	l_id INTEGER
	)
LANGUAGE plpgsql as
$$
DECLARE
    
BEGIN
    RETURN query SELECT 	
	p.p_id INTEGER,
	p.project_name VARCHAR,
	p.budget NUMERIC,
	p.commission_percentage NUMERIC,
	p.p_start_date DATE,
	p.p_end_date DATE,
	
	c.c_id INTEGER,
	c.c_name VARCHAR,
	c.c_type VARCHAR,
	c.phone VARCHAR,
	c.email VARCHAR,
	c.l_id INTEGER
	FROM project p
		JOIN customer c ON c.c_id = p.c_id
		where 
			dateIN BETWEEN p.p_start_date AND p.p_end_date
-- 			dateIN <= p.p_end_date
			;
END;
$$;

SELECT * from get_running_projects('2000-10-10')


-- Function to calculate the skill based salary bonus total
CREATE OR REPLACE FUNCTION skillSalaryBonus(emp_id int) RETURNS INT LANGUAGE plpgsql AS $$
DECLARE
    total_benefit numeric;
BEGIN
    SELECT SUM(salary_benefit_value) INTO total_benefit FROM skills
            WHERE salary_benefit = True AND s_id IN (
                SELECT s_id FROM employee_skills WHERE e_id = emp_id);
    RETURN total_benefit;
END;
$$;


-- Additional view to showcase the skills of each employee and different dates they worked for the company

-- NOTE: THIS IS DUPLICATE !! THIS CAN ALSO BE FOUND IN createViews.sql file

DROP VIEW skillsOfEmployees;
CREATE OR REPLACE VIEW skillsOfEmployees AS
SELECT DISTINCT
    e.emp_name "Name",
    e.salary "Salary",
    (SELECT SUM(salary_benefit_value) FROM skills
            WHERE salary_benefit = True AND s_id IN (
                SELECT s_id FROM employee_skills WHERE e_id = e.e_id)) "Skill Bonus",
    STRING_AGG(DISTINCT s.skill, ' ') "Skills",
    e.contract_start "Started",
    e.contract_end "Ended"

FROM employee e
    JOIN employee_skills es ON e.e_id = es.e_id
    JOIN skills s ON s.s_id = es.s_id
    GROUP BY e.e_id, e.emp_name, e.salary, e.contract_start, e.contract_end
    ORDER BY e.emp_name, e.contract_start;



--------------- FOR ADDITIONAL TASK ------------
-- Shows headquarters different departments and their employee groups
-- providing information about type of users in a department.

-- NOTE: THIS IS DUPLICATE !! WHICH CAN ALSO BE FOUND IN createViews.sql file

DROP VIEW groupingAndDepartments;
CREATE OR REPLACE VIEW groupingAndDepartments AS
	SELECT
		hq.hq_name "Headquarter",
		d.dep_name "Department",
		ug.group_title "Group"
FROM Employee e
	JOIN department d 			ON e.d_id = d.d_id
	JOIN headquarters hq 		ON hq.h_id = d.hid
	JOIN employee_user_group eug ON eug.e_id = e.e_id
	JOIN user_group ug 			ON ug.u_id = eug.u_id
GROUP BY hq.hq_name, d.dep_name, ug.group_title
ORDER BY hq.hq_name, d.dep_name, ug.group_title;


-- Function to calculate the skill based salary bonus total
CREATE OR REPLACE FUNCTION skillSalaryBonus(emp_id int) RETURNS INT LANGUAGE plpgsql AS $$
DECLARE
    total_benefit numeric;
BEGIN
    SELECT SUM(salary_benefit_value) INTO total_benefit FROM skills
            WHERE salary_benefit = True AND s_id IN (
                SELECT s_id FROM employee_skills WHERE e_id = emp_id);
    RETURN total_benefit;
END;
$$;


-- Procedure to calculate the skill based salary for all Employees
CREATE OR REPLACE PROCEDURE skillBasedSalaryCalculation() LANGUAGE plpgsql AS $$
DECLARE
    total_benefit numeric;
    EMP record;
BEGIN
    FOR EMP IN SELECT * FROM Employee LOOP
        total_benefit:=skillSalaryBonus(EMP.e_id);
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
CREATE OR REPLACE FUNCTION employeeGrouping() RETURNS TRIGGER LANGUAGE plpgsql AS $$
DECLARE
    id int;
    comp_title TEXT;
BEGIN
    /*
        We can assume that if some specific user_group has been defined for the user, we do not want to update it to
        common place based on the title as so, we handle it as an exception.
    */
    IF EXISTS (SELECT * FROM employee_user_group WHERE e_id = NEW.e_id)
        THEN
            RETURN NEW;
    END IF;

    SELECT title INTO comp_title FROM job_title WHERE j_id = NEW.j_id;

    IF comp_title ILIKE '%admin%'
        THEN
            -- GET ID OF user_group
            SELECT u_id INTO id FROM user_group WHERE group_title ILIKE 'Administration group';
            -- INSERT NEW ROW TO CONNECT Employee and user_group
            INSERT INTO employee_user_group (e_id, u_id, eug_join_date) VALUES (
                NEW.e_id, id,  NOW()::date);

    ELSIF comp_title ILIKE '%HR secretary%'
        THEN
            -- GET ID OF user_group
            SELECT u_id INTO id FROM user_group WHERE group_title ILIKE 'HR group';
            -- INSERT NEW ROW TO CONNECT Employee and user_group
            INSERT INTO employee_user_group (e_id, u_id, eug_join_date)
                VALUES (NEW.e_id, id,  NOW()::date);
    ELSE
        -- GET ID OF user_group
        SELECT u_id INTO id FROM user_group WHERE group_title ILIKE 'Employee group';
        -- INSERT NEW ROW TO CONNECT Employee and user_group
        INSERT INTO employee_user_group (e_id, u_id, eug_join_date)
            VALUES (NEW.e_id, id,  NOW()::date);
    END IF;
    RETURN NEW;
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
			dateIN BETWEEN p.p_start_date AND p.p_end_date;
END;
$$;


-- Additional task, view_only role
CREATE ROLE view_only WITH LOGIN;
--GRANT SELECT ON view_customers, view_employees, skillsOfEmployees TO view_only;
-- Or the dynamic way:
-- https://dba.stackexchange.com/questions/23836/how-to-list-all-views-in-sql-in-postgresql
-- https://stackoverflow.com/questions/41335423/grant-access-to-views-in-postgresql
-- https://www.postgresql.org/docs/current/sql-do.html
DO
$$
DECLARE
	v_name VARCHAR;
BEGIN
	FOR v_name IN (SELECT table_name FROM information_schema.views WHERE table_schema = 'public') LOOP
		EXECUTE format('GRANT SELECT ON %I TO view_only', v_name);
	END LOOP;
END;
$$;



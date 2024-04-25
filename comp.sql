BEGIN;

/*
    NOTE PARTITIONS
*/
--------- CUSTOMER PARTITION ---------------
CREATE TABLE customer_new (
	c_id SERIAL,
	c_name VARCHAR NOT NULL DEFAULT 'No Name',
	c_type VARCHAR,
	phone VARCHAR,
	email VARCHAR,
	l_id INTEGER,
	PRIMARY KEY (c_id),
	CONSTRAINT customer_l_id_fkey
	FOREIGN KEY (l_id) REFERENCES geo_location(l_id)
	) PARTITION BY RANGE(c_id);

-- create partitions
CREATE TABLE customer_1 PARTITION OF customer_new
	FOR VALUES FROM (MINVALUE) TO (250);
CREATE TABLE customer_2 PARTITION OF customer_new
	FOR VALUES FROM (251) TO (500);
CREATE TABLE customer_3 PARTITION OF customer_new
	FOR VALUES FROM (501) TO (750);

CREATE TABLE customer_default PARTITION OF customer_new DEFAULT;


-- add data from not partitioned to partitioned table
INSERT INTO customer_new
	SELECT * FROM customer;

-- add default constraints
ALTER TABLE project ADD CONSTRAINT project_c_id_fkey_new FOREIGN KEY (c_id) REFERENCES customer_new(c_id);

-- change names
ALTER TABLE customer RENAME TO customer_old;
ALTER TABLE customer_new RENAME TO customer;

--last remove old constraints and  delete old not partitioned table
ALTER TABLE project drop constraint project_c_id_fkey;
DROP TABLE customer_old;
--------- EOF CUSTOMER PARTITION ---------------
--------- PROJECT PARTITION ---------------
CREATE TABLE project_new (
	p_id INTEGER NOT NULL,
	project_name VARCHAR,
	budget NUMERIC,
	commission_percentage NUMERIC,
	p_start_date DATE,
	p_end_date DATE,
    c_id INTEGER,
	PRIMARY KEY (p_id),
	CONSTRAINT project_c_id_fkey
	FOREIGN KEY (c_id) REFERENCES customer(c_id)
	)PARTITION BY RANGE(p_id);

-- create partitions
CREATE TABLE project_1 PARTITION OF project_new
	FOR VALUES FROM (MINVALUE) TO (250);
CREATE TABLE project_2 PARTITION OF project_new
	FOR VALUES FROM (251) TO (500);
CREATE TABLE project_3 PARTITION OF project_new
	FOR VALUES FROM (501) TO (750);

CREATE TABLE project_default PARTITION OF project_new DEFAULT;


-- add data from not partitioned to partitioned table
INSERT INTO project_new
	SELECT * FROM project;

-- add default constraints

ALTER TABLE project_role ADD CONSTRAINT project_role_p_id_fkey_new FOREIGN KEY (p_id) REFERENCES project_new(p_id);
-- change names
ALTER TABLE project RENAME TO project_old;
ALTER TABLE project_new RENAME TO project;

--last remove old constraints and  delete old not partitioned table
ALTER TABLE project_role drop constraint project_role_p_id_fkey;
DROP TABLE project_old;
-- rollback;
--------- EOF PROJECT PARTITION ---------------


/*
    NOTE PROCEDURES
*/

/*
Procedure that sets all employees salary to the base level based on their job title
*/
CREATE OR REPLACE PROCEDURE salaryChecking() LANGUAGE plpgsql AS $$
DECLARE
    EMP record;
    bs_sal numeric;
BEGIN
    FOR EMP IN SELECT * FROM Employee LOOP
        SELECT base_salary INTO bs_sal FROM job_title WHERE j_id = EMP.j_id;

        UPDATE Employee SET salary = bs_sal WHERE e_id = EMP.e_id;
    END LOOP;
END;
$$;


-- NOTE WE CALL SALARYCHECKING FOR EMPLOYEES
CALL salaryChecking();


/*
    Procedure that adds 3 months to all temporary contracts
*/
CREATE OR REPLACE PROCEDURE tempContractAddition() LANGUAGE plpgsql AS $$
BEGIN
    UPDATE Employee SET contract_end  = contract_end + (interval '3 months')
            WHERE contract_type ILIKE '%temporary%' OR contract_type ILIKE '%määräaikainen%';
END;
$$;


/*
    Procedure that increases salaries by a percentage based on the given percentage. You can also specify the highest salary to be increased (give limit X and salaries that are below X are increased).
    EDIT 20.04.2023: The user can specify the salary limit when calling the procedure. If user doesn't specify one (or gives 0 or null), then the limit is not considered. The percentage can be given in decimals or numbers or what ever you specify, as long as the procedure works.
*/
CREATE OR REPLACE PROCEDURE increaseSalariesByPrecentage(
    raisePercentage numeric, lim numeric ) LANGUAGE plpgsql AS $$
DECLARE
    raiseMult numeric;
BEGIN
    raiseMult:= ((100 + raisePercentage)/100);
    -- If user does not specify upper limit, give boost to salary
    IF lim IS NULL OR lim = 0
        THEN
            UPDATE Employee SET salary = salary::numeric * raiseMult;
    ELSE
        UPDATE Employee SET salary = salary::numeric * raiseMult
            WHERE (salary::numeric) < lim;
    END IF;
END;
$$;

/*
    NOTE CONSTRAINTS
*/
ALTER TABLE geo_location ADD COLUMN zip_code CHAR(10);

ALTER TABLE customer ALTER COLUMN email SET NOT NULL;
ALTER TABLE project ALTER COLUMN p_start_date SET NOT NULL;

ALTER TABLE employee ADD CHECK (salary > 1000);



/*
    NOTE ALL VIEWS, INCLUDING ADDITIONAL

*/

-- can find employees by country
--DROP VIEW view_employees;
CREATE VIEW view_employees AS
	select
		employee.e_id,
		employee.emp_name,
		job_title.title,
		department.dep_name,
		geo.country,
		employee.supervisor,
		employee.salary
	from employee
		JOIN job_title ON job_title.j_id = employee.j_id
		JOIN department ON department.d_id = employee.d_id
		JOIN headquarters head ON head.h_id = department.hid
		JOIN geo_location geo ON geo.l_id = head.l_id
		order by geo.country,job_title.title;


-- can find customers by country
--DROP VIEW view_customers;
CREATE VIEW view_customers AS
	SELECT customer.c_id,
		customer.c_name,
		geo.country,
		STRING_AGG(pro.p_id::text, ',') p_id
	FROM customer
		JOIN geo_location geo ON geo.l_id = customer.l_id
		LEFT JOIN project pro ON pro.c_id = customer.l_id
		group by customer.c_id,geo.country
		order by geo.country, customer.c_id;



/*
	This view shows information for each project, budget, commission,
	startdate, customer and their country. This way a lot of important and interesting information is shown for each project.

	This also allows to search from the view based on the project name, customer or other distinct aspect.
*/

--DROP VIEW projectBasicInformation;
CREATE OR REPLACE VIEW projectBasicInformation AS
	SELECT
		p.project_name "Project Name",
		TO_CHAR(p.budget, '999G999G999') "Budget",
		p.commission_percentage "Commission (%)",
		p.p_start_date "Started",
		c.c_name "Client",
		g.country "Client Country"
	FROM project p
		JOIN customer c ON c.c_id = p.c_id
		JOIN geo_location g ON g.l_id = c.l_id
	GROUP BY p.project_name,
		p.budget,
		p.commission_percentage,
		p.p_start_date,
		c.c_name,
		g.country
	ORDER BY p.project_name, p.p_start_date;


/*
	This view is addition to previous project related views, but this showcases the
	employees and their positions for each project and projects stakeholder.
*/

--DROP VIEW projectEmployeeInformation;
CREATE OR REPLACE VIEW projectEmployeeInformation AS
	SELECT
		p.project_name "Project",
		c.c_name "Customer",
		e.emp_name "Employee",
		jt.title "Employee Position"
	FROM project p
		JOIN project_role pl ON p.p_id = pl.p_id
		JOIN Employee e ON e.e_id = pl.e_id
		JOIN customer c ON c.c_id = p.c_id
		JOIN job_title jt ON jt.j_id = e.j_id
	GROUP BY p.project_name,
		c.c_name,
		e.emp_name,
		jt.title
	ORDER BY "Project", "Customer";


------------ for additional task ------------------
-- Additional view to showcase the skills of each employee and different dates they worked for the company
--DROP VIEW skillsOfEmployees;
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
--DROP VIEW groupingAndDepartments;
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



/*
    NOTE TRIGGERS
*/

/*
One for before inserting a new skill, make sure that the same skill does not already exist
this is case insensitive version:
*/
CREATE OR REPLACE FUNCTION skillCheck() RETURNS TRIGGER LANGUAGE plpgsql AS $$
DECLARE
    ace VARCHAR;
BEGIN
    FOR ace IN SELECT skill FROM Skills LOOP
        IF NEW.skill ILIKE ace
            THEN
                RAISE EXCEPTION 'Skill already exists.';
        END IF;
    END LOOP;
END;
$$;

CREATE OR REPLACE TRIGGER newSkillAddition
    BEFORE INSERT ON Skills
    FOR EACH ROW EXECUTE FUNCTION skillCheck();


/*
One for after inserting a new project,  check the customer country and select three employees from that country to start working with the project (i.e. create new project roles)

NOTE: Well, this trigger function does just that, select employee based on their country
	and nothing else, it does not matter whether the employee is qualified or they are not
	participating in other projects.

	ALSO THIS FUNCTION REQUIRES VIEW view_employees TO WORK, Also why that view is located also in here...
*/
CREATE OR REPLACE FUNCTION setProjectRoles() RETURNS TRIGGER LANGUAGE plpgsql AS $$
DECLARE
    cust_cnt VARCHAR;
    doers INT[];
BEGIN
    SELECT country INTO cust_cnt FROM geo_location WHERE l_id = (
		SELECT l_id FROM customer WHERE NEW.c_id = c_id);

    doers:= ARRAY(SELECT e_id FROM view_employees WHERE "country" = cust_cnt
        ORDER BY RANDOM() LIMIT 3);

    FOR idx IN 1 .. array_length(doers, 1) LOOP
		INSERT INTO project_role (e_id, p_id, prole_start_date)
			VALUES ( doers[idx], NEW.p_id, NOW()::date);
    END LOOP;

    RETURN NEW;
END;
$$;

CREATE OR REPLACE TRIGGER projectRoleSetup
    AFTER INSERT ON project
    FOR EACH ROW EXECUTE FUNCTION setProjectRoles();


/*
One for before updating the employee contract type, make sure that the contract start date is also set to the current date and end date is either 2 years after the start date if contract is of Temporary type, NULL otherwise. (Temporary contract in Finnish is "määräaikainen". It's a contract that has an end date specified).
*/
CREATE OR REPLACE FUNCTION contractCheck() RETURNS TRIGGER LANGUAGE plpgsql AS $$
DECLARE
    d DATE;
BEGIN
    d:= NOW();

    NEW.contract_start:=d::date;

    IF NEW.contract_type ILIKE '%temporary%' OR NEW.contract_type ILIKE '%määräaikainen%'
        THEN
            NEW.contract_end:=(d + interval '2 years');
    ELSE
        NEW.contract_end := NULL;
    END IF;

    RETURN NEW;
END;
$$;

CREATE OR REPLACE TRIGGER contractUpdateCheck
    BEFORE UPDATE OF contract_type ON Employee
    FOR EACH ROW EXECUTE FUNCTION contractCheck();



/*
    NOTE ADDITIONAL PART
*/


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



--DROP FUNCTION get_running_projects(date);
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

COMMIT;

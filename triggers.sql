/*
One for before inserting a new skill, make sure that the same skill does not already exist
this is case insensitive version:
*/
CREATE OR REPLACE FUNCTION skillCheck() RETURNS TRIGGER LANGUAGE plpgsql AS $$
DECLARE
    skill VARCHAR;
BEGIN
    FOR skill IN SELECT skill FROM Skills LOOP
        IF NEW.skill ILIKE skill
            THEN
                RAISE EXCEPTION 'Skill already exists.';
        END IF;
    END LOOP;
END;
$$;

CREATE OR REPLACE TRIGGER newSkillAddition
    BEFORE INSERT ON Skills
    FOR EACH ROW EXECUTE FUNCTION skillCheck();


-- ### DUPLICATE VIEW ###, exists to help in trigger function "setProjectRoles()"
-- can find employees by country
DROP VIEW view_employees;
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

    doers:= ARRAY(SELECT e_id FROM view_employees WHERE "country" = cust_cnt ORDER BY RANDOM() LIMIT 3);

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
    -- There is NOT NULL constraint on contract_type, so this becomes undefined behaviour
    IF NEW.contract_type IS NULL
        THEN
            RETURN NEW;
    END IF;

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



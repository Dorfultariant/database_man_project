-- Role with access to only generatated views
-- CREATE ROLE views_only WITH LOGIN;
-- GRANT SELECT ON ALL VIEWS IN SCHEMA public TO views_only;


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
CREATE OR REPLACE VIEW skillsOfEmployees AS
SELECT DISTINCT
    e.emp_name "Name",
    e.salary "Salary",
    skillSalaryBonus(e.e_id) "Skill Bonus",
    STRING_AGG(DISTINCT s.skill, ' ') "Skills",
    e.contract_start "Started",
    e.contract_end "Ended"

FROM employee e
    JOIN employee_skills es ON e.e_id = es.e_id
    JOIN skills s ON s.s_id = es.s_id
    GROUP BY e.e_id, e.emp_name, e.salary, e.contract_start, e.contract_end
    ORDER BY e.emp_name, e.contract_start;


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
    Everyone else is added to the employee group*/

CREATE OR REPLACE FUNCTION employeeGrouping() RETURNS TRIGGER LANGUAGE plpgsql AS $$
DECLARE
    id int;
BEGIN
    /*
        We can assume that if some specific user_group has been defined for the user, we do not want to update it to
        common place based on the title as so, we handle it as an exception.
    */

    IF EXISTS (SELECT * FROM employee_user_group WHERE e_id = NEW.e_id)
        THEN
            RETURN NEW;
    END IF;

    IF (SELECT title FROM job_title WHERE j_id = NEW.j_id) ILIKE '%admin'
        THEN
            -- GET ID OF user_group
            SELECT u_id INTO id FROM user_group WHERE group_title ILIKE 'Administration group';
            -- INSERT NEW ROW TO CONNECT Employee and user_group
            INSERT INTO employee_user_group (e_id, u_id, eug_join_date) VALUES (NEW.e_id, id,  NOW()::timestamp);

    ELSIF (SELECT title FROM job_title WHERE j_id = NEW.j_id) ILIKE 'HR%'
        THEN
            -- GET ID OF user_group
            SELECT u_id INTO id FROM user_group WHERE group_title ILIKE 'HR group';
            -- INSERT NEW ROW TO CONNECT Employee and user_group
            INSERT INTO employee_user_group (e_id, u_id, eug_join_date) VALUES (NEW.e_id, id,  NOW()::timestamp);
    ELSE
        -- GET ID OF user_group
        SELECT u_id INTO id FROM user_group WHERE group_title ILIKE 'Employee group';
        -- INSERT NEW ROW TO CONNECT Employee and user_group
        INSERT INTO employee_user_group (e_id, u_id, eug_join_date) VALUES (NEW.e_id, id,  NOW()::timestamp);
    END IF;
    RETURN NEW;
END;
$$;


CREATE OR REPLACE TRIGGER newEmployeeGrouping
    AFTER INSERT ON Employee
    FOR EACH ROW EXECUTE FUNCTION employeeGrouping();


/*

 u_id |       group_title       |     group_rights
------+-------------------------+-----------------------
    1 | Database group          | Data addition
    2 | Network group           | Network configuration
    3 | Administration group    | System administration
    5 | Database admin       |        5000
    6 | Data admin           |        4500
    7 | System admin         |        5000
    4 | Officer group           | Super access
    5 | Supervisor group        | Supervisor
    6 | HR group                | Human resources
   12 | HR secretary         |        3500
    7 | Customer service group  | Customer information
    8 | Restricted access group | Limited
    9 | Employee group          | Default
    1 | Web developer        |        3500
    2 | Business analyst     |        3500
    3 | UI designer          |        3500
    4 | Data analyst         |        4000
    8 | System architect     |        4500
    9 | Back-end developer   |        4000
   10 | Front-end developer  |        4000
   11 | Full-stack developer |        4500
   13 | Marketing personnel  |        3500
   14 | Accountant           |        3500
   15 | Sales agent          |        3500
(9 rows)*/

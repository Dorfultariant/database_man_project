BEGIN;
-- Rename current table to old_employee
ALTER TABLE employee RENAME TO old_employee;

-- Create a new table with partition
CREATE TABLE employee (
    e_id INT NOT NULL,
    emp_name VARCHAR(100),
    email VARCHAR(100),
    contract_type VARCHAR(100) NOT NULL,
    contract_start DATE NOT NULL,
    contract_end DATE,
    salary INT,
    supervisor INT,
    d_id INT,
    j_id INT,
    PRIMARY KEY (e_id, salary),
    FOREIGN KEY (d_id) REFERENCES department(d_id),
    FOREIGN KEY (j_id) REFERENCES job_title(j_id)
) PARTITION BY RANGE (salary);


CREATE TABLE employee_salary_low PARTITION OF employee FOR VALUES FROM (0) TO (4000);
CREATE TABLE employee_salary_medium PARTITION OF employee FOR VALUES FROM (4001) TO (6000);
CREATE TABLE employee_salary_high PARTITION OF employee FOR VALUES FROM (6001) TO (10000);
CREATE TABLE employee_default PARTITION OF employee DEFAULT;


INSERT INTO employee_salary_low SELECT * FROM old_employee
    WHERE salary < 4000;

INSERT INTO employee_salary_medium SELECT * FROM old_employee
    WHERE salary BETWEEN 4001 AND 6000;

INSERT INTO employee_salary_high SELECT * FROM old_employee
    WHERE salary BETWEEN 6001 AND 10000;

INSERT INTO employee_default SELECT * FROM old_employee WHERE salary > 10000;


-- Drop the old constraint
ALTER TABLE employee_skills DROP CONSTRAINT employee_skills_e_id_fkey;

-- Add a new constraint referencing the new employee table
ALTER TABLE employee_skills ADD CONSTRAINT employee_skills_e_id_fkey FOREIGN KEY (e_id) REFERENCES employee (e_id);

-- Drop the old constraint
ALTER TABLE user_group DROP CONSTRAINT employee_user_group_e_id_fkey;

-- Add a new constraint referencing the new employee table
ALTER TABLE user_group ADD CONSTRAINT employee_user_group_e_id_fkey FOREIGN KEY (e_id) REFERENCES employee (e_id);

-- Drop the old constraint
ALTER TABLE project_role DROP CONSTRAINT project_role_e_id_fkey;

-- Add a new constraint referencing the new employee table
ALTER TABLE project_role ADD CONSTRAINT project_role_e_id_fkey FOREIGN KEY (e_id) REFERENCES employee (e_id);


DROP TABLE old_employee;

COMMIT;

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
    PRIMARY KEY (e_id),
    FOREIGN KEY (d_id) REFERENCES department(d_id),
    FOREIGN KEY (j_id) REFERENCES job_title(j_id),
    FOREIGN KEY (supervisor) REFERENCES employee(e_id)
) PARTITION BY RANGE (salary);


ALTER TABLE employee ATTACH PARTITION old_employee;

CREATE TABLE employee_salary_low PARTITION OF employee FOR VALUES FROM (0) TO (4000);

CREATE TABLE employee_salary_medium PARTITION OF employee FOR VALUES FROM (4001) TO (6000);

CREATE TABLE employee_salary_high PARTITION OF employee FOR VALUES FROM (6001) TO (10000);

CREATE TABLE employee_default PARTITION OF employee DEFAULT;

INSERT INTO employee SELECT * FROM old_employee;

DROP TABLE old_employee;

COMMIT;

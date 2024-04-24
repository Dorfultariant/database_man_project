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
	)PARTITION BY RANGE(c_id);

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
	p_id INTEGER SERIAL NOT NULL,
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

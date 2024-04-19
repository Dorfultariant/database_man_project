-- 5000 rows
-- SELECT COUNT(*) FROM employee;
-- 1000 rows
-- SELECT COUNT(*) FROM project;
-- SELECT COUNT(*) FROM customer;
-- SELECT * FROM project_role;
-- SELECT c.c_id, c.c_name, g.l_id, g.country
--     FROM customer c
--     JOIN geo_location g ON g.l_id = c.l_id
--     LIMIT 10;

SELECT * FROM employee WHERE contract_type = 'Temporary' LIMIT 50;
SELECT * FROM employee WHERE contract_type ILIKE '%temporary%' LIMIT 50;
SELECT * FROM employee WHERE contract_type ILIKE '%määräaikainen%' LIMIT 50;

/*
SELECT * FROM customer ORDER BY c_id LIMIT 10;
SELECT * FROM geo_location;

SELECT e.e_id
    FROM headquarters h
    JOIN department d ON d.hid = h.h_id
    JOIN employee e ON d.d_id = e.d_id
    WHERE h.l_id = 748;*/


/*
SELECT e_id FROM employee WHERE d_id = (
            SELECT d_id FROM department WHERE hid = (
                SELECT h_id FROM headquarters WHERE l_id = (
                    SELECT l_id FROM geo_location WHERE country = 'Finland' LIMIT 1)
                    )
                ) LIMIT 3;*/
/*
CREATE OR REPLACE VIEW employeeCountry AS
SELECT e.e_id "EID", e.emp_name "Name", g.country "Country"
    FROM employee e
    JOIN department d ON d.d_id = e.d_id
    JOIN headquarters h ON d.hid = h.h_id
    JOIN geo_location g ON g.l_id = h.l_id
    ORDER BY e.e_id;*/

-- SELECT * FROM view_employees WHERE country = 'Finland' LIMIT 10;
-- SELECT * FROM employeeCountry WHERE "Country" = 'United Kingdom';



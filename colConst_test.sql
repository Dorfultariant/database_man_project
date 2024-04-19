
-- Test updating salary lower than or equal to 1000
BEGIN;
UPDATE Employee SET salary = 999 WHERE e_id = 1;
COMMIT;

-- Test trying to set project start_date to NULL
BEGIN;
UPDATE project SET p_start_date = NULL WHERE p_id = 1;
COMMIT;

-- Test trying to set customer email to NULL
BEGIN;
UPDATE customer SET email = NULL WHERE c_id = 1;
COMMIT;

-- Test trying to set zip_code for geo_location
BEGIN;
UPDATE geo_location SET zip_code = '24244' WHERE l_id = 1;
COMMIT;

SELECT zip_code FROM geo_location WHERE l_id = 1;


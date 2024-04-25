/*
    CREATE BASIC ROLES

    NOTE view_only is at the bottom after VIEWs
*/


CREATE ROLE admin SUPERUSER LOGIN PASSWORD 'kolo';
CREATE ROLE employee WITH LOGIN;
CREATE ROLE trainee WITH LOGIN;
-- ALTER ROLE trainee WITH LOGIN;

GRANT SELECT ON ALL TABLES IN SCHEMA public TO employee;
GRANT SELECT ON project, customer, geo_location, project_role TO trainee;
GRANT SELECT (e_id, emp_name, email) ON employee TO trainee;


-- Additional task, view_only role
CREATE ROLE view_only WITH LOGIN;
--GRANT SELECT ON view_customers, view_employees, skillsOfEmployees TO view_only;
-- Or the dynamic way:
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

COMMIT;

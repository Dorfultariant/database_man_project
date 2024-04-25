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


GRANT SELECT ON ALL TABLES IN SCHEMA public TO employee;
GRANT SELECT ON project, customer, geo_location, project_role TO trainee;
GRANT SELECT (e_id, emp_name, email) ON employee TO trainee;

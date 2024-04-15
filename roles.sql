CREATE ROLE admin SUPERUSER LOGIN PASSWORD 'kolo';
CREATE ROLE employee WITH LOGIN;
CREATE ROLE trainee WITH LOGIN;
ALTER ROLE trainee WITH LOGIN;

GRANT SELECT ON ALL TABLES IN SCHEMA public TO employee;
GRANT SELECT ON project, customer, geo_location, project_role TO trainee;
GRANT SELECT (e_id, emp_name, email) ON employee TO trainee;


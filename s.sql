



-- SELECT * FROM project_role;

-- SELECT * FROM Employee WHERE supervisor is not null;

-- SELECT * FROM user_group;
/*
SELECT * FROM job_title;
SELECT * FROM employee ORDER BY e_id DESC LIMIT 20;*/
-- SELECT * FROM skills;

    /*
DELETE FROM employee_user_group WHERE e_id = 5045;
DELETE FROM employee_user_group WHERE e_id = 5044;
DELETE FROM employee_user_group WHERE e_id = 5043;
DELETE FROM employee_user_group WHERE e_id = 5042;
DELETE FROM employee_user_group WHERE e_id = 5041;


DELETE FROM Employee WHERE e_id = 5045;
DELETE FROM Employee WHERE e_id = 5044;
DELETE FROM Employee WHERE e_id = 5043;
DELETE FROM Employee WHERE e_id = 5042;
DELETE FROM Employee WHERE e_id = 5041;
*/

SELECT u_id, group_title FROM user_group WHERE u_id = (SELECT u_id FROM employee_user_group WHERE e_id = 5046);
SELECT u_id, group_title FROM user_group WHERE u_id = (SELECT u_id FROM employee_user_group WHERE e_id = 5047);
SELECT u_id, group_title FROM user_group WHERE u_id = (SELECT u_id FROM employee_user_group WHERE e_id = 5048);
SELECT u_id, group_title FROM user_group WHERE u_id = (SELECT u_id FROM employee_user_group WHERE e_id = 5049);
SELECT u_id, group_title FROM user_group WHERE u_id = (SELECT u_id FROM employee_user_group WHERE e_id = 5050);

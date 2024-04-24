-- can find employees by country
DROP VIEW view_employees;
CREATE VIEW view_employees AS
	select
		employee.e_id,
		employee.emp_name,
		job_title.title,
		department.dep_name,
		geo.country,
		employee.supervisor,
		employee.salary
	from employee
		JOIN job_title ON job_title.j_id = employee.j_id
		JOIN department ON department.d_id = employee.d_id
		JOIN headquarters head ON head.h_id = department.hid
		JOIN geo_location geo ON geo.l_id = head.l_id
		order by geo.country,job_title.title;


-- can find customers by country
DROP VIEW view_customers;
CREATE VIEW view_customers AS
	SELECT customer.c_id,
		customer.c_name,
		geo.country,
		STRING_AGG(pro.p_id::text, ',') p_id
	FROM customer
		JOIN geo_location geo ON geo.l_id = customer.l_id
		LEFT JOIN project pro ON pro.c_id = customer.l_id
		group by customer.c_id,geo.country
		order by geo.country, customer.c_id;



/*
	This view shows information for each project, budget, commission,
	startdate, customer and their country. This way a lot of important and interesting information is shown for each project.

	This also allows to search from the view based on the project name, customer or other distinct aspect.
*/

--DROP VIEW projectBasicInformation;
CREATE OR REPLACE VIEW projectBasicInformation AS
	SELECT
		p.project_name "Project Name",
		TO_CHAR(p.budget, '999G999G999') "Budget",
		p.commission_percentage "Commission (%)",
		p.p_start_date "Started",
		c.c_name "Client",
		g.country "Client Country"
	FROM project p
		JOIN customer c ON c.c_id = p.c_id
		JOIN geo_location g ON g.l_id = c.l_id
	GROUP BY p.project_name,
		p.budget,
		p.commission_percentage,
		p.p_start_date,
		c.c_name,
		g.country
	ORDER BY p.project_name, p.p_start_date;


/*
	This view is addition to previous project related views, but this showcases the
	employees and their positions for each project and projects stakeholder.
*/

--DROP VIEW projectEmployeeInformation;
CREATE OR REPLACE VIEW projectEmployeeInformation AS
	SELECT
		p.project_name "Project",
		c.c_name "Customer",
		e.emp_name "Employee",
		jt.title "Employee Position"
	FROM project p
		JOIN project_role pl ON p.p_id = pl.p_id
		JOIN Employee e ON e.e_id = pl.e_id
		JOIN customer c ON c.c_id = p.c_id
		JOIN job_title jt ON jt.j_id = e.j_id
	GROUP BY p.project_name,
		c.c_name,
		e.emp_name,
		jt.title
	ORDER BY "Project", "Customer";


------------ for additional task ------------------
-- Additional view to showcase the skills of each employee and different dates they worked for the company
--DROP VIEW skillsOfEmployees;
CREATE OR REPLACE VIEW skillsOfEmployees AS
SELECT DISTINCT
    e.emp_name "Name",
    e.salary "Salary",
    (SELECT SUM(salary_benefit_value) FROM skills
            WHERE salary_benefit = True AND s_id IN (
                SELECT s_id FROM employee_skills WHERE e_id = e.e_id)) "Skill Bonus",
    STRING_AGG(DISTINCT s.skill, ' ') "Skills",
    e.contract_start "Started",
    e.contract_end "Ended"

FROM employee e
    JOIN employee_skills es ON e.e_id = es.e_id
    JOIN skills s ON s.s_id = es.s_id
    GROUP BY e.e_id, e.emp_name, e.salary, e.contract_start, e.contract_end
    ORDER BY e.emp_name, e.contract_start;



--------------- FOR ADDITIONAL TASK ------------
-- Shows headquarters different departments and their employee groups
-- providing information about type of users in a department.
--DROP VIEW groupingAndDepartments;
CREATE OR REPLACE VIEW groupingAndDepartments AS
	SELECT
		hq.hq_name "Headquarter",
		d.dep_name "Department",
		ug.group_title "Group"
FROM Employee e
	JOIN department d 			ON e.d_id = d.d_id
	JOIN headquarters hq 		ON hq.h_id = d.hid
	JOIN employee_user_group eug ON eug.e_id = e.e_id
	JOIN user_group ug 			ON ug.u_id = eug.u_id
GROUP BY hq.hq_name, d.dep_name, ug.group_title
ORDER BY hq.hq_name, d.dep_name, ug.group_title;









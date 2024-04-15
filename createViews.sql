-- can find employees by country
DROP VIEW view_employees;
CREATE VIEW view_employees AS
select employee.e_id, employee.emp_name,job_title.title,department.dep_name, geo.country,employee.supervisor,employee.salary from employee
	JOIN job_title ON job_title.j_id = employee.j_id
	JOIN department ON department.d_id = employee.d_id
	JOIN headquarters head ON head.h_id = department.hid
	JOIN geo_location geo ON geo.l_id = head.l_id
	
	order by geo.country,job_title.title;
	

-- can find customers by country
DROP VIEW view_customers;
CREATE VIEW view_customers AS
	SELECT customer.c_id, customer.c_name, geo.country , STRING_AGG(pro.p_id::text, ',') p_id
		FROM customer
		JOIN geo_location geo ON geo.l_id = customer.l_id
		LEFT JOIN project pro ON pro.c_id = customer.l_id
		group by customer.c_id,geo.country
		order by geo.country, customer.c_id;

	
/*
Procedure that sets all employees salary to the base level based on their job title
*/
CREATE OR REPLACE PROCEDURE salaryChecking() LANGUAGE plpgsql AS $$
DECLARE
    EMP record;
    bs_sal numeric;
BEGIN
    FOR EMP IN SELECT * FROM Employee LOOP
        SELECT base_salary INTO bs_sal FROM job_title WHERE j_id = EMP.j_id;

        UPDATE Employee SET salary = bs_sal WHERE e_id = EMP.e_id;
    END LOOP;
    COMMIT;
END;
$$;


/*
Procedure that adds 3 months to all temporary contracts
*/
CREATE OR REPLACE PROCEDURE tempContractAddition() LANGUAGE plpgsql AS $$
BEGIN
    UPDATE Employee SET contract_end  = contract_end + (interval '3 months')
            WHERE contract_type ILIKE '%temporary%' OR contract_type ILIKE '%määräaikainen%';
    COMMIT;
END;
$$;


/*
Procedure that increases salaries by a percentage based on the given percentage. You can also specify the highest salary to be increased (give limit X and salaries that are below X are increased).
EDIT 20.04.2023: The user can specify the salary limit when calling the procedure. If user doesn't specify one (or gives 0 or null), then the limit is not considered. The percentage can be given in decimals or numbers or what ever you specify, as long as the procedure works.
*/
CREATE OR REPLACE PROCEDURE increaseSalariesByPrecentage(
    raisePercentage numeric, lim numeric ) LANGUAGE plpgsql AS $$
DECLARE
    raiseMult numeric;
BEGIN
    raiseMult:= ((100 + raisePercentage)/100);
    -- If user does not specify upper limit, give boost to salary
    IF lim IS NULL OR lim = 0
        THEN
            UPDATE Employee SET salary = salary::numeric * raiseMult;
    ELSE
        UPDATE Employee SET salary = salary::numeric * raiseMult
            WHERE (salary::numeric) < lim;
    END IF;
    COMMIT;
END;
$$;



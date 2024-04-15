CREATE OR REPLACE FUNCTION skillCheck() RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
    IF NEW.skill LIKE (SELECT skill FROM Skills)
        THEN RAISE EXCEPTION 'Skill already exists.';
    END IF;
END;
$$;


CREATE OR REPLACE FUNCTION projectCheck() RETURNS TRIGGER LANGUAGE plpgsql AS $$
DECLARE
    cust_country varchar;
    doers TEXT[];
BEGIN
    SELECT country INTO cust_country FROM geo_location WHERE I_id = (
        SELECT I_id FROM customer WHERE NEW.c_id = c_id)
    SELECT e_id INTO doers FROM employee WHERE I_id = (SELECT I_id FROM geo_location WHERE )


    IF NEW.skill LIKE (SELECT skill FROM Skills)
        THEN RAISE EXCEPTION 'Skill already exists.';
    END IF;
END;
$$;


CREATE OR REPLACE TRIGGER newSkillAddition
    BEFORE INSERT ON Skills
    FOR EACH ROW EXECUTE FUNCTION skillCheck();


CREATE OR REPLACE TRIGGER newProjectCheck
    AFTER INSERT ON project
    FOR EACH ROW EXECUTE FUNCTION projectCheck();


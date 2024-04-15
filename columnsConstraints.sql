ALTER TABLE geo_location ADD COLUMN zip_code CHAR(10);

ALTER TABLE customer ALTER COLUMN email SET NOT NULL;
ALTER TABLE project ALTER COLUMN p_start_date SET NOT NULL;

ALTER TABLE employee ADD CHECK (salary > 1000);


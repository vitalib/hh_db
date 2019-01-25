\c hh_homework;
DROP FUNCTION IF EXISTS copy;
CREATE OR REPLACE FUNCTION copy_job_location()
RETURNS void AS
$BODY$
DECLARE
    table_for_copy varchar(20);
begin
insert into map_job_location select main.job_location_id, outerbase.job_location_id
    from job_location as main
    join outer_base.job_location as outerbase
    using(city, state, country, zip);
end;
$BODY$
LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE FUNCTION copy()
RETURNS void AS
$BODY$
DECLARE
    table_for_copy varchar(20);
begin
    select copied_tables.name
        INTO table_for_copy
    from copied_tables
    where is_copied=false
    ORDER BY id
    limit 1;
    raise notice 'Table for copy %', table_for_copy;
    if (table_for_copy = 'job_location') then
        PERFORM copy_job_location();
    end if;
end;
$BODY$
LANGUAGE plpgsql VOLATILE;
DO $$ BEGIN
    PERFORM copy();
END $$;

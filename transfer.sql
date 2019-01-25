\c hh_homework;

CREATE OR REPLACE FUNCTION copy_job_location(limit_num int)
RETURNS void AS
$BODY$
DECLARE
    inserted_rows integer;
    is_table_updated boolean;
begin
    select is_updated
    into is_table_updated
        from copied_tables
            where name = 'job_location';
    if (is_table_updated = false) then
    insert into map_job_location select main.job_location_id, outerbase.job_location_id
        from job_location as main
        join outer_base.job_location as outerbase
        using(city, state, country, zip);
    update copied_tables set is_updated = true
        where name = 'job_location';
    end if;

    with ids as(
        insert into job_location(street_address ,city ,state ,country, zip, foreign_id)
            select street_address ,city ,state ,country, zip, job_location_id
            from outer_base.job_location
            where not exists (select * from map_job_location where job_location_id = outer_id)
            limit limit_num
        returning job_location_id, foreign_id),
     ins as (
        insert into map_job_location
            select * from ids
        returning primary_id
    )
    select count(*) into inserted_rows
    from ins;
    raise notice 'Rows copied %', inserted_rows;
    if (inserted_rows < limit_num) then
        update copied_tables set is_copied=true
            where name ='job_location';
    end if;
end;
$BODY$
LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE FUNCTION copy_skill(limit_num int)
RETURNS void AS
$BODY$
DECLARE
    inserted_rows integer;
    is_table_updated boolean;
begin
    select is_updated
    into is_table_updated
        from copied_tables
            where name = 'skill';
    if (is_table_updated = false) then
    insert into map_skill select main.skill_id, outerbase.skill_id
        from skill as main
        join outer_base.skill as outerbase
        using(skill_name);
    update copied_tables set is_updated = true
        where name = 'skill';
    end if;

    with ids as(
        insert into skill(skill_name, foreign_id)
            select skill_name, skill_id
            from outer_base.skill
            where not exists (select * from map_skill where skill_id = outer_id)
            limit limit_num
        returning skill_id,foreign_id),
     ins as (
        insert into map_skill
            select * from ids
        returning primary_id
    )
    select count(*) into inserted_rows
    from ins;
    raise notice 'in skills: Rows copied %', inserted_rows;
    if (inserted_rows < limit_num) then
        update copied_tables set is_copied=true
            where name ='skill';
    end if;
end;
$BODY$
LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE FUNCTION copy(limit_num int)
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
        PERFORM copy_job_location(limit_num);
    elseif (table_for_copy = 'skill') then
        PERFORM copy_skill(limit_num);
    end if;
end;
$BODY$
LANGUAGE plpgsql VOLATILE;
DO $$ BEGIN
    PERFORM copy(10);
END $$;

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

CREATE OR REPLACE FUNCTION copy_account(limit_num int)
RETURNS void AS
$BODY$
DECLARE
    inserted_rows integer;
    is_table_updated boolean;
begin
    select is_updated
    into is_table_updated
        from copied_tables
            where name = 'account';
    if (is_table_updated = false) then
    insert into map_account select main.account_id, outerbase.account_id
        from account as main
        join outer_base.account as outerbase
        using(email);
    update copied_tables set is_updated = true
        where name = 'account';
    end if;

    with ids as(
        insert into account(type_of_user, login, password, email, is_active,
            registration_date, last_login_date, foreign_id)
            select type_of_user, login, password, email, is_active,
                registration_date, last_login_date, account_id
            from outer_base.account
            where not exists (select * from map_account where account_id = outer_id)
            limit limit_num
        returning account_id,foreign_id),
     ins as (
        insert into map_account
            select * from ids
        returning primary_id
    )
    select count(*) into inserted_rows
    from ins;
    raise notice 'in account: Rows copied %', inserted_rows;
    if (inserted_rows < limit_num) then
        update copied_tables set is_copied=true
            where name ='account';
    end if;
end;
$BODY$
LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE FUNCTION copy_resume(limit_num int)
RETURNS void AS
$BODY$
DECLARE
    inserted_rows integer;
begin
    update copied_tables set is_updated = true
        where name = 'account';

    with ids as(
        insert into resume(account_id, first_name, middle_name, last_name, min_salary,
            max_salary, currency, birth_date, is_active, foreign_id)
            select account_id, first_name, middle_name, last_name, min_salary,
                max_salary, currency, birth_date, is_active, resume_id
            from outer_base.resume
            where not exists (select * from map_resume where resume_id = outer_id)
            limit limit_num
        returning resume_id,foreign_id),
     ins as (
        insert into map_resume
            select * from ids
        returning primary_id
    )
    select count(*) into inserted_rows
    from ins;
    raise notice 'in resume: Rows copied %', inserted_rows;
    if (inserted_rows < limit_num) then
        update copied_tables set is_copied=true
            where name ='resume';
    end if;
end;
$BODY$
LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE FUNCTION copy_company(limit_num int)
RETURNS void AS
$BODY$
DECLARE
    inserted_rows integer;
    is_table_updated boolean;
begin
    select is_updated
    into is_table_updated
        from copied_tables
            where name = 'company';
    if (is_table_updated = false) then
    insert into map_company select main.company_id, outerbase.company_id
        from company as main
        join outer_base.company as outerbase
        using(company_website_url);
    update copied_tables set is_updated = true
        where name = 'company';
    end if;

    with ids as(
        insert into company(company_name,
        activity_description,
        creation_date,
        company_website_url, foreign_id)
            select company_name ,
                activity_description,
                creation_date,
                company_website_url, company_id
            from outer_base.company
                where not exists (select * from map_company where company_id = outer_id)
            limit limit_num
        returning company_id,foreign_id),
     ins as (
        insert into map_company
            select * from ids
        returning primary_id
    )
    select count(*) into inserted_rows
    from ins;
    raise notice 'in company: Rows copied %', inserted_rows;
    if (inserted_rows < limit_num) then
        update copied_tables set is_copied=true
            where name ='company';
    end if;
end;
$BODY$
LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE FUNCTION copy_vacancy(limit_num int)
RETURNS void AS
$BODY$
DECLARE
    inserted_rows integer;
    is_table_updated boolean;
begin
    with ids as(
        insert into vacancy(
        posted_by_id,
        current_job_type,
        company_id,
        is_company_name_hidden,
        job_description,
        job_location_id,
        is_active,
        min_salary,
        max_salary,
        publication_time, foreign_id)
            select map_account.primary_id,
                current_job_type,
                map_company.primary_id,
                is_company_name_hidden,
                job_description,
                map_job_location.primary_id,
                is_active,
                min_salary,
                max_salary,
                publication_time,
                vacancy_id
            from outer_base.vacancy
            join map_account on map_account.outer_id = posted_by_id
            join map_company on map_company.outer_id = company_id
            join map_job_location on map_job_location.outer_id = job_location_id
                where not exists (select * from map_vacancy where vacancy_id = outer_id)
            limit limit_num
        returning vacancy_id,foreign_id),
     ins as (
        insert into map_vacancy
            select * from ids
        returning primary_id
    )
    select count(*) into inserted_rows
    from ins;
    raise notice 'in vacancy: Rows copied %', inserted_rows;
    if (inserted_rows < limit_num) then
        update copied_tables set is_copied=true
            where name ='vacancy';
    end if;
end;
$BODY$
LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE FUNCTION copy_invitation(limit_num int)
RETURNS integer AS
$BODY$
DECLARE
    an_offset integer;
    rows integer;
    is_table_updated boolean;
    inserted_rows integer;
begin
    select table_offset
    into an_offset
        from copied_tables
            where name='invitation';
    raise notice 'in invitatino: offset %', an_offset;
    select table_rows
    into rows
        from copied_tables
            where name='invitation';
    raise notice 'in invitatino: rows %', rows;
    with ids as(
    insert into invitation(
        resume_id,
        vacancy_id,
        meeting_time,
        invitation_time,
        message,
        is_watched)
        select map_resume.primary_id,
            map_vacancy.primary_id,
            meeting_time,
            invitation_time,
            message,
            is_watched
        from outer_base.invitation
        join map_resume on map_resume.outer_id = resume_id
        join map_vacancy on map_vacancy.outer_id = vacancy_id
        order by map_resume.primary_id, map_vacancy.primary_id
        limit limit_num offset an_offset
        on conflict do nothing
        returning resume_id)
    select count(*) into inserted_rows
    from ids;
    an_offset := an_offset + limit_num;
    -- raise notice 'in invitatino: Rows copied (%)';
    if (an_offset > rows) then
        update copied_tables set is_copied=true
            where name ='invitation';
    else
        update copied_tables set table_offset = an_offset
            where name = 'invitation';
    end if;
    return inserted_rows;
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
    case table_for_copy
        when 'job_location' then
            PERFORM copy_job_location(limit_num);
        when 'skill' then
            PERFORM copy_skill(limit_num);
        when 'account' then
            PERFORM copy_account(limit_num);
        when 'resume' then
            PERFORM copy_resume(limit_num);
        when 'company' then
            PERFORM copy_company(limit_num);
        when 'vacancy' then
            PERFORM copy_vacancy(limit_num);
        when 'invitation' then
            PERFORM copy_invitation(limit_num);
        else
            table_for_copy := 'kuku';
    end case;
end;
$BODY$
LANGUAGE plpgsql VOLATILE;
DO $$ BEGIN
    PERFORM copy(10);
END $$;

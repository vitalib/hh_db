CREATE OR REPLACE FUNCTION copy_job_location(limit_num int)
RETURNS integer AS
$BODY$
DECLARE
    inserted_rows integer;
    is_table_updated boolean;
begin
    with outer_batch as (
        select job_location_id, street_address ,city ,state ,country, zip
        from outer_base.job_location
        where not exists (select 1 from map_job_location where job_location_id = outer_id)
        limit limit_num
    ), inner_batch as(
        insert into job_location(street_address ,city ,state ,country, zip)
            select street_address ,city ,state ,country, zip
            from outer_batch
            returning job_location_id, street_address ,city ,state ,country, zip
    ), map_batch as (
        insert into map_job_location(primary_id, outer_id)
            select inner_batch.job_location_id, outer_batch.job_location_id
            from inner_batch
            inner join outer_batch using(street_address ,city ,state ,country, zip)
            returning primary_id
    )
    select count(*) into inserted_rows
    from map_batch;
    RETURN inserted_rows;
end;
$BODY$
LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE FUNCTION map_equal_skill(limit_num int)
RETURNS integer AS
$BODY$
BEGIN
    insert into map_skill(primary_id, outer_id) select main.skill_id, outerbase.skill_id
    from skill as main
    join outer_base.skill as outerbase
    using(skill_name);
    DROP INDEX outer_base.skill_idx;
RETURN 0;
end;
$BODY$
LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE FUNCTION copy_skill(limit_num int)
RETURNS integer AS
$BODY$
DECLARE
    inserted_rows integer;
begin
    with outer_batch as (
        select skill_id, skill_name
        from outer_base.skill
        where not exists (select 1 from map_skill where skill_id = outer_id)
        limit limit_num
    ), inner_batch as(
        insert into skill(skill_name)
            select skill_name
            from outer_batch
            returning skill_id, skill_name
    ), map_batch as (
        insert into map_skill(primary_id, outer_id)
            select inner_batch.skill_id, outer_batch.skill_id
            from inner_batch
            inner join outer_batch using(skill_name)
            returning primary_id
    )
    select count(*) into inserted_rows
    from map_batch;
    RETURN inserted_rows;
end;
$BODY$
LANGUAGE plpgsql VOLATILE;


CREATE OR REPLACE FUNCTION map_equal_account(limit_num int)
RETURNS integer AS
$BODY$
BEGIN
    insert into map_account(primary_id, outer_id) select main.account_id, outerbase.account_id
    from account as main
    join outer_base.account as outerbase
    using(email);
    DROP INDEX outer_base.account_idx;
RETURN 0;
end;
$BODY$
LANGUAGE plpgsql VOLATILE;


CREATE OR REPLACE FUNCTION copy_account(limit_num int)
RETURNS integer AS
$BODY$
DECLARE
    inserted_rows integer;
begin
    with outer_batch as (
        select account_id, map_company.primary_id as company_id, type_of_user, login, password, email, is_active,
            registration_date, last_login_date
        from outer_base.account
        left join map_company on company_id = outer_id
        where not exists (select 1 from map_account where account_id = outer_id)
        limit limit_num
    ), inner_batch as(
        insert into account(company_id, type_of_user, login, password, email, is_active,
            registration_date, last_login_date)
            select company_id, type_of_user, login, password, email, is_active,
                registration_date, last_login_date
            from outer_batch
            returning account_id, email
    ), map_batch as (
        insert into map_account(primary_id, outer_id)
            select inner_batch.account_id, outer_batch.account_id
            from inner_batch
            inner join outer_batch using(email)
            returning primary_id
    )
    select count(*) into inserted_rows
    from map_batch;
    RETURN inserted_rows;
end;
$BODY$
LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE FUNCTION copy_resume(limit_num int)
RETURNS integer AS
$BODY$
DECLARE
    inserted_rows integer;
begin
        with outer_batch as (
        select resume_id, map_account.primary_id as account_id, first_name, middle_name,
        last_name, min_salary, max_salary, currency, birth_date, is_active
        from outer_base.resume
        join map_account on account_id = outer_id
        where not exists (select 1 from map_resume where resume_id = outer_id)
        limit limit_num
    ), inner_batch as(
        insert into resume(account_id, first_name, middle_name, last_name, min_salary,
            max_salary, currency, birth_date, is_active)
            select account_id, first_name, middle_name, last_name, min_salary,
                max_salary, currency, birth_date, is_active
            from outer_batch
            returning resume_id, account_id, first_name, last_name, birth_date
    ), map_batch as (
        insert into map_resume(primary_id, outer_id)
            select inner_batch.resume_id, outer_batch.resume_id
            from inner_batch
            inner join outer_batch using(account_id, first_name, last_name, birth_date)
            returning primary_id
    )
    select count(*) into inserted_rows
    from map_batch;
    RETURN inserted_rows;
end;
$BODY$
LANGUAGE plpgsql VOLATILE;


CREATE OR REPLACE FUNCTION map_equal_company(limit_num int)
RETURNS integer AS
$BODY$
BEGIN
    insert into map_company(primary_id, outer_id)
    select main.company_id, outerbase.company_id
    from company as main
    join outer_base.company as outerbase
    using(company_name, creation_date);
    DROP INDEX outer_base.company_idx;
RETURN 0;
end;
$BODY$
LANGUAGE plpgsql VOLATILE;


CREATE OR REPLACE FUNCTION copy_company(limit_num int)
RETURNS integer AS
$BODY$
DECLARE
    inserted_rows integer;
begin
    with outer_batch as (
        select company_id, company_name, activity_description, creation_date, company_website_url
        from outer_base.company
        where not exists (select 1 from map_company where company_id = outer_id)
        limit limit_num
    ), inner_batch as(
        insert into company(company_name, activity_description, creation_date, company_website_url)
            select company_name, activity_description, creation_date, company_website_url
            from outer_batch
            returning company_id, company_name, creation_date
    ), map_batch as (
        insert into map_company(primary_id, outer_id)
            select inner_batch.company_id, outer_batch.company_id
            from inner_batch
            inner join outer_batch using(company_name, creation_date)
            returning primary_id
    )
    select count(*) into inserted_rows
    from map_batch;
    RETURN inserted_rows;
end;
$BODY$
LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE FUNCTION copy_vacancy(limit_num int)
RETURNS integer AS
$BODY$
DECLARE
    inserted_rows integer;
    is_table_updated boolean;
begin
    with outer_batch as (
        select vacancy_id, map_account.primary_id as posted_by_id, current_job_type,
        map_company.primary_id as company_id, is_company_name_hidden,
        job_description, map_job_location.primary_id as job_location_id, is_active, min_salary, max_salary, publication_time, expiry_time
        from outer_base.vacancy
        join map_account on posted_by_id = map_account.outer_id
        join map_company on company_id = map_company.outer_id
        join map_job_location on job_location_id = map_job_location.outer_id
        where not exists (select 1 from map_vacancy where vacancy_id = outer_id)
        limit limit_num
    ), inner_batch as(
        insert into vacancy(posted_by_id, current_job_type, company_id,
        is_company_name_hidden, job_description, job_location_id,
        is_active, min_salary, max_salary, publication_time, expiry_time)
            select posted_by_id, current_job_type, company_id,
            is_company_name_hidden, job_description, job_location_id,
            is_active, min_salary, max_salary, publication_time, expiry_time
            from outer_batch
            returning vacancy_id, posted_by_id, company_id, job_description
    ), map_batch as (
        insert into map_vacancy(primary_id, outer_id)
            select inner_batch.vacancy_id , outer_batch.vacancy_id
            from inner_batch
            inner join outer_batch using(posted_by_id, company_id, job_description)
            returning primary_id
    )
    select count(*) into inserted_rows
    from map_batch;
    RETURN inserted_rows;
end;
$BODY$
LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE FUNCTION copy_invitation(limit_num int)
RETURNS integer AS
$BODY$
DECLARE
    an_offset integer;
    rows integer;
begin
    select table_offset
        into an_offset
            from copied_tables
                where name='invitation';
    select table_rows
        into rows
            from copied_tables
                where name='invitation';
    with inv_batch as (
        select resume_id, vacancy_id, meeting_time,
        invitation_time, message, is_watched
        FROM outer_base.invitation
        where invitation_id between an_offset + 1 and an_offset + limit_num
    )
    insert into invitation(resume_id, vacancy_id, meeting_time, invitation_time,
    message,is_watched)
    select map_resume.primary_id, map_vacancy.primary_id, meeting_time,
        invitation_time, message, is_watched
    from inv_batch
    join map_resume on map_resume.outer_id = resume_id
    join map_vacancy on map_vacancy.outer_id = vacancy_id
    on conflict do nothing;
    an_offset := an_offset + limit_num;
    update copied_tables set table_offset = an_offset
        where name = 'invitation';
    RETURN rows - an_offset;
end;
$BODY$
LANGUAGE plpgsql VOLATILE;


CREATE OR REPLACE FUNCTION copy_respond(limit_num int)
RETURNS integer AS
$BODY$
DECLARE
    an_offset integer;
    rows integer;
begin
    select table_offset
        into an_offset
            from copied_tables
                where name='respond';
    select table_rows
        into rows
            from copied_tables
                where name='respond';
    with inv_batch as (
        select resume_id, vacancy_id, apply_date,
        message, is_watched
        FROM outer_base.respond
        where respond_id between an_offset + 1 and an_offset + limit_num
    )
    insert into respond(resume_id, vacancy_id, apply_date, message, is_watched)
    select map_resume.primary_id, map_vacancy.primary_id, apply_date,
         message, is_watched
    from inv_batch
    join map_resume on map_resume.outer_id = resume_id
    join map_vacancy on map_vacancy.outer_id = vacancy_id
    on conflict do nothing;
    an_offset := an_offset + limit_num;
    update copied_tables set table_offset = an_offset
        where name = 'respond';
    RETURN rows - an_offset;
end;
$BODY$
LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE FUNCTION copy_message(limit_num int)
RETURNS integer AS
$BODY$
DECLARE
    an_offset integer;
    rows integer;
begin
    select table_offset
        into an_offset
            from copied_tables
                where name='message';
    select table_rows
        into rows
            from copied_tables
                where name='message';
    with inv_batch as (
        select resume_id, vacancy_id, message_time  ,
        message, is_watched
        FROM outer_base.message
        where message_id between an_offset + 1 and an_offset + limit_num
    )
    insert into message(resume_id, vacancy_id, message_time, message, is_watched)
    select map_resume.primary_id, map_vacancy.primary_id, message_time,
         message, is_watched
    from inv_batch
    join map_resume on map_resume.outer_id = resume_id
    join map_vacancy on map_vacancy.outer_id = vacancy_id
    on conflict do nothing;
    an_offset := an_offset + limit_num;
    update copied_tables set table_offset = an_offset
        where name = 'message';
    RETURN rows - an_offset;
end;
$BODY$
LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE FUNCTION copy_resume_skill_set(limit_num int)
RETURNS integer AS
$BODY$
DECLARE
    an_offset integer;
    rows integer;
    is_table_updated boolean;
begin
    select table_offset
        into an_offset
            from copied_tables
                where name='resume_skill_set';
    select table_rows
        into rows
            from copied_tables
                where name='resume_skill_set';

    insert into resume_skill_set(
        resume_id, skill_id, skill_level)
        select
            map_resume.primary_id,
            map_skill.primary_id,
            skill_level
        from outer_base.resume_skill_set
        join map_skill on map_skill.outer_id = skill_id
        join map_resume on map_resume.outer_id = resume_id
        order by map_resume.primary_id, map_skill.primary_id
        limit limit_num offset an_offset
        on conflict do nothing;
    an_offset := an_offset + limit_num;
    update copied_tables set table_offset = an_offset
        where name = 'resume_skill_set';
    return rows - an_offset;
end;
$BODY$
LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE FUNCTION copy_vacancy_skill_set(limit_num int)
RETURNS integer AS
$BODY$
DECLARE
    an_offset integer;
    rows integer;
    is_table_updated boolean;
begin
    select table_offset
        into an_offset
            from copied_tables
                where name='vacancy_skill_set';
    select table_rows
        into rows
            from copied_tables
                where name='vacancy_skill_set';

    insert into vacancy_skill_set(
        skill_id, vacancy_id, skill_level)
        select
            map_skill.primary_id,
            map_vacancy.primary_id,
            skill_level
        from outer_base.vacancy_skill_set
        join map_skill on map_skill.outer_id = skill_id
        join map_vacancy on map_vacancy.outer_id = vacancy_id
        order by map_vacancy.primary_id, map_skill.primary_id
        limit limit_num offset an_offset
        on conflict do nothing;
    an_offset := an_offset + limit_num;
    update copied_tables set table_offset = an_offset
        where name = 'vacancy_skill_set';
    return rows - an_offset;
end;
$BODY$
LANGUAGE plpgsql VOLATILE;

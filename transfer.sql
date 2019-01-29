CREATE OR REPLACE FUNCTION copy_job_location(limit_num int)
RETURNS void AS
$BODY$
DECLARE
    inserted_rows integer;
    is_table_updated boolean;
begin
    with outer_batch as (
        select job_location_id, street_address ,city ,state ,country, zip
        from outer_base.job_location
        where not exists (select * from map_job_location where job_location_id = outer_id)
        limit limit_num
    ), inner_batch as(
        insert into job_location(street_address ,city ,state ,country, zip)
            select street_address ,city ,state ,country, zip
            from outer_batch
            returning job_location_id, street_address ,city ,state ,country, zip
    ), map_batch as (
        insert into map_job_location
            select inner_batch.job_location_id, outer_batch.job_location_id
            from inner_batch
            inner join outer_batch using(street_address ,city ,state ,country, zip)
            returning *
    )
    select count(*) into inserted_rows
    from map_batch;
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

    with outer_batch as (
        select skill_id, skill_name
        from outer_base.skill
        where not exists (select * from map_skill where skill_id = outer_id)
        limit limit_num
    ), inner_batch as(
        insert into skill(skill_name)
            select skill_name
            from outer_batch
            returning skill_id, skill_name
    ), map_batch as (
        insert into map_skill
            select inner_batch.skill_id, outer_batch.skill_id
            from inner_batch
            inner join outer_batch using(skill_name)
            returning *
    )
    select count(*) into inserted_rows
    from map_batch;
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
        using( email);
    update copied_tables set is_updated = true
        where name = 'account';
    end if;

    with outer_batch as (
        select account_id, map_company.primary_id as company_id, type_of_user, login, password, email, is_active,
            registration_date, last_login_date
        from outer_base.account
        left join map_company on company_id = outer_id
        where not exists (select * from map_account where account_id = outer_id)
        limit limit_num
    ), inner_batch as(
        insert into account(company_id, type_of_user, login, password, email, is_active,
            registration_date, last_login_date)
            select company_id, type_of_user, login, password, email, is_active,
                registration_date, last_login_date
            from outer_batch
            returning *
    ), map_batch as (
        insert into map_account
            select inner_batch.account_id, outer_batch.account_id
            from inner_batch
            inner join outer_batch using(email)
            returning *
    )
    select count(*) into inserted_rows
    from map_batch;
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
    with outer_batch as (
        select resume_id, map_account.primary_id as account_id, first_name, middle_name,
        last_name, min_salary, max_salary, currency, birth_date, is_active
        from outer_base.resume
        join map_account on account_id = outer_id
        where not exists (select * from map_resume where resume_id = outer_id)
        limit limit_num
    ), inner_batch as(
        insert into resume(account_id, first_name, middle_name, last_name, min_salary,
            max_salary, currency, birth_date, is_active)
            select account_id, first_name, middle_name, last_name, min_salary,
                max_salary, currency, birth_date, is_active
            from outer_batch
            returning *
    ), map_batch as (
        insert into map_resume
            select inner_batch.resume_id, outer_batch.resume_id
            from inner_batch
            inner join outer_batch using(account_id, first_name, last_name, birth_date)
            returning *
    )
    select count(*) into inserted_rows
    from map_batch;
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
        using(company_name, company_website_url, activity_description, creation_date);
    update copied_tables set is_updated = true
        where name = 'company';
    end if;

    with outer_batch as (
        select company_id, company_name, activity_description, creation_date, company_website_url
        from outer_base.company
        where not exists (select * from map_company where company_id = outer_id)
        limit limit_num
    ), inner_batch as(
        insert into company(company_name, activity_description, creation_date, company_website_url)
            select company_name, activity_description, creation_date, company_website_url
            from outer_batch
            returning company_id, company_name, activity_description, creation_date, company_website_url
    ), map_batch as (
        insert into map_company
            select inner_batch.company_id, outer_batch.company_id
            from inner_batch
            inner join outer_batch using(company_name, company_website_url, activity_description, creation_date)
            returning *
    )
    select count(*) into inserted_rows
    from map_batch;
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
    with outer_batch as (
        select vacancy_id, map_account.primary_id as posted_by_id, current_job_type,
        map_company.primary_id as company_id, is_company_name_hidden,
        job_description, map_job_location.primary_id as job_location_id, is_active, min_salary, max_salary, publication_time, expiry_time
        from outer_base.vacancy
        join map_account on posted_by_id = map_account.outer_id
        join map_company on company_id = map_company.outer_id
        join map_job_location on job_location_id = map_job_location.outer_id
        where not exists (select * from map_vacancy where vacancy_id = outer_id)
        limit limit_num
    ), inner_batch as(
        insert into vacancy(posted_by_id, current_job_type, company_id,
        is_company_name_hidden, job_description, job_location_id,
        is_active, min_salary, max_salary, publication_time, expiry_time)
            select posted_by_id, current_job_type, company_id,
            is_company_name_hidden, job_description, job_location_id,
            is_active, min_salary, max_salary, publication_time, expiry_time
            from outer_batch
            returning *
    ), map_batch as (
        insert into map_vacancy
            select inner_batch.vacancy_id, outer_batch.vacancy_id
            from inner_batch
            inner join outer_batch using(posted_by_id, company_id, job_description)
            returning *
    )
    select count(*) into inserted_rows
    from map_batch;
    if (inserted_rows < limit_num) then
        update copied_tables set is_copied=true
            where name ='vacancy';
    end if;
end;
$BODY$
LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE FUNCTION copy_invitation(limit_num int)
RETURNS void AS
$BODY$
DECLARE
    an_offset integer;
    rows integer;
begin
ALTER TABLE invitation DROP CONSTRAINT "invitation_resume_id_fkey";
ALTER TABLE invitation DROP CONSTRAINT "invitation_vacancy_id_fkey";
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
    if (an_offset > rows) then
        update copied_tables set is_copied=true
            where name ='invitation';
    else
        update copied_tables set table_offset = an_offset
            where name = 'invitation';
    end if;
    ALTER TABLE invitation ADD CONSTRAINT "invitation_resume_id_fkey" FOREIGN KEY (resume_id)
    REFERENCES resume(resume_id);
    ALTER TABLE invitation ADD CONSTRAINT "invitation_vacancy_id_fkey" FOREIGN KEY (vacancy_id)
    REFERENCES vacancy(vacancy_id);
end;
$BODY$
LANGUAGE plpgsql VOLATILE;


CREATE OR REPLACE FUNCTION copy_respond(limit_num int)
RETURNS void AS
$BODY$
DECLARE
    an_offset integer;
    rows integer;
begin
ALTER TABLE respond DROP CONSTRAINT "respond_resume_id_fkey";
ALTER TABLE respond DROP CONSTRAINT "respond_vacancy_id_fkey";
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
    if (an_offset > rows) then
        update copied_tables set is_copied=true
            where name ='respond';
    else
        update copied_tables set table_offset = an_offset
            where name = 'respond';
    end if;
    ALTER TABLE respond ADD CONSTRAINT "respond_resume_id_fkey" FOREIGN KEY (resume_id)
    REFERENCES resume(resume_id);
    ALTER TABLE respond ADD CONSTRAINT "respond_vacancy_id_fkey" FOREIGN KEY (vacancy_id)
    REFERENCES vacancy(vacancy_id);
end;
$BODY$
LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE FUNCTION copy_message(limit_num int)
RETURNS void AS
$BODY$
DECLARE
    an_offset integer;
    rows integer;
begin
ALTER TABLE message DROP CONSTRAINT "message_resume_id_fkey";
ALTER TABLE message DROP CONSTRAINT "message_vacancy_id_fkey";
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
    if (an_offset > rows) then
        update copied_tables set is_copied=true
            where name ='message';
    else
        update copied_tables set table_offset = an_offset
            where name = 'message';
    end if;
    ALTER TABLE message ADD CONSTRAINT "message_resume_id_fkey" FOREIGN KEY (resume_id)
    REFERENCES resume(resume_id);
    ALTER TABLE message ADD CONSTRAINT "message_vacancy_id_fkey" FOREIGN KEY (vacancy_id)
    REFERENCES vacancy(vacancy_id);
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
    inserted_rows integer;
begin
    select table_offset
        into an_offset
            from copied_tables
                where name='resume_skill_set';
    select table_rows
        into rows
            from copied_tables
                where name='resume_skill_set';
    with ids as(
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
        on conflict do nothing
        returning resume_id)
    select count(*) into inserted_rows
    from ids;
    an_offset := an_offset + limit_num;
    if (an_offset > rows) then
        update copied_tables set is_copied=true
            where name ='resume_skill_set';
    else
        update copied_tables set table_offset = an_offset
            where name = 'resume_skill_set';
    end if;
    return inserted_rows;
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
    inserted_rows integer;
begin
    select table_offset
        into an_offset
            from copied_tables
                where name='vacancy_skill_set';
    select table_rows
        into rows
            from copied_tables
                where name='vacancy_skill_set';
    with ids as(
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
        on conflict do nothing
        returning vacancy_id)
    select count(*) into inserted_rows
    from ids;
    an_offset := an_offset + limit_num;
    if (an_offset > rows) then
        update copied_tables set is_copied=true
            where name ='vacancy_skill_set';
    else
        update copied_tables set table_offset = an_offset
            where name = 'vacancy_skill_set';
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
        when 'respond' then
            PERFORM copy_respond(limit_num);
        when 'message' then
            PERFORM copy_message(limit_num);
        when 'resume_skill_set' then
            PERFORM copy_resume_skill_set(limit_num);
        when 'vacancy_skill_set' then
            PERFORM copy_vacancy_skill_set(limit_num);
        else
            table_for_copy := 'Error table';
    end case;
end;
$BODY$
LANGUAGE plpgsql VOLATILE;

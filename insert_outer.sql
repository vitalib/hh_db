\set big_value 10000
\set mid_value 1000
\set low_value 100

\set respond_quantity :big_value
\set resume_quantity :mid_value * 2
\set vacancy_quantity :mid_value
\set invitation_quantity :big_value
\set message_quantity :big_value
\set vacancy_skill_set_quantity :mid_value
\set resume_skill_set_quantity :mid_value
\set skill_quantity :low_value
\set job_location_quantity :low_value
\set account_quantity :low_value
\set company_quantity :low_value
\set education_quantity :low_value
\set experience_detail_quantity :low_value
\set limit_num 0;

INSERT INTO outer_base.skill (skill_name)
   SELECT 'skill'|| a.n
       FROM generate_series(1, :skill_quantity) as a(n);
select * from outer_base.skill limit :limit_num;


INSERT INTO outer_base.job_location (street_address ,city ,state ,country, zip )
    SELECT 'address' || a.n, 'city' || a.n, 'state' || a.n, 'Russia', a.n
        FROM generate_series(1, :job_location_quantity) as a(n);
select * from outer_base.job_location limit :limit_num;

INSERT INTO outer_base.company (
    company_name ,
    activity_description,
    creation_date,
    company_website_url)
SELECT
    'company' || a.n,
    a.n || ') this is some company description',
    now() - '1 day':: INTERVAL * ROUND(RANDOM() * 10000 + 1000),
    'www.company' || a.n || '.com'
FROM generate_series(1, :company_quantity) as a(n);

select * from outer_base.company limit :limit_num;

-- Insertion of applicants
INSERT INTO outer_base.account(company_id, type_of_user, login, password, email, is_active,
    registration_date, last_login_date)
    SELECT
         null,
        'APPLICANT',
        'login' || a.n,
        'password' || a.n,
        'account_email' || a.n || '@.mail.ru',
        random() > 0.2,
        now() - '1 day':: INTERVAL * ROUND(RANDOM() * 1000 + 1000),
        now() - '1 day':: INTERVAL * ROUND(RANDOM() * 1000)
            FROM generate_series(1, :account_quantity/2) as a(n);

-- Insertion of employers
INSERT INTO outer_base.account(company_id, type_of_user, login, password, email, is_active,
    registration_date, last_login_date)
    SELECT
        ceil(random() * :company_quantity),
        (ARRAY['RECRUITER', 'HH_AGENCY'])[ceil(random()*2)]::USER_TYPE,
        'login' || a.n,
        'password' || a.n,
        'account_email' || a.n || '@.mail.ru',
        random() > 0.2,
        now() - '1 day':: INTERVAL * ROUND(RANDOM() * 1000 + 1000),
        now() - '1 day':: INTERVAL * ROUND(RANDOM() * 1000)
            FROM generate_series(:account_quantity/2 + 1, :account_quantity) as a(n);

select * from outer_base.account limit :limit_num;

WITH potential_employees AS (
    SELECT account_id FROM outer_base.account
        WHERE type_of_user = 'APPLICANT'
), total_employees as (
    SELECT count(*) as total FROM potential_employees
)
INSERT INTO outer_base.resume(account_id, first_name, middle_name, last_name, min_salary,
    max_salary, currency, birth_date, is_active)
    SELECT
        (SELECT account_id FROM potential_employees ORDER BY RANDOM() LIMIT 1),
        'first_name' || a.n,
        'middle_name' || a.n,
        'last_name' || a.n,
        random() * 20000 + 20000,
        random() * 100000 + 40000,
        'RUR',
        now() - '1 day':: INTERVAL * ROUND(RANDOM() * 10000 + 10000),
        random() > 0.3
            FROM generate_series(1, :resume_quantity) as a(n);
select * from outer_base.resume limit :limit_num;







INSERT INTO  outer_base.education (
    resume_id,
    course_name ,
    start_date ,
    end_date ,
    description)
SELECT
    ceil(random() * :resume_quantity),
    'course' || a.n,
    now() - '1 day':: INTERVAL * ROUND(RANDOM() * 10000 + 10000),
    now() - '1 day':: INTERVAL * ROUND(RANDOM() * 10000),
    'super education rank' || a.n
FROM
    generate_series(1, :education_quantity) as a(n);
select * from outer_base.education limit :limit_num;


INSERT INTO  outer_base.experience_detail (
    resume_id,
    start_date,
    is_current_job,
    end_date,
    job_title,
    company_name,
    description,
    job_location_id)
SELECT
   ceil(random() * :resume_quantity),
   now() - '1 day':: INTERVAL * ROUND(RANDOM() * 10000 + 10000),
   random() > 0.5,
   now() - '1 day':: INTERVAL * ROUND(RANDOM() * 10000),
   'job title' || a.n,
   'company name ' || a.n,
   'job description from experience_detail' || a.n,
   ceil(random() * :job_location_quantity)
From
    generate_series(1, :experience_detail_quantity) as a(n);
select * from outer_base.experience_detail limit :limit_num;

WITH employers AS (
    SELECT account_id FROM outer_base.account
        WHERE type_of_user != 'APPLICANT'
), total_employers as (
    SELECT count(*) as total FROM employers
)
INSERT INTO outer_base.vacancy (
    posted_by_id,
    current_job_type,
    company_id,
    is_company_name_hidden,
    job_description,
    job_location_id,
    is_active,
    min_salary,
    max_salary,
    publication_time)
SELECT
    (SELECT account_id FROM employers OFFSET floor(random()* (SELECT  * from total_employers)) LIMIT 1),
    (ARRAY['REMOTE_JOB', 'PART_TIME', 'FULL_TIME'])[ceil(random()*3)]::JOB_TYPE,
    ceil(random() * :company_quantity),
    random() > 0.8,
    'very nice job description' || a.n,
    ceil(random() * :job_location_quantity),
    random() > 0.2,
    20000 + random() * 20000,
    40000 + random() * 100000,
    now() - '1 day':: INTERVAL * ROUND(RANDOM() * 1000)
FROM
    generate_series(1, :vacancy_quantity) as a(n);

select * from outer_base.vacancy limit :limit_num;


INSERT INTO outer_base.invitation (
    resume_id,
    vacancy_id,
    meeting_time,
    invitation_time,
    message,
    is_watched)
SELECT
    ceil(random() * :resume_quantity),
    ceil(random() * :vacancy_quantity),
    now() - '1 day':: INTERVAL * ROUND(RANDOM() * 1000),
    now() - '1 day':: INTERVAL * ROUND(RANDOM() * 1000 + 1000),
    'Invitaion message from employer' || a.n,
    random()  > 0.5
FROM
    generate_series(1, :invitation_quantity) as a(n)
ON CONFLICT DO NOTHING;

select * from outer_base.invitation limit :limit_num;


INSERT INTO outer_base.respond (
    vacancy_id,
    resume_id,
    apply_date,
    message,
    is_watched)
SELECT
    ceil(random() * :vacancy_quantity),
    ceil(random() * :resume_quantity),
    now() - '1 day':: INTERVAL * ROUND(RANDOM() * 1000),
    'Respnd message from employer' || a.n,
    random()  > 0.5
FROM
    generate_series(1, :respond_quantity) as a(n)
ON CONFLICT DO NOTHING;

select * from outer_base.respond limit :limit_num;


INSERT INTO outer_base.message (
    vacancy_id,
    resume_id,
    message_time,
    message,
    is_watched)
SELECT
    ceil(random() * :vacancy_quantity),
    ceil(random() * :resume_quantity),
    now() - '1 day':: INTERVAL * ROUND(RANDOM() * 1000),
    'Message concerning jobs' || a.n,
    random()  > 0.5
FROM
    generate_series(1, :message_quantity) as a(n)
ON CONFLICT DO NOTHING;

select * from outer_base.message limit :limit_num;

INSERT INTO outer_base.resume_skill_set (
    resume_id,  skill_id,  skill_level)
SELECT
    ceil(random() * :resume_quantity),
    ceil(random() * :skill_quantity),
    ceil(1 + random() * 9)
FROM
    generate_series(1, :resume_skill_set_quantity) as a(n)
ON CONFLICT DO NOTHING;

SELECT * FROM outer_base.resume_skill_set limit :limit_num;


INSERT INTO outer_base.vacancy_skill_set (
    skill_id, vacancy_id, skill_level)
SELECT
    ceil(random() * :skill_quantity),
    ceil(random() * :vacancy_quantity),
    ceil(1 + random() * 9)
FROM
    generate_series(1, :vacancy_skill_set_quantity) as a(n)
ON CONFLICT DO NOTHING;

SELECT * FROM outer_base.vacancy_skill_set limit :limit_num;

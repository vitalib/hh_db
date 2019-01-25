\set skill_quantity 10
\set job_location_quantity 10
\set account_quantity 50
\set resume_quantity 50

INSERT INTO outer_base.skill (skill_name)
   SELECT 'skill'|| a.n
       FROM generate_series(1, :skill_quantity) as a(n);
select * from outer_base.skill limit 10;


INSERT INTO  outer_base.job_location (street_address ,city ,state ,country, zip )
    SELECT 'addres' || a.n, 'city' || a.n, 'state' || a.n, 'Russia', a.n
        FROM generate_series(1, :job_location_quantity) as a(n);
select * from outer_base.job_location limit 10;

INSERT INTO account(type_of_user, login, password, email, is_active,
    registration_date, last_login_date)
    SELECT
        (ARRAY['APPLICANT', 'RECRUITER', 'HH_AGENCY'])[ceil(random()*3)]::USER_TYPE,
        'login' || a.n,
        'password' || a.n,
        'account_email' || a.n || '@.mail.ru',
        random() > 0.2,
        now() - '1 day':: INTERVAL * ROUND(RANDOM() * 1000 + 1000),
        now() - '1 day':: INTERVAL * ROUND(RANDOM() * 1000)
            FROM generate_series(1, :account_quantity) as a(n);

select * from account limit 10;


INSERT INTO resume(account_id, first_name, middle_name, last_name, min_salary,
    max_salary, currency, birth_date, is_active)
    SELECT
        ceil(random() * :account_quantity),
        'first_name' || a.n,
        'middle_name' || a.n,
        'last_name' || a.n,
        random() * 20000 + 20000,
        random() * 100000 + 40000,
        'RUR',
        now() - '1 day':: INTERVAL * ROUND(RANDOM() * 10000 + 10000),
        random() > 0.3
            FROM generate_series(1, :resume_quantity) as a(n);
select * from resume limit 10;

-- I want to find a job (sorry, no money left :( )
-- I create a users account in database
INSERT INTO account (type_of_user, login, password, email, is_active,
    registration_date, last_login_date)
        VALUES
            ('APPLICANT', 'ivanov_ivan', crypt('ivanov_password', gen_salt('bf')),
                'ivanov_ivan@mail.ru', true, now(), now());

-- Verify that account was createad
EXPLAIN ANALYZE SELECT account_id, login, email, registration_date, is_active FROM account WHERE login = 'ivanov_ivan';
-- Index Scan using account_login_key on account  (cost=0.42..8.44 rows=1 width=50
-- ) (actual time=0.059..0.062 rows=1 loops=1)
--   Index Cond: ((login)::text = 'ivanov_ivan'::text)
-- Planning time: 0.211 ms
-- Execution time: 0.111 ms
-- (4 rows)
-- ЗАпрос выполнен оптимально.


-- I create a resume
INSERT INTO resume(account_id, first_name, middle_name, last_name, min_salary, max_salary, currency, birth_date, is_active)
    SELECT account_id, 'Ivan', 'Ivanovich', 'Ivanov', 40000, 60000, 'RUB', '1982-07-01', true
       FROM account WHERE login = 'ivanov_ivan';

-- I create my second resume
INSERT INTO resume(account_id, first_name, middle_name, last_name, min_salary, max_salary, currency, birth_date, is_active)
    SELECT account_id, 'Ivan', 'Ivanovich', 'Ivanov', 40000, 60000, 'RUB', '1982-07-01', true
       FROM account WHERE login = 'ivanov_ivan';


-- Check whether my new resume is in database
EXPLAIN ANALYZE SELECT resume_id, first_name, last_name, birth_date, max_salary, is_active
    FROM resume
    WHERE account_id=100033;

--  Gather  (cost=1000.00..39893.79 rows=1 width=46) (actual time=942.898..946.182
-- rows=0 loops=1)
--    Workers Planned: 2
--    Workers Launched: 2
--    ->  Parallel Seq Scan on resume  (cost=0.00..38893.69 rows=1 width=46) (actua
-- l time=926.074..926.074 rows=0 loops=3)
--          Filter: (account_id = 100033)
--          Rows Removed by Filter: 666668
--  Planning time: 0.911 ms
--  Execution time: 946.252 ms
-- (8 rows)
---- Медленный sequence scan. Добавим индекс по полю account_id:
CREATE INDEX ON resume(account_id);
VACUUM ANALYZE resume;
-- Index Scan using resume_account_id_idx on resume  (cost=0.43..4.45 rows=1 width
-- =46) (actual time=0.044..0.044 rows=0 loops=1)
--   Index Cond: (account_id = 100033)
-- Planning time: 0.380 ms
-- Execution time: 0.081 ms
-- (4 rows)
-- Index Scan значительно улучшил время выполнения запроса.

-- Indicate my education
INSERT INTO education (resume_id, course_name, start_date, end_date, description)
    VALUES
        (6, 'BSEU', '2001-09-01', '2005-06-30', 'Higher Education - Banking Department'),
        (6, 'BSEU', '2006-09-01', '2007-06-30', 'Magistr Degrees - Banking Department');

-- Indicate my working experience
INSERT INTO experience_detail(resume_id, start_date, is_current_job, end_date, job_title, company_name, description, job_location_id)
    VALUES
        (6, '2005-04-30', false, '2008-07-30', 'Head Economist Currency Control Dept', 'ASB Belarusbank', 'Currency Control', 1),
        (6, '2008-11-15', false, '2017-10-15', 'Managing Expert', 'JSC Promsvyazbank', 'Letters of Credit', 2);

-- Indicate my skill
INSERT INTO resume_skill_set(resume_id, skill_id, skill_level)
    VALUES
       (6, 1, 10),
       (6, 2, 4);

-- I search vacancies that are suitable for me
EXPLAIN ANALYZE SELECT vacancy_id, vacancy.job_description, vacancy.current_job_type, vacancy.max_salary, company.company_name
    FROM vacancy
    JOIN company USING(company_id)
    WHERE vacancy.is_active = true
        AND lower(vacancy.job_description) LIKE '%letter of credit%';
--  Gather  (cost=1000.29..22787.46 rows=80 width=55) (actual time=753.763..759.419
--  rows=1 loops=1)
--    Workers Planned: 2
--    Workers Launched: 2
--    ->  Nested Loop  (cost=0.29..21779.46 rows=33 width=55) (actual time=724.750.
-- .740.868 rows=0 loops=3)
--          ->  Parallel Seq Scan on vacancy  (cost=0.00..21525.03 rows=33 width=47
-- ) (actual time=724.740..740.857 rows=0 loops=3)
--                Filter: (is_active AND (lower((job_description)::text) ~~ '%lette
-- r of credit%'::text))
--                Rows Removed by Filter: 333335
--          ->  Index Scan using company_pkey on company  (cost=0.29..7.71 rows=1 w
-- idth=16) (actual time=0.021..0.021 rows=1 loops=1)
--                Index Cond: (company_id = vacancy.company_id)
--  Planning time: 1.228 ms
--  Execution time: 759.502 ms
-- (11 rows)
-- Попытаемся улучшить выполнение запроса путем создания индекса GIN
-- на поле job_description
CREATE INDEX vacancy_jd_idx ON vacancy USING GIN (to_tsvector('english', job_description));
-- Откорректируем соответствущим образом текст запроса
SELECT vacancy_id, vacancy.job_description, vacancy.current_job_type, vacancy.max_salary, company.company_name
   FROM vacancy
   JOIN company USING(company_id)
   WHERE vacancy.is_active = true
       AND to_tsvector('english', job_description) @@ plainto_tsquery('english', 'letter of credit');
 --   Nested Loop  (cost=36.74..312.31 rows=20 width=55) (actual time=0.212..0.213 rows=1 l
 --  oops=1)
 --  Nested Loop  (cost=36.49..305.81 rows=20 width=55) (actual time=0.130..0.131 rows=1 l
 -- oops=1)
--    ->  Bitmap Heap Scan on vacancy  (cost=36.19..139.61 rows=20 width=47) (actual time
-- =0.120..0.120 rows=1 loops=1)
--          Recheck Cond: (to_tsvector('english'::regconfig, (job_description)::text) @@
-- '''letter'' & ''credit'''::tsquery)
--          Filter: is_active
--          Heap Blocks: exact=1
--          ->  Bitmap Index Scan on vacancy_jd_idx  (cost=0.00..36.19 rows=25 width=0) (
-- actual time=0.096..0.096 rows=1 loops=1)
--                Index Cond: (to_tsvector('english'::regconfig, (job_description)::text)
--  @@ '''letter'' & ''credit'''::tsquery)
--    ->  Index Scan using company_pkey on company  (cost=0.29..8.31 rows=1 width=16) (ac
-- tual time=0.007..0.007 rows=1 loops=1)
--          Index Cond: (company_id = vacancy.company_id)
--  Planning time: 0.409 ms
--  Execution time: 0.172 ms
-- (11 rows)
-- Запрос значательно улучшился


-- I want to get some more information about skill required
EXPLAIN ANALYZE SELECT skill.skill_name, vacancy_skill_set.skill_level
    FROM vacancy_skill_set
    JOIN skill USING(skill_id)
    JOIN vacancy USING(vacancy_id)
        WHERE vacancy.vacancy_id = 2;

-- Gather  (cost=1000.72..11627.30 rows=2 width=14) (actual time=0.592..80.818 row
-- s=1 loops=1)
--   Workers Planned: 2
--   Workers Launched: 2
--   ->  Nested Loop  (cost=0.72..10627.10 rows=1 width=14) (actual time=41.115..6
-- 6.780 rows=0 loops=3)
--         ->  Nested Loop  (cost=0.29..10622.64 rows=1 width=18) (actual time=41.
-- 104..66.768 rows=0 loops=3)
--               ->  Parallel Seq Scan on vacancy_skill_set  (cost=0.00..10614.33
-- rows=1 width=12) (actual time=41.097..66.761 rows=0 loops=3)
--                     Filter: (vacancy_id = 2)
--                     Rows Removed by Filter: 333333
--               ->  Index Scan using skill_pkey on skill  (cost=0.29..8.31 rows=1
-- width=14) (actual time=0.013..0.013 rows=1 loops=1)
--                     Index Cond: (skill_id = vacancy_skill_set.skill_id)
--         ->  Index Only Scan using vacancy_pkey on vacancy  (cost=0.42..4.44 row
-- s=1 width=4) (actual time=0.029..0.031 rows=1 loops=1)
--               Index Cond: (vacancy_id = 2)
--               Heap Fetches: 0
-- Planning time: 4.176 ms
-- Execution time: 80.890 ms
-- (15 rows)
-- Запрос неэффективен из-за Seq Scan on vacancy_skill_set. Добавим индекс
-- по полю vacancy_id
CREATE INDEX ON vacancy_skill_set(vacancy_id);
VACUUM ANALYZE vacancy_skill_set;
-- Результаты повторного запроса значительно лучше:
-- Nested Loop  (cost=1.14..29.54 rows=2 width=14) (actual time=0.109..0.113 rows=
-- 1 loops=1)
--   ->  Index Only Scan using vacancy_pkey on vacancy  (cost=0.42..4.44 rows=1 wi
-- dth=4) (actual time=0.021..0.023 rows=1 loops=1)
--         Index Cond: (vacancy_id = 2)
--         Heap Fetches: 0
--   ->  Nested Loop  (cost=0.72..25.08 rows=2 width=18) (actual time=0.083..0.086
-- rows=1 loops=1)
--         ->  Index Scan using vacancy_skill_set_vacancy_id_idx on vacancy_skill_
-- set  (cost=0.42..8.46 rows=2 width=12) (actual time=0.067..0.069 rows=1 loops=1)
--               Index Cond: (vacancy_id = 2)
--         ->  Index Scan using skill_pkey on skill  (cost=0.29..8.31 rows=1 width
-- =14) (actual time=0.010..0.010 rows=1 loops=1)
--               Index Cond: (skill_id = vacancy_skill_set.skill_id)
-- Planning time: 1.234 ms
-- Execution time: 0.196 ms



-- Vacancy and skill are satisfactory and I make a response
INSERT INTO respond(vacancy_id, resume_id, apply_date, message, is_watched)
    VALUES
        (2, 6, now(), 'Hello, my name is Ivan. Please consider my resume', false);

-- Check whether it appears in respond table
EXPLAIN ANALYZE SELECT respond.is_watched
        FROM respond
        WHERE vacancy_id = 2 AND resume_id = 6;

-- Employer read respond
UPDATE respond
    SET is_watched = true
    WHERE vacancy_id = 2 AND resume_id = 6;

-- Check whether status of respond has changed
SELECT respond.is_watched
        FROM respond
        WHERE vacancy_id = 2 AND resume_id = 6;
--  Index Scan using respond_pkey on respond  (cost=0.43..8.46 rows=1 width=1) (act
-- ual time=0.983..0.983 rows=0 loops=1)
--    Index Cond: ((vacancy_id = 2) AND (resume_id = 6))
--  Planning time: 0.888 ms
--  Execution time: 1.055 ms
-- Достаточно быстрый Index Scan.


-- I receive invitation for interview
INSERT INTO invitation(vacancy_id, resume_id, meeting_time, message, is_watched, invitation_time)
    VALUES
        (2, 6, now() + interval '12 hours',
         'Hello, your resume is suitable for us, please confirm meeting',
         false, now());

-- Check occurence of new invitation
EXPLAIN ANALYZE SELECT inv.resume_id, inv.vacancy_id, inv.is_watched
    FROM invitation inv
    where inv.meeting_time = (SELECT max(meeting_time) from invitation);
--  Seq Scan on invitation inv  (cost=166720.85..405358.55 rows=9990 width=9) (actu
-- al time=3962.049..5620.206 rows=4947 loops=1)
--    Filter: (meeting_time = $1)
--    Rows Removed by Filter: 9995037
--    InitPlan 1 (returns $1)
--      ->  Finalize Aggregate  (cost=166720.84..166720.85 rows=1 width=8) (actual
-- time=3958.349..3958.350 rows=1 loops=1)
--            ->  Gather  (cost=166720.62..166720.84 rows=2 width=8) (actual time=3
-- 958.261..3958.430 rows=3 loops=1)
--                  Workers Planned: 2
--                  Workers Launched: 2
--                  ->  Partial Aggregate  (cost=165720.62..165720.64 rows=1 width=
-- 8) (actual time=3945.267..3945.267 rows=1 loops=3)
--                        ->  Parallel Seq Scan on invitation  (cost=0.00..155303.9
-- 0 rows=4166690 width=8) (actual time=0.080..3117.861 rows=3333328 loops=3)
--  Planning time: 1.563 ms
--  Execution time: 5621.159 ms
-- (12 rows)
-- Запрос не эффективен. Добавим индекс на поле meeting_time
CREATE INDEX inv_mt_idx ON ivitation(meeting_time);
-- Результат значительно улучшился
-- Bitmap Heap Scan on invitation inv  (cost=190.38..30263.63 rows=9990 width=9) (actual
-- time=5.291..314.590 rows=4964 loops=1)
--   Recheck Cond: (meeting_time = $1)
--   Heap Blocks: exact=4854
--   InitPlan 2 (returns $1)
--     ->  Result  (cost=0.51..0.52 rows=1 width=8) (actual time=0.141..0.142 rows=1 loo
-- ps=1)
--           InitPlan 1 (returns $0)
--             ->  Limit  (cost=0.43..0.51 rows=1 width=8) (actual time=0.134..0.136 row
-- s=1 loops=1)
--                   ->  Index Only Scan Backward using inv_mt_idx on invitation  (cost=
-- 0.43..739226.83 rows=9999983 width=8) (actual time=0.132..0.132 rows=1 loops=1)
--                         Index Cond: (meeting_time IS NOT NULL)
--                         Heap Fetches: 1
--   ->  Bitmap Index Scan on inv_mt_idx  (cost=0.00..187.36 rows=9990 width=0) (actual
-- time=2.778..2.778 rows=4964 loops=1)
--         Index Cond: (meeting_time = $1)
-- Planning time: 0.434 ms
-- Execution time: 315.444 ms

-- I have accepted invitation
UPDATE respond
    SET is_watched = true
    WHERE vacancy_id = 2 AND resume_id = 6;

-- I was employed
-- Vacancy status was set as unactive
UPDATE vacancy
    SET is_active = false
        WHERE vacancy_id = 2;

EXPLAIN ANALYZE SELECT vacancy_id, is_active
    FROM vacancy
    WHERE vacancy_id = 2;
--  Index Scan using vacancy_pkey on vacancy  (cost=0.42..8.44 rows=1 width=5) (act
-- ual time=0.048..0.051 rows=1 loops=1)
--    Index Cond: (vacancy_id = 2)
--  Planning time: 0.385 ms
--  Execution time: 0.122 ms
-- (4 rows)
-- Эффективно


-- I have change status of my resume to unactive
UPDATE resume
    SET is_active = false
        WHERE resume_id = 6;

EXPLAIN ANALYZE SELECT resume_id, is_active
    FROM resume
        WHERE resume_id = 6;
--  Index Scan using resume_pkey on resume  (cost=0.43..8.45 rows=1 width=5) (actua
-- l time=0.165..0.167 rows=1 loops=1)
--    Index Cond: (resume_id = 6)
--  Planning time: 0.319 ms
--  Execution time: 0.218 ms
-- (4 rows)
-- Эффективно

-- I want to change this job and start a new search
-- This time I will search on skills and salary
EXPLAIN ANALYZE SELECT vacancy.vacancy_id, company.company_name, vacancy_skill_set.skill_id
    FROM vacancy
    JOIN company USING (company_id)
    JOIN vacancy_skill_set USING(vacancy_id)
    JOIN resume_skill_set USING (skill_id)
        WHERE resume_skill_set.resume_id = 100005
        AND vacancy.max_salary < 600000
        AND vacancy.min_salary >= 20000
        AND vacancy.is_active = true;

-- Gather  (cost=1371.42..11415.64 rows=6130 width=19) (actual time=18.411..140.874 rows=1985 loops=1)
-- Workers Planned: 2
-- Workers Launched: 2
-- ->  Hash Join  (cost=371.42..9802.64 rows=2554 width=19) (actual time=15.408..122.850 rows=662 loops=3)
-- Hash Cond: (vacancy.company_id = company.company_id)
-- ->  Nested Loop  (cost=12.30..9436.82 rows=2554 width=12) (actual time=0.589..107.366 rows=662 loops=3)
-- ->  Hash Join  (cost=12.01..8408.74 rows=3181 width=8) (actual time=0.474..101.136 rows=826 loops=3)
-- Hash Cond: (vacancy_skill_set.skill_id = resume_skill_set.skill_id)
-- ->  Parallel Seq Scan on vacancy_skill_set  (cost=0.00..7523.94 rows=327494 width=8) (actual time=0.025..48.395 rows=261995 loops=3)
-- ->  Hash  (cost=11.97..11.97 rows=3 width=4) (actual time=0.077..0.077 rows=2 loops=3)
-- Buckets: 1024  Batches: 1  Memory Usage: 9kB
-- ->  Index Only Scan using resume_skill_set_pkey on resume_skill_set  (cost=0.42..11.97 rows=3 width=4) (actual time=0.063..0.067 rows=2 loops=3)
-- Index Cond: (resume_id = 100005)
-- Heap Fetches: 2
-- ->  Index Scan using vacancy_pkey on vacancy  (cost=0.29..0.32 rows=1 width=8) (actual time=0.006..0.006 rows=1 loops=2478)
-- Index Cond: (vacancy_id = vacancy_skill_set.vacancy_id)
-- Filter: (is_active AND (max_salary < 600000) AND (min_salary >= 20000))
-- Rows Removed by Filter: 0
-- ->  Hash  (cost=234.05..234.05 rows=10005 width=15) (actual time=14.696..14.696 rows=10005 loops=3)
-- Buckets: 16384  Batches: 1  Memory Usage: 598kB
-- ->  Seq Scan on company  (cost=0.00..234.05 rows=10005 width=15) (actual time=0.041..5.984 rows=10005 loops=3)
-- Planning time: 1.901 ms
-- Execution time: 141.225 ms

-- Запрос выполнен не очень эффективно, это связано с очень селективным использованием индекса skill_id в
-- таблицах resume_skill_set и vacancy_skill_set. Возможно нет смысла в индексировании
-- данных полей. Попробуем удалить данные индексы и снова запустить запрос.
ALTER TABLE resume_skill_set DROP CONSTRAINT resume_skill_set_pkey;
ALTER TABLE vacancy_skill_set DROP CONSTRAINT vacancy_skill_set_pkey;
ALTER TABLE resume_skill_set ADD CONSTRAINT resume_skill_set_unique UNIQUE(resume_id, skill_id);
ALTER TABLE vacancy_skill_set ADD CONSTRAINT vacancy_skill_set_unique UNIQUE(vacancy_id, skill_id);

-- Gather  (cost=1371.42..11415.64 rows=6130 width=19) (actual time=11.787..144.337 rows=1985 loops=1)
--   Workers Planned: 2
--   Workers Launched: 2
--   ->  Hash Join  (cost=371.42..9802.64 rows=2554 width=19) (actual time=16.203..128.310 rows=662 loops=3)
--         Hash Cond: (vacancy.company_id = company.company_id)
--         ->  Nested Loop  (cost=12.30..9436.82 rows=2554 width=12) (actual time=0.472..111.880 rows=662 loops=3)
--               ->  Hash Join  (cost=12.01..8408.74 rows=3181 width=8) (actual time=0.419..105.149 rows=826 loops=3)
--                     Hash Cond: (vacancy_skill_set.skill_id = resume_skill_set.skill_id)
--                     ->  Parallel Seq Scan on vacancy_skill_set  (cost=0.00..7523.94 rows=327494 width=8) (actual time=0.027..49.530 rows=261995 loops=3)
--                     ->  Hash  (cost=11.97..11.97 rows=3 width=4) (actual time=0.069..0.069 rows=2 loops=3)
--                           Buckets: 1024  Batches: 1  Memory Usage: 9kB
--                           ->  Index Only Scan using resume_skill_set_unique on resume_skill_set  (cost=0.42..11.97 rows=3 width=4) (actual time=0.057..0.060 rows=2 loops=
-- 3)
--                                 Index Cond: (resume_id = 100005)
--                                 Heap Fetches: 2
--               ->  Index Scan using vacancy_pkey on vacancy  (cost=0.29..0.32 rows=1 width=8) (actual time=0.007..0.007 rows=1 loops=2478)
--                     Index Cond: (vacancy_id = vacancy_skill_set.vacancy_id)
--                     Filter: (is_active AND (max_salary < 600000) AND (min_salary >= 20000))
--                     Rows Removed by Filter: 0
--         ->  Hash  (cost=234.05..234.05 rows=10005 width=15) (actual time=13.957..13.957 rows=10005 loops=3)
--               Buckets: 16384  Batches: 1  Memory Usage: 598kB
--               ->  Seq Scan on company  (cost=0.00..234.05 rows=10005 width=15) (actual time=0.048..4.881 rows=10005 loops=3)
-- Planning time: 1.719 ms
-- Execution time: 144.680 ms
-- (23 rows)

-- Запрос выполнился за то же время, соответственно, возможно не имеет смысла
-- создавать индексы на данные поля в таблицах





-- I check whether I've got new invitations
EXPLAIN ANALYZE SELECT vacancy_id
    FROM invitation
        WHERE is_watched = false AND resume_id = 100006;
--  Index Scan using invitation_pkey on invitation  (cost=0.43..32.56 rows=3 width=
-- 4) (actual time=0.152..0.152 rows=0 loops=1)
--    Index Cond: (resume_id = 100006)
--    Filter: (NOT is_watched)
--    Rows Removed by Filter: 5
--  Planning time: 0.193 ms
--  Execution time: 0.192 ms
-- (6 rows)
-- Запрос эффективен


-- An employer check whether it has received new responds on their vacancy
EXPLAIN ANALYZE SELECT resume_id
    FROM respond
        WHERE is_watched = false and vacancy_id = 4;
--  Index Scan using respond_pkey on respond  (cost=0.43..48.63 rows=6 width=4) (ac
-- tual time=0.482..0.482 rows=0 loops=1)
--    Index Cond: (vacancy_id = 4)
--    Filter: (NOT is_watched)
--    Rows Removed by Filter: 2
--  Planning time: 0.188 ms
--  Execution time: 0.536 ms
-- (6 rows)
-- ОК


-- I fetch list of my resumes with  quantity of invitations
EXPLAIN ANALYZE SELECT account_id, resume.resume_id, count(invitation.vacancy_id)
    FROM resume
    LEFT JOIN invitation USING(resume_id)
    WHERE account_id = 100033
    GROUP BY account_id, resume_id;
   --  GroupAggregate  (cost=9.13..9.18 rows=1 width=20) (actual time=0.095..0.098 row
   -- s=2 loops=1)
   --    Group Key: resume.resume_id
   --    ->  Sort  (cost=9.13..9.14 rows=5 width=12) (actual time=0.087..0.088 rows=2
   -- loops=1)
   --          Sort Key: resume.resume_id
   --          Sort Method: quicksort  Memory: 25kB
   --          ->  Nested Loop Left Join  (cost=0.86..9.07 rows=5 width=12) (actual ti
   -- me=0.046..0.067 rows=2 loops=1)
   --                ->  Index Scan using resume_account_id_idx on resume  (cost=0.43.
   -- .4.45 rows=1 width=8) (actual time=0.025..0.032 rows=2 loops=1)
   --                      Index Cond: (account_id = 100033)
   --                ->  Index Only Scan using invitation_pkey on invitation  (cost=0.
   -- 43..4.56 rows=7 width=8) (actual time=0.011..0.011 rows=0 loops=2)
   --                      Index Cond: (resume_id = resume.resume_id)
   --                      Heap Fetches: 0
   --  Planning time: 0.926 ms
   --  Execution time: 0.210 ms
   -- (13 rows)
   -- OK



-- I fetch list of my resumes indicating quanity of new invitations
EXPLAIN ANALYZE SELECT account_id, resume.resume_id, invitation.is_watched, count(invitation.vacancy_id)
    FROM resume
    LEFT JOIN invitation USING(resume_id)
    WHERE account_id = 100033
    GROUP BY account_id, resume_id, is_watched
    HAVING is_watched = false;
--     GroupAggregate  (cost=37.04..37.08 rows=2 width=22) (actual time=0.067..0.068 r
-- ows=0 loops=1)
--   Group Key: resume.resume_id, invitation.is_watched
--   ->  Sort  (cost=37.04..37.05 rows=2 width=13) (actual time=0.065..0.065 rows=
-- 0 loops=1)
--         Sort Key: resume.resume_id, invitation.is_watched
--         Sort Method: quicksort  Memory: 25kB
--         ->  Nested Loop  (cost=0.86..37.03 rows=2 width=13) (actual time=0.050.
-- .0.050 rows=0 loops=1)
--               ->  Index Scan using resume_account_id_idx on resume  (cost=0.43.
-- .4.45 rows=1 width=8) (actual time=0.022..0.026 rows=2 loops=1)
--                     Index Cond: (account_id = 100033)
--               ->  Index Scan using invitation_pkey on invitation  (cost=0.43..3
-- 2.56 rows=3 width=9) (actual time=0.008..0.008 rows=0 loops=2)
--                     Index Cond: (resume_id = resume.resume_id)
--                     Filter: (NOT is_watched)
-- Planning time: 0.849 ms
-- Execution time: 0.182 ms
-- (13 rows)
-- OK





-- Employer fetch list of its vacancies with quantity of all responds
EXPLAIN ANALYZE SELECT posted_by_id, vacancy.vacancy_id, count(respond.resume_id)
    FROM vacancy
    LEFT JOIN respond USING(vacancy_id)
    WHERE posted_by_id = 11
    GROUP BY posted_by_id, vacancy_id;
--     Finalize GroupAggregate  (cost=21508.34..21511.56 rows=11 width=20) (actual tim
-- e=93.795..93.802 rows=2 loops=1)
--   Group Key: vacancy.vacancy_id
--   ->  Gather Merge  (cost=21508.34..21511.34 rows=22 width=16) (actual time=93.
-- 777..99.717 rows=2 loops=1)
--         Workers Planned: 2
--         Workers Launched: 2
--         ->  Partial GroupAggregate  (cost=20508.32..20508.77 rows=11 width=16)
-- (actual time=83.091..83.092 rows=1 loops=3)
--               Group Key: vacancy.vacancy_id
--               ->  Sort  (cost=20508.32..20508.43 rows=46 width=12) (actual time
-- =83.085..83.085 rows=1 loops=3)
--                     Sort Key: vacancy.vacancy_id
--                     Sort Method: quicksort  Memory: 25kB
--                     ->  Nested Loop Left Join  (cost=0.43..20507.05 rows=46 wid
-- th=12) (actual time=81.566..83.030 rows=1 loops=3)
--                           ->  Parallel Seq Scan on vacancy  (cost=0.00..20483.3
-- 6 rows=5 width=8) (actual time=81.541..83.002 rows=1 loops=3)
--                                 Filter: (posted_by_id = 11)
--                                 Rows Removed by Filter: 333334
--                           ->  Index Only Scan using respond_pkey on respond  (c
-- ost=0.43..4.63 rows=11 width=8) (actual time=0.033..0.035 rows=2 loops=2)
--                                 Index Cond: (vacancy_id = vacancy.vacancy_id)
--                                 Heap Fetches: 0
-- Planning time: 3.430 ms
-- Execution time: 99.861 ms
-- Запрос неэффективен из-за ->  Parallel Seq Scan on vacancy  (cost=0.00..20483.3
-- 6 rows=5 width=8) (actual time=81.541..83.002 rows=1 loops=3)
CREATE INDEX ON vacancy(posted_by_id);
VACUUM ANALYZE vacancy;
-- -- Результаты повторного запроса на порядок лучше
--  HashAggregate  (cost=100.42..100.53 rows=11 width=20) (actual time=0.195..0.197
--  rows=2 loops=1)
--    Group Key: vacancy.vacancy_id
--    ->  Nested Loop Left Join  (cost=4.95..99.87 rows=110 width=12) (actual time=
-- 0.139..0.169 rows=4 loops=1)
--          ->  Bitmap Heap Scan on vacancy  (cost=4.51..47.76 rows=11 width=8) (ac
-- tual time=0.081..0.084 rows=2 loops=1)
--                Recheck Cond: (posted_by_id = 11)
--                Heap Blocks: exact=1
--                ->  Bitmap Index Scan on vacancy_posted_by_id_idx  (cost=0.00..4.
-- 51 rows=11 width=0) (actual time=0.071..0.071 rows=2 loops=1)
--                      Index Cond: (posted_by_id = 11)
--          ->  Index Only Scan using respond_pkey on respond  (cost=0.43..4.63 row
-- s=11 width=8) (actual time=0.031..0.034 rows=2 loops=2)
--                Index Cond: (vacancy_id = vacancy.vacancy_id)
--                Heap Fetches: 0
--  Planning time: 1.150 ms
--  Execution time: 0.338 ms
-- (13 rows)

-- Employer fetch list of vacancies with quantity of new responsed
EXPLAIN ANALYZE SELECT posted_by_id, vacancy.vacancy_id, respond.is_watched, count(respond.resume_id)
    FROM vacancy
    LEFT JOIN respond USING(vacancy_id)
    WHERE posted_by_id = 11
    GROUP BY posted_by_id, vacancy_id, is_watched
    HAVING is_watched = false;
   --  GroupAggregate  (cost=584.91..585.68 rows=22 width=22) (actual time=0.118..0.11
   -- 8 rows=1 loops=1)
   --    Group Key: vacancy.vacancy_id, respond.is_watched
   --    ->  Sort  (cost=584.91..585.05 rows=55 width=13) (actual time=0.109..0.110 ro
   -- ws=1 loops=1)
   --          Sort Key: vacancy.vacancy_id, respond.is_watched
   --          Sort Method: quicksort  Memory: 25kB
   --          ->  Nested Loop  (cost=4.95..583.32 rows=55 width=13) (actual time=0.08
   -- 3..0.087 rows=1 loops=1)
   --                ->  Bitmap Heap Scan on vacancy  (cost=4.51..47.76 rows=11 width=
   -- 8) (actual time=0.034..0.037 rows=2 loops=1)
   --                      Recheck Cond: (posted_by_id = 11)
   --                      Heap Blocks: exact=1
   --                      ->  Bitmap Index Scan on vacancy_posted_by_id_idx  (cost=0.
   -- 00..4.51 rows=11 width=0) (actual time=0.024..0.024 rows=2 loops=1)
   --                            Index Cond: (posted_by_id = 11)
   --                ->  Index Scan using respond_pkey on respond  (cost=0.43..48.63 r
   -- ows=6 width=9) (actual time=0.018..0.020 rows=0 loops=2)
   --                      Index Cond: (vacancy_id = vacancy.vacancy_id)
   --                      Filter: (NOT is_watched)
   --                      Rows Removed by Filter: 2
   --  Planning time: 0.741 ms
   --  Execution time: 0.263 ms
   -- ОК


-- I fetch quantity of new invitations for all my resumes
EXPLAIN ANALYZE SELECT COUNT(invitation.is_watched), resume.resume_id
    FROM resume
    LEFT JOIN invitation USING (resume_id)
    JOIN account USING (account_id)
    WHERE account_id = 100033
    GROUP BY resume.resume_id;
    --HAVING invitation.is_watched = false;
--     GroupAggregate  (cost=41.45..41.50 rows=1 width=12) (actual time=0.113..0.116 r
-- ows=2 loops=1)
--    Group Key: resume.resume_id
--    ->  Sort  (cost=41.45..41.46 rows=5 width=5) (actual time=0.103..0.104 rows=2
--  loops=1)
--          Sort Key: resume.resume_id
--          Sort Method: quicksort  Memory: 25kB
--          ->  Nested Loop Left Join  (cost=1.16..41.39 rows=5 width=5) (actual ti
-- me=0.060..0.084 rows=2 loops=1)
--                ->  Nested Loop  (cost=0.72..8.77 rows=1 width=4) (actual time=0.
-- 045..0.061 rows=2 loops=1)
--                      ->  Index Scan using resume_account_id_idx on resume  (cost
-- =0.43..4.45 rows=1 width=8) (actual time=0.027..0.033 rows=2 loops=1)
--                            Index Cond: (account_id = 100033)
--                      ->  Index Only Scan using account_pkey on account  (cost=0.
-- 29..4.31 rows=1 width=4) (actual time=0.010..0.011 rows=1 loops=2)
--                            Index Cond: (account_id = 100033)
--                            Heap Fetches: 0
--                ->  Index Scan using invitation_pkey on invitation  (cost=0.43..3
-- 2.56 rows=7 width=5) (actual time=0.008..0.008 rows=0 loops=2)
--                      Index Cond: (resume.resume_id = resume_id)
--  Planning time: 1.044 ms
--  Execution time: 0.242 ms
-- (16 rows)
-- OK


-- I make my resume active
UPDATE resume
    SET is_active = true
        WHERE resume_id = 6;

-- And send respond to the found vacancy
INSERT INTO respond(vacancy_id, resume_id, apply_date, message, is_watched)
    VALUES
        (4, 6, now(), 'Hello, my name is Ivan. Please consider my resume', false);

-- Employer has read my respond
UPDATE respond
    SET is_watched = true
        WHERE vacancy_id = 4 AND resume_id = 6;

-- It has sent me a message with additional question about my current occupation
INSERT INTO message (vacancy_id, resume_id, message_time, message, is_watched)
    VALUES
        (4, 6, '2019-01-11 09:00:00', 'Please explain your current occupation', false);

-- I have read this message
UPDATE message
    SET is_watched = true
        WHERE vacancy_id = 4 AND resume_id = 6 AND message_time = '2019-01-11 09:00:00';

-- Employer check whether he has new responds on its vacancy
EXPLAIN ANALYZE SELECT resume_id
    FROM respond
        WHERE vacancy_id = 4 AND is_watched = false;
--          Index Scan using respond_pkey on respond  (cost=0.43..48.63 rows=6 width=4) (ac
-- tual time=0.045..0.045 rows=0 loops=1)
--    Index Cond: (vacancy_id = 4)
--    Filter: (NOT is_watched)
--    Rows Removed by Filter: 2
--  Planning time: 0.197 ms
--  Execution time: 0.090 ms
-- (6 rows)
-- OK


-- Partly it was so because these employer has already find a better candidate
-- for less money.
EXPLAIN ANALYZE SELECT resume.resume_id
    FROM resume
    JOIN resume_skill_set rss USING(resume_id)
    JOIN vacancy_skill_set vss USING(skill_id)
        WHERE vacancy_id = 4
        AND
            resume.is_active=true
        AND
            resume.max_salary < 60000;
--  Gather  (cost=1008.91..11680.51 rows=3 width=4) (actual time=1.003..209.481 row
-- s=1 loops=1)
--    Workers Planned: 2
--    Workers Launched: 2
--    ->  Nested Loop  (cost=8.91..10680.21 rows=1 width=4) (actual time=123.660..1
-- 92.189 rows=0 loops=3)
--          ->  Hash Join  (cost=8.49..10674.96 rows=9 width=4) (actual time=123.63
-- 8..192.154 rows=1 loops=3)
--                Hash Cond: (rss.skill_id = vss.skill_id)
--                ->  Parallel Seq Scan on resume_skill_set rss  (cost=0.00..9572.6
-- 8 rows=416668 width=8) (actual time=0.059..102.796 rows=333334 loops=3)
--                ->  Hash  (cost=8.46..8.46 rows=2 width=4) (actual time=0.072..0.
-- 072 rows=1 loops=3)
--                      Buckets: 1024  Batches: 1  Memory Usage: 9kB
--                      ->  Index Scan using vacancy_skill_set_vacancy_id_idx on va
-- cancy_skill_set vss  (cost=0.42..8.46 rows=2 width=4) (actual time=0.053..0.055
-- rows=1 loops=3)
--                            Index Cond: (vacancy_id = 4)
--          ->  Index Scan using resume_pkey on resume  (cost=0.43..0.58 rows=1 wid
-- th=4) (actual time=0.019..0.019 rows=0 loops=3)
--                Index Cond: (resume_id = rss.resume_id)
--                Filter: (is_active AND (max_salary < 60000))
--                Rows Removed by Filter: 1
--  Planning time: 3.147 ms
--  Execution time: 209.586 ms
-- Запрос неэффективен в части --->  Parallel Seq Scan on resume_skill_set rss  (cost=0.00..9572.6
-- 8 rows=416668 width=8) (actual time=0.059..102.796 rows=333334 loops=3)
-- Попытаемся поправить, добавив индекс
CREATE INDEX ON resume_skill_set(skill_id);
VACUUM ANALYZE resume_skill_set;
-- Nested Loop  (cost=5.36..115.83 rows=3 width=4) (actual time=0.068..0.109 rows=
-- 1 loops=1)
--   ->  Nested Loop  (cost=4.94..103.00 rows=22 width=4) (actual time=0.051..0.05
-- 6 rows=3 loops=1)
--         ->  Index Scan using vacancy_skill_set_vacancy_id_idx on vacancy_skill_
-- set vss  (cost=0.42..8.46 rows=2 width=4) (actual time=0.022..0.023 rows=1 loops
-- =1)
--               Index Cond: (vacancy_id = 4)
--         ->  Bitmap Heap Scan on resume_skill_set rss  (cost=4.51..47.16 rows=11
-- width=8) (actual time=0.021..0.023 rows=3 loops=1)
--               Recheck Cond: (skill_id = vss.skill_id)
--               Heap Blocks: exact=1
--               ->  Bitmap Index Scan on resume_skill_set_skill_id_idx  (cost=0.0
-- 0..4.51 rows=11 width=0) (actual time=0.012..0.012 rows=3 loops=1)
--                     Index Cond: (skill_id = vss.skill_id)
--   ->  Index Scan using resume_pkey on resume  (cost=0.43..0.58 rows=1 width=4)
-- (actual time=0.015..0.015 rows=0 loops=3)
--         Index Cond: (resume_id = rss.resume_id)
--         Filter: (is_active AND (max_salary < 60000))
--         Rows Removed by Filter: 1
-- Planning time: 2.431 ms
-- Execution time: 0.208 ms
-- (15 rows)
-- Хорошо




-- After hiring of this candiate emloyer has changed the status of this vacancy
-- to unactive
UPDATE vacancy
    SET is_active = false
        WHERE vacancy_id = 4;

-- Hired employee makes his resume unactive
UPDATE resume
    SET is_active = false
        WHERE resume_id = 1;

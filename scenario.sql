-- I want to find a job (sorry, no money left :( ) 
-- I create a user account in database
INSERT INTO users (user_type_id, login, password, email, is_active,
    registration_date, last_login_date) 
        VALUES
            (1, 'ivanov_ivan', crypt('ivanov_password', gen_salt('bf')),
                'ivanov_ivan@mail.ru', true, now(), now());

-- Verify that account was createad
SELECT id, login, email, registration_date, is_active FROM users WHERE login = 'ivanov_ivan';

-- I create a resume
INSERT INTO resumes(users_id, first_name, middle_name, last_name, min_salary, max_salary, currency, age)
    SELECT id, 'Ivan', 'Ivanovich', 'Ivanov', 40000, 60000, 'RUB', 35
       FROM users WHERE login = 'ivanov_ivan';

-- Check whether resume is in database
SELECT * FROM resumes;

-- Indicate my education
INSERT INTO educations (resumes_id, course_name, start_date, end_date, description)
    VALUES
        (6, 'BSEU', '2001-09-01', '2005-06-30', 'Higher Education - Banking Department'),
        (6, 'BSEU', '2006-09-01', '2007-06-30', 'Magistr Degrees - Banking Department');

-- Indicate my working experience
INSERT INTO experience_details(resumes_id, start_date, is_current_job, end_date, job_title, company_name, description, job_location_id)
    VALUES
        (6, '2005-04-30', false, '2008-07-30', 'Head Economist Currency Control Dept', 'ASB Belarusbank', 'Currency Control', 1),
        (6, '2008-11-15', false, '2017-10-15', 'Managing Expert', 'JSC Promsvyazbank', 'Letters of Credit', 2);

-- Indicate my skills
INSERT INTO resume_skills_set(resumes_id, skills_id, skill_level)
    VALUES
       (6, 1, 10),
       (6, 2, 4);

-- I search vacancies that are suitable for me
SELECT * from vacancies, companies
    WHERE lower(job_description) LIKE '%letter of credit%' 
        AND vacancies.companies_id = companies.id;

-- I want to get some more information about skills required 
SELECT skills.skill_name, vskl.skill_level FROM vacancy_skills_set vskl
    JOIN skills ON vskl.skills_id = skills.id
    JOIN vacancies vcns ON vskl.vacancies_id = vcns.id
        WHERE vcns.id in (SELECT vacancies.id FROM vacancies WHERE lower(job_description) LIKE '%letter of credit%');

-- Vacancy and skills are satisfactory and I make a response 
INSERT INTO responds(vacancies_id, resumes_id, apply_date, message, communication_status_id)
    VALUES
        (2, 6, now(), 'Hello, my name is Ivan. Please consider my resume', 1);

-- Check whether it appears in responds table
SELECT responds.*, communication_status.status_name 
        FROM responds
        JOIN communication_status
        ON responds.communication_status_id = communication_status.id
        WHERE vacancies_id = 2 AND resumes_id = 6;

-- Employer read respond 
UPDATE responds
    SET communication_status_id = 3
    WHERE vacancies_id = 2 AND resumes_id = 6;

-- Check whether status of respond has changed
SELECT responds.*, communication_status.status_name 
        FROM responds
        JOIN communication_status
        ON responds.communication_status_id = communication_status.id
        WHERE vacancies_id = 2 AND resumes_id = 6;

-- I receive invitation for interview
INSERT INTO invitations(vacancies_id, resumes_id, meeting_time, message, communication_status_id)
    VALUES
        (2, 6, now() + interval '12 hours', 'Hello, your resume is suitable for us, please confirm meeting', 1);

-- Check occurence of new invitation
SELECT * FROM invitations
    where invitations.meeting_time = (SELECT max(meeting_time) from invitations);

-- I have accepted invitation 
UPDATE responds
    SET communication_status_id = 3
    WHERE vacancies_id = 2 AND resumes_id = 6;

-- I was employed
-- Vacancy status was set as archieved
UPDATE vacancies
    SET statuses_id = 3
        WHERE id = 2;

SELECT s.name, v.id
    FROM statuses s, vacancies v
    WHERE v.id = 2 AND v.statuses_id = s.id;

-- I have change status of my resume to 'Hidden'
UPDATE resumes
    SET statuses_id = 2
        WHERE id = 6;

SELECT id, statuses_id
    FROM resumes
        WHERE id = 6;

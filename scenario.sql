-- I want to find a job (sorry, no money left :( ) 
-- I create a users account in database
INSERT INTO users (type_of_user, login, password, email, is_active,
    registration_date, last_login_date) 
        VALUES
            ('seeker', 'ivanov_ivan', crypt('ivanov_password', gen_salt('bf')),
                'ivanov_ivan@mail.ru', true, now(), now());

-- Verify that account was createad
SELECT users_id, login, email, registration_date, is_active FROM users WHERE login = 'ivanov_ivan';

-- I create a resume
INSERT INTO resume(users_id, first_name, middle_name, last_name, min_salary, max_salary, currency, age)
    SELECT users_id, 'Ivan', 'Ivanovich', 'Ivanov', 40000, 60000, 'RUB', 35
       FROM users WHERE login = 'ivanov_ivan';

-- Check whether resume is in database
SELECT * FROM resume;

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

-- I search vacancy that are suitable for me
SELECT * from vacancy, company
    WHERE lower(job_description) LIKE '%letter of credit%' 
        AND vacancy.company_id = company.company_id;

-- I want to get some more information about skill required 
SELECT skill.skill_name, vskl.skill_level FROM vacancy_skill_set vskl
    JOIN skill ON vskl.skill_id = skill.skill_id
    JOIN vacancy vcns ON vskl.vacancy_id = vcns.vacancy_id
        WHERE vcns.vacancy_id in (SELECT vacancy.vacancy_id FROM vacancy WHERE lower(job_description) LIKE '%letter of credit%');

-- Vacancy and skill are satisfactory and I make a response 
INSERT INTO respond(vacancy_id, resume_id, apply_date, message, current_communication_status)
    VALUES
        (2, 6, now(), 'Hello, my name is Ivan. Please consider my resume', 'RECEIVED');

-- Check whether it appears in respond table
SELECT respond.current_communication_status 
        FROM respond
        WHERE vacancy_id = 2 AND resume_id = 6;

-- Employer read respond 
UPDATE respond
    SET current_communication_status = 'ACCEPTED' 
    WHERE vacancy_id = 2 AND resume_id = 6;

-- Check whether status of respond has changed
SELECT respond.current_communication_status
        FROM respond
        WHERE vacancy_id = 2 AND resume_id = 6;

-- I receive invitation for interview
INSERT INTO invitation(vacancy_id, resume_id, meeting_time, message, current_communication_status)
    VALUES
        (2, 6, now() + interval '12 hours', 'Hello, your resume is suitable for us, please confirm meeting', 'RECEIVED');

-- Check occurence of new invitation
SELECT * FROM invitation
    where invitation.meeting_time = (SELECT max(meeting_time) from invitation);

-- I have accepted invitation 
UPDATE respond
    SET current_communication_status = 'ACCEPTED'
    WHERE vacancy_id = 2 AND resume_id = 6;

-- I was employed
-- Vacancy status was set as archieved
UPDATE vacancy
    SET current_status = 'Archive'
        WHERE vacancy_id = 2;

SELECT vacancy_id, current_status 
    FROM vacancy 
    WHERE vacancy_id = 2;

-- I have change status of my resume to 'Hidden'
UPDATE resume
    SET current_status = 'Hidden'
        WHERE resume_id = 6;

SELECT resume_id, current_status 
    FROM resume
        WHERE resume_id = 6;

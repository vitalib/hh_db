CREATE EXTENSION pgcrypto;

INSERT INTO account (type_of_user, login, password, email, is_active, 
	registration_date, last_login_date) 
		SELECT 'APPLICANT', 'newseeker' || a.n, 
    		crypt('password'|| a.n, gen_salt('bf')), 
			a.n ||'seeker@mail.ru', true, 
            now() - '1 day':: INTERVAL * ROUND(RANDOM() * 1000 + 1000),
            now() - '1 day':: INTERVAL * ROUND(RANDOM() * 1000)
				FROM generate_series(1, 10) as a(n);

INSERT INTO account (type_of_user, login, password, email, is_active, 
	registration_date, last_login_date) 
		SELECT 'RECRUITER', 'recruiter' || a.n, 
    		crypt('password'|| a.n, gen_salt('bf')), 
			a.n ||'recruiter@mail.ru', true,
            now() - '1 day':: INTERVAL * ROUND(RANDOM() * 1000 + 1000),
            now() - '1 day':: INTERVAL * ROUND(RANDOM() * 1000)
				FROM generate_series(10, 20) as a(n);

INSERT INTO account (type_of_user, login, password, email, is_active, 
	registration_date, last_login_date) 
		SELECT 'HH_AGENCY', 'newagency' || a.n, 
    		crypt('password'|| a.n, gen_salt('bf')), 
			a.n ||'agency@mail.ru', true,
            now() - '1 day':: INTERVAL * ROUND(RANDOM() * 1000 + 1000),
            now() - '1 day':: INTERVAL * ROUND(RANDOM() * 1000) FROM generate_series(20, 30) as a(n);



-- Table: skill
INSERT INTO skill (skill_name)
    VALUES ('letter of credit'), ('currency control'), ('java'), ('python'), ('postgres'), ('javascript'), ('go');


-- Table: job_location

INSERT INTO job_location
    (street_address, city, state, country, zip)
    VALUES
        ('Aerodromnaya, 16', 'Moscow', 'Moscow', 'Russia', '365333'),
        ('Mira, 16', 'Moscow', 'Moscow', 'Russia', '365331'),
        ('Godovikova, 8', 'Moscow', 'Moscow', 'Russia', '364333'),
        ('Smirnovskaya, 15', 'Moscow', 'Moscow', 'Russia', '125363'),
        ('Podemnaya, 15', 'Moscow', 'Moscow', 'Russia', '111111');


-- Table: resume
INSERT INTO resume(account_id, first_name, middle_name, last_name, min_salary, max_salary, currency, birth_date, is_active)
    VALUES
        (1, 'Vitali', 'Grigor''evich', 'Baranov', 40000, 50000, 'RUB', '1983-11-24', true),
        (1, 'Vitali', 'Grigor''evich', 'Baranov', 130000, 220000, 'RUB', '1983-11-24', true),
        (2, 'Egor', 'Konstantinovich', 'Shmelkov', 5000, 6000, 'RUB', '2002-05-12', true),
        (3, 'Ekaterina', 'Nikolaevna', 'Andreeva', 150000, 200000, 'RUB', '1981-06-19', true),
        (4, 'Nikolay', 'Vasil''evich', 'Ivanov', 30000, 45000, 'RUB', '1956-06-12', true);


-- Table: company
INSERT INTO company(company_name, activity_description, creation_date, company_website_url)
    VALUES
        ('JSC Promsvyazbank', 'Banking', '1992-01-02', 'https://www.psbank.ru'),
        ('Company Prog', 'IT', '2005-05-23', 'https://www.companyit.ru'),
        ('JSC New Reasearch', 'Construction', '2015-05-23', 'https://www.builders.ru'),
        ('Tropic JSC', 'Trade, Fruits', '2008-01-23', 'https://www.tropic.ru'),
        ('Flowers', 'Trade, Flowers', '2018-01-23', 'https://www.top_flowers.ru');

-- Table: educations

INSERT INTO education (resume_id, course_name, start_date, end_date, description)
    VALUES
        (1, 'BSEU', '2001-09-01', '2005-06-30', 'Higher Education - Banking Department'),
        (1, 'BSEU', '2006-09-01', '2007-06-30', 'Magist Degrees - Banking Department'),
        (1, 'CDCS', '2009-10-30', '2010-05-15', 'Certfied Documentary Credit Specialist IFS School of London'),
        (4, 'TGU', '2000-09-01', '2004-06-30', 'High Education - Economic Department'),
        (4, 'CSDG', '2010-10-30', '2010-05-15', 'Certfied Specialist for Demant Guaranteees IFS School of London');

-- Table: experience_detail
INSERT INTO experience_detail(resume_id, start_date, is_current_job, end_date, job_title, company_name, description, job_location_id) VALUES
    (1, '2005-04-30', false, '2008-07-30', 'Head Economist Currency Control Dept', 'ASB Belarusbank', 'Currency Control', 1),
    (1, '2008-11-15', false, '2017-10-15', 'Managing Expert', 'JSC Promsvyazbank', 'Letters of Credit', 2),
    (4, '2006-11-15', false, '2010-10-15', 'Head Economist', 'JSC Promsvyazbank', 'Letters of Credit', 2),
    (4, '2010-10-16', false, '2013-08-20', 'Head Economist', 'JSC Sberbank', 'Letters of Credit', 3),
    (4, '2017-10-16', true, null,  'Managing Expert', 'JSC Promsvyazbank', 'Letters of Credit', 2);



-- Table: vacancy
INSERT INTO vacancy(posted_by_id, current_job_type, company_id, is_company_name_hidden,
    job_description, job_location_id, min_salary, max_salary, publication_time, expiry_time, is_active)
        VALUES
            (11, 'FULL_TIME', 1, false, 'Java programmer', 1, null, null, '2018-12-30', null, true),
            (12, 'FULL_TIME', 2, false, 'Letter of credit specialist', 2, null, 150000, '2018-11-25', null, true),
            (11, 'FULL_TIME', 1, false, 'Python programmer', 1, 80000, 90000, '2018-12-25', null, true),
            (13, 'PART_TIME', 3, false, 'Architercture', 3, 180000, 190000, '2018-12-30', null, true),
            (23, 'FULL_TIME', 4, true, 'Currency control', 4, 100000, 110000, '2018-11-30', '2019-01-15', true);

-- Table: invitation
INSERT INTO invitation(resume_id, vacancy_id, meeting_time, message, current_communication_status, invitation_time)
    VALUES
        (1, 1, '2019-01-15 10:00:00', 'We are waiting for you', 'RECEIVED', '2019-01-14 10:00:00'),
        (2, 1, '2019-01-15 11:00:00', 'We are waiting for you', 'RECEIVED', '2019-01-14 09:00:00'),
        (2, 3, '2019-01-12 10:00:00', 'We are waiting for you', 'WATCHED', '2019-01-11 09:30:56'),
        (3, 4, '2019-01-09 09:00:00', 'We are waiting for you', 'ACCEPTED', '2018-12-31 23:59:59'),
        (5, 5, '2019-01-13 12:00:00', 'We are waiting for you', 'WATCHED', '2019-01-01 00:00:01');

-- Table: respond
INSERT INTO respond (resume_id, vacancy_id, apply_date, message, current_communication_status)
    VALUES
        (1, 1, '2019-01-05 09:00:00', 'I am interested in your position', 'ACCEPTED'),
        (2, 1, '2019-01-05 11:11:11', 'I am interested in your position', 'ACCEPTED'),
        (2, 3, '2019-01-02 10:00:00', 'I am interested in your position', 'ACCEPTED'),
        (1, 4, '2019-12-30 09:00:00', 'Please invite I will do my best', 'DECLINED'),
        (3, 4, '2019-12-31 09:00:00', 'Please invite I will do my best', 'ACCEPTED'),
        (5, 5, '2019-01-03 12:00:00', 'Hi, I am good in for your job', 'ACCEPTED');

-- Table: message
-- Table: respond
INSERT INTO message (resume_id, vacancy_id, message_time, message, current_communication_status)
    VALUES
        (1, 1, '2019-01-15 11:00:00', 'Hi, I''m sorry, but your position is not actual for me  ', 'RECEIVED'),
        (1, 1, '2019-01-15 11:05:00', 'Ok, maybe next time :)', 'RECEIVED'),
        (2, 1, '2019-01-05 15:11:11', 'Please provide the working schedule', 'RECEIVED'),
        (2, 1, '2019-01-05 15:11:12', 'From 09.00 till 18.00', 'RECEIVED'),
        (5, 5, '2019-01-10 12:00:00', 'I reconfirm our meeting', 'RECEIVED');


-- Table: resume_skill_set
INSERT INTO resume_skill_set(resume_id, skill_id, skill_level)
    VALUES
        (1, 1, 5),
        (1, 2, 3),
        (2, 1, 6),
        (3, 3, 7),
        (4, 1, 6); 


-- Table: vacancy_skill_set
INSERT INTO vacancy_skill_set(vacancy_id, skill_id, skill_level)
    VALUES
        (1, 1, 5),
        (1, 2, 3),
        (2, 1, 6),
        (3, 3, 7),
        (4, 1, 6); 

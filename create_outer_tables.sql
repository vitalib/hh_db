\c hh_homework;
DROP SCHEMA IF EXISTS outer_base CASCADE;
-- DROP TABLE IF EXISTS outer_base.skill;
-- DROP TABLE IF EXISTS outer_base.job_location;
-- DROP TABLE IF EXISTS outer_base.account;
-- DROP TABLE IF EXISTS outer_base.resume;
-- DROP TABLE IF EXISTS outer_base.experience_detail;
-- DROP TABLE IF EXISTS outer_base.vacancy;
-- DROP TABLE IF EXISTS outer_base.respond;
-- DROP TABLE IF EXISTS outer_base.message;
-- DROP TABLE IF EXISTS outer_base.vacancy_skill_set;
-- DROP TABLE IF EXISTS outer_base.resume_skill_set;
-- DROP SCHEMA IF EXISTS outer_base;
CREATE SCHEMA outer_base;


-- Table: skill
CREATE TABLE outer_base.skill (
    skill_id serial PRIMARY KEY,
    skill_name varchar(50)  NOT NULL
);

-- Table: job_location
CREATE TABLE outer_base.job_location (
    job_location_id serial PRIMARY KEY,
    street_address varchar(100)  NOT NULL,
    city varchar(50)  NOT NULL,
    state varchar(50)  NOT NULL,
    country varchar(50)  NOT NULL,
    zip varchar(50)  NOT NULL
);


-- CREATE TYPE USER_TYPE AS ENUM ('APPLICANT', 'RECRUITER', 'HH_AGENCY');

-- Table: account
CREATE TABLE outer_base.account (
    account_id serial PRIMARY KEY,
    type_of_user USER_TYPE,
    login varchar(100)  NOT NULL UNIQUE,
    password varchar(100)  NOT NULL,
    email varchar(255)  NOT NULL UNIQUE,
    is_active boolean  NOT NULL,
    registration_date timestamp NOT NULL,
    last_login_date timestamp  NOT NULL
);

-- Table: resume
CREATE TABLE outer_base.resume (
    resume_id serial PRIMARY KEY,
    account_id integer REFERENCES outer_base.account(account_id),
    first_name varchar(50)  NOT NULL,
    middle_name varchar(50),
    last_name varchar(50)  NOT NULL,
    min_salary integer,
    max_salary integer,
    currency varchar(50),
    birth_date date NOT NULL,
    is_active boolean NOT NULL
);


-- Table: company
CREATE TABLE outer_base.company (
    company_id serial PRIMARY KEY ,
    company_name varchar(100)  NOT NULL,
    activity_description varchar(1000) NOT NULL,
    creation_date date NOT NULL,
    company_website_url varchar(500)
);

-- Table: education
CREATE TABLE outer_base.education (
    resume_id integer REFERENCES outer_base.resume(resume_id),
    course_name varchar(50),
    start_date date ,
    end_date date,
    description varchar(1000),
    PRIMARY KEY(resume_id, course_name, start_date)
);

-- Table: experience_detail
CREATE TABLE outer_base.experience_detail (
    resume_id integer REFERENCES outer_base.resume(resume_id),
    start_date date,
    is_current_job boolean NOT NULL,
    end_date date,
    job_title varchar(50) NOT NULL,
    company_name varchar(100) NOT NULL,
    description varchar(4000) NOT NULL,
    job_location_id integer REFERENCES outer_base.job_location(job_location_id),
    PRIMARY KEY(resume_id, start_date, job_title)
);

-- CREATE TYPE JOB_TYPE AS ENUM ('PART_TIME', 'FULL_TIME', 'PROJECT_OCCUPATION', 'REMOTE_JOB');

-- Table: vacancy
CREATE TABLE outer_base.vacancy (
    vacancy_id serial PRIMARY KEY,
    posted_by_id integer REFERENCES outer_base.account(account_id),
    current_job_type JOB_TYPE,
    company_id integer  REFERENCES outer_base.company(company_id),
    is_company_name_hidden boolean  NOT NULL,
    job_description varchar(500)  NOT NULL,
    job_location_id integer REFERENCES outer_base.job_location(job_location_id),
    is_active boolean NOT NULL,
    min_salary integer,
    max_salary integer,
    publication_time timestamp  NOT NULL,
    expiry_time timestamp
);

-- Table: invitation
CREATE TABLE outer_base.invitation (
    resume_id integer REFERENCES outer_base.resume(resume_id),
    vacancy_id integer REFERENCES outer_base.vacancy(vacancy_id),
    meeting_time timestamp  NOT NULL,
    invitation_time timestamp,
    message varchar(1000),
    is_watched boolean NOT NULL ,
    PRIMARY KEY(resume_id, vacancy_id)
);

-- Table: respond
CREATE TABLE outer_base.respond (
    vacancy_id integer REFERENCES outer_base.vacancy(vacancy_id),
    resume_id integer REFERENCES outer_base.resume(resume_id),
    apply_date timestamp NOT NULL,
    message varchar(1000),
    is_watched boolean NOT NULL ,
    PRIMARY KEY(vacancy_id, resume_id)
);

-- Table: message
CREATE TABLE outer_base.message (
    vacancy_id integer REFERENCES outer_base.vacancy(vacancy_id),
    resume_id integer REFERENCES outer_base.resume(resume_id),
    message_time timestamp NOT NULL,
    message varchar(1000),
    is_watched boolean NOT NULL,
    PRIMARY KEY(vacancy_id, resume_id, message_time)
);

-- Table: resume_skill_set
CREATE TABLE outer_base.resume_skill_set (
    resume_id integer REFERENCES outer_base.resume(resume_id),
    skill_id integer REFERENCES outer_base.skill(skill_id),
    skill_level integer NOT NULL,
    PRIMARY KEY(resume_id, skill_id)
);

-- Table: vacancy_skill_set
CREATE TABLE outer_base.vacancy_skill_set (
    skill_id integer REFERENCES outer_base.skill(skill_id),
    vacancy_id integer REFERENCES outer_base.vacancy(vacancy_id),
    skill_level integer NOT NULL,
    PRIMARY KEY(skill_id, vacancy_id)
);

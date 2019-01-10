\c hh_homework;

-- Table: skill
CREATE TABLE skill (
    skill_id serial PRIMARY KEY,
    skill_name varchar(50)  NOT NULL
);

-- Table: job_location
CREATE TABLE job_location (
    job_location_id serial PRIMARY KEY,
    street_address varchar(100)  NOT NULL,
    city varchar(50)  NOT NULL,
    state varchar(50)  NOT NULL,
    country varchar(50)  NOT NULL,
    zip varchar(50)  NOT NULL
);


CREATE TYPE user_type AS ENUM ('seeker', 'recruiter', 'hh_agency');

-- Table: users
CREATE TABLE users (
    users_id serial PRIMARY KEY, 
    type_of_user user_type,
    login varchar(100)  NOT NULL UNIQUE,
    password varchar(100)  NOT NULL,
    email varchar(255)  NOT NULL UNIQUE,
    is_active boolean  NOT NULL,
    registration_date timestamp NOT NULL,
    last_login_date timestamp  NOT NULL
);

CREATE TYPE status AS ENUM ('Active', 'Hidden', 'Archive', 'Deleted');


-- Table: resume
CREATE TABLE resume (
    resume_id serial PRIMARY KEY, 
    users_id integer REFERENCES users(users_id),
    first_name varchar(50)  NOT NULL,
    middle_name varchar(50),
    last_name varchar(50)  NOT NULL,
    min_salary integer,
    max_salary integer,
    currency varchar(50),
    age integer NOT NULL, 
    current_status status
);

CREATE TYPE communication_status AS ENUM ('RECEIVED', 'WATCHED', 'ACCEPTED', 'DECLINED');

-- Table: company
CREATE TABLE company (
    company_id serial PRIMARY KEY ,
    company_name varchar(100)  NOT NULL,
    activity_description varchar(1000) NOT NULL,
    creation_date date NOT NULL,
    company_website_url varchar(500) NOT NULL
);

-- Table: education
CREATE TABLE education (
    resume_id integer REFERENCES resume(resume_id), 
    course_name varchar(50),
    start_date date , 
    end_date date,
    description varchar(1000),
    PRIMARY KEY(resume_id, course_name, start_date)
);

-- Table: experience_detail
CREATE TABLE experience_detail (
    resume_id integer REFERENCES resume(resume_id), 
    start_date date, 
    is_current_job boolean NOT NULL,
    end_date date,
    job_title varchar(50) NOT NULL,
    company_name varchar(100) NOT NULL,
    description varchar(4000) NOT NULL,
    job_location_id integer REFERENCES job_location(job_location_id),
    PRIMARY KEY(resume_id, start_date, job_title)
);

CREATE TYPE job_type AS ENUM ('part time', 'full time', 'project occupation', 'remote job');

-- Table: vacancy
CREATE TABLE vacancy (
    vacancy_id serial PRIMARY KEY,
    posted_by_id integer REFERENCES users(users_id),
    current_job_type job_type,
    company_id integer  REFERENCES company(company_id),
    is_company_name_hidden boolean  NOT NULL,
    job_description varchar(500)  NOT NULL,
    job_location_id integer REFERENCES job_location(job_location_id),
    current_status status,
    min_salary integer,
    max_salary integer,
    publication_time timestamp  NOT NULL,
    expiry_time timestamp
);

-- Table: invitation
CREATE TABLE invitation (
    resume_id integer REFERENCES resume(resume_id),
    vacancy_id integer REFERENCES vacancy(vacancy_id),
    meeting_time timestamp  NOT NULL,
    message varchar(1000), 
    current_communication_status communication_status ,
    PRIMARY KEY(resume_id, vacancy_id)
);

-- Table: respond
CREATE TABLE respond (
    vacancy_id integer REFERENCES vacancy(vacancy_id),
    resume_id integer REFERENCES resume(resume_id),
    apply_date timestamp NOT NULL,
    message varchar(1000),
    current_communication_status communication_status ,
    PRIMARY KEY(vacancy_id, resume_id)
);

-- Table: resume_skill_set
CREATE TABLE resume_skill_set (
    resume_id integer REFERENCES resume(resume_id),
    skill_id integer REFERENCES skill(skill_id),
    skill_level integer NOT NULL, 
    PRIMARY KEY(resume_id, skill_id)
);

-- Table: vacancy_skill_set
CREATE TABLE vacancy_skill_set (
    skill_id integer REFERENCES skill(skill_id),
    vacancy_id integer REFERENCES vacancy(vacancy_id),
    skill_level integer NOT NULL, 
    PRIMARY KEY(skill_id, vacancy_id)
);

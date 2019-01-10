\c hh_homework;

-- Table: skill
CREATE TABLE skill (
    id serial PRIMARY KEY,
    skill_name varchar(50)  NOT NULL
);

-- Table: job_location
CREATE TABLE job_location (
    id serial PRIMARY KEY,
    street_address varchar(100)  NOT NULL,
    city varchar(50)  NOT NULL,
    state varchar(50)  NOT NULL,
    country varchar(50)  NOT NULL,
    zip varchar(50)  NOT NULL
);

-- Table: user_type
CREATE TABLE user_type (
    id serial PRIMARY KEY,
    user_type_name varchar(20)  NOT NULL CHECK (length(user_type_name) > 0)
);

-- Table: users
CREATE TABLE users (
    id serial PRIMARY KEY, 
    user_type_id integer REFERENCES user_type(id), 
    login varchar(100)  NOT NULL CHECK (length(login) > 7) UNIQUE,
    password varchar(100)  NOT NULL,
    email varchar(255)  NOT NULL UNIQUE,
    is_active boolean  NOT NULL,
    registration_date timestamp NOT NULL,
    last_login_date timestamp  NOT NULL,
    CHECK (registration_date <= last_login_date)
);

-- Table status
CREATE TABLE status(
    id serial PRIMARY KEY,
    name varchar(50) NOT NULL
);
-- Table: resume
CREATE TABLE resume (
    id serial PRIMARY KEY, 
    users_id integer REFERENCES users(id),
    first_name varchar(50)  NOT NULL CHECK (length(first_name) > 0),
    middle_name varchar(50)  NULL,
    last_name varchar(50)  NOT NULL CHECK (length(last_name) > 0),
    min_salary integer  NULL,
    max_salary integer  NULL,
    currency varchar(50)  NULL,
    age integer NOT NULL CHECK (age > 13 AND age < 110),
    status_id integer REFERENCES status(id) DEFAULT 1
);

CREATE TABLE communication_status (
    id serial PRIMARY KEY,
    status_name varchar(50)  NOT NULL
);

-- Table: company
CREATE TABLE company (
    id serial PRIMARY KEY ,
    company_name varchar(100)  NOT NULL CHECK (length(company_name) > 0),
    activity_description varchar(1000)  NOT NULL,
    creation_date date  NOT NULL,
    company_website_url varchar(500)  NOT NULL
);

-- Table: education
CREATE TABLE education (
    resume_id integer REFERENCES resume(id), 
    course_name varchar(50),
    start_date date , 
    end_date date  NULL,
    description varchar(1000)  NULL,
    PRIMARY KEY(resume_id, course_name, start_date)
);

-- Table: experience_detail
CREATE TABLE experience_detail (
    resume_id integer REFERENCES resume(id), 
    start_date date, 
    is_current_job boolean NOT NULL,
    end_date date NULL,
    job_title varchar(50) NOT NULL,
    company_name varchar(100) NOT NULL,
    description varchar(4000) NOT NULL,
    job_location_id integer REFERENCES job_location(id),
    PRIMARY KEY(resume_id, start_date, job_title)
);

-- Table: job_type
CREATE TABLE job_type (
    id serial PRIMARY KEY,
    job_type varchar(20)  NOT NULL
);

-- Table: vacancy
CREATE TABLE vacancy (
    id serial PRIMARY KEY,
    posted_by_id integer REFERENCES users(id),
    job_type_id integer REFERENCES job_type(id),
    company_id integer  REFERENCES company(id),
    is_company_name_hidden boolean  NOT NULL,
    job_description varchar(500)  NOT NULL,
    job_location_id integer REFERENCES job_location(id),
    status_id integer REFERENCES status(id) DEFAULT 1,
    min_salary integer  NULL,
    max_salary integer  NULL,
    publication_time timestamp  NOT NULL,
    expiry_time timestamp NULL
);

-- Table: invitation
CREATE TABLE invitation (
    resume_id integer REFERENCES resume(id),
    vacancy_id integer REFERENCES vacancy(id),
    meeting_time timestamp  NOT NULL,
    message varchar(1000)  NULL,
    communication_status_id integer  NOT NULL,
    PRIMARY KEY(resume_id, vacancy_id)
);

-- Table: respond
CREATE TABLE respond (
    vacancy_id integer REFERENCES vacancy(id),
    resume_id integer REFERENCES resume(id),
    apply_date timestamp NOT NULL,
    message varchar(1000) NULL,
    communication_status_id integer NOT NULL,
    PRIMARY KEY(vacancy_id, resume_id)
);

-- Table: resume_skill_set
CREATE TABLE resume_skill_set (
    resume_id integer REFERENCES resume(id),
    skill_id integer REFERENCES skill(id),
    skill_level integer NOT NULL check (skill_level >= 0 AND skill_level < 11),
    PRIMARY KEY(resume_id, skill_id)
);

-- Table: vacancy_skill_set
CREATE TABLE vacancy_skill_set (
    skill_id integer REFERENCES skill(id),
    vacancy_id integer REFERENCES vacancy(id),
    skill_level integer NOT NULL CHECK (skill_level >= 0 AND skill_level < 11),
    PRIMARY KEY(skill_id, vacancy_id)
);

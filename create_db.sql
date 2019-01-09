\c hh_homework;

-- Table: skills
CREATE TABLE skills (
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

-- Table statuses
CREATE TABLE statuses(
    id serial PRIMARY KEY,
    name varchar(50) NOT NULL
);
-- Table: resumes
CREATE TABLE resumes (
    id serial PRIMARY KEY, 
    users_id integer REFERENCES users(id),
    first_name varchar(50)  NOT NULL CHECK (length(first_name) > 0),
    middle_name varchar(50)  NULL,
    last_name varchar(50)  NOT NULL CHECK (length(last_name) > 0),
    min_salary integer  NULL,
    max_salary integer  NULL,
    currency varchar(50)  NULL,
    age integer NOT NULL CHECK (age > 13 AND age < 110),
    statuses_id integer REFERENCES statuses(id) DEFAULT 1
);

CREATE TABLE communication_status (
    id serial PRIMARY KEY,
    status_name varchar(50)  NOT NULL
);

-- Table: company
CREATE TABLE companies (
    id serial PRIMARY KEY ,
    company_name varchar(100)  NOT NULL CHECK (length(company_name) > 0),
    activity_description varchar(1000)  NOT NULL,
    creation_date date  NOT NULL,
    company_website_url varchar(500)  NOT NULL
);

-- Table: educations
CREATE TABLE educations (
    resumes_id integer REFERENCES resumes(id), 
    course_name varchar(50),
    start_date date , 
    end_date date  NULL,
    description varchar(1000)  NULL,
    PRIMARY KEY(resumes_id, course_name, start_date)
);

-- Table: experience_detail
CREATE TABLE experience_details (
    resumes_id integer REFERENCES resumes(id), 
    start_date date, 
    is_current_job boolean NOT NULL,
    end_date date NULL,
    job_title varchar(50) NOT NULL,
    company_name varchar(100) NOT NULL,
    description varchar(4000) NOT NULL,
    job_location_id integer REFERENCES job_location(id),
    PRIMARY KEY(resumes_id, start_date, job_title)
);

-- Table: job_type
CREATE TABLE job_type (
    id serial PRIMARY KEY,
    job_type varchar(20)  NOT NULL
);

-- Table: vacancies
CREATE TABLE vacancies (
    id serial PRIMARY KEY,
    posted_by_id integer REFERENCES users(id),
    job_type_id integer REFERENCES job_type(id),
    companies_id integer  REFERENCES companies(id),
    is_company_name_hidden boolean  NOT NULL,
    job_description varchar(500)  NOT NULL,
    job_location_id integer REFERENCES job_location(id),
    statuses_id integer REFERENCES statuses(id) DEFAULT 1,
    min_salary integer  NULL,
    max_salary integer  NULL,
    publication_time timestamp  NOT NULL,
    expiry_time timestamp NULL
);

-- Table: invitations
CREATE TABLE invitations (
    resumes_id integer REFERENCES resumes(id),
    vacancies_id integer REFERENCES vacancies(id),
    meeting_time timestamp  NOT NULL,
    message varchar(1000)  NULL,
    communication_status_id integer  NOT NULL,
    PRIMARY KEY(resumes_id, vacancies_id)
);

-- Table: responds
CREATE TABLE responds (
    vacancies_id integer REFERENCES vacancies(id),
    resumes_id integer REFERENCES resumes(id),
    apply_date timestamp NOT NULL,
    message varchar(1000) NULL,
    communication_status_id integer NOT NULL,
    PRIMARY KEY(vacancies_id, resumes_id)
);

-- Table: resume_skills_set
CREATE TABLE resume_skills_set (
    resumes_id integer REFERENCES resumes(id),
    skills_id integer REFERENCES skills(id),
    skill_level integer NOT NULL check (skill_level >= 0 AND skill_level < 11),
    PRIMARY KEY(resumes_id, skills_id)
);

-- Table: vacancy_skills_set
CREATE TABLE vacancy_skills_set (
    skills_id integer REFERENCES skills(id),
    vacancies_id integer REFERENCES vacancies(id),
    skill_level integer NOT NULL CHECK (skill_level >= 0 AND skill_level < 11),
    PRIMARY KEY(skills_id, vacancies_id)
);

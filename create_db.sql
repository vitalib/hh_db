-- Last modification date: 2019-01-07 11:21:57.799

-- tables
-- Table: communication_status
DROP DATABASE IF EXISTS hh_homework;

CREATE DATABASE hh_homework;
\c hh_homework;

CREATE TABLE communication_status (
    id serial PRIMARY KEY,
    status_name varchar(50)  NOT NULL,
    CONSTRAINT communication_status_pk PRIMARY KEY (id)
);

-- Table: company
CREATE TABLE company (
    id serial  NOT NULL,
    company_name varchar(100)  NOT NULL,
    profile_description varchar(1000)  NOT NULL,
    creation_date date  NOT NULL,
    company_website_url varchar(500)  NOT NULL,
    CONSTRAINT company_pk PRIMARY KEY (id)
);

-- Table: educations
CREATE TABLE educations (
    course_name varchar(50)  NOT NULL,
    start_date date  NOT NULL,
    end_date date  NULL,
    resumes_id integer  NOT NULL,
    description varchar(1000)  NULL,
    CONSTRAINT educations_pk PRIMARY KEY (course_name,start_date,resumes_id)
);

-- Table: experience_detail
CREATE TABLE experience_detail (
    resumes_id integer  NOT NULL,
    is_current_job boolean  NOT NULL,
    start_date date  NOT NULL,
    end_date date  NULL,
    job_title varchar(50)  NOT NULL,
    company_name varchar(100)  NOT NULL,
    description varchar(4000)  NOT NULL,
    job_location_id integer  NOT NULL,
    CONSTRAINT experience_detail_pk PRIMARY KEY (resumes_id,start_date)
);

-- Table: invitations
CREATE TABLE invitations (
    meeting_time timestamp  NOT NULL,
    message varchar(1000)  NOT NULL,
    resumes_id int  NOT NULL,
    vacancies_id int  NOT NULL,
    communication_status_id integer  NOT NULL,
    CONSTRAINT invitations_pk PRIMARY KEY (resumes_id,vacancies_id)
);

-- Table: job_location
CREATE TABLE job_location (
    id serial  NOT NULL,
    street_address varchar(100)  NOT NULL,
    city varchar(50)  NOT NULL,
    state varchar(50)  NOT NULL,
    country varchar(50)  NOT NULL,
    zip varchar(50)  NOT NULL,
    CONSTRAINT job_location_pk PRIMARY KEY (id)
);

-- Table: job_type
CREATE TABLE job_type (
    id serial  NOT NULL,
    job_type varchar(20)  NOT NULL,
    CONSTRAINT job_type_pk PRIMARY KEY (id)
);

-- Table: responds
CREATE TABLE responds (
    vacancies_id integer  NOT NULL,
    apply_date date  NOT NULL,
    message varchar(1000)  NOT NULL,
    resumes_id int  NOT NULL,
    communication_status_id integer  NOT NULL,
    CONSTRAINT responds_pk PRIMARY KEY (vacancies_id,resumes_id)
);

-- Table: resume_skills_set
CREATE TABLE resume_skills_set (
    resumes_id integer  NOT NULL,
    skills_id integer  NOT NULL,
    skill_level integer  NOT NULL,
    CONSTRAINT resume_skills_set_pk PRIMARY KEY (resumes_id,skills_id)
);

-- Table: resumes
CREATE TABLE resumes (
    id serial  NOT NULL,
    users_id integer  NOT NULL,
    first_name varchar(50)  NOT NULL,
    middle_name varchar(50)  NULL,
    last_name varchar(50)  NOT NULL,
    min_salary integer  NULL,
    max_salary integer  NULL,
    currency varchar(50)  NULL,
    age integer  NOT NULL,
    CONSTRAINT resumes_pk PRIMARY KEY (id)
);

-- Table: skills
CREATE TABLE skills (
    id serial  NOT NULL,
    skill_name varchar(50)  NOT NULL,
    CONSTRAINT skills_pk PRIMARY KEY (id)
);

-- Table: user_type
CREATE TABLE user_type (
    id serial  NOT NULL,
    user_type_name varchar(20)  NOT NULL,
    CONSTRAINT user_type_pk PRIMARY KEY (id)
);

-- Table: users
CREATE TABLE users (
    id serial  NOT NULL,
    user_type_id integer  NOT NULL,
    login varchar(100)  NOT NULL,
    password varchar(100)  NOT NULL,
    email varchar(255)  NOT NULL,
    is_active boolean  NOT NULL,
    registration_date date  NOT NULL,
    last_login_date timestamp  NOT NULL,
    CONSTRAINT users_pk PRIMARY KEY (id)
);

-- Table: vacancies
CREATE TABLE vacancies (
    id serial  NOT NULL,
    posted_by_id integer  NOT NULL,
    job_type_id integer  NOT NULL,
    company_id integer  NOT NULL,
    is_company_name_hidden boolean  NOT NULL,
    job_description varchar(500)  NOT NULL,
    job_location_id integer  NOT NULL,
    is_active boolean  NOT NULL,
    min_salary integer  NULL,
    max_salary integer  NULL,
    publication_time timestamp  NOT NULL,
    expiry_time timestamp  NOT NULL,
    CONSTRAINT vacancies_pk PRIMARY KEY (id)
);

-- Table: vacancy_skill_set
CREATE TABLE vacancy_skill_set (
    skills_id integer  NOT NULL,
    vacancy_id integer  NOT NULL,
    skill_level integer  NOT NULL,
    CONSTRAINT vacancy_skill_set_pk PRIMARY KEY (skills_id,vacancy_id)
);

-- foreign keys
-- Reference: educations_resumes (table: educations)
ALTER TABLE educations ADD CONSTRAINT educations_resumes
    FOREIGN KEY (resumes_id)
    REFERENCES resumes (id)  
    NOT DEFERRABLE 
    INITIALLY IMMEDIATE
;

-- Reference: exp_dtl_seeker_profile (table: experience_detail)
ALTER TABLE experience_detail ADD CONSTRAINT exp_dtl_seeker_profile
    FOREIGN KEY (resumes_id)
    REFERENCES resumes (id)  
    NOT DEFERRABLE 
    INITIALLY IMMEDIATE
;

-- Reference: experience_detail_job_location (table: experience_detail)
ALTER TABLE experience_detail ADD CONSTRAINT experience_detail_job_location
    FOREIGN KEY (job_location_id)
    REFERENCES job_location (id)  
    NOT DEFERRABLE 
    INITIALLY IMMEDIATE
;

-- Reference: invitations_communication_status (table: invitations)
ALTER TABLE invitations ADD CONSTRAINT invitations_communication_status
    FOREIGN KEY (communication_status_id)
    REFERENCES communication_status (id)  
    NOT DEFERRABLE 
    INITIALLY IMMEDIATE
;

-- Reference: invitations_resumes (table: invitations)
ALTER TABLE invitations ADD CONSTRAINT invitations_resumes
    FOREIGN KEY (resumes_id)
    REFERENCES resumes (id)  
    NOT DEFERRABLE 
    INITIALLY IMMEDIATE
;

-- Reference: invitations_vacancies (table: invitations)
ALTER TABLE invitations ADD CONSTRAINT invitations_vacancies
    FOREIGN KEY (vacancies_id)
    REFERENCES vacancies (id)  
    NOT DEFERRABLE 
    INITIALLY IMMEDIATE
;

-- Reference: job_post_activity_job_post (table: responds)
ALTER TABLE responds ADD CONSTRAINT job_post_activity_job_post
    FOREIGN KEY (vacancies_id)
    REFERENCES vacancies (id)  
    NOT DEFERRABLE 
    INITIALLY IMMEDIATE
;

-- Reference: job_post_company (table: vacancies)
ALTER TABLE vacancies ADD CONSTRAINT job_post_company
    FOREIGN KEY (company_id)
    REFERENCES company (id)  
    NOT DEFERRABLE 
    INITIALLY IMMEDIATE
;

-- Reference: job_post_job_location (table: vacancies)
ALTER TABLE vacancies ADD CONSTRAINT job_post_job_location
    FOREIGN KEY (job_location_id)
    REFERENCES job_location (id)  
    NOT DEFERRABLE 
    INITIALLY IMMEDIATE
;

-- Reference: job_post_job_type (table: vacancies)
ALTER TABLE vacancies ADD CONSTRAINT job_post_job_type
    FOREIGN KEY (job_type_id)
    REFERENCES job_type (id)  
    NOT DEFERRABLE 
    INITIALLY IMMEDIATE
;

-- Reference: job_post_skill_set_job_post (table: vacancy_skill_set)
ALTER TABLE vacancy_skill_set ADD CONSTRAINT job_post_skill_set_job_post
    FOREIGN KEY (vacancy_id)
    REFERENCES vacancies (id)  
    NOT DEFERRABLE 
    INITIALLY IMMEDIATE
;

-- Reference: job_post_skill_set_skill_set (table: vacancy_skill_set)
ALTER TABLE vacancy_skill_set ADD CONSTRAINT job_post_skill_set_skill_set
    FOREIGN KEY (skills_id)
    REFERENCES skills (id)  
    NOT DEFERRABLE 
    INITIALLY IMMEDIATE
;

-- Reference: job_post_user_register (table: vacancies)
ALTER TABLE vacancies ADD CONSTRAINT job_post_user_register
    FOREIGN KEY (posted_by_id)
    REFERENCES users (id)  
    NOT DEFERRABLE 
    INITIALLY IMMEDIATE
;

-- Reference: responds_communication_status (table: responds)
ALTER TABLE responds ADD CONSTRAINT responds_communication_status
    FOREIGN KEY (communication_status_id)
    REFERENCES communication_status (id)  
    NOT DEFERRABLE 
    INITIALLY IMMEDIATE
;

-- Reference: responds_resumes (table: responds)
ALTER TABLE responds ADD CONSTRAINT responds_resumes
    FOREIGN KEY (resumes_id)
    REFERENCES resumes (id)  
    NOT DEFERRABLE 
    INITIALLY IMMEDIATE
;

-- Reference: seeker_profile_user_register (table: resumes)
ALTER TABLE resumes ADD CONSTRAINT seeker_profile_user_register
    FOREIGN KEY (users_id)
    REFERENCES users (id)  
    NOT DEFERRABLE 
    INITIALLY IMMEDIATE
;

-- Reference: seeker_skill_set_skill_set (table: resume_skills_set)
ALTER TABLE resume_skills_set ADD CONSTRAINT seeker_skill_set_skill_set
    FOREIGN KEY (skills_id)
    REFERENCES skills (id)  
    NOT DEFERRABLE 
    INITIALLY IMMEDIATE
;

-- Reference: skill_set_seeker_profile (table: resume_skills_set)
ALTER TABLE resume_skills_set ADD CONSTRAINT skill_set_seeker_profile
    FOREIGN KEY (resumes_id)
    REFERENCES resumes (id)  
    NOT DEFERRABLE 
    INITIALLY IMMEDIATE
;

-- Reference: user_register_user_type (table: users)
ALTER TABLE users ADD CONSTRAINT user_register_user_type
    FOREIGN KEY (user_type_id)
    REFERENCES user_type (id)  
    NOT DEFERRABLE 
    INITIALLY IMMEDIATE
;

-- End of file.


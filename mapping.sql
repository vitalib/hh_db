\c hh_homework;
DROP TABLE IF EXISTS map_job_location;
DROP TABLE IF EXISTS map_skill;
DROP TABLE IF EXISTS map_account;
DROP TABLE IF EXISTS map_resume;
DROP TABLE IF EXISTS map_company;
DROP TABLE IF EXISTS map_education;
DROP TABLE IF EXISTS map_experience;
DROP TABLE IF EXISTS map_vacancy;
DROP TABLE IF EXISTS copied_tables;


CREATE TABLE map_job_location(primary_id integer, outer_id INTEGER PRIMARY KEY);
CREATE TABLE map_skill(primary_id integer, outer_id INTEGER PRIMARY KEY);
CREATE TABLE map_account(primary_id integer, outer_id INTEGER PRIMARY KEY);
CREATE TABLE map_resume(primary_id integer, outer_id INTEGER PRIMARY KEY);
CREATE TABLE map_company(primary_id integer, outer_id INTEGER PRIMARY KEY);
CREATE TABLE map_education(primary_id integer, outer_id INTEGER PRIMARY KEY);
CREATE TABLE map_experience(primary_id integer, outer_id INTEGER PRIMARY KEY);
CREATE TABLE map_vacancy(primary_id integer, outer_id INTEGER PRIMARY KEY);

CREATE TABLE copied_tables(id SERIAL, name varchar(20), is_copied boolean DEFAULT false,
    is_updated boolean DEFAULT false);

INSERT INTO copied_tables (name)
    VALUES
        ('job_location'), ('skill'), ('account'), ('resume'), ('company'), ('education'),
            ('experience'), ('vacancy'), ('invitation'), ('respond'), ('message'),
            ('resume_skill_set'), ('vacancy_skill_set');

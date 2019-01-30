DROP TABLE IF EXISTS map_job_location;
DROP TABLE IF EXISTS map_skill;
DROP TABLE IF EXISTS map_account;
DROP TABLE IF EXISTS map_resume;
DROP TABLE IF EXISTS map_company;
DROP TABLE IF EXISTS map_education;
DROP TABLE IF EXISTS map_experience;
DROP TABLE IF EXISTS map_vacancy;
DROP TABLE IF EXISTS copied_tables;
DROP TABLE IF EXISTS invitations_copied;


CREATE TABLE map_job_location(primary_id integer, outer_id INTEGER PRIMARY KEY);
CREATE TABLE map_skill(primary_id integer, outer_id INTEGER PRIMARY KEY);
CREATE TABLE map_account(primary_id integer, outer_id INTEGER PRIMARY KEY);
CREATE TABLE map_resume(primary_id integer, outer_id INTEGER PRIMARY KEY);
CREATE TABLE map_company(primary_id integer, outer_id INTEGER PRIMARY KEY);
CREATE TABLE map_vacancy(primary_id integer, outer_id INTEGER PRIMARY KEY);


CREATE TABLE copied_tables(id SERIAL, name varchar(20), is_copied boolean DEFAULT false,
    is_updated boolean DEFAULT false, table_offset integer DEFAULT 0, table_rows integer default 0);

INSERT INTO copied_tables (name)
VALUES
('job_location'), ('skill'), ('company'), ('account'), ('resume'),
('vacancy'), ('invitation'), ('respond'), ('message'),
('resume_skill_set'), ('vacancy_skill_set');

UPDATE copied_tables SET
    table_rows = (select count(*) from outer_base.invitation)
    where name = 'invitation';

UPDATE copied_tables SET
    table_rows = (select count(*) from outer_base.respond)
    where name = 'respond';

UPDATE copied_tables SET
    table_rows = (select count(*) from outer_base.message)
    where name = 'message';

UPDATE copied_tables SET
    table_rows = (select count(*) from outer_base.resume_skill_set)
    where name = 'resume_skill_set';

UPDATE copied_tables SET
    table_rows = (select count(*) from outer_base.vacancy_skill_set)
    where name = 'vacancy_skill_set';


CREATE INDEX ON outer_base.invitation (invitation_id);
CREATE INDEX ON outer_base.respond (respond_id);
CREATE INDEX ON outer_base.message (message_id);

CREATE INDEX skill_idx ON outer_base.skill(skill_name, skill_id);
CREATE INDEX account_idx ON outer_base.account(account_id, email);
CREATE INDEX company_idx ON outer_base.company(company_id, company_name, creation_date);

--
-- PostgreSQL database dump
--
DROP DATABASE IF EXISTS hh_homework;

CREATE DATABASE hh_homework;
\c hh_homework
CREATE SCHEMA hh;

SET client_encoding = 'UTF-8';

CREATE TABLE users (
	userid SERIAL PRIMARY KEY,
	login varchar (50) NOT NULL,
	password varchar (50) NOT NULL,
	registration timestamp NOT NULL,
	last_login timestamp
);

CREATE TABLE vacancies (
	vacancyid SERIAL PRIMARY KEY,
	position varchar (150) NOT NULL,
	description varchar (250),
	min_salary integer,
	max_salary integer,
	experience integer,
	skills varchar (250),
	placement timestamp,
	expiry timestamp
);

CREATE TABLE resumes (
	resumeid SERIAL PRIMARY KEY,
	position varchar (150) NOT NULL,
	first_name varchar(50) NOT NULL,
	middle_name varchar (50),
	last_naem varchar (50) NOT NULL,
	min_salary integer,
	max_salary integer,
	experience integer,
	skills varchar(250)
);

CREATE TABLE responses (
	responseid SERIAL PRIMARY KEY,
	vacancyid integer REFERENCES vacancies(vacancyid),
	resumeid integer REFERENCES resumes(resumeid),
	response_date timestamp NOT NULL,
	status varchar (50) check (status in ('watched', 'unwatched'))
);


CREATE TABLE invitations (
	invitationid SERIAL PRIMARY KEY,
	vacancyid integer REFERENCES vacancies(vacancyid),
	resumeid integer REFERENCES resumes(resumeid),
	message varchar (250),
	invitaion_date timestamp
);

CREATE TABLE messages (
	messageid SERIAL PRIMARY KEY,
	vacancyid integer REFERENCES vacancies(vacancyid),
	resumeid integer REFERENCES resumes(resumeid),
	message varchar (250) NOT NULL,
	message_date timestamp
);

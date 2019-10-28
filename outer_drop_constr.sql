ALTER TABLE outer_base."education" DROP CONSTRAINT "education_resume_id_fkey";
ALTER TABLE outer_base."experience_detail" DROP CONSTRAINT "experience_detail_job_location_id_fkey";
ALTER TABLE outer_base."experience_detail" DROP CONSTRAINT "experience_detail_resume_id_fkey";
ALTER TABLE outer_base."message" DROP CONSTRAINT "message_resume_id_fkey";
ALTER TABLE outer_base."message" DROP CONSTRAINT "message_vacancy_id_fkey";
ALTER TABLE outer_base."respond" DROP CONSTRAINT "respond_resume_id_fkey";
ALTER TABLE outer_base."respond" DROP CONSTRAINT "respond_vacancy_id_fkey";
ALTER TABLE outer_base."resume" DROP CONSTRAINT "resume_account_id_fkey";
ALTER TABLE outer_base."resume_skill_set" DROP CONSTRAINT "resume_skill_set_resume_id_fkey";
ALTER TABLE outer_base."resume_skill_set" DROP CONSTRAINT "resume_skill_set_skill_id_fkey";
ALTER TABLE outer_base."vacancy" DROP CONSTRAINT "vacancy_company_id_fkey";
ALTER TABLE outer_base."vacancy" DROP CONSTRAINT "vacancy_job_location_id_fkey";
ALTER TABLE outer_base."vacancy" DROP CONSTRAINT "vacancy_posted_by_id_fkey";
ALTER TABLE outer_base."vacancy_skill_set" DROP CONSTRAINT "vacancy_skill_set_skill_id_fkey";
ALTER TABLE outer_base."vacancy_skill_set" DROP CONSTRAINT "vacancy_skill_set_vacancy_id_fkey";
ALTER TABLE outer_base."account" DROP CONSTRAINT "account_pkey";
ALTER TABLE outer_base."company" DROP CONSTRAINT "company_pkey" CASCADE;
ALTER TABLE outer_base."education" DROP CONSTRAINT "education_pkey";
ALTER TABLE outer_base."experience_detail" DROP CONSTRAINT "experience_detail_pkey";
ALTER TABLE outer_base."invitation" DROP CONSTRAINT "invitation_resume_id_fkey";
ALTER TABLE outer_base."invitation" DROP CONSTRAINT "invitation_vacancy_id_fkey";
ALTER TABLE outer_base."invitation" DROP CONSTRAINT "invitation_pkey";
ALTER TABLE outer_base."job_location" DROP CONSTRAINT "job_location_pkey";
ALTER TABLE outer_base."message" DROP CONSTRAINT "message_pkey";
ALTER TABLE outer_base."respond" DROP CONSTRAINT "respond_pkey";
ALTER TABLE outer_base."resume" DROP CONSTRAINT "resume_pkey";
ALTER TABLE outer_base."resume_skill_set" DROP CONSTRAINT "resume_skill_set_pkey";
ALTER TABLE outer_base."skill" DROP CONSTRAINT "skill_pkey";
ALTER TABLE outer_base."vacancy" DROP CONSTRAINT "vacancy_pkey";
ALTER TABLE outer_base."vacancy_skill_set" DROP CONSTRAINT "vacancy_skill_set_pkey";
ALTER TABLE outer_base."account" DROP CONSTRAINT "account_email_key";
ALTER TABLE outer_base."account" DROP CONSTRAINT "account_login_key";

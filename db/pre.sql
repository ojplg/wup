--create database wup;
--create user wupuser with password 'wupuserpass';
grant all on database wup to wupuser;
grant all on table exercise_sessions to wupuser;
grant all on table exercise_sets to wupuser;

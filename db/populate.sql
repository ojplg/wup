
insert into exercise_sessions (id, session_date) 
   values (1, date '2017-10-23');
insert into exercise_sessions (id, session_date) 
   values (2, date '2017-12-25');

insert into exercise_sets (id, session_id, exercise, sets, reps_per_set, weight) 
  select nextval('exercise_set_seq'),1,'Squat',5,5,155;
insert into exercise_sets (id, session_id, exercise, sets, reps_per_set, weight) 
  select nextval('exercise_set_seq'),1,'Bench Press',5,5,115;
insert into exercise_sets (id, session_id, exercise, sets, reps_per_set, weight) 
  select nextval('exercise_set_seq'),1,'Low Row',5,5,115;

insert into exercise_sets (id, session_id, exercise, sets, reps_per_set, weight) 
  select nextval('exercise_set_seq'),2,'Squat',5,5,155;
insert into exercise_sets (id, session_id, exercise, sets, reps_per_set, weight) 
  select nextval('exercise_set_seq'),2,'Overhead Press',5,5,115;
insert into exercise_sets (id, session_id, exercise, sets, reps_per_set, weight) 
  select nextval('exercise_set_seq'),2,'Deadlift',1,5,135;


-- psql -f initialize.sql wup

begin;

create sequence exercise_session_seq start 1;

create table exercise_sessions (
    id integer PRIMARY KEY,
    session_date date not null unique
);

create sequence exercise_set_seq start 1;

create table exercise_sets (
    id integer PRIMARY KEY,
    session_id integer not null REFERENCES exercise_sessions (id),
    exercise text not null,
    sets integer not null check (sets>0),
    reps_per_set integer not null check (reps_per_set>0),
    weight integer not null check (weight>0)
);

end;

-- psql -f initialize.sql wup

begin;

create sequence exercise_set_seq start 1;

create table exercise_sets (
    id integer not null,
    session_id integer not null,
    exercise text not null,
    sets integer not null,
    reps_per_set integer not null,
    weight integer not null
);

create sequence exercise_session_seq start 1;

create table exercise_sessions (
    id integer not null,
    session_date date not null
);

end;

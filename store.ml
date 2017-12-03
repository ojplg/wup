open Core
open! Postgresql
open Model

let conn_str="host=localhost dbname=wup user=wupuser password=wupuserpass"

let print_conn_info conn =
  printf "db      = %s\n" conn#db;
  printf "user    = %s\n" conn#user;
  printf "pass    = %s\n" conn#pass;
  printf "host    = %s\n" conn#host;
  printf "port    = %s\n" conn#port;
  printf "tty     = %s\n" conn#tty;
  printf "option  = %s\n" conn#options;
  printf "pid     = %i\n" conn#backend_pid

let result_status res =
  match res#status with
  | Empty_query -> print_endline("empty query")
  | Command_ok -> print_endline("Command ok")
  | Tuples_ok -> print_endline("Tuples ok")
  | Bad_response -> print_endline("Bad response")
  | Nonfatal_error -> print_endline("error")
  | Fatal_error -> print_endline("fatal error " ^ res#error)
  | _         -> print_endline("Do not know")

let parse_session results idx =
  ( results#getvalue idx 0, results#getvalue idx 1)

let rec parse_sessions results idx sessions =
  if idx < results#ntuples 
    then parse_session results idx :: parse_sessions results (idx+1) sessions
    else sessions

let parse_session_results con =
  match con#get_result with
  | Some res -> parse_sessions res 0 []
  | None     -> []

let find_exercise_sessions =
  try
    let con = new connection ~conninfo:conn_str () in
      con#send_query "select* from exercise_sessions";
      parse_session_results con
  with Postgresql.Error(m) -> print_endline("BAD " ^ string_of_error(m)); []

let parse_set results idx =
  { 
    Model.exercise=results#getvalue idx 2;
    sets=int_of_string(results#getvalue idx 3);
    reps_per_set=int_of_string(results#getvalue idx 4);
    weight=int_of_string(results#getvalue idx 5);
    session_id=results#getvalue idx 1;
  }

let rec parse_sets results idx sets =
  if idx < results#ntuples 
    then parse_set results idx :: parse_sets results (idx+1) sets
    else sets

let parse_set_results con =
  match con#get_result with
  | Some res -> parse_sets res 0 []
  | None     -> []

let find_exercise_sets =
  try 
     let con = new connection ~conninfo:conn_str () in
      con#send_query "select* from exercise_sets";
      parse_set_results con
  with Postgresql.Error(m) -> print_endline("BAD " ^ string_of_error(m)); []

let find_all_sessions =
  let ss = find_exercise_sessions in
    let sets = find_exercise_sets in
      List.map ss (fun sess_tuple-> { Model.date=snd sess_tuple;
                                      sets=List.filter sets (fun set->set.session_id=fst sess_tuple); }) 
      

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

let rec parse_results_recurse results idx ls datum_parser =
  if idx < results#ntuples
  then datum_parser results idx :: parse_results_recurse results (idx+1) ls datum_parser
  else ls

let execute_result_set con datum_parser =
  match con#get_result with
  | Some res -> parse_results_recurse res 0 [] datum_parser
  | None     -> []

let find_all_data query datum_parser =
  try
    let con = new connection ~conninfo:conn_str () in
      con#send_query query;
      execute_result_set con datum_parser
  with Postgresql.Error(m) -> print_endline("BAD " ^ string_of_error(m)); []

let parse_session_tuple results idx =
  ( int_of_string(results#getvalue idx 0), results#getvalue idx 1)

let find_exercise_sessions = find_all_data 
                              "select * from exercise_sessions" 
                              parse_session_tuple

let parse_set results idx =
  { 
    Model.exercise=results#getvalue idx 2;
    sets=int_of_string(results#getvalue idx 3);
    reps_per_set=int_of_string(results#getvalue idx 4);
    weight=int_of_string(results#getvalue idx 5);
    session_id=int_of_string(results#getvalue idx 1);
  }

let find_exercise_sets = find_all_data 
                           "select * from exercise_sets" 
                           parse_set

let find_all_sessions =
  let ss = find_exercise_sessions in
    let sets = find_exercise_sets in
      List.map ss (fun sess_tuple-> { Model.date=snd sess_tuple;
                                      sets=List.filter sets (fun set->set.session_id=fst sess_tuple); }) 
      

open Core
open! Postgresql

let print_conn_info conn =
  printf "db      = %s\n" conn#db;
  printf "user    = %s\n" conn#user;
  printf "pass    = %s\n" conn#pass;
  printf "host    = %s\n" conn#host;
  printf "port    = %s\n" conn#port;
  printf "tty     = %s\n" conn#tty;
  printf "option  = %s\n" conn#options;
  printf "pid     = %i\n" conn#backend_pid

let conn_str="host=localhost dbname=wup user=wupuser password=wupuserpass"

(*
let fetch_result c = wait_for_result c; c#get_result

let fetch_single_result c =
  match fetch_result c with
  | None -> assert false
  | Some r -> assert (fetch_result c = None); r
*)

let result_status res =
  match res#status with
  | Empty_query -> print_endline("empty query")
  | Command_ok -> print_endline("Command ok")
  | Tuples_ok -> print_endline("Tuples ok")
  | Bad_response -> print_endline("Bad response")
  | Nonfatal_error -> print_endline("error")
  | Fatal_error -> print_endline("fatal error " ^ res#error)
  | _         -> print_endline("Do not know")

let dump_result res = 
  print_endline("have a result");
  result_status res;
  print_endline("number of tuples " ^ string_of_int(res#ntuples));
  print_endline("number of nfields " ^ string_of_int(res#nfields))

let dump_out con = 
  match con#get_result with
  | Some res -> dump_result(res)
  | None     -> print_endline("No result found")

let do_stuff =
  try
    let con = new connection ~conninfo:conn_str () in
      print_conn_info con;
      con#send_query "select * from exercise_sessions";
      dump_out con;
      print_endline("and done");
      (*   print_endline(" found record number " ^ (res#fname 0)) *)
  with | Postgresql.Error(m) -> print_endline ("postgres error \n " 
                                                ^ string_of_error(m))
       | Not_found -> print_endline ("Something not found")

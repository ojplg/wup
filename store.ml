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

let do_stuff =
  try
    let con = new connection ~conninfo:conn_str () in
      print_conn_info con;
      let res = con#prepare "select trial" "select * from exercise_sessions" in
        print_endline("prepared");
        con#exec_prepared "select trial";
        let num = res#fnumber "id" in
          print_endline("found " ^ (string_of_int) num);
        print_endline("and done");
      (*   print_endline(" found record number " ^ (res#fname 0)) *)
  with | Postgresql.Error(m) -> print_endline ("postgres error \n " 
                                                ^ string_of_error(m))
       | Not_found -> print_endline ("Something not found")

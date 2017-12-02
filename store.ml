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

let do_stuff =
  try
    let con = new connection ~conninfo:conn_str () in
      print_conn_info con
  with Postgresql.Error(m) -> print_endline ("postgres error \n " 
                                                ^ string_of_error(m))

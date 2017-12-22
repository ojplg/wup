open Core

let get_connection_info conn =
     "db      = " ^ conn#db     ^ "\n" 
   ^ "user    = " ^ conn#user   ^ "\n"
   ^ "pass    = " ^ conn#pass   ^ "\n"
   ^ "host    = " ^ conn#host   ^ "\n"
   ^ "port    = " ^ conn#port   ^ "\n"
   ^ "tty     = " ^ conn#tty    ^ "\n"
   ^ "option  = " ^ conn#options     ^ "\n"
   ^ "pid     = " ^ conn#backend_pid ^ "\n"

let result_status res =
    let msg = match res#status with
      | Postgresql.Empty_query     -> "Empty query"
      | Postgresql.Command_ok      -> "Command ok"
      | Postgresql.Tuples_ok       -> "Tuples ok"
      | Postgresql.Bad_response    -> "Bad response"
      | Postgresql.Nonfatal_error  -> "Non fatal error"
      | Postgresql.Fatal_error     -> "fatal error " ^ res#error
      | _                          -> "Do not know"
      in Logs.info (fun m -> m "Result: %s" msg)

(* framework functions - find all functions *)

let rec parse_results_recurse results idx ls datum_parser =
  if idx < results#ntuples
  then datum_parser results idx :: parse_results_recurse results (idx+1) ls datum_parser
  else ls

let execute_result_set con datum_parser =
  match con#get_result with
  | Some res -> Logs.info(fun m -> m "Found results with %d" res#ntuples);
                parse_results_recurse res 0 [] datum_parser;
  | None     -> []

let find_all_data con_str query datum_parser =
  try
    let con = new Postgresql.connection ~conninfo:con_str () in
      con#send_query query;
      execute_result_set con datum_parser
  with Postgresql.Error(e) -> 
         let msg = Postgresql.string_of_error(e) in
           Logs.info (fun m -> m "DB error: %s" msg); 
         []

(* EXERCISE_SET table *)

let parse_set results idx =
  { 
    session_id=int_of_string(results#getvalue idx 1);
    Model.exercise=results#getvalue idx 2;
    sets=int_of_string(results#getvalue idx 3);
    reps_per_set=int_of_string(results#getvalue idx 4);
    weight=int_of_string(results#getvalue idx 5);
  }

let find_exercise_sets con_str = find_all_data 
                         con_str
                         "select id,session_id,exercise,sets,reps_per_set,weight from exercise_sets" 
                         parse_set

let insert_set_sql set =
    "insert into exercise_sets (id, session_id, exercise, sets, reps_per_set, weight) "
      ^ "select nextval('exercise_set_seq'), " 
      ^ string_of_int(set.Model.session_id) ^ ", "
      ^ "'" ^ set.exercise ^ "', "
      ^ string_of_int(set.sets) ^ ", "
      ^ string_of_int(set.reps_per_set) ^ ", "
      ^ string_of_int(set.weight) 

let insert_exercise_set con_str set =
  Logs.info (fun m -> m "doing set insert");
  try
    let con = new Postgresql.connection ~conninfo:con_str () in
      con#send_query(insert_set_sql set);
      let res=con#get_result in
        result_status(Util.opt_get(res));
        None
  with Postgresql.Error(m) -> Some (Postgresql.string_of_error(m))

(* EXERCISE_SESSION table *)

let insert_sql date_str =
       "insert into exercise_sessions (id, session_date) " 
           ^ "select nextval('exercise_session_seq'), '" ^ Date.to_string_american( date_str ) ^ "'"

let insert_session con_str date = 
  Logs.info (fun m -> m "doing session insert");
  try
    let con = new Postgresql.connection ~conninfo:con_str () in
      con#send_query (insert_sql date);
      let res=con#get_result in
        result_status(Util.opt_get(res));
        None
  with Postgresql.Error(m) -> Some (Postgresql.string_of_error(m))

let parse_session_tuple results idx =
  ( int_of_string(results#getvalue idx 0), results#getvalue idx 1)

let find_exercise_sessions con_str = find_all_data 
                                     con_str
                                     "select id,session_date from exercise_sessions" 
                                     parse_session_tuple

let find_session con_str date_str =
    Logs.info (fun m -> m "Searching for session %s" date_str);
    let sql = "select id, session_date from exercise_sessions "
                ^ " where session_date ='" ^ date_str ^ "'"
      in List.hd @@ find_all_data con_str sql parse_session_tuple

let db_tuple_to_session sets tuple =
    { 
      Model.id   = fst tuple;
      Model.date = Date.of_string @@ snd tuple;
      Model.sets = List.filter 
                     sets
                     (fun set-> set.Model.session_id = fst tuple);
    }

let find_all_sessions con_str =
  Logs.info (fun m -> m "Finding sessions");
  let ss = find_exercise_sessions con_str in
    Logs.info (fun m -> m "Found some sessions %d" (List.length ss));
    let sets = find_exercise_sets con_str in
      List.map ss (db_tuple_to_session sets)

let copy_sql from_id to_id =
    "insert into exercise_sets (id, session_id, exercise, sets, reps_per_set, weight) "
      ^ "select nextval('exercise_set_seq'), " 
      ^ to_id ^ " , exercise, sets, reps_per_set, weight "
      ^ "from exercise_sets "
      ^ "where session_id = " ^ from_id ^ ";"

let execute_copy con_str old_session_id new_session_id =
    let sql = copy_sql old_session_id new_session_id in
      let con = new Postgresql.connection ~conninfo:con_str () in
        con#send_query sql

let copy_session con_str date_str session_id =
    Logs.info (fun m -> m "Copying session %s id %s " date_str session_id);
    let insert_result = insert_session con_str (Date.of_string date_str); in
    match insert_result with
      | None -> Logs.info (fun m -> m "Did insert ");
                let new_session_tuple = find_session con_str date_str in 
                  let new_session_id = fst (Util.opt_get new_session_tuple) in 

                    execute_copy con_str session_id (string_of_int new_session_id);
                    None
      | Some x -> Some x
    


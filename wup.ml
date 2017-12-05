open Core

let squat_example = { Model.exercise="Squat"; sets=5; reps_per_set=5; weight=155; session_id=7 }
let bench_example = { Model.exercise="Bench"; sets=5; reps_per_set=5; weight=105 ; session_id=7}
let barbell_row_example = { Model.exercise="Barbell Row"; sets=5; reps_per_set=5; weight=75 ; session_id=7}
let overhead_press_example = { Model.exercise="Overhead Press"; sets=5; reps_per_set=5; weight=75 ; session_id=7}
let deadlift_example = { Model.exercise="Deadlift"; sets=2; reps_per_set=5; weight=135 ; session_id=7}

let example_session_1 = { Model.date="27-Nov-2017"; id=4; sets=[squat_example; bench_example; barbell_row_example] }
let example_session_2 = { Model.date="30-Nov-2017"; id=23; sets=[squat_example; overhead_press_example; deadlift_example] }

let parse_set_from_request req = let params = Http.extract_query_parameters req in
                                          { Model.exercise=Http.find_string_param params "Movement";
                                            sets=Http.find_int_param params "Sets";
                                            reps_per_set=Http.find_int_param params "Repetitions";
                                            weight=Http.find_int_param params "Weights";
                                            session_id = -1; } 
                           
let parse_date_from_request req = 
    Http.find_string_param (Http.extract_query_parameters req) "Date"
      
let home_page_binding = Opium.Std.get "/" 
                          begin
                            fun req -> print_endline("Serving home page"); 
                                       Store.find_all_sessions Store.conn_str
                              |> Html.home_page 
                              |> Html.render
                              |> Opium.Std.respond'
                          end

let new_set_binding = Opium.Std.get "/newset/:session_id"
                        begin
                          fun req -> Opium.Std.param req "session_id"
                            |> Html.set_form 
                            |> Html.render
                            |> Opium.Std.respond'
                        end

let submit_set_binding = Opium.Std.get "/submitset"
                           begin
                             fun req -> req
                               |> parse_set_from_request
                               |> Model.set_to_string
                               |> Html.simple_page
                               |> Html.render
                               |> Opium.Std.respond'
                           end

let submit_session_binding = Opium.Std.get "/submitsession"
                               begin
                                 fun req -> req 
                                   |> parse_date_from_request
                                   |> Store.insert_session
                                   |> Html.simple_page
                                   |> Html.render
                                   |> Opium.Std.respond'
                               end

let app =
  Opium.Std.App.empty 
  |> new_set_binding
  |> submit_set_binding
  |> submit_session_binding
  |> home_page_binding

let () =
  app
  |> Opium.Std.App.run_command


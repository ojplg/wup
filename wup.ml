open Core
open Model
open Opium.Std

let squat_example = { exercise="Squat"; sets=5; reps_per_set=5; weight=155 }
let bench_example = { exercise="Bench"; sets=5; reps_per_set=5; weight=105 }
let barbell_row_example = { exercise="Barbell Row"; sets=5; reps_per_set=5; weight=75 }
let overhead_press_example = { exercise="Overhead Press"; sets=5; reps_per_set=5; weight=75 }
let deadlift_example = { exercise="Deadlift"; sets=2; reps_per_set=5; weight=135 }

let example_session_1 = { date="27-Nov-2017"; sets=[squat_example; bench_example; barbell_row_example] }
let example_session_2 = { date="30-Nov-2017"; sets=[squat_example; overhead_press_example; deadlift_example] }

let parse_set_from_request req = let params = Http.extract_query_parameters req in
                                          { exercise=Http.find_string_param params "Movement";
                                            sets=Http.find_int_param params "Sets";
                                            reps_per_set=Http.find_int_param params "Repetitions";
                                            weight=Http.find_int_param params "Weights" } 
                           
let home_page_binding = get "/" 
                          begin
                            fun req -> Html.render (Html.home_page [example_session_1;
                                                                    example_session_2]) 
                            |> respond'
                          end

let new_set_binding = get "/new"
                        begin
                          fun req -> Html.render Html.set_form 
                          |> respond'
                        end

let submit_set_binding = get "/submitset"
                           begin
                             fun req -> Html.render (Html.simple_page (set_to_string (parse_set_from_request req)))
                             |> respond'
                           end

let app =
  App.empty 
  |> home_page_binding
  |> new_set_binding
  |> submit_set_binding

let () =
  app
  |> App.run_command


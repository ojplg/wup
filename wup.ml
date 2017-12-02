open Core

let squat_example = { Model.exercise="Squat"; sets=5; reps_per_set=5; weight=155 }
let bench_example = { Model.exercise="Bench"; sets=5; reps_per_set=5; weight=105 }
let barbell_row_example = { Model.exercise="Barbell Row"; sets=5; reps_per_set=5; weight=75 }
let overhead_press_example = { Model.exercise="Overhead Press"; sets=5; reps_per_set=5; weight=75 }
let deadlift_example = { Model.exercise="Deadlift"; sets=2; reps_per_set=5; weight=135 }

let example_session_1 = { Model.date="27-Nov-2017"; sets=[squat_example; bench_example; barbell_row_example] }
let example_session_2 = { Model.date="30-Nov-2017"; sets=[squat_example; overhead_press_example; deadlift_example] }

let parse_set_from_request req = let params = Http.extract_query_parameters req in
                                          { Model.exercise=Http.find_string_param params "Movement";
                                            sets=Http.find_int_param params "Sets";
                                            reps_per_set=Http.find_int_param params "Repetitions";
                                            weight=Http.find_int_param params "Weights" } 
                           
let home_page_binding = Opium.Std.get "/" 
                          begin
                            fun req -> [example_session_1; example_session_2] 
                              |> Html.home_page 
                              |> Html.render
                              |> Opium.Std.respond'
                          end

let new_set_binding = Opium.Std.get "/new"
                        begin
                          fun req -> Html.set_form 
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

let app =
  Opium.Std.App.empty 
  |> home_page_binding
  |> new_set_binding
  |> submit_set_binding

let () =
  app
  |> Opium.Std.App.run_command


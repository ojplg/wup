open Core

let conn_str="host=localhost dbname=wup user=wupuser password=wupuserpass"

let parse_set_from_request req = 
    let params = 
        Http.extract_query_parameters req in
      { Model.exercise=Http.find_string_param params "Movement";
        sets=Http.find_int_param params "Sets";
        reps_per_set=Http.find_int_param params "Repetitions";
        weight=Http.find_int_param params "Weights";
        session_id = Http.find_int_param params "Session" } 
                           
let parse_date_from_request req = 
    Http.find_string_param (Http.extract_query_parameters req) "Date"
      
let home_page con_str = 
    Store.find_all_sessions con_str
      |> Html.home_page

let home_page_binding = 
    begin
      fun req -> 
          print_endline("Serving home page"); 
          home_page conn_str
        |> Html.render
        |> Opium.Std.respond'
    end

let new_set_binding = 
    begin
      fun req -> 
          Opium.Std.param req "session_id"
        |> Html.set_form 
        |> Html.render
        |> Opium.Std.respond'
    end

let submit_set_binding = 
    begin
      fun req -> 
          req
        |> parse_set_from_request
        |> Store.insert_exercise_set conn_str
        |> Html.simple_page
        |> Html.render
        |> Opium.Std.respond'
     end

let submit_session_binding = 
    begin
      fun req -> 
          req 
        |> parse_date_from_request
        |> Store.insert_session conn_str
        |> Html.simple_page
        |> Html.render
        |> Opium.Std.respond'
    end

let app =
  Opium.Std.App.empty 
  |> Opium.Std.get "/newset/:session_id" new_set_binding
  |> Opium.Std.get "/newset/submitset" submit_set_binding
  |> Opium.Std.get "/submitsession" submit_session_binding
  |> Opium.Std.get "/" home_page_binding

let () =
  app
  |> Opium.Std.App.run_command


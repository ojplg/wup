open Core

let conn_str="host=localhost dbname=wup user=wupuser password=wupuserpass"

let get_query_param req name =
    (Opium.Std.Request.request req).resource 
      |> Uri.of_string
      |> Fn.flip Uri.get_query_param name
      |> Util.opt_get
 
let parse_set_from_request req = 
    { 
      Model.exercise = get_query_param req "Movement";
      sets           = int_of_string(get_query_param req "Sets");
      reps_per_set   = int_of_string(get_query_param req "Repetitions");
      weight         = int_of_string(get_query_param req "Weights");
      session_id     = int_of_string(get_query_param req "Session")
    } 
                           
let home_page con_str = 
    Store.find_all_sessions con_str
      |> Model.sort_sessions
      |> Html.home_page

let error_page error =
  error 
    |> Html.simple_page

let home_or_error possible_error = 
  match possible_error with
  | Some error -> Logs.info (fun m -> m "Had an error");
                     error_page error
                  |> Html.render
                  |> Opium.Std.respond'
  | None       -> Logs.info (fun m -> m "No error");
                  Opium.Std.redirect' @@ Uri.of_string "home"

let home_page_binding = 
    begin
      fun req -> 
          Logs.info (fun m -> m "Home page requested");
          home_page conn_str
        |> Html.render
        |> Opium.Std.respond'
    end

let new_set_binding = 
    begin
      fun req -> 
          Logs.info (fun m -> m "New set form requested");
          Opium.Std.param req "session_id"
        |> Html.set_form 
        |> Html.render
        |> Opium.Std.respond'
    end

let submit_set_binding = 
    begin
      fun req -> 
          Logs.info ( fun m -> m "New set submitted");
          req
        |> parse_set_from_request
        |> Store.insert_exercise_set conn_str
        |> home_or_error
     end

let submit_session_binding = 
    begin
      fun req -> 
          req 
        |> Fn.flip get_query_param "Date"
        |> Date.of_string
        |> Store.insert_session conn_str
        |> home_or_error
    end


let copy_session_binding = 
    begin
      fun req -> 
          Opium.Std.param req "session_id"
        |> Store.copy_session conn_str (Html.today_string (Time.now ()))
        |> home_or_error
    end

let app =
  Opium.Std.App.empty 
  |> Opium.Std.get "/newset/:session_id" new_set_binding
  |> Opium.Std.get "/submitset" submit_set_binding
  |> Opium.Std.get "/submitsession" submit_session_binding
  |> Opium.Std.get "/copy/:session_id" copy_session_binding
  |> Opium.Std.get "/" home_page_binding
  |> Opium.Std.get "/home" home_page_binding

let () =
  Logs.set_reporter (Logs.format_reporter ());
  Logs.set_level (Some Logs.Info);
  Logs.info (fun m -> m "Starting");
  app
  |> Opium.Std.App.run_command


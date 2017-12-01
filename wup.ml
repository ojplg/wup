open Opium.Std
open Async
open Core
open Cohttp.Request
open Cow.Html

type exercise_set = { exercise : string;
                      sets : int;
                      reps_per_set : int;
                      weight : int }

let set_to_string set = "Set. " ^ set.exercise ^ " sets: " ^ (string_of_int set.sets)
                                               ^ " reps_per_set: " ^ (string_of_int set.reps_per_set)
                                               ^ " weight: " ^ (string_of_int set.weight)

type exercise_session = { date : string;
                          sets : exercise_set list }

let squat_example = { exercise="Squat"; sets=5; reps_per_set=5; weight=155 }
let bench_example = { exercise="Bench"; sets=5; reps_per_set=5; weight=105 }
let barbell_row_example = { exercise="Barbell Row"; sets=5; reps_per_set=5; weight=75 }
let overhead_press_example = { exercise="Overhead Press"; sets=5; reps_per_set=5; weight=75 }
let deadlift_example = { exercise="Deadlift"; sets=2; reps_per_set=5; weight=135 }

let example_session_1 = { date="27-Nov-2017"; sets=[squat_example; bench_example; barbell_row_example] }
let example_session_2 = { date="30-Nov-2017"; sets=[squat_example; overhead_press_example; deadlift_example] }

let display set = set.exercise 
                    ^ " - " 
                    ^ string_of_int (set.sets * set.reps_per_set)
                    ^ "x"
                    ^ string_of_int set.weight

let sets_as_list sets = ul (List.map sets (fun s -> string (display s)))

let cow_content = html 
                               @@ body 
                                  @@ Cow.Html.Create.table ~flags:[] 
                                                  ~row:(fun session -> [string session.date; 
                                                                        sets_as_list session.sets]) 
                                                  [example_session_1; example_session_2]

let label lbl = tag "label" (string lbl)

let select form_id name opts = tag "select" 
                                   ~attrs:["form", form_id; "name", name] 
                                   (list (List.map opts (fun opt -> tag "option" (string opt))))

let weights = ["50";"55";"60";"65"]

let new_form = html 
               @@ body
                  @@ tag "form" ~attrs:["id","new_set";"action","/submitset"]
                     (list
                       [label "Movement";
                        select "new_set" "Movement" ["Squat"; "Bench"; "Barbell Row"; "Overhead Press"; "Deadlift"];
                        br empty;
                        label "Sets";
                        select "new_set" "Sets" ["1"; "2"; "3"; "4"; "5"];
                        br empty;
                        label "Repetitions";
                        select "new_set" "Repetitions" ["1"; "2"; "3"; "4"; "5"; "6"; "7"; "8"; "9"; "10"];
                        br empty;
                        label "Weight";
                        select "new_set" "Weights" weights;
                        br empty;
                        tag "input" ~attrs:["type","submit";"value","Submit"] empty])

let render_request req = App.param req "foo"

let foo_content req = `String (to_string (html @@ body @@ p (string (render_request req)))) |> respond'

let get_parameter req name = try App.param req name
                             with e -> Exn.to_string e ^ " " 

let parse_parameters req = let s = { exercise=get_parameter req "Movement";
                                     sets=2;
                                     reps_per_set=3;
                                     weight=75 } in set_to_string s
                                     (*
                                     sets=int_of_string (App.param req "Sets");
                                     reps_per_set=int_of_string (App.param req "Repetitions");
                                     weight=int_of_string (App.param req "Weights") } in set_to_string s
                                     *)
                           
let handle_submission req = html @@ body @@ p (string (parse_parameters req))

let app =
  App.empty 
  |> (get "/" ( ( fun req -> `String (to_string cow_content ) |> respond')  ))
  |> (get "/foo" foo_content)
  |> (get "/new" begin fun req -> `String (to_string new_form) |> respond' end)
  |> (get "/submitset" begin fun req -> `String (to_string (handle_submission req)) |> respond' end)

let () =
  app
  |> App.run_command


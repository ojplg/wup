open Opium.Std
open Async
open Core
open Cow.Html

type exercise_set = { exercise : string;
                      sets : int;
                      reps_per_set : int;
                      weight : int }

type exercise_session = { date : string;
                          sets : exercise_set list }

let squat_example = { exercise="Squat"; sets=5; reps_per_set=5; weight=155 }
let bench_example = { exercise="Bench"; sets=5; reps_per_set=5; weight=105 }
let overhead_press_example = { exercise="Overhead Press"; sets=5; reps_per_set=5; weight=75 }

let example_session = { date="27-Nov-2017"; sets=[squat_example; bench_example; overhead_press_example] }

let display set = set.exercise 
                    ^ " - " 
                    ^ string_of_int (set.sets * set.reps_per_set)
                    ^ "x"
                    ^ string_of_int set.weight

let sets_as_list sets = ul (List.map sets (fun s -> string (display s)))

let cow_content = to_string @@ html 
                               @@ body 
                                  @@ Create.table ~flags:[] 
                                                  ~row:(fun session -> [string session.date; 
                                                                        sets_as_list session.sets]) 
                                                  [example_session]

let app =
  App.empty |> (get "/" begin fun req ->
  `String cow_content |> respond'
  end)

let () =
  app
  |> App.run_command


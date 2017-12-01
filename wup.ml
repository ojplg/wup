open Opium.Std
open Async
open Core
open Cow.Html

type exercise_set = { exercise : string;
                      sets : int;
                      reps_per_set : int;
                      weight : int }

let squat_example = { exercise="Squat"; sets=5; reps_per_set=5; weight=155 }

let render_attribute (name, value) =
    name ^ "=" ^ value
 
let render_attributes attributes =
    String.concat ~sep:" " (List.map attributes render_attribute)

let render_element element attributes content =
      "<" ^ element 
          ^ (render_attributes attributes) ^ ">"
          ^ content ^
      "</" ^ element ^ ">"

let build_item content = render_element "li" [] content

let build_list items = render_element "ul"
                                      []
                                      (String.concat ~sep:"\n" items)

let build_td content = render_element "td" [] content

let date_data date = render_element "td"
                                    ["class", "date"]
                                    date

let build_row data = render_element "tr"
                                    []
                                    (String.concat ~sep:"\n" data)

let display set = set.exercise ^ " - " 
                               ^ string_of_int (set.sets * set.reps_per_set)
                               ^ "x"
                               ^ string_of_int set.weight

let example_content = render_element "html" [] (render_element "body" [] 
                        (build_row [date_data "27-Nov-2017";
                                    build_td (build_list [build_item 
                                             (display squat_example)])]))

let cow_content = to_string @@ html 
                               @@ body 
                                  @@ p @@ string "Hello"

let app =
  App.empty |> (get "/" begin fun req ->
  `String cow_content |> respond'
  end)

let () =
  app
  |> App.run_command


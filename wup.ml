open Core

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
      "<" ^ element ^ ">"
          ^ (render_attributes attributes) 
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

let () = Out_channel.output_string stdout (build_row 
                                           [date_data "27-Nov-2017";
                                            build_td 
                                              (build_list [build_item 
                                                             (display squat_example)
                                                                   ])])


open Core
open Cow.Html

let label lbl = tag "label" (string lbl)

let select form_id name opts = tag "select" 
                                   ~attrs:["form", form_id; "name", name] 
                                   (list (List.map opts 
                                                   (fun opt -> tag "option" (string opt))))

let display set = set.Model.exercise 
                    ^ " - " 
                    ^ string_of_int (set.sets * set.reps_per_set)
                    ^ "x"
                    ^ string_of_int set.weight

let sets_as_list sets = ul (List.map sets (fun s -> string (display s)))

let home_page ss = html 
                    @@ body 
                      @@ Create.table ~flags:[] 
                                      ~row:(fun session -> [string session.Model.date; 
                                                            sets_as_list session.sets]) 
                                      ss

let weights = ["50";"55";"60";"65"]

let set_form = html 
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


let simple_page content = html @@ body @@ p (string content)

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

let session_link id date_str =
  let url = Uri.of_string("/newset/" ^ string_of_int(id)) in
    a url (string date_str)

let home_page ss = 
      html 
        @@ body 
          (list
            [p (string "Welcome");
             Create.table ~flags:[] 
               ~row:(fun session -> [session_link session.Model.id session.Model.date; 
                                     sets_as_list session.sets]) 
               ss;
             p (string "Enter new session date below!");
             tag "form" ~attrs:["id","new_session";"action","/submitsession"]
               (list
                 [tag "input" ~attrs:["type","date";"name","Date"] empty;
                 tag "input" ~attrs:["type","submit";"value","Submit"] empty])
            ]
          )

let weights = ["50";"55";"60";"65"]

let set_form session_id = 
    html 
      @@ body
        @@ tag "form" ~attrs:["id","new_set";"action","/submitset"]
             (list
               [tag "input" ~attrs:["type","hidden";"value",session_id;"name","Session"] empty;
                br empty;
                label "Movement";
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

let render h = `String (to_string h)

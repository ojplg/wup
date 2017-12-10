open Core
open Cow.Html

let rec build_list_recur low high increment ls =
  if low > high 
    then ls
    else low :: build_list_recur (low+increment) high increment ls

let build_list low high increment =
  List.rev (List.map (build_list_recur low high increment []) string_of_int)

let label lbl = tag "label" (string lbl)

let select form_id name opts = tag "select" 
                                   ~attrs:["form", form_id; "name", name] 
                                   (list (List.map opts 
                                                   (fun opt -> tag "option" (string opt))))

let css = tag 
    "link" 
    ~attrs:["rel","stylesheet";
            "href","https://unpkg.com/purecss@1.0.0/build/pure-min.css";
            "integrity","sha384-nn4HPE8lTHyVtfCBi5yW9d20FjT8BJwUXyWZT9InLYax14RDjBj46LmSztkmNP9w";
            "crossorigin","anonymous"]
    empty

let today_string time_now =
  let tz = Time.Zone.of_utc_offset(-6) in
    Time.format time_now "%Y-%m-%d" tz

let header =
    head 
      (list
        [title (string "Wup");
         css])

let display set = set.Model.exercise 
                    ^ " - " 
                    ^ string_of_int (set.sets * set.reps_per_set)
                    ^ "x"
                    ^ string_of_int set.weight

let sets_as_list sets = ul (List.map sets (fun s -> string (display s)))

let session_link id date_str =
  let url = Uri.of_string("newset/" ^ string_of_int(id)) in
    a url (string (Date.to_string_american date_str))
 
let home_table ss =
    tag "table"
      ~attrs:["class","pure-table pure-table-bordered"] 
      (list
        (List.map 
          ss
          (fun session -> 
            tag "tr" 
              ~attrs:[]
              (list 
                [tag "td"
                  ~attrs:[]
                  (session_link session.Model.id session.Model.date);
                 tag "td" 
                   ~attrs:[]
                   (sets_as_list session.sets)])) ))
 
let home_page ss = 
      html 
        (list 
          [header;
           body 
            (list
              [p (string "Welcome");
               home_table ss;
               p (string "Enter new session date below!");
               tag "form" ~attrs:["id","new_session";"action","submitsession"]
                 (list
                   [tag "input" ~attrs:["type","date";
                                        "name","Date";
                                        "value",today_string (Time.now ())] empty;
                   tag "input" ~attrs:["type","submit";"value","Submit"] empty])
              ]
            )
          ]
        )

let weights = build_list 65 185 5
let five_to_one = build_list 1 5 1

let set_form session_id = 
    html 
      (list 
        [header;
         body
           @@ tag "form" ~attrs:["id","new_set";
                                 "action","../submitset";
                                 "class","pure-form pure-form-aligned"]
               (list
                 [tag "input" ~attrs:["type","hidden";"value",session_id;"name","Session"] empty;
                  div ~attrs:["class","pure-control-group"]
                    (list [
                      label "Movement";
                      select "new_set" "Movement" ["Squat"; "Bench"; "Barbell Row"; "Overhead Press"; "Deadlift"]]);
                  div ~attrs:["class","pure-control-group"]
                    (list [
                       label "Sets";
                       select "new_set" "Sets" five_to_one]);
                  div ~attrs:["class","pure-control-group"]
                    (list [
                      label "Repetitions";
                      select "new_set" "Repetitions" five_to_one]);
                  div ~attrs:["class","pure-control-group"]
                    (list [
                      label "Weight";
                      select "new_set" "Weights" weights]);
                  tag "input" 
                      ~attrs:["type","submit";
                              "value","Submit";
                              "class","pure-controls"]
                       empty])])


let simple_page content = html @@ body @@ p (string content)

let render h = `String (to_string h)

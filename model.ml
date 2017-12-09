open Core

type exercise_set = 
    { 
      exercise : string;
      session_id : int;
      sets : int;
      reps_per_set : int;
      weight : int 
    }

type exercise_session = 
    { 
      id : int;
      date : Date.t;
      sets : exercise_set list 
    }

let set_to_string set = 
    "Set. " ^ set.exercise ^ " sets: " ^ (string_of_int set.sets)
      ^ " reps_per_set: " ^ (string_of_int set.reps_per_set)
      ^ " weight: " ^ (string_of_int set.weight)

let session_to_string sess = 
    "Session. " ^ (Date.to_string_american (sess.date))
      ^ String.concat ~sep:"\n" (List.map sess.sets set_to_string)

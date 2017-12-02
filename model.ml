
type exercise_set = { exercise : string;
                      sets : int;
                      reps_per_set : int;
                      weight : int }

let set_to_string set = "Set. " ^ set.exercise ^ " sets: " ^ (string_of_int set.sets)
                                               ^ " reps_per_set: " ^ (string_of_int set.reps_per_set)
                                               ^ " weight: " ^ (string_of_int set.weight)

type exercise_session = { date : string;
                          sets : exercise_set list }



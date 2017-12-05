
let opt_get opt = 
    match opt with
    | Some x -> x
    | None -> raise Not_found


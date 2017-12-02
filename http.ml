open Core
open Opium.Std

let rec build_param_assoc_list assoc params = match params with
                                              | []      -> assoc
                                              | p :: tl -> let ps = String.split p ~on:'=' in 
                                                             (Util.opt_get (List.nth ps 0), Util.opt_get (List.nth ps 1)) :: 
                                                               build_param_assoc_list assoc tl

let extract_query_parameters req = let url = (Request.request req).resource in 
                                     let idx = Util.opt_get (String.index url '?') in 
                                       let len = (String.length url) - idx in
                                         let query = String.sub url (idx + 1) (len -1) in
                                           let param_strings = String.split query ~on:'&' in
                                             build_param_assoc_list [] param_strings 

let find_string_param assoc key = List.Assoc.find_exn assoc ~equal:(fun x y->x=y) key

let find_int_param ls k = int_of_string (find_string_param ls k)


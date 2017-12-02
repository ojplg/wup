open Core

let label lbl = Cow.Html.tag "label" (Cow.Html.string lbl)

let select form_id name opts = Cow.Html.tag "select" 
                                            ~attrs:["form", form_id; "name", name] 
                                            (Cow.Html.list 
                                              (List.map opts 
                                                        (fun opt -> Cow.Html.tag "option" 
                                                                                 (Cow.Html.string opt))))

open Core

let build_row date items = "<tr>\n<td class=\"date\">" ^ date ^ "</td>\n"
                              ^ "<td><ul>"
                              ^ (String.concat ~sep:"\n" items)
                              ^ "</ul></td>\n</tr>\n\n"
let render_attribute (name, value) =
    name ^ "=" ^ value
 
let render_attributes attributes =
    String.concat ~sep:" " (List.map attributes render_attribute)

let render_element element attributes content =
      "<" ^ element ^ ">"
          ^ (render_attributes attributes) 
          ^ content ^
      "</" ^ element ^ ">"

let build_item exercise repetitions weight = render_element "li"
                                             []
                                             ( exercise 
                                              ^ " - "
                                              ^ repetitions
                                              ^ "x"
                                              ^ weight )

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


let () = Out_channel.output_string stdout (build_row 
                                           [date_data "27-Nov-2017";
                                            build_td 
                                              (build_list [build_item "Squat"
                                                                   "25"
                                                                   "155"])])


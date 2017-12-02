eval `opam config env`

ocamlfind ocamlc -linkpkg -thread -package core,async,opium,cow model.ml html.ml wup.ml -o wup

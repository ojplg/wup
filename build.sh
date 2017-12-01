eval `opam config env`

ocamlfind ocamlc -linkpkg -thread -package core,async,opium  wup.ml -o wup

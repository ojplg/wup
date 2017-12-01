eval `opam config env`

ocamlfind ocamlc -linkpkg -thread -package core,async,opium,cow  wup.ml -o wup

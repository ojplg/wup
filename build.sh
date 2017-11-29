eval `opam config env`

ocamlfind ocamlc -linkpkg -thread -package core wup.ml -o wup

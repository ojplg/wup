eval `opam config env`

PACKAGES=async\
,core\
,cow\
,logs\
,opium\
,postgresql

FILES="util.ml model.ml store.ml html.ml wup.ml"

ocamlfind ocamlc -linkpkg -thread -package $PACKAGES $FILES -o wup

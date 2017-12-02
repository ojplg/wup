eval `opam config env`

PACKAGES=async\
,core\
,cow\
,opium\
,postgresql

FILES="util.ml model.ml store.ml http.ml html.ml wup.ml"

ocamlfind ocamlc -linkpkg -thread -package $PACKAGES $FILES -o wup

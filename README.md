# wup
Simple web application for some primitive CRUD operations for tracking exercise. I am working on this to learn OCaml.

I do not understand the OCaml pakaging and build system, so things are even more crufty and primitive than my usual low standard.

# Random thoughts about OCaml

1) Compiler seems lame. Only finds one error at a time and then gives up.
2) I loves me the pipe (|>) operator. More intuitive to me than the threading macros in Clojure.
3) The way no-arg functions are considered constant and can run at start of a program is odd to me. Functions in OCaml are not always pure, so just because something has no arguments does not mean it always does the same thing, and since there is no equivalent of an IO Action a-la Haskell, it can get things screwed up. Very possible I am missing things here.
4) The library for Postgres integration seems weakly typed. Why handle everything with strings? Java does much better here, though perhaps a different library does things more tightly. Again, I could be missing a lot of things here.
5) I do love the great specificity and simplicity of type errors with line and character given. Seems easier than GHC.
6) I miss list comprehensions.

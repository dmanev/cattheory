# Cattheory library and exercises

This is scientific library with exersises intended for learning Cathegory Theory.

## How to run

### Preconditions

* Have installed [coq](https://coq.inria.fr/download)
  * tested currently with `coq 8.18.0`
* Optionally you could use [VSCode coq plugin](https://github.com/coq-community/vscoq)

### Steps

* Each module has to be separately compiled with
```
$ coqc <module_name.v>
```
* The two focal modules are:
  * `Notations.v`
  * `Common.v`
* If you are trying to compile an `Exercise_*.v` all its' dependencies has to be successfully compiled

## TODO
* Compile all Exercise files successfully
* Organize the project with up to date capabilities of `coq`
  * ref: [Categories project](https://github.com/amintimany/Categories)

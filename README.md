Linux-misc
==========

Scripts for everyday use.

## Pok 

Handles opening of pdf-files or directories of pdf-files given as cmd-line arguments in the 
Okular pdf-viewer.

_Working with Okular v. 0.19.3 - earlier versions of Okular needed multiple calls to open
several pdf's; this version of pok is not compatible with those._

#### Features

* When given specific pdf-files as part of list of arguments - opens these in Okular.
* When given directories as part of the arguments, pok searches non-recursively for pdf-files
within the directories, and adds them to the pdf's-to-be-opened.
* When supplied no argument, pok acts as though you supplied the current working directory as
argument.
* The output of Okular is suppressed, so you can continue working in your current terminal.

#### Use-cases

* Quickly open pdf-files when working in a terminal environment.
* From within Emacs use `M-x !` to call `pok` with some pdf from the current working directory.
* Make a directory for *active pdf's* with symbolic links to the pdf's you're currently reading
and supply the directory as argument to `pok` for quick-opening. 

#### Dependencies

* Okular https://okular.kde.org/
* OCaml http://ocaml.org/
* _(Optional)_ Opam https://opam.ocaml.org/
* Batteries included https://github.com/ocaml-batteries-team/batteries-included
* OCaml Pcre https://github.com/mmottl/pcre-ocaml/
* OCaml Text https://github.com/vbmithr/ocaml-text

_OCaml packages can be found on opam._

#### How to compile

Run `ocamlbuild -use-ocamlfind pok.native` from within directory containing `pok.ml`.

## Cdot

Copy current working directory path to the *X-servers primary selection*.

#### Use-cases

* When working in several terminals / GNU-screen, quickly copy cwd to primary selection
and paste with `Shift + Insert` or _MiddleMouse_ in other window.
* When editing source code within Emacs and need to run some build-scripts several times,
it might be more practical to run the buildscripts from another terminal window than from
Emacs - run `M-x ! cdot` in Emacs and then `cd` to the pasted directory from
within the other terminal window.

#### Dependencies

* xsel http://www.vergenet.net/~conrad/software/xsel/
* bash _(std. utility on GNU/Linux)_

## Cpugrep

Watch a live-updating view of the each cpu-cores frequency.

#### Dependencies

* watch _(std. utility on GNU/Linux)_
* grep _(std. utility on GNU/Linux)_
* bash _(std. utility on GNU/Linux)_

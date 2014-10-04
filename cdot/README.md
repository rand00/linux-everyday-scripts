Cdot
================

Copy current working directory path to the *X-servers primary selection*.

## Use-cases

* When working in several terminals / GNU-screen, quickly copy cwd to primary selection
and paste with `Shift + Insert` or _MiddleMouse_ in other window.
* When editing source code within Emacs and need to run some build-scripts several times,
it might be more practical to run the buildscripts from another terminal window than from
Emacs - run `M-x ! cdot` in Emacs and then `cd` to the pasted directory from
within the other terminal window.

## Dependencies

* xsel http://www.vergenet.net/~conrad/software/xsel/
* bash _(std. utility on GNU/Linux)_

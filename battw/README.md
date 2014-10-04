Battw 
================

A cmd-line application for keeping a watch on how much laptop-battery-capacity is left.
The command is separated into two files for `watch` to be able execute the `batt` script.

## Use-case
* When using a terminal frame-manager, e.g. GNU-screen, set one tab to watch the battery
left by running `battw`.
* When using a tiling window-manager, e.g. StumpWM, have a minimal frame in top/bottom of
screen to watch battery-level. `watch` also outputs the time, so works as a simple
terminal-based mode-line.

## Dependencies

* acpi 
* notify-send _- standard on ubuntu_ 
* paplay _- from pulseaudio - standard on ubuntu_ 
* watch _(std. utility on GNU/Linux)_
* bash _(std. utility on GNU/Linux)_

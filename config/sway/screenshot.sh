#!/bin/bash

FILENAME="screenshot-`date +%F-%T`"
FILEPATH="$HOME/Pictures/Screenshots/$FILENAME.png"

unclutter --timeout 0 &
grim -g "$(slurp)" $FILEPATH

killall unclutter
wl-copy < $FILEPATH

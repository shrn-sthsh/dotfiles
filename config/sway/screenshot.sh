#!/bin/bash

FILENAME="screenshot-`date +%F-%T`"
# grim -g "$(slurp)" ~/Pictures/Screenshots/$FILENAME.png | swappy -f -

grim -o $(swaymsg -t get_outputs | jq -r '.[] | select(.focused) | .name') - | wl-copy -t image/png

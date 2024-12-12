#!/usr/bin/env sh

# Terminate already running bar instances
killall -q waybar

# Wait until the processes have been killed
while pgrep -x waybar > /dev/null; do sleep 1; done

# Temporaily double the number of file descriptors 
# allowed to be spawned by terminal
ulimit -n $((2 * $(ulimit -n)))

# Launch waybar
waybar &

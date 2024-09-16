#!/bin/sh

# Times the screen off and puts it to background
swayidle \
    timeout 10 'swaymsg "output * dpms off"' \
    resume 'swaymsg "output * dpms on"' &

# Locks the screen immediately
swaylock --image "$1" \
  --indicator-radius 100 \
	--indicator-thickness 8 \
  --font JetBrainsMonoNerdFont \
  --font-size 48 \
  --text-color=#ffffff \
  --text-clear-color=#ffffff \
  --text-caps-lock-color=#ffffff \
  --text-ver-color=#ffffff \
  --text-wrong-color=#ffffff \
	--bs-hl-color=#4926ae \
  --indicator-radius=100 \
  --indicator-thickness=8 \
  --inside-color=#1616363f \
  --inside-clear-color=#4926ae7f \
  --inside-ver-color=#9BCCBF8f \
  --inside-wrong-color=#FF761Abf \
  --key-hl-color=#6699ff \
  --line-color=#000000 \
  --line-clear-color=#161636 \
  --line-caps-lock-color=#161636 \
  --line-ver-color=#161636 \
  --line-wrong-color=#161636 \
  --ring-color=#a1bce1 \
  --ring-clear-color=#4926ae \
  --ring-ver-color=#9bccbf \
  --ring-wrong-color=#ff761a \
  --separator-color=#000000 \
  -c 550000 

# Kills last background task so idle timer doesn't keep running
kill %%

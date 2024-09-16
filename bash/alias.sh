#!/bin/bash

## Device contorl
# display
alias dsp='brightnessctl set'

# audio
alias vol='wpctl set-volume -l 1.0 @DEFAULT_SINK@'

# keyboard
alias kbd='brightnessctl --device="kbd_backlight" set'

## Commands
# status
alias fetch='fastfetch'

# files
alias ls='exa'
alias ll='exa -lh'
alias tree='exa --tree'

# file content
alias cat='bat --theme=ansi'

# changing directories
alias cd='z'

# file browsers
alias fb='ranger'

# line count
alias lc='xargs wc -l'

# docker
alias docker='sudo docker'

# window managers
PATH="$PATH:$HOME/System/sway"
alias startw='XDG_SESSION_TYPE=wayland dbus-run-session gnome-session'

# gui tools
alias open='xdg-open'

# network
alias wifi='nmcli device wifi'

# neovim
alias nvimdiff='nvim -d'

# tmux
alias list-sessions='tmux list-sessions'
alias new-session='tmux new -t'
alias attach-session='tmux attach -t'
alias kill-session='tmux kill-session -t'
alias kill-server='tmux kill-server'

# cargo
export PATH=$PATH:$HOME/.cargo/bin/

# pacman
alias pacman='pacaptr'

# lock screen
alias lockscreen='vlock'

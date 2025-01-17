# .rc


############################## Set up PATH & bash completion ###########################

# Source global definitions
if [ -f /etc/bashrc ]; then
  source /etc/bashrc
fi

# User specific environment
if ! [[ "$PATH" =~ "$HOME/.local/bin:$HOME/bin:" ]]; then
  export PATH="$HOME/.local/bin:$HOME/bin:$PATH"
fi
if [[ "$OSTYPE" == "darwin"* ]]; then
  export PATH=/opt/homebrew/bin:/usr/local/bin:/System/Cryptexes/App/usr/bin:/usr/bin:/bin:/usr/sbin:/sbin
fi
if [ -d "$HOME/.bin" ]; then
  for dir in $(find "$HOME/.bin" -type d -name "bin"); do
    PATH="$dir:$PATH"
  done
fi

# Bash completion
if [[ $OSTYPE == "darwin"* ]] && [[ -r "$(brew --prefix)/etc/profile.d/bash_completion.sh" ]]; then
  source "$(brew --prefix)/etc/profile.d/bash_completion.sh"
fi

# Space from prompt
if [[ $- != *i* ]]; then
  echo ""
fi


############################## Run dotfiles set up scripts #############################

# User specific aliases and functions
if [ -d $HOME/.bashrc.d ]; then
  for rc in $HOME/.bashrc.d/*; do
    if [ -f "$rc" ]; then
      source "$rc"
    fi
  done
fi
unset rc

# Load utilities
dotfiles="$HOME/.dotfiles"
if [ -d "$dotfiles/shell/util/" ]; then
  for script in "$dotfiles/shell/util/"*.sh; do
    if [ -f "$script" ]; then
      source "$script"
    fi
  done
fi

# Apply aliases
aliasing_success=true
if [ -f "$dotfiles/shell/cmd.sh" ]; then
  source "$dotfiles/shell/cmd.sh"

  if [ "$?" -ne 0 ]; then
    aliasing_success=false
  fi
fi

# Set environment
if [ -f "$dotfiles/shell/env.sh" ]; then
  source "$dotfiles/shell/env.sh"
fi

# Load modules
if [ -d "$dotfiles/shell/mod/" ]; then
  for script in "$dotfiles/shell/mod/"*.sh; do
    if [ -f "$script" ]; then
      source "$script"
    fi
  done
fi

# Check for updates to configurations
state="$dotfiles/shell/.cache/setup.cache" 
if ! [ -f "$state" ]; then
  bash "$dotfiles/setup.sh"
else
  linked="$(sed -n '2p' "$state")"
  backed="$(sed -n '3p' "$state")"

  actual="$(find "$HOME/.config" -mindepth 1 -maxdepth 1 -type d | wc -l)"
  expect="$(($backed-$linked))"
  if [ "$actual" -gt "$expect" ]; then
    bash "$dotfiles/setup.sh"
  fi
fi


############################## Start up interactive session ############################

if [[ $- != *i* ]]; then
  return 0
fi

# Set bash prompt
set_bash_prompt
set -o vi

# Double console font size if running in Linux TTY
if [[ "$OSTYPE" == "linux-gnu" ]] && [[ "$(tty)" =~ "/dev/tty" ]] && [[ "$-" == *i* ]]; then
  setfont ter-u32n
  sleep 1.5
fi

# Write start up system information if iteractive session
if [[ "$aliasing_success" == true ]] && type clean &> /dev/null; then
  clean
fi

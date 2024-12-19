# .bashrc


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
if [ -d "$HOME/.dotfiles/shell/util/" ]; then
  for script in "$HOME/.dotfiles/shell/util/"*.sh; do
    if [ -f "$script" ]; then
      source "$script"
    fi
  done
fi

# Apply aliases
aliasing_success=true
if [ -f "$HOME/.dotfiles/shell/name.sh" ]; then
  source "$HOME/.dotfiles/shell/name.sh"

  if [ "$?" -ne 0 ]; then
    aliasing_success=false
  fi
fi

# Set environment
if [ -f $HOME/.dotfiles/shell/env.sh ]; then
  source $HOME/.dotfiles/shell/env.sh
fi

# Load modules
if [ -d "$HOME/.dotfiles/shell/mod/" ]; then
  for script in "$HOME/.dotfiles/shell/mod/"*.sh; do
    if [ -f "$script" ]; then
      source "$script"
    fi
  done
fi


############################## Start up interactive session ############################

if [[ $- != *i* ]]; then
  return 0
fi

# Set bash prompt
set_bash_prompt
set -o vi

# Double console font size if running in Linux TTY
if [[ "$OSTYPE" == "linux-gnu" ]] && [[ $(tty) =~ "/dev/tty" ]] && [[ $- == *i* ]]; then
  setfont ter-u32n
  sleep 1.5
fi

# Write start up system information if iteractive session
if [[ "$aliasing_success" == true ]] && type clean &> /dev/null; then
  clean
fi
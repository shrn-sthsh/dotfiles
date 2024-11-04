# .bashrc

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

# Script successes variable
success=true

# User specific aliases and functions
if [ -d $HOME/.bashrc.d ]; then
  for rc in $HOME/.bashrc.d/*; do
    if [ -f "$rc" ]; then
      source "$rc"
    fi
  done
fi
unset rc

# Apply aliases and import utilities and modules
if [ -f "$HOME/.dotfiles/bash/name.sh" ]; then
  source "$HOME/.dotfiles/bash/name.sh"

  if [ "$?" -ne 0 ]; then
    success=false
  fi
fi
if [ -f $HOME/.dotfiles/bash/env.sh ]; then
  source $HOME/.dotfiles/bash/env.sh
fi
if [ -d "$HOME/.dotfiles/bash/util/" ]; then
  for script in "$HOME/.dotfiles/bash/util/"*.sh; do
    if [ -f "$script" ]; then
      source "$script"
    fi
  done
fi
if [ -d "$HOME/.dotfiles/bash/mod/" ]; then
  for script in "$HOME/.dotfiles/bash/mod/"*.sh; do
    if [ -f "$script" ]; then
      source "$script"
    fi
  done
fi


# Bash prompt
   RED="\[\033[0;31m\]"
 GREEN="\[\033[0;32m\]"
YELLOW="\[\033[1;33m\]"
  BLUE="\[\033[1;34m\]"
PURPLE="\[\033[0;35m\]"
  CYAN="\[\033[0;36m\]"
 WHITE="\[\033[1;37m\]"
 CLEAR="\[\e[0m\]"

function set_bash_prompt()
{
  # Turn off showing environment
  export VIRTUAL_ENV_DISABLE_PROMPT=1

  # prepend new line for TTY for MacBook curved bezels
  if ! pgrep -x sway > /dev/null || ! pgrep -x gnome > /dev/null; then
    export PS1="\n"
  else
    export PS1=""
  fi
 
  # set style and colors
  export PS1=$PS1"${YELLOW}\t"
  export PS1=$PS1"${GREEN}\`parse_python_env\`"
  export PS1=$PS1"$CLEAR ["
  export PS1=$PS1"${BLUE}\u${CLEAR}@${CYAN}\h"
  export PS1=$PS1"${PURPLE} \`parse_git_branch\`"
  export PS1=$PS1"${CLEAR}\`git_branch_junction\`"
  export PS1=$PS1"${RED}\W${CLEAR}]: ${WHITE}"
}


# New line after commands but top command will not be affected through clear for PTS
if pgrep -x sway > /dev/null || ! pgrep -x gnome > /dev/null; then
  PROMPT_COMMAND="export PROMPT_COMMAND=echo"
  alias clear="unset PROMPT_COMMAND; clear; PROMPT_COMMAND='export PROMPT_COMMAND=echo';"
else
  alias clear="clear && echo;" 
fi


############################## Start up interactive session ############################

if [[ $- != *i* ]]; then
  return 0
fi

# Set bash prompt
set_bash_prompt

# Set bash to be in vim mode
set -o vi

# Double console font size if running in Linux TTY
if [[ "$OSTYPE" == "linux-gnu" ]] && [[ $(tty) =~ "/dev/tty" ]] && [[ $- == *i* ]]; then
  setfont ter-u32n
  sleep 1.5
fi

# Write start up system information if iteractive session
if [ "$success" = true ]; then
  clean
fi

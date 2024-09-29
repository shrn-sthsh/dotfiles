# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
  . /etc/bashrc
fi

# User specific environment
if ! [[ "$PATH" =~ "$HOME/.local/bin:$HOME/bin:" ]]; then
    PATH="$HOME/.local/bin:$HOME/bin:$PATH"
fi
export PATH
export PATH=/opt/homebrew/bin:/usr/local/bin:/System/Cryptexes/App/usr/bin:/usr/bin:/bin:/usr/sbin:/sbin

# User specific aliases and functions
if [ -d ~/.bashrc.d ]; then
  for rc in ~/.bashrc.d/*; do
    if [ -f "$rc" ]; then
      . "$rc"
    fi
  done
fi
unset rc

# Import bash aliases and functions
if [ -f ~/.dotfiles/bash/alias.sh ]; then
  source ~/.dotfiles/bash/alias.sh
fi
if [ -f ~/.dotfiles/bash/vars.sh ]; then
  source ~/.dotfiles/bash/vars.sh
fi

# Check if the ~/.bash/functions/ directory exists
if [ -d "$HOME/.dotfiles/bash/func/" ]; then
  for script in "$HOME/.dotfiles/bash/func/"*.sh; do
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

function set_bash_prompt ()
{
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


###################################### Start up #####################################
# Zoxide set up
eval "$(zoxide init bash)"

# Set bash prompt
set_bash_prompt

# Double console font size if running in Linux TTY
if test -f "/etc/os-release" && [[ $(tty) =~ "/dev/tty" ]]; then
  setfont -d
  sleep 1.5
fi

# Write start up system information if iteractive session
if [[ $- == *i* ]]; then
  clean
fi

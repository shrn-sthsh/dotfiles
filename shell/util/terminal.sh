#!/bin/bash

## Functions
# echo only in interactive shell
function safe_echo()
{
  if [[ $- == *i* ]]; then
    echo "$@"
  fi

  return 0
}

# new line routines based on echo
function new_line()
{
    echo ""
}
function safe_new_line()
{
   safe_echo "" 
}


# status + clear
function clean()
{
  clear

  if type fetch &> /dev/null; then
    echo ""
    fetch 
    echo ""
  fi
}

## Prompt
# setter
CUSTOM_PROMPT_SET=false
function set_bash_prompt()
{
  # check if prompt is already set
  if [[ "$CUSTOM_PROMPT_SET" == true ]]; then
    safe_echo "ABORT: bash prompt already set"
    return 0
  fi

  # ANSI bash terminal colors
  local    RED="\[\033[0;31m\]"
  local  GREEN="\[\033[0;32m\]"
  local YELLOW="\[\033[1;33m\]"
  local   BLUE="\[\033[1;34m\]"
  local PURPLE="\[\033[0;35m\]"
  local   CYAN="\[\033[0;36m\]"
  local  WHITE="\[\033[1;37m\]"
  local  CLEAR="\[\e[0m\]"

  # Turn off showing environment
  export VIRTUAL_ENV_DISABLE_PROMPT=1

  # prepend new line for TTY for MacBook curved bezels
  if ! pgrep -x sway &> /dev/null || ! pgrep -x gnome &> /dev/null; then
    export prompt="\n"
  else
    export prompt=""
  fi

  # python environment symbols
  function space-open-bracket-symbol()
  {
    if [[ -n $(parse_python_env) ]]; then
      safe_echo -n " {"
    fi
  }
  function close-bracket-symbol()
  {
    if [[ -n $(parse_python_env) ]]; then
      safe_echo -n "}"
    fi
  }

  # git branch symbol
  function resolve-symbol()
  {
    if [[ -n $(parse_git_branch) ]]; then
      safe_echo -n "::"
    fi
  }

  # set style and colors
  prompt=$prompt"${YELLOW}\t"
  prompt=$prompt"${CLEAR}\`space-open-bracket-symbol\`"
  prompt=$prompt"${GREEN}\`parse_python_env\`"
  prompt=$prompt"${CLEAR}\`close-bracket-symbol\`"
  prompt=$prompt"$CLEAR ["
  prompt=$prompt"${BLUE}\u${CLEAR}@${CYAN}\h"
  prompt=$prompt"${PURPLE} \`parse_git_branch\`"
  prompt=$prompt"${CLEAR}\`resolve-symbol\`"
  prompt=$prompt"${RED}\W"
  prompt=$prompt"${CLEAR}]: "
  prompt=$prompt"${WHITE}"

  unset PS1
  export PS1="$prompt"
  CUSTOM_PROMPT_SET=true
}

# New line after commands but top command will not be affected through clear for PTS
if pgrep -x sway > /dev/null || ! pgrep -x gnome > /dev/null; then
  PROMPT_COMMAND="export PROMPT_COMMAND=echo"
  alias clear="unset PROMPT_COMMAND; clear; PROMPT_COMMAND='export PROMPT_COMMAND=echo';"
else
  alias clear="clear && echo;" 
fi

# current branch 
function parse_git_branch()
{
  BRANCH=`command git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/'`
  if [ ! "${BRANCH}" == "" ]; then
    echo "<${BRANCH}>"
  else
    echo ""
  fi
}

# text junction from branch to folder
function git_branch_junction()
{
  BRANCH=`command git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/'`
  if [ ! "${BRANCH}" == "" ]; then
    safe_echo "::"
  else
    safe_echo ""
  fi
}

# conda set up
if type conda &> /dev/null; then
  conda_setup="$('/path/to/conda' 'shell.bash' 'hook' 2> /dev/null)"
  if [ $? -eq 0 ]; then
    eval "$conda_setup"

    conda config --set auto_activate_base false 
    conda config --set changeps1 false

    conda deactivate
  else
    if [ -f "/path/to/conda/etc/profile.d/conda.sh" ]; then
      source "/path/to/conda/etc/profile.d/conda.sh"
    else
      export PATH="/path/to/conda/bin:$PATH"
    fi
  fi
  unset conda_setup
fi

# current python environment
function parse_python_env()
{
  if [ -n "$VIRTUAL_ENV" ]; then
    safe_echo "$(basename "$VIRTUAL_ENV")"
  elif [ -n "$CONDA_DEFAULT_ENV" ]; then
    safe_echo "$CONDA_DEFAULT_ENV"
  else
    safe_echo ""
  fi
}

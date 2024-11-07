#!/bin/bash

# echo only in interactive shell
function safe_echo()
{
  if [[ $- == *i* ]]; then
    echo "$@"
  fi

  return 0
}

# status + clear
function clean()
{
  clear
  echo ""
  fetch 
  echo ""
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
    echo " {$(basename "$VIRTUAL_ENV")}"
  elif [ -n "$CONDA_DEFAULT_ENV" ]; then
    echo " {$CONDA_DEFAULT_ENV}"
  else
    echo ""
  fi
}

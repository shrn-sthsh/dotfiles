#!/bin/bash

# status + clear
function clean ()
{
  clear
  echo ""
  fetch 
  echo ""
}

# conda set up
if [ -f ~/.dotfiles/bash/util/install.sh ]; then
  source ~/.dotfiles/bash/util/install.sh
  install_required_package "conda"
else
  echo "ERROR: Unable to check if conda is installed"
  return 1
fi

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

# current python environment
function parse_python_env ()
{
  if [ -n "$VIRTUAL_ENV" ]; then
    echo " {$(basename "$VIRTUAL_ENV")}"
  elif [ -n "$CONDA_DEFAULT_ENV" ]; then
    echo " {$CONDA_DEFAULT_ENV}"
  else
    echo ""
  fi
}

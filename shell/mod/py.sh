#!/bin/bash


# import print utilities
terminal_source_file="$HOME/.dotfiles/shell/util/terminal.sh"
if [[ ! " ${BASH_SOURCE[@]} " =~ " $terminal_source_file " ]]; then

  if [ -f $terminal_source_file ]; then
    source $terminal_source_file

  else
    if [[ $- != *i* ]]; then
      echo "ERROR: python and conda environment commands require 'safe_echo' command from terminal utility"
    fi

    return 1
  fi
fi


# python/conda environment activation
function activate() 
{
  # python env path provided or conda env name provided
  if [ -n "$1" ]; then
    pyenv_path="$1/bin/activate"
    if [ -f "$pyenv_path" ]; then
      source $pyenv_path
    
    elif type conda &> /dev/null; then
      conda activate "$1"

    else
      safe_echo "ERROR: Unable to find environment for $1"
      return 1
    fi

  # search for python env or activate default conda env
  else
    targets=$(find . -name "activate")
    if [ -n "$targets" ]; then
      for file in "${targets[@]}"; do 
        source "$file"
        break
      done

    elif type conda &> /dev/null; then
      conda activate

    else
      safe_echo "ERROR: No environments found and unable activate default environment"
      return 1 
    fi
  fi
}

# conda environment deactivation
# note: python env will override deactivate implemation so it handles itself
function deactivate()
{
  if type conda &> /dev/null; then
    if [ -z "$CONDA_DEFAULT_ENV" ]; then
      safe_echo "ERROR: No conda or python environment active"
      return 1
    fi

    conda deactivate
    return 0
  fi

  safe_echo "ERROR: No python environment active"
  return 1
}


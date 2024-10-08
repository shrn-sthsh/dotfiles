#!/bin/bash

# ensure git is installed
if [ -f ~/.dotfiles/bash/func/install.sh ]; then
  source ~/.dotfiles/bash/func/install.sh
  install_source_if_required "git"
else
  echo "ERROR: Unable to check if git is installed"
  return 1
fi

# git with github key
function git-with-key()
{
  if [ "$1" == "key" ]; then
    if [ "$2" == "-v" ] || [ "$2" == "--verbose" ]; then
      unzip $HOME/Projects/git.zip gitkey && \
        cat gitkey && rm gitkey
    elif [ "$OSTYPE" == "darwin"* ]; then
      unzip $HOME/Projects/git.zip gitkey && \
        cat gitkey | wl-copy && \
        rm gitkey
    elif [ "$OSTYPE" == "linux-gnu" ]; then
      if [ "$XDG_SESSION_TYPE" == "wayland" ]; then
        unzip $HOME/Projects/git.zip gitkey && \
          cat gitkey | wl-copy && \
          rm gitkey 
      else 
        zip $HOME/Projects/git.zip gitkey && \
          cat gitkey | xsel --clipboard && \
          rm gitkey
      fi
    fi
  else
    git $@
  fi
}
alias git='git-with-key'

# current branch 
function parse_git_branch ()
{
  BRANCH=`git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/'`
  if [ ! "${BRANCH}" == "" ]; then
    echo "<${BRANCH}>"
  else
    echo ""
  fi
}

# text junction from branch to folder
function git_branch_junction ()
{
  BRANCH=`git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/'`
  if [ ! "${BRANCH}" == "" ]; then
    echo "::"
  else
    echo ""
  fi
}

# lines in a project
alias git-lc='git ls-files | xargs wc -l'

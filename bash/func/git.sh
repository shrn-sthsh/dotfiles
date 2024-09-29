#!/bin/bash

# git with github key
function git-with-key()
{
  if [ "$1" == "key" ]; then
    if [ "$2" == "-v" ] || [ "$2" == "--verbose" ]; then
      unzip $HOME/Projects/gitkey.zip gitkey && \
        cat gitkey && rm gitkey 
    else
      unzip $HOME/Projects/gitkey.zip gitkey && \
        cat gitkey | pbcopy && \
        rm gitkey 
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

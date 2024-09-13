#!/bin/bash

# github token
function gitkey ()
{
  unzip $HOME/Projects/git.zip gitkey && \
    cat gitkey | xargs wl-copy #&& \
    rm gitkey
}

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

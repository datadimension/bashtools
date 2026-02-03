#!/usr/bin/env bash

# shows site selection
# list to pick from for various funcs
function repo-show() {
  echo-br "Current repos are:"
  for i in {0..9}; do
    repolabel=${wwwrepos[$i]}
    if [ "$repolabel" != "" ]; then
    	repodevurl="${repolabel//[^[:alnum:]]}.$serverid.com"
      repolabel="$repolabel  [dev URL: $repodevurl ]"
    fi
    echo "$((i + 1)): $repolabel"
  done
  echo ""
  echo "repo-switch to change / www-reposet to configure "
  echo ""
  echo "selected DEV URL:"
  echo "$dev_url"
  echo ""
}

#switch the repo to work on
function repo-switch() {
  repo-show
  echo "Please select a repo number to chose for operations"
  read option
  reponumber=$(($option - 1))
  echo "Auto sync with GIT (recommended) ? n=no"
  read -t 5 input
  if [ "$environment" != "production" ]; then #never push from production
    if [ "$input" != "n" ]; then
      git-push
    fi
  fi
  www_repofocus=${wwwrepos[reponumber]}
  cd "$wwwroot/html/$www_repofocus"
  echo "setting repo to $www_repofocus"
  bash-writesettings
  if [ "$input" != "n" ]; then
    git-pull
  fi
  bash-start
}

#installs a named repo
function repo-install() {
  dir=$1
  reponame=$2
  echo "repoinstall"
  echo "Please enter the git reponame to put here"
  read reponame
  echo "Installing '$reponame' under $wwwroot/html/$dir"
  git-repo_install $dir $reponame
  composer-update
}
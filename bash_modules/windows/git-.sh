#!/usr/bin/env bash

function git-installrepo() {
  env-attributerequire gituname
  reponame=$1
  if [ "$reponame" == "" ]; then
    read -p "No repo name provided" wait
    return 0
  fi
  user=$USER
  rm -R -f $wwwroot/html/$reponame
  mkdir $wwwroot/html/$reponame
  git clone git@github.com:$gituname/$reponame.git $wwwroot/html/$reponame
  git-deploysubrepos
  cd "$wwwroot/html/$www_repofocus"
  echo "set focused repo to '$www_repofocus'"
  bash-writesettings
  bash-restart
}

function git-deploysubrepos() {
  git-deploysubrepo "$www_repofocus/public" "DD_libwww"
  git-deploysubrepo "$www_repofocus/app" "DD_laravelAp"
  git-deploysubrepo "$www_repofocus/resources/views" "DD_laraview"
  echo-hr
}

function git-deploysubrepo() {
  subrepopath=$1
  subreponame=$2
  subrepopath="$wwwroot/html/$subrepopath"
  rm -R $subrepopath/$subreponame
  echo-hr
  echo "cloning subrepo $subreponame"
  echo-hr
  echo ""
  git clone git@github.com:$gituname/$subreponame.git $subrepopath/$subreponame
  echo ""
  echo "subrepo deployment of $subreponame finished at:"
  echo-now
  echo ""
}

function git-pull() {
  curpwd=$(pwd)
  clear
  echo-hr
  echo "Pulling all repos and subrepos"
  echo-b $www_repofocus
  echo "Pulling to $www_repofocus"
  echo-hr
  git-pull-all
  cd $curpwd
}

function git-pull-all() {
  git-pull-repo "bashtools"
  git-pull-repo "DD_laraview" FORCED
  git-pull-repo "DD_libwww" FORCED
  git-pull-repo "DD_laravelAp" FORCED
  git-pull-repo "$www_repofocus" FORCED
}

function git-pull-repo() {
  gitreponame=$1
  forced=$2
  if [ "$gitreponame" == "DD_laraview" ]; then
    gitrepopath="$wwwroot/html/$www_repofocus/resources/views"
  elif [ "$gitreponame" == "DD_libwww" ]; then
    gitrepopath="$wwwroot/html/$www_repofocus/public"
  elif [ "$gitreponame" == "DD_laravelAp" ]; then
    gitrepopath="$wwwroot/html/$www_repofocus/app"
  elif [ "$gitreponame" == "bashtools" ]; then
    gitrepopath=~
  else
    gitrepopath="$wwwroot/html"
    gitreponame=$www_repofocus
  fi
  echo-hr
  echo "pulling repo $gitreponame $forced"
  echo "to $gitrepopath/$gitreponame;"
  echo-hr
  cd $gitrepopath/$gitreponame
  if [ "$forced" == "FORCED" ]; then
    git fetch
    git reset --hard HEAD
    git merge '@{u}'
  else
    git pull
  fi
  echo ""
  echo "Finished at:"
  echo-now
  echo-hr
}

function git-push() {
  echo ""
  echo "GIT-PUSH is disabled in Windows IDE as you should set PHPStorm or other IDE to deploy to test server in order to debug."
  echo ""
  echo "Then you should run git-push on a terminal on the actual DEV server to make changes live in the repo"
}

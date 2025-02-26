#!/usr/bin/env bash

function git-installrepo() {
  env-attributerequire gituname
  reponame=$1
  if [ "$reponame" == "" ]; then
    read -p "No repo name provided" wait
    return 0
  fi
  user=$USER
  sudo rm -r -f $wwwroot/html/$reponame
  sudo mkdir $wwwroot/html/$reponame
  git clone git@github.com:$gituname/$reponame.git $wwwroot/html/$reponame
  git-deploysubrepos
  git-addlocalexcludedfiles
  www-envinstall
  www-install-dependancies
  # cd "$wwwroot/html/$www_repofocus"
  # echo "set focused repo to '$www_repofocus'"
  bash-writesettings
  nginx-setserverblock $www_repofocus sslselfsigned
  bash-restart
}

function git-addlocalexcludedfiles() {
  echo "Adding local non git files"
  sudo mkdir -p $wwwroot/html/$www_repofocus/storage/framework/views/
  sudo mkdir -p $wwwroot/html/$www_repofocus/storage/framework/sessions/
  sudo mkdir -p $wwwroot/html/$www_repofocus/storage/framework/cache/
  sudo mkdir -p $wwwroot/html/$www_repofocus/storage/app/cache/

  sudo mkdir -p $wwwroot/html/$www_repofocus/storage/logs/

  sudo touch $wwwroot/html/$www_repofocus/storage/logs/laravel.log
  sudo touch $wwwroot/html/$www_repofocus/storage/logs/nginxaccess.log
  sudo touch $wwwroot/html/$www_repofocus/storage/logs/nginxerror.log

  sudo touch $wwwroot/html/$www_repofocus/storage/logs/cronlog.log
  sudo touch $wwwroot/html/$www_repofocus/storage/logs/cronresult.log
  sudo touch $wwwroot/html/$www_repofocus/storage/logs/apperror.log
  sudo touch $wwwroot/html/$www_repofocus/storage/logs/ssh.log

  sudo chown -R $USER:www-data $wwwroot/html/$www_repofocus/storage
  sudo chmod -R 770 $wwwroot/html/$www_repofocus/storage

  sudo mkdir -p $wwwroot/html/$www_repofocus/bootstrap/cache
  sudo mkdir -p $wwwroot/html/$www_repofocus/public/downloads/
  sudo mkdir -p $wwwroot/html/$www_repofocus/private/
}

function git-pull-select() {
  clear
  echo-hr
  curpwd=$(pwd)
  echo-h1 "Pulling to $www_repofocus"
  echo "Enter a repo name"
  echo ""
  echo "1: DD_libwww"
  echo "2: DD_laravelAp"
  echo "3: DD_laraview"
  echo "or wait / hit enter for everything"
  read -t 3 option
  if [ "$option" == "1" ]; then
    git-pull-repo "DD_libwww"
  elif [ "$option" == "2" ]; then
    git-pull-repo "DD_laravelAp"
  elif [ "$option" == "3" ]; then
    git-pull-repo "DD_laraview"
  else
    git-pull-all
  fi
  cd $curpwd
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

function git-push-select() {
  clear
  curpwd=$(pwd)
  echo-h1 "Pushing from $www_repofocus"
  echo "Enter a repo name"
  echo ""
  echo "1: DD_libwww"
  echo "2: DD_laravelAp"
  echo "3: DD_laraview"
  echo "or wait / hit enter for everything"
  read -t 3 option
  if [ "$option" == "1" ]; then
    git-push-repo "DD_libwww"
    git-pull-repo "DD_libwww"
  elif [ "$option" == "2" ]; then
    git-push-repo "DD_laravelAp"
    git-pull-repo "DD_laravelAp"
  elif [ "$option" == "3" ]; then
    git-push-repo "DD_laraview"
    git-pull-repo "DD_laraview"
  else
    git-push-all
  fi
  cd $curpwd
}

function git-push() {
  curpwd=$(pwd)
  clear
  echo-hr
  echo "Pushing all repos and subrepos"
  echo-b $www_repofocus
  git-push-all
  cd $curpwd
}

function git-add() {
  git status -uno
  git add -A
  git commit -a -m update
  echo "... all files added"
}

#reset all repos
function git-reset-all() {
  git-reset-repo "DD_laraview"
  git-reset-repo "DD_libwww"
  git-reset-repo "DD_laravelAp"
  git-reset-repo "$www_repofocus"
  echo "Reset file and directory permissions ? [y/n]"
  read input
  if [ "$input" == "y" ]; then
    fsys-secure
  fi

}

function git-reset() {
  clear
  curpwd=$(pwd)
  echo "Enter a repo name"
  echo ""
  echo "1: DD_libwww"
  echo "2: DD_laravelAp"
  echo "3: DD_laraview"
  echo "or hit enter for everything"
  read option
  if [ "$option" == "1" ]; then
    git-reset-repo "DD_libwww"
  elif [ "$option" == "2" ]; then
    git-reset-repo "DD_laravelAp"
  elif [ "$option" == "3" ]; then
    git-reset-repo "DD_laraview"
  else
    git-reset-all
  fi
  cd $curpwd
}

#forces file overwrite from server, untracked files remain
function git-reset-repo() {
  gitreponame=$1
  if [ "$gitreponame" == "DD_laraview" ]; then
    gitrepopath="$wwwroot/html/$www_repofocus/resources/views"
  elif [ "$gitreponame" == "DD_libwww" ]; then
    gitrepopath="$wwwroot/html/$www_repofocus/public"
  elif [ "$gitreponame" == "DD_laravelAp" ]; then
    gitrepopath="$wwwroot/html/$www_repofocus/app"
  else
    gitrepopath="$wwwroot/html"
    gitreponame=$www_repofocus
  fi
  echo-hr
  echo "reseting repo ..."
  echo-h1 "$gitreponame"
  echo "to $gitrepopath/$gitreponame;"
  cd $gitrepopath/$gitreponame
  git fetch --all
  # branchname=$(date +%Y%m%d%I%M)
  echo "Reseting to $gitreponame$branchname"
  # git branch "reset$gitreponame$branchname"
  git reset --hard origin/master
  git pull
}

function git-push-all() {
  git-push-repo "DD_laraview"
  git-push-repo "DD_libwww"
  git-push-repo "DD_laravelAp"
  git-push-repo "$www_repofocus"
  echo-hr
}

function git-push-repo() {
  gitreponame=$1
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
  echo "pushing repo $gitreponame"
  echo "from $gitrepopath/$gitreponame;"
  echo-hr
  cd $gitrepopath/$gitreponame
  git-add
  git push
  echo ""
  echo "Finished at:"
  echo-now
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

function git-pull-all() {
  git-pull-repo "bashtools"
  git-pull-repo "DD_laraview"
  git-pull-repo "DD_libwww"
  git-pull-repo "DD_laravelAp"
  git-pull-repo "$www_repofocus"
}

function git-setup() {
  echo ""
  echo "Enter GIT username (used to create urls for push / pull etc"
  read gituname
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

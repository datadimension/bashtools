#!/usr/bin/env bash

#help for this module
function git-h(){
	bash-helpformodule git
}

function git-repo_install() {
  env-attributerequire gituname
  reponame=$1
  if [ "$reponame" == "" ]; then
    read -p "No repo name provided" wait
    return 0
  fi
  user=$USER
  sudo rm -r -f $wwwroot/html/$reponame
  sudo mkdir $wwwroot/html/$reponame
  sudo chown $user:www-data $wwwroot/html/$reponame
  git clone git@github.com:$gituname/$reponame.git $wwwroot/html/$reponame
  git-deploysubrepos
  git-addlocalexcludedfiles
  composer-create-DD-dependacies
    laravel-envinstall

  # cd "$wwwroot/html/$www_repofocus"
  # echo "set focused repo to '$www_repofocus'"
  bash-writesettings
  nginx-setserverblock $www_repofocus sslselfsigned
  bash-restart
}

function git-addlocalexcludedfiles() {
  echo "Adding local non git files"

  templatestore=~/bashtools/templates/git
  targetroot=$wwwroot/html/$www_repofocus
  repodir=$wwwroot/html/$www_repofocus
  sudo mkdir -p $repodir/config/
  sudo mkdir -p $repodir/routes/
  sudo mkdir -p $repodir/app/Console/Commands
  sudo mkdir -p $repodir/app/API

  sudo mkdir -p $repodir/storage/framework/views/
  sudo mkdir -p $repodir/storage/framework/sessions/
  sudo mkdir -p $repodir/storage/framework/cache/
  sudo mkdir -p $repodir/storage/app/cache/

  sudo mkdir -p $repodir/storage/logs/

  sudo touch $repodir/storage/logs/laravel.log
  sudo touch $repodir/storage/logs/nginxaccess.log
  sudo touch $repodir/storage/logs/nginxerror.log

  sudo touch $repodir/storage/logs/cronlog.log
  sudo touch $repodir/storage/logs/cronresult.log
  sudo touch $repodir/storage/logs/apperror.log
  sudo touch $repodir/storage/logs/ssh.log

  sudo chown -R $USER:www-data $repodir/storage
  sudo chmod -R 770 $repodir/storage

  sudo mkdir -p $repodir/bootstrap/cache
  sudo mkdir -p $repodir/private/
  sudo mkdir -p $repodir/public/downloads/


  cat $templatestore/gitignoreadd >>$targetroot/.gitignore

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
  setSyncTimestamp;
  nginx-start;# to stop xdebug
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
  setSyncTimestamp
}

function setSyncTimestamp() {
  php ~/bashtools/php_helpers/bash/setrepoenvval.php reponame=$www_repofocus key=GIT_SYNC_TIMESTAMP #auto generated in script
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

#given reponame (or no argument for main repo) forces file overwrite from server, untracked files remain
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
  git-push-repo "DD_libmedia"
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
elif [ "$gitreponame" == "DD_libmedia" ]; then
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
  elif [ "$gitreponame" == "DD_libmedia" ]; then
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
  echo "to $gitrepopath/$gitreponame"
  echo-hr


  cd $gitrepopath/$gitreponame
  	if [ "$forced" == "FORCED" ]; then
    	git fetch
   	 git reset --hard HEAD
  	  git merge '@{u}'
   	 git rebase
  	else
    	git pull
  	fi

  echo ""
  echo "Finished at:"
  echo-now
  echo-hr
}

# after laravel-create, this will add it as a new git repo
function git-repo_create() {
  echo "Vist https://github.com/new to create new repo under $www_repofocus"
  echo "chose":
  echo "Private"
  echo "readme: unticked"
  echo ".gitgnore template: no .gitignore"
  echo "license: no license"
  echo "When done enter the initial branch name eg main"
  echo "if already created, use git-clean "
  read branchname
  git init
  git branch -m $branchname
  git add -A
  git commit -m "first commit"
  git remote add origin git@github.com:$gituname/$www_repofocus.git
  git push -u origin $branchname
  echo "Files set on server"
    wait clear
}

#https://stackoverflow.com/questions/46273032/is-there-a-way-to-remove-all-ignored-files-from-a-local-git-working-tree"
function git-clean() {
  echo "to set repo to ignore local files with new .gitignore see https://stackoverflow.com/questions/46273032/is-there-a-way-to-remove-all-ignored-files-from-a-local-git-working-tree"
}

function git-pull-all() {
  git-pull-repo "bashtools"
  git-pull-repo "DD_laraview"
  git-pull-repo "DD_libwww"
  git-pull-repo "DD_libmedia"
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
  git-deploysubrepo "$www_repofocus/public" "DD_libmedia"
  git-deploysubrepo "$www_repofocus/app" "DD_laravelAp"
  git-deploysubrepo "$www_repofocus/resources/views" "DD_laraview"
  echo-hr
}

function git-deploysubrepo() {
  subrepopath=$1
  subreponame=$2
  subrepopath="$wwwroot/html/$subrepopath"
  if [ -d "$subrepopath/$subreponame" ]; then #abort if directory exists
    echo "removing $subreponame as exists"
    rm -R -f $subrepopath/$subreponame
  fi
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

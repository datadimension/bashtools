#!/usr/bin/env bash

function repo-h(){
	bash-helpformodule repo
}

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
  echo "repo-switch to change / repo-set to configure "
  echo ""
  echo "selected DEV URL:"
  echo "$LOCAL_URL"
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


# sets up and assigns site to site index list, installing if needed
function repo-set() {
  clear
  echo-h1 "Repo Set"
  echo "Available Repos:"
  echo-hr
  ls $wwwroot/html
  echo-hr
  repo-show
  echo ""
  echo "NOTE: Reassigning repo number will not delete the repo - you will need to run www-reporemove"
  echo ""
  echo "Enter repo number to change"
  read option
  reponumber=$(($option - 1))
  read -p "Enter repo name to set against #$option: " newrepo #[note on dev server use the url for the dev server eg liveinfo247"
  wwwrepos[$reponumber]=$newrepo
  if [ -d "$wwwroot/html/$newrepo" ]; then #just change option if repo exists
    echo "Setting $option to existing $newrepo"
    www_repofocus=$newrepo
    bash-writesettings
    bash-restart
  else # need to set up repo
    #set -e #stop everything if there is a failure
    www_repofocus=$newrepo
    bash-writesettings
    echo "Directory $newrepo not found so will install."
    echo "Will install under $wwwroot/html/$www_repofocus"
    echo "with dev URL: $www_repofocus.$serverid.com"
    git-repo_install $www_repofocus
  fi
}


#creates a new website eg localserver_admin
function repo-create() {
  #based on https://kbroman.org/github_tutorial/pages/init.html
  clear
  echo "This will create a new laravel project"
  repo-show
  echo-br "Please enter new repo name (no special chars / underscore)"
  read newrepo
  read -p "Please enter index for '$newrepo' : " reponumber
  laravel-create $newrepo
  cd "$wwwroot/html"
  reponumber=$((reponumber - 1))
  wwwrepos[$reponumber]=$newrepo
  bash-writesettings
  echo "ssh to PRODUCTION database server and run"
  echo-b "mysql-createrepodatabase $db_app"
  wait "Finished database ? Enter to continue"
  repo-setoauth
  fsys-secure;
  echo "Now test with:";
  echo "https://$LOCAL_URL/servertest"
}

#copies all fies from backup
function repo-frombackup() {
  read -p "Enter backup dir " backupdir
  read -p "Enter target dir " targetdir
  cd "$wwwroot/html/"
  cp -a -v --update=none $wwwroot/html/$backupdir/private $wwwroot/html/$targetdir
}

#info for setting up outh on Google Dev
function repo-setoauth() {
  echo-newpage "Set up in Google Developer Console"
  echo "visit"
  echo-br "https://console.cloud.google.com/projectcreate"
  echo "and set up project for $www_repofocus"
  echo "note it will advise removing special characters from project name"
  echo "then configure OAuth screen"
  echo "https://console.cloud.google.com/apis/credentials/consent"
  echo "and Create OAuth client ID"
  echo-nl "https://console.cloud.google.com/auth/clients/create"
  echo-nl "and add as per these examples as seperate entries, eg for dev server:"
  echo "https://$LOCAL_URL"
  echo "https://$LOCAL_URL/auth/google/callback"
  echo-nl "https://$LOCAL_URL/google/api_getauth"
echo "also add for production server at some point"
}

function repo-getlocalurl(){
	LOCAL_URL=$www_repofocus.$serverid.com;
}



#!/usr/bin/env bash
function laravel-showversion() {
  php artisan --version
}

function laravel-configcheck() {
  echo "config check"
}

function laravel-getenv_value() {
  key=$1
  echo "getting $key"
}

# refreshes and installs composer dependancies
function laravel-install-dependancies() {
  echo ""
  echo-hr
  echo "Updating Repo Dependancies"
  echo-hr
  composer-update
}

#creates new laravel project with reponame as argument and sets www-repofocus to it
function laravel-create() {
  # https://www.appfinz.com/blogs/laravel-middleware-for-auth-admin-users-roles/
  #https://www.itsolutionstuff.com/post/laravel-11-user-roles-and-permissions-tutorialexample.html
  newrepo=$1
    if [ "$newrepo" == "" ]; then #abort if no new reponame given
    wait clear "No repo create name specified, Aborting"
    bash-restart
    return
fi
  newreopodir=$wwwroot/html/$newrepo
  echo "creating new repo $newrepo in directory $newreopodir"
  if [ -d "$newreopodir" ]; then #abort if directory exists
    wait clear "Error: repo '$newrepo' already exists at $newreopodir. Enter to exit."
    exit
  fi
  composer create-project laravel/laravel $newreopodir
  www_repofocus=$newrepo
  cd "$wwwroot/html/$www_repofocus"
  bash-writesettings
  ~www
  git-deploysubrepos
  php ~/bashtools/php_helpers/laravel/composerjsonincludes.php
  git-addlocalexcludedfiles
  ###################

  #would be better here to have php func to add array element to the config file
  laraveltemplatestore=~/bashtools/templates/laravel
  #20250824 already created mkdir $targetroot/config
  sudo cp -v --update=none $laraveltemplatestore/routes/*.* $targetroot/app/routes

  #add in DD  stubs
  sudo cp -v -R --update=none $laraveltemplatestore/app/* $wwwroot/html/$www_repofocus/app
  sudo cp -v -R --update=none $laraveltemplatestore/bootstrap/* $wwwroot/html/$www_repofocus/bootstrap
  sudo cp -v -R --update=none $laraveltemplatestore/config/* $wwwroot/html/$www_repofocus/config
  sudo cp -v -R --update=none $laraveltemplatestore/public/* $wwwroot/html/$www_repofocus/public

  #20250320 not need as copied whole app stubs above  sudo cp -v --update=none $laraveltemplatestore/DD_laravelAppComponents/app/Console/Commands/*.* $targetroot/app/Console/Commands

  #add project files that use DD files

  #add other eg bootstrap
  ~www
  composer-create-DD-dependacies
  laravel-envinstall
  echo "need to create .env now for nginx setup"
  nginx-setserverblock $www_repofocus
  git-repo_create
  wait clear
  echo "Now visit $localurl to test"
  echo "Now to push to git if all ok"
}

function laravel-envinstall() {
  echo-newpagetitle "Creating .env file in project $www_repofocus"
  echo ""
  php ~/bashtools/php_helpers/laravel/env_ops.php method=env_generate user=$USER
  echo ""
  echo "Set permissions for the .env file"
 sudo chown $user:www-data $wwwroot/html/$www_repofocus/.env
  echo-hr
  echo-hr
  cd $wwwroot/html/$www_repofocus
  php artisan key:generate
  read -p "View final result as editable [y/n] : " inputp
  if [ "$input" == "y" ]; then
    clear
    nano $wwwroot/html/$www_repofocus/.env
  else
    tail -1000 $wwwroot/html/$www_repofocus/.env
  fi
}

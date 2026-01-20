#!/usr/bin/env bash

#help for this module
function laravel-h(){
	bash-helpformodule laravel
}

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
  newrepodir=$wwwroot/html/$newrepo
  echo "creating new repo $newrepo in directory $newrepodir"
  if [ -d "$newreopodir" ]; then #abort if directory exists
    wait clear "Error: repo '$newrepo' already exists at $newrepodir. Enter to exit."
    exit
  fi
  composer create-project laravel/laravel $newrepodir
  www_repofocus=$newrepo
  cd "$wwwroot/html/$www_repofocus"
  bash-writesettings
  ~www
  git-deploysubrepos
  #add single files to composer lock
  php ~/bashtools/php_helpers/laravel/composerjsonincludes.php
  git-addlocalexcludedfiles
  ###################

  #would be better here to have php func to add array element to the config file
  laraveltemplatestore=~/bashtools/templates/laravel
  #20250824 already created mkdir $targetroot/config
  #20260108 sudo cp -v --update=none $laraveltemplatestore/routes/*.* $targetroot/routes

  #add in DD  stubs
  	sudo cp -v -R --update=none $laraveltemplatestore/app/* $wwwroot/html/$www_repofocus/app

  	sudo cp -v -R --update=none $laraveltemplatestore/bootstrap/* $wwwroot/html/$www_repofocus/bootstrap
  	sudo cp  $laraveltemplatestore/bootstrap/app.php $wwwroot/html/$www_repofocus/bootstrap/app.php

  	sudo cp -v -R --update=none $laraveltemplatestore/routes/* $wwwroot/html/$www_repofocus/routes
  	sudo cp  $laraveltemplatestore/routes/web.php $wwwroot/html/$www_repofocus/routes/web.php

	sudo cp -v -R $laraveltemplatestore/config/* $wwwroot/html/$www_repofocus/config
  	sudo cp -v -R --update=none $laraveltemplatestore/public/* $wwwroot/html/$www_repofocus/public
  	sudo cp -v -R --update=none $laraveltemplatestore/resources/* $wwwroot/html/$www_repofocus/resources


  #20250320 not need as copied whole app stubs above  sudo cp -v --update=none $laraveltemplatestore/DD_laravelAppComponents/app/Console/Commands/*.* $targetroot/app/Console/Commands

  #add project files that use DD files

  #add other eg bootstrap
  ~www
  composer-create-DD-dependacies
  laravel-envinstall
  echo "need to create .env now for nginx setup"
  nginx-setserverblock $www_repofocus
  git-repo_create
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

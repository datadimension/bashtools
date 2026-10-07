#!/usr/bin/env bash

#help for this module
function laravel-h() {
  bash-helpformodule laravel
}

#shows laravel version
function laravel-showversion() {
  echo "for all laravel functions we are going to site focus root (~www)"
  cd "$wwwroot/html/$www_repofocus"
  php artisan --version
}

function laravel-dependancy-set() {
  echo "config check"
  laraveltemplate_source=~/bashtools/templates/laravel
  root_target=$wwwroot/html/$www_repofocus/app
  sudo cp -v -R --update=none $laraveltemplate_source/app/BizClasses* $wwwroot/html/$www_repofocus/app/
  fsys-secure app/BizClasses

  sourcedir=
  # sudo cp -v -R --update=none $laraveltemplatestore/app/* $wwwroot/html/$www_repofocus/app

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
    exception "No repo create name specified, Aborting"
  fi
  newrepodir=$wwwroot/html/$newrepo
  echo "creating new laravel project $newrepo in directory $newrepodir"

  if [ -d "$newrepodir" ]; then
    echo-error "Error: project '$newrepo' already exists at $newrepodir. Use www-remove to remove it from this server if its not an existing GIT repo."
    return 0
  fi
  echo "creating"

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

  #add in DD  stubs
  sudo cp -v -R --update=none $laraveltemplatestore/app/* $wwwroot/html/$www_repofocus/app

  sudo cp -v -R --update=none $laraveltemplatestore/bootstrap/* $wwwroot/html/$www_repofocus/bootstrap
  sudo cp $laraveltemplatestore/bootstrap/app.php $wwwroot/html/$www_repofocus/bootstrap/app.php

  sudo cp -v -R --update=none $laraveltemplatestore/routes/* $wwwroot/html/$www_repofocus/routes
  sudo cp $laraveltemplatestore/routes/web.php $wwwroot/html/$www_repofocus/routes/web.php

  sudo cp -v -R $laraveltemplatestore/config/* $wwwroot/html/$www_repofocus/config
  sudo cp -v -R --update=none $laraveltemplatestore/public/* $wwwroot/html/$www_repofocus/public
  sudo cp -v -R --update=none $laraveltemplatestore/resources/* $wwwroot/html/$www_repofocus/resources

  #add project files that use DD files
  #add other eg bootstrap
  ~www
  composer-create-DD-dependacies
  echo "need to create .env now for nginx setup"
  laravel-envinstall $newrepo
  nginx-setserverblock $www_repofocus
  git-repo_create
}

function laravel-envinstall() {
  repoenv=$1
  if [ "$repoenv" == "" ]; then #abort if no new reponame given
    exception "Repo name required to set its env"
  fi
  echo-newpage "Creating .env file in project $www_repofocus"
  echo ""
  echo "You will need as a minimum:"
  echo "DATA_CONTROLLER_EMAIL"
  echo "GOOGLE_CLIENT_ID"
  echo "GOOGLE_CLIENT_SECRET"
  echo "GOOGLE_JAVASCRIPT_APIKEY"
  echo "DB_PASSWORD_ddDB"
  echo "DB_PASSWORD_appDB"

  if [ "$newmysqlpassword" == "" ]; then #abort if no new reponame given
    echo ""
    echo "Require mysql password in memory for env install."
    read -p "Reset mysql code credentials(y/n]? " nomysqlpwd
    if [ "$nomysqlpwd" == "y" ]; then #abort if no new reponame given
      mysql-setrepoaccess_credentials $repoenv
    else
      exception "For security, mysql password required in memory for env install"
    fi
  fi
  echo $newmysqlpassword
}

function stoptest_laravel-envinstall() {
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

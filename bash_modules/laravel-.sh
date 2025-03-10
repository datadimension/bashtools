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

#creates new laravel project and sets www-repofocus to it
function laravel-create() {
  # https://www.appfinz.com/blogs/laravel-middleware-for-auth-admin-users-roles/
  #https://www.itsolutionstuff.com/post/laravel-11-user-roles-and-permissions-tutorialexample.html
  newrepo=$1
  newreopodir=$wwwroot/html/$newrepo
  echo "creating new repo $newrepo in directory $newreopodir"
  if [ -d "$newreopodir" ]; then #abort if directory exists
    wait clear "Error: repo '$newrepo' already exists at $newreopodir. Enter to exit create."
    return 0
  fi
  return 0 #debug
  composer create-project laravel/laravel $newreopodir
  www_repofocus=$newrepo
  bash-writesettings
  ~www
  git-deploysubrepos
  php ~/bashtools/php_helpers/laravel/composerjsonincludes.php
  git-addlocalexcludedfiles
}

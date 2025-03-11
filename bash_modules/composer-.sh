#!/usr/bin/env bash

function composer-stopxdebug() {
  echo "ensure IDEs are not using Xdebug and stopping PHP at a breakpoint"
  echo "otherwise composer functions will freeze"
  wait
}

function composer-update() {
  composer-stopxdebug
  return 0
  # updates dependencies
  cd $wwwroot/html/$www_repofocus
  echo "Updating composer packages"
  #20250226composer dump-autoload
  composer update -W
  composer clear-cache
  # this also generates autoload;
  php artisan key:generate
  php artisan view:clear
  php artisan --version
  fsys-secure
}

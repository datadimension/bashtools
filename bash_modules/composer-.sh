#!/usr/bin/env bash

function composer-stopxdebug() {
  echo "if composer functions freeze, consider IDEs are not using Xdebug and stopping PHP at a breakpoint"
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

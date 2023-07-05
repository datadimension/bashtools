#!/usr/bin/env bash

function php-v(){
  maj=$(php -r "echo PHP_MAJOR_VERSION ;")
  min=$(php -r "echo PHP_MINOR_VERSION ;")
  phpNo="$maj.$min";
  bash-writesettings;
  echo "$phpNo";
}

function php-install() {
	sudo apt -y install php
	sudo apt -y install php-fpm
	sudo apt -y install php-zip
	#https://www.digitalocean.com/community/tutorials/how-to-install-and-secure-phpmyadmin-with-nginx-on-ubuntu-16-04
	sudo apt -y install php-soap
	sudo apt -y install php-curl
	sudo apt -y install php-bcmath
	sudo apt -y install php-bz2
	sudo apt -y install php-intl
	sudo apt -y install php-mbstring
	sudo apt -y install php-mysql
	sudo apt -y install php-readline
	sudo apt -y install php-xml
	php-v;
}

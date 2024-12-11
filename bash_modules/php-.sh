#!/usr/bin/env bash

function php-v(){
  maj=$(php -r "echo PHP_MAJOR_VERSION ;")
  min=$(php -r "echo PHP_MINOR_VERSION ;")
  phpNo="$maj.$min";
  bash-writesettings;
  echo "$phpNo";
}

function php-install() {
	sudo apt-get -y install php
	sudo apt-get -y install php-fpm
	sudo apt-get -y install php-zip
	#https://www.digitalocean.com/community/tutorials/how-to-install-and-secure-phpmyadmin-with-nginx-on-ubuntu-16-04
	sudo apt-get -y install php-soap
	sudo apt-get -y install php-curl
	sudo apt-get -y install php-bcmath
	sudo apt-get -y install php-bz2
	sudo apt-get -y install php-intl
	sudo apt-get -y install php-mbstring
	sudo apt-get -y install php-mysql
	sudo apt-get -y install php-readline
	sudo apt-get -y install php-xml
	php -v;
}

function php-edit() {
	echo "You might need the gateway ip:"
	tail /etc/resolv.conf
	read waitinput
	phproot="/etc/php/$phpNo/fpm"
	inifileName="$phproot/php.ini"
	sudo nano +9999 $inifileName
	nginx-start
}

function phpfpm-edit() {
	phproot="/etc/php/$phpNo/fpm"
	confFileName="$phproot/php-fpm.conf"
	sudo nano $confFileName
	nginx-start
}

function ~php() {
	phproot="/etc/php/$phpNo/fpm"
	ls -al $phproot
}

function php-start() {
	clear
	echo-h1 "Closing PHP"
	ps aux | grep php
	sudo pkill php-fpm
	clear
	echo-h1 "Starting PHP"
	sudo service php7.4-fpm start
	ps aux | grep php
}

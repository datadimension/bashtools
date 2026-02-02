#!/usr/bin/env bash


function php-install() {
	php_defaultvs=$1;
	sudo apt remove php7* php8* php9* -y
	sudo rm -R /etc/php/*.*;
	sudo service apache2 stop;
	sudo apt-get autoremove
	sudo add-apt-repository -y ppa:ondrej/php
    sudo apt update
	sudo apt-get -y install php$php$php_defaultvs

	#remove apache
	sudo apt-get purge apache2 apache2-utils apache2.2-bin apache2-common
sudo apt-get purge apache2 apache2-utils apache2-bin apache2.2-common
sudo apt-get autoremove

	sudo apt-get -y install php$php$php_defaultvs-fpm
	sudo apt-get -y install php$php$php_defaultvs-zip
	#https://www.digitalocean.com/community/tutorials/how-to-install-and-secure-phpmyadmin-with-nginx-on-ubuntu-16-04
	sudo apt-get -y install php$php$php_defaultvs-soap
	sudo apt-get -y install php$php$php_defaultvs-curl
	sudo apt-get -y install php$php$php_defaultvs-bcmath
	sudo apt-get -y install php$php$php_defaultvs-bz2
	sudo apt-get -y install php$php$php_defaultvs-intl
	sudo apt-get -y install php$php$php_defaultvs-mbstring
	sudo apt-get -y install php$php$php_defaultvs-mysql
	sudo apt-get -y install php$php$php_defaultvs-readline
	sudo apt-get -y install php$php$php_defaultvs-xml
	sudo apt-get -y install php$php$php_defaultvs-memcached
		sudo apt-get -y install php$php$php_default-sqlite3
		sudo apt-get -y install php-dev autoconf automake #allow to build php packages on this system eg xdebug

	echo ""
	echo ""
	echo ""
	echo ""
	php -v;
	php-getfullversion;
	php-getdirversion;
	clear;
	echo $PHP_FULL_VERSION;
	echo $PHP_DIR_VERSION;
	php -v;
  echo "We will now edit /etc/php/$PHP_DIR_VERSION/fpm/php.ini"
  echo "And for security change line to be"
  echo "cgi.fix_pathinfo=0; [eg uncomment and set value to 0]"
  read wait
  sudo nano +817 /etc/php/$PHP_DIR_VERSION/fpm/php.ini
}

#for the full version id
function php-getfullversion(){
		PHP_FULL_VERSION=$(php -r "echo PHP_VERSION;")
}

#for locating eg /php/etc/8.5
function php-getdirversion(){
		PHP_DIR_VERSION=$(php -r "echo PHP_MAJOR_VERSION.'.'.PHP_MINOR_VERSION;")
}

function php-edit() {
	echo "You might need the gateway ip:"
	tail /etc/resolv.conf
	read waitinput
	phproot="/etc/php/$PHP_DIR_VERSION/fpm"
	inifileName="$phproot/php.ini"
	sudo nano +9999 $inifileName
	nginx-start
}

function phpfpm-edit() {
	phproot="/etc/php/$PHP_DIR_VERSION/fpm"
	confFileName="$phproot/php-fpm.conf"
	sudo nano $confFileName
	nginx-start
}

function ~php() {
	phproot="/etc/php/$PHP_DIR_VERSION/fpm"
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

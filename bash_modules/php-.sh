#!/usr/bin/env bash

php_defaultvs="8.3";#the default version to use

function php-install() {
	sudo add-apt-repository -y ppa:ondrej/php
    sudo apt update
	sudo apt-get -y install php$php$php_defaultvs
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

	echo ""
	echo ""
	echo ""
	echo ""
	php -v;
	php-getversion;
  echo "We will now edit /etc/php/$php_defaultvs/fpm/php.ini"
  echo "And for security change line to be"
  echo "cgi.fix_pathinfo=0; [eg uncomment and set value to 0]"
  read wait
  sudo nano +817 /etc/php/$php_defaultvs/fpm/php.ini
}

function php-getversion(){
		PHP_VERSION=$(php -r "echo PHP_VERSION;")
		echo "PHP version: $PHP_VERSION";
}

function php-edit() {
	echo "You might need the gateway ip:"
	tail /etc/resolv.conf
	read waitinput
	phproot="/etc/php/$PHP_VERSION/fpm"
	inifileName="$phproot/php.ini"
	sudo nano +9999 $inifileName
	nginx-start
}

function phpfpm-edit() {
	phproot="/etc/php/$PHP_VERSION/fpm"
	confFileName="$phproot/php-fpm.conf"
	sudo nano $confFileName
	nginx-start
}

function ~php() {
	phproot="/etc/php/$PHP_VERSION/fpm"
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

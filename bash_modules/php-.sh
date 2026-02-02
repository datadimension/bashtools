#!/usr/bin/env bash

#removes as much of exisiting php as possible and installs it according to php_defaultvs
function php-install() {
	php_defaultvs=$1;
		if [ "$php_defaultvs" == "" ]; then
			echo "no php version stated to install"
return 0;
fi
clear
echo  "CURRENT PHP"
echo-hr
	    cd /etc/php;
	    pwd;
        ls;
                echo-hr
                echo "Install will remove all PHP"
                wait
                	  sudo pkill php-fpm
	    		sudo apt-get -y --purge remove php-common
	sudo apt-get -y remove php7* php8* php9*
	sudo rm /lib/systemd/system/php8*
	sudo rm -R /etc/php/*.*;

	sudo add-apt-repository -y ppa:ondrej/php
    sudo apt update

wait clear  "REMOVING APACHE"#remove apache
	    cd /etc/php;
	    pwd;
        ls;
                echo-hr

		sudo service apache2 stop;
	sudo apt-get -y purge apache2 apache2-utils apache2.2-bin apache2-data libaprutil1-dbd-sqlite3 libaprutil1-ldap liblua5.3-0 apache2-common  apache2-utils apache2-bin apache2.2-common
sudo apt-get -y autoremove

	sudo apt-get -y install php$php_defaultvs
			sudo service apache2 stop;
    	sudo apt-get -y purge apache2 apache2-utils apache2.2-bin apache2-data libaprutil1-dbd-sqlite3 libaprutil1-ldap liblua5.3-0 apache2-common  apache2-utils apache2-bin apache2.2-common
    sudo apt-get -y autoremove

wait clear  "INSTALLING MODULES"#remove apache
	    cd /etc/php;
	    pwd;
        ls;
                echo-hr

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
        sudo apt-get install php-common php-mysql php-cli

		sudo apt-get -y install php-dev autoconf automake #allow to build php packages on this system eg xdebug

	    cd /etc/php;
	    pwd;
        ls;
                echo-hr

wait clear  "SECURING INSTALLATION"#remove apache
	    cd /etc/php;
	    pwd;
        ls;
        echo-hr

	echo $PHP_FULL_VERSION;
	echo $PHP_DIR_VERSION;
	php -v;
  echo "We will now edit /etc/php/$PHP_DIR_VERSION/fpm/php.ini"
  echo "And for security change line to be"
  echo "cgi.fix_pathinfo=0; [eg uncomment and set value to 0]"
 wait
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

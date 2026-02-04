#!/usr/bin/env bash

#removes as much of exisiting php as possible and installs it according to php_defaultvs
function php-install() {
clear
echo  "CURRENT PHP"
echo-hr
	    cd /etc/php;
	    pwd;
        ls;
                echo-hr
                echo "Install will remove all PHP and install PHP version $PHP_DD_VERSION"
                wait
                	  sudo pkill php-fpm
	    		sudo apt-get -y --purge remove php-common
	sudo apt-get -y remove php7* php8* php9*
	sudo rm /lib/systemd/system/php8*
	sudo rm /lib/systemd/system/php9*
	sudo rm -R /etc/php/*.*;
sudo apt-get -y autoremove
    sudo apt update
	sudo add-apt-repository -y ppa:ondrej/php
wait clear  "INSTALLING php version $PHP_DD_VERSION"
                echo-hr

	sudo apt-get -y install php$PHP_DD_VERSION
		sudo apt-get -y install php$PHP_DD_VERSION-fpm
	    cd /etc/php;
	    pwd;
        ls;
        wait

wait clear  "INSTALLING MODULES"#remove apache
	    cd /etc/php;
	    pwd;
        ls;
                echo-hr

	sudo apt-get -y install php$PHP_DD_VERSION-fpm
	sudo apt-get -y install php$PHP_DD_VERSION-zip
	#https://www.digitalocean.com/community/tutorials/how-to-install-and-secure-phpmyadmin-with-nginx-on-ubuntu-16-04
	sudo apt-get -y install php$PHP_DD_VERSION-soap
	sudo apt-get -y install php$PHP_DD_VERSION-curl
	sudo apt-get -y install php$PHP_DD_VERSION-bcmath
	sudo apt-get -y install php$PHP_DD_VERSION-bz2
	sudo apt-get -y install php$PHP_DD_VERSION-intl
	sudo apt-get -y install php$PHP_DD_VERSION-mbstring
	sudo apt-get -y install php$PHP_DD_VERSION-mysql
	sudo apt-get -y install php$PHP_DD_VERSION-readline
	sudo apt-get -y install php$PHP_DD_VERSION-xml
	sudo apt-get -y install php$PHP_DD_VERSION-memcached
		sudo apt-get -y install php$PHP_DD_VERSION-sqlite3
        #installs extra php versions sudo apt-get -y install php-common php$PHP_DD_VERSION-mysql
		sudo apt-get -y install php$PHP_DD_VERSION-dev autoconf automake #allow to build php packages on this system eg xdebug
	php-removeapache

	    cd /etc/php;
	    pwd;
        ls;
                echo-hr

wait clear  "SECURING INSTALLATION"
	    cd /etc/php;
	    pwd;
        ls;
        echo-hr

	echo $PHP_FULL_VERSION;
	echo $PHP_DIR_VERSION;
	php -v;
  echo "We will now edit /etc/php/$PHP_DD_VERSION/fpm/php.ini"
  echo "And for security change line to be"
  echo ""
  echo "cgi.fix_pathinfo=0; [eg uncomment ';' and set value to 0]"
   echo ""

 wait
  sudo nano +817 /etc/php/$PHP_DD_VERSION/fpm/php.ini
  php-restart
}

function php-removeapache(){
					sudo service apache2 stop;
					sudo rm -r /usr/sbin/apache2
	wait clear  "REMOVING APACHE"
    	    cd /etc/php;
    	    pwd;
            ls;
                    echo-hr
                    sudo apt-get purge apache2
        	sudo apt-get -y purge apache2 apache2-utils apache2.2-bin apache2-data libaprutil1-dbd-sqlite3 libaprutil1-ldap liblua5.3-0 apache2-common  apache2-utils apache2-bin apache2.2-common
        sudo apt-get -y purge libapache2-mod-php$PHP_DIR_VERSION
        sudo apt-get -y autoremove
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

function php-restart() {
	echo "Closing PHP"
	ps aux | grep php
	sudo pkill php-fpm
	echo-hr
	echo "Starting PHP"
	sudo service php$PHP_DIR_VERSION-fpm start
	ps aux | grep php
}

function php-install-xdebug() {
	echo "Do not install Xdebug on production servers. Install Xdebug here ? y/n"
	read input
	if [ "$input" == "y" ]; then
		clear
 #sudo apt-get install php-xdebug;
 echo-br;
  #20260203php --ini;
		echo-br "See the xdebug Install Wizard Instructions for full details at https://xdebug.org/docs/install."
 echo-br "First configure PHP.";
 echo ""
 echo "from the above list copy and paste the file name with xdebug in it so we can locate the file to edit".
  xdebugpath="/etc/php/$PHP_DIR_VERSION/fpm/conf.d/99-xdebug.ini"
 echo "Usually "$xdebugpath;

echo "Hit enter to use this or enter a different value";
 read xdebugpathedit;
 	if [ "$xdebugpathedit" != "" ]; then
 	xdebugpath=$xdebugpathedit;
fi
sudo rm $xdebugpath;
  php ~/bashtools/php_helpers/nginx/xdebugini.php xdebugpath=$xdebugpath

 #20260203sudo bash -c "echo 'zend_extension=xdebug' >> $xdebugpath"
 #20260203sudo bash -c "echo 'xdebug.mode = debug' >> $xdebugpath"
 #20260203sudo bash -c "echo 'xdebug.start_with_request = yes' >> $xdebugpath"
 #20260203sudo bash -c "echo 'xdebug.client_port = 9003' >> $xdebugpath"
 #20260203sudo bash -c "echo xdebug.log = \"/var/log/xdebug.log\" >> $xdebugpath"
 #20260203sudo bash -c "echo 'xdebug.idekey = PHPSTORM' >> $xdebugpath"

 #20260203sudo tail -100 $xdebugpath;
#20260203sudo touch /var/log/xdebug.log
#20260203sudo chown -R $USER:www-data /var/log/xdebug.log
#20260203sudo chmod -R 770  /var/log/xdebug.log

#20260203nginx-start;
# echo "/etc/php/8.3/fpm/php.ini";
#20260203echo-br "To check installed - visit the xdebug info at:"
#20260203echo-nl "$www_repofocus/xdebuginfo.php";
#20260203echo "and check for errors";
	fi
}


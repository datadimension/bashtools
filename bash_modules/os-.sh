#!/usr/bin/env bash

function os-() {
	# at some point we could have a list of options here

	#echo "only available management is os-installer"
	#echo "any key to continue"
	#read wait
	os-installer
}

function os-installer() {
	lastoption=$1
	clear
	echo "Please enter option to install"
	if [ "$lastoption" != "" ]; then
		echo "You previously picked $lastoption:"
	fi
	echo "1: Basic OS Additionals"
	echo "2: PHP"
	echo "3: Composer"
	echo "4: MySQL"
	echo "5: Access Security"
	echo "6: OS Additional"
	echo "7: Install Nginx"
	echo "10: VPN client"
	echo "anything else to Exit"
	read option
	if [ "$option" == "1" ]; then
		os-installadditional
	elif [ "$option" == "2" ]; then
		install-php
	elif [ "$option" == "3" ]; then
		install-composer
	elif [ "$option" == "4" ]; then
		installmysql
	elif [ "$option" == "5" ]; then
		os-access
	elif [ "$option" == "6" ]; then
		os-additional
	elif [ "$option" == "7" ]; then
		os-install-nginx
	elif [ "$option" == "10" ]; then
		sudo apt-get -y install network-manager-openconnect-gnome
	else
		option="undefined"
	fi
	if [ "$option" != "undefined" ]; then
		echo ""
		echo "Finished, press any key to continue"
		read $wait
		os-installer $option
	else
		bash-start
	fi
}

function os-upgrade() {
	sudo apt-get -y update
	sudo apt-get -y upgrade
}
function os-installdependancies() {
	os-upgrade
	#force utc timezone
	sudo rm -f /etc/localtime                         # Delete the current time zone file
	sudo ln -s /usr/share/zoneinfo/UTC /etc/localtime # Set it to the new value
	#sudo apt-get -y install -y members;
	sudo apt-get -y remove apache2.*
	sudo apt-get -y purge apache2
	sudo apt-get -y autoremove
	sudo apt-get -y autoclean
	#sudo apt-get -y install software-properties-common;
	#sudo apt-get -y install jq;#terminal json processor https://stedolan.github.io/jq/
	#sudo apt-get -y install tree;#https://lintut.com/use-tree-command-in-linux/
	#sudo apt-get -y install curl;
	#sudo apt-get -y install xclip;#allows copying of file to clipboard in the terminal
	sudo apt-get -y install figlet
	sudo apt-get install -y nodejs
	sudo apt install net-tools
	sudo apt-get install -y whois
	sudo mkdir /var/www/html
	php-install;
}
function install-newselfsignedcert() {
	#self signed certificate#######################################################
	# https://linuxize.com/post/redirect-http-to-https-in-nginx/
	#also see https://linuxize.com/post/redirect-http-to-https-in-nginx/
	#https://www.digitalocean.com/community/tutorials/how-to-create-a-self-signed-ssl-certificate-for-nginx-in-ubuntu-18-04
	echo "This requires a stable connection and can take a long time ~40 mins"
	echo "therefore its recommended to use a screen session for this in case of disconnect https://linuxize.com/post/how-to-use-linux-screen/?utm_content=cmp-true"
	echo "when generating, can leave all blank apart from"
	echo "Common Name (e.g. server FQDN or YOUR name) []:server_IP_address"
	sudo mkdir /etc/nginx
	sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/nginx-selfsigned.key -out /etc/ssl/certs/nginx-selfsigned.crt
	sudo openssl dhparam -out /etc/nginx/dhparam.pem 4096
}

function install-nginx() {
	sudo apt -y install nginx
	#clear default files
	sudo rm /etc/nginx/sites-enabled/default
	sudo rm /etc/nginx/sites-available/default
	sudo rm /var/www/html/index.nginx-debian.html

	#copy nginx test package into html directory
	sudo cp -R ~/bashtools/templates/nginx/nginxtest /var/www/html
	#move test block so nginx can read it
	sudo cp ~/bashtools/templates/nginx/nginxsetup/nginxtestblockssl /etc/nginx/sites-enabled/nginxtest
	sudo mkdir /etc/nginx

	echo "Copy self signed cert ? So dev server can run  HTTPS (y/n) - note this is an insecure certificate and will not be valid on live server"
	read input
	if [ "$input" != "y" ]; then
		sudo cp ~/bashtools/templates/nginx/nginxsetup/nginx-selfsigned.crt /etc/ssl/certs/nginx-selfsigned.crt
		sudo cp ~/bashtools/templates/nginx/nginxsetup/dhparam.pem /etc/nginx/dhparam.pem
		sudo cp ~/bashtools/templates/nginx/nginxsetup/ssl-params.conf /etc/nginx/snippets/ssl-params.conf
		sudo cp ~/bashtools/templates/nginx/nginxsetup/self-signed.conf /etc/nginx/snippets/self-signed.conf
	fi

	#cp /var/www/html/serveradmin/_cli/bash/templates/.bash_cfg ~/.bash_cfg;
	# #20230113
	# sudo cp /etc/nginx/snippets/phpmyadmin.conf /var/www/html/serveradmin/_cli/bash/templates/phpmyadminnginxsnippet;
	nginx-start
	echo "Now go to hosts file (we moved it to C:\www"
	echo "and add lines as appropriate for local browser address entry"
	echo "127.0.0.1    nginxtest"
	echo "127.0.0.1    mysite.local.com"
	$()
}

function os-access() {
	echo "any key to edit ssh to remove root - set"
	echo "PermitRootLogin no"
	read wait
	sudo nano +36 /etc/ssh/sshd_config
	echo "Edit ssh to remove password access"
	echo "******* ONLY IF YOU HAVE SETUP AND TESTED SSH CERTIFICATION LOGIN ***** set"
	echo "PasswordAuthentication no"
	read wait
	sudo nano +60 /etc/ssh/sshd_config
	echo "PubkeyAuthentication yes"
	read wait
	sudo nano +41 /etc/ssh/sshd_config
	echo "Any key to restart sshd - you will get booted - make sure you set up ssh which is not root"
	read wait
	sudo sudo service ssh reload;
		echo "We will edit /etc/php/$phpNo/fpm/php.ini"
	echo "And for security change line to be"
	echo "cgi.fix_pathinfo=0; [eg uncomment and set value to 0]"
	read wait
	sudo nano +801 /etc/php/$phpNo/fpm/php.ini
}

function install-composer() {
	cd ~/
	php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
	php composer-setup.php
	php -r "unlink('composer-setup.php');"
	sudo mv composer.phar /usr/local/bin/composer
	composer global require laravel/installer
}

function installmysql() {
	#https://support.rackspace.com/how-to/installing-mysql-server-on-ubuntu/
	#ignore part about ufw, we will do that seperate
	echo "Follow this guide for mysql8"
	echo "https://tastethelinux.com/upgrade-mysql-server-from-5-7-to-8-ubuntu-18-04/"
	sudo apt-get -y install mysql-server
	echo "Now set up security"
	echo "Set max security password"
	echo "Deny remote root access"
	echo "Remove default test tables"
	echo "Reload priviledges to take effect"
	echo "Set Strong password with options"
	read wait

	#set max security and remove min priviledges such as root access
	sudo mysql_secure_installation utility
	sudo systemctl start mysql
	sudo systemctl enable mysql

	#set bind address for all ip addresses so can remote access
	# bind-address            = 0.0.0.0
	echo "
You need to edit mysqld.cnf
set bind address for all ip addresses so can remote access
bind-address            = 0.0.0.0
bind-address            = <wan ip address>
Enter to edit conf ....
"
	read wait
	sudo nano +43 /etc/mysql/mysql.conf.d/mysqld.cnf
	sudo systemctl restart mysql
	sudo ufw allow mysql

	#remote access and if you break it:
	#
	#sudo mysql --no-defaults --force --user=root --host=localhost --database=mysql
	#select host, user from mysql.user;
	#add user
	echo "
log in to mysql using

sudo mysql

and run:

CREATE USER '<mysqladminuser />'@'%' IDENTIFIED BY '<mysqladminpassword />';
GRANT ALL PRIVILEGES ON *.* TO '<mysqladminuser />'@'%' IDENTIFIED BY '<mysqladminpassword /> 'WITH GRANT OPTION;
FLUSH PRIVILEGES;
"
}

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
		os-install-additional
	elif [ "$option" == "2" ]; then
		os-installphp
	elif [ "$option" == "3" ]; then
		os-install-composer
	elif [ "$option" == "4" ]; then
		os-install-mysql
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
function os-install-dependancies() {
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
	sudo apt-get install putty-tools
	sudo mkdir /var/www/html
	php-install
}
function os-installnewselfsignedcert() {
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

function os-install-nginx() {
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

function os-sshaccess() {
	clear
	echo-h1 "Securing server access - note this is intended for if you are logging in as root. If you are loggin in as another user you will lose access"
	echo "Please enter login name to be used as sudo"
	read newuser
	if [ "$newuser" != "" ]; then
		sudo adduser $newuser
		sudo usermod -aG sudo $newuser
		currentuser=$USER
		sudo mv /home/$currentuser/.bash_profile /home/$newuser/.bash_profile
		sudo chown $newuser:$newuser /home/$newuser/.bash_profile

		sudo mv /home/$currentuser/bashtools /home/$newuser/bashtools
		sudo chown -R $newuser:$newuser /home/$newuser/bashtools

		sudo mv /home/$currentuser/bashtoolscfg /home/$newuser/bashtoolscfg
		sudo touch /home/$newuser/bashtoolscfg/gitcfg
		sudo chown -R $newuser:$newuser /home/$newuser/bashtoolscfg

		echo "Now generating ssh keys, you are ok to accept defaults"
		ssh-keygen
		pubkey=$(<~/.ssh/id_rsa.pub)
		touch /home/$newuser/.ssh/authorized_keys
		sudo mv /home/$currentuser/.ssh/id_rsa /home/$newuser/.ssh/id_rsa
		sudo mv /home/$currentuser/.ssh/id_rsa.pub /home/$newuser/.ssh/id_rsa.pub
		sudo chown -R $newuser:$newuser /home/$newuser/.ssh

		echo "$pubkey" >/home/$newuser/.ssh/authorized_keys
		puttygen id_rsa -o id_rsa.ppk
		ppk=$(<~/.ssh/id_rsa.ppk)
		echo "Now paste this into a windows .ppk file and tell Putty where to find it."
		echo ""
		echo $echo ppk
		echo "Press any key to exit and then log in as this user using ssh key"
		read wait
		exit
	fi
}

function os-sshsecure() {
	echo "any key to edit ssh to remove root - set"
	echo "Comment out includes":
	sudo nano +12 /etc/ssh/sshd_config
	echo "PermitRootLogin no"
	read wait
	sudo nano +36 /etc/ssh/sshd_config
	echo "PubkeyAuthentication yes"
	read wait
	sudo nano +41 /etc/ssh/sshd_config
	echo "Any key to restart sshd - you will get booted - make sure you set up ssh which is not root"
	read wait
	echo "Edit ssh to remove password access"
	echo "PasswordAuthentication no"
	read wait
	sudo nano +60 /etc/ssh/sshd_config
	sudo sudo service ssh reload
	echo "We will edit /etc/php/$phpNo/fpm/php.ini"
	echo "And for security change line to be"
	echo "cgi.fix_pathinfo=0; [eg uncomment and set value to 0]"
	read wait
	sudo nano +802 /etc/php/$phpNo/fpm/php.ini
	echo "***** DO NOT CLOSE CURRENT SESSION UNTIL YOU VERIFY YOU CAN ACCESS USING NEW PUTTY SESSION"
}

function os-install-composer() {
	cd ~/
	php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
	php composer-setup.php
	php -r "unlink('composer-setup.php');"
	sudo mv composer.phar /usr/local/bin/composer
	composer global require laravel/installer
}

function os-install-mysql() {
	#https://support.rackspace.com/how-to/installing-mysql-server-on-ubuntu/
	#ignore part about ufw, we will do that seperate
	echo "Follow this guide for mysql8"
	echo "https://tastethelinux.com/upgrade-mysql-server-from-5-7-to-8-ubuntu-18-04/"
	sudo apt-get -y install mysql-server

	#set max security and remove min priviledges such as root access
	sudo mysql_secure_installation utility
	sudo systemctl start mysql
	sudo systemctl enable mysql

	#set bind address for all ip addresses so can remote access
	# bind-address            = 0.0.0.0
	echo "
You need to edit mysqld.cnf
set bind address for all ip addresses so can remote access
bind-address            = 0.0.0.0 #remove 127.0.0.1
bind-address            = <wan ip address>
Enter to edit conf ....
"
	read wait
	sudo nano +31 /etc/mysql/mysql.conf.d/mysqld.cnf
	sudo systemctl restart mysql
	sudo ufw allow mysql
	echo "Enter new SQL admin username"
	read sqluser
	echo "Enter new SQL admin password"
	read -s pword

	echo "log in to mysql using sudo mysql and run:"
	echo "CREATE USER '"$sqluser"'@'%' IDENTIFIED BY '"$pword"';"
	echo "GRANT ALL PRIVILEGES ON *.* TO '"$sqluser"'@'%' WITH GRANT OPTION;"
	echo "FLUSH PRIVILEGES;"

	echo "
Note if something breaks or password is lost:
sudo mysql --no-defaults --force --user=root --host=localhost --database=mysql
select host, user from mysql.user;
add user
"
}

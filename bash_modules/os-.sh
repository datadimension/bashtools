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
		php-install
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

function os-screen() {
	screen -ls
	echo ""
	echo "Please enter action"
	echo "1: Close Screen session"
	echo "2: Start Screen session"
	read option
	if [ "$option" == "1" ]; then
		echo "Enter screen id"
		read screenid
		screen -XS $screenid quit
		echo ""
		screen -ls
	elif [ "$option" == "2" ]; then
		echo "Enter new screen id"
		read screenid
		screen -S $screenid
		echo ""
		screen -ls
	fi
}

function os-upgrade() {
	sudo apt-get -y update
	sudo apt-get -y upgrade
}

function os-install-dependancies() {
echo "System Setup.";
echo "Ready to install system dependencies";
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
	sudo mkdir /var/www/certs
	php-install
	net-firewall-start
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
	echo "Copy self signed cert ? So dev server can run  HTTPS (y/n) - note this is an insecure certificate and will not be valid on live server"
	read input
	if [ "$input" != "y" ]; then
		sudo cp ~/bashtools/templates/nginx/nginxsetup/nginx-selfsigned.crt /etc/ssl/certs/nginx-selfsigned.crt
		sudo cp ~/bashtools/templates/nginx/nginxsetup/dhparam.pem /etc/nginx/dhparam.pem
		sudo cp ~/bashtools/templates/nginx/nginxsetup/ssl-params.conf /etc/nginx/snippets/ssl-params.conf
		sudo cp ~/bashtools/templates/nginx/nginxsetup/self-signed.conf /etc/nginx/snippets/self-signed.conf
	fi
	www-nginxtest_install
	sudo net-firewall-start
}

#downloads only into user downloads dir with the sub path given
function os-download() {
	url=$1
	path=$2
	curl $url --create-dirs -o ~/downloads/$path
}

function os-install-xdebug() {
	echo "You will need to enable the nginxtest pages here to show the required info."
	echo "Enable ? y/n"
	read input
	if [ "$input" != "y" ]; then
		www-nginxtest_install
		echo "Enter to continue"
		read input
		clear
		echo "From the xdebug Install Wizard Instructions, please enter the version number required eg 3.2.2 if we require xdebug-3.2.2.tgz"
		read xvers
		echo "Please enter the Zend Module Api No"
		echo "eg Configuring for:     Zend Module Api No:  20210902"
		echo "Just the number please"
		read zendapi_no
		echo "Finally enter the FULL xdebug.ini path given eg /etc/php/8.1/fpm/conf.d/99-xdebug.ini"
		read inipath
		os-download https://xdebug.org/files/xdebug-$xvers.tgz tmp/xdebug-$xvers.tgz
		cd ~/downloads/tmp
		tar -xvzf xdebug-$xvers.tgz
		cd xdebug-$xvers
		phpize
		./configure
		make
		#to generic echo "zend_extension = xdebug" >conf
		echo "zend_extension = /usr/lib/php/$zendapi_no/xdebug.so" >conf
		sudo cp modules/xdebug.so /usr/lib/php/$zendapi_no
		sudo cp conf $inipath
		sudo touch /var/log/xdebug.log
		sudo net-firewall-start
		echo "make sure port 9003 is enabled"
		read wait
		nginx-start
	fi
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
		echo "Remove temp key for this server from git at add this"
		echo pubkey
		read wait
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
	net-firewall-start
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

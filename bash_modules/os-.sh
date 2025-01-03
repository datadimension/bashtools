#!/usr/bin/env bash

function os-() {
	# at some point we could have a list of options here

	#echo "only available management is os-installer"
	#echo "any key to continue"
	#read wait
	os-installer
}

function os-checkstatus(){
	      if [ "$os_status" == "" ]; then
          os_status=0;
        fi
        declare -a os_steps=(
        		"os-sudo-create" "os-sshkeygen" "os-sshsecure" "os-install-dependancies"
        )
    		size=${#os_steps[@]}
    		os_setupfunc="${os_steps[$os_status]}";
        if [ "$os_status" -lt "$size"  ]; then
        	  os_num=$((os_status+1))
        		echo "OS Setup $os_num of $size"
        		echo "$os_setupfunc";
        		echo "Hit enter to run";
        		read waitforit;
        		eval $os_setupfunc;
    				os_status=$((os_status+1))
        		return 1;
        else
        	os_status=$size;
        	osinstall=0;
        	return 0;
    		fi
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
	echo "System Setup."
	echo "Ready to install system dependencies"
	os-upgrade
	#force utc timezone
	sudo rm -f /etc/localtime                         # Delete the current time zone file
	sudo ln -s /usr/share/zoneinfo/UTC /etc/localtime # Set it to UTC
	sudo apt-get -y remove apache2.*#ensure apache is completely removed
	sudo apt-get -y purge apache2
	sudo apt-get -y autoremove
	sudo apt-get -y autoclean
	sudo apt-get -y install curl
	sudo apt-get -y install figlet
	sudo apt-get -y install nodejs
	sudo apt install net-tools
	sudo apt-get install -y whois
	sudo apt-get install putty-tools
	sudo mkdir -p /var/www/html
	sudo mkdir -p /var/www/certs
	sudo apt-get -y install openssh-server
	sudo apt-get -y install npm
	sudo apt-get install php-sqlite3
	os-installcomposer
	php-install
	os-install-nginx
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
	echo "Making self signed cert so dev server can run  HTTPS- note this is an insecure certificate and will not be valid on live server"
 # os-installnewselfsignedcert
	www-nginxtest_install
	net-firewall-start
}

#downloads only into user downloads dir with the sub path given
function os-download() {
	url=$1
	path=$2
	curl $url --create-dirs -o ~/downloads/$path
}

function os-install-xdebug() {
	echo "Do not install Xdebug on production servers. Install Xdebug here ? y/n"
	read input
	if [ "$input" == "y" ]; then
		clear
 sudo apt-get install php-xdebug;
 echo-br;
  php --ini;
		echo-br "See the xdebug Install Wizard Instructions for full details at https://xdebug.org/docs/install."
 echo-br "First configure PHP.";
 echo "from the above list copy and paste the file name with xdebug in it so we can locate the file to edit".
 read xdebugpath;
 #echo "To check installed - visit the xdebug info at:"
 #echo "$www_sitefocus/xdebuginfo.php";
 #echo "Scroll down to Settings and enter the path for  the .ini file for fpm eg"
 sudo bash -c "echo 'zend_extension=xdebug' >> $xdebugpath"
 sudo bash -c "echo 'xdebug.mode = debug' >> $xdebugpath"
 sudo bash -c "echo 'xdebug.start_with_request = yes' >> $xdebugpath"
 sudo bash -c "echo 'xdebug.client_port = 9003' >> $xdebugpath"
 sudo bash -c "echo xdebug.log = \"/var/log/xdebug.log\" >> $xdebugpath"
 sudo bash -c "echo 'xdebug.idekey = PHPSTORM' >> $xdebugpath"

 sudo tail -100 $xdebugpath;
sudo touch /var/log/xdebug.log
sudo chown -R $USER:www-data /var/log/xdebug.log
sudo chmod -R 770  /var/log/xdebug.log

nginx-start;
# echo "/etc/php/8.3/fpm/php.ini";
echo-br "To check installed - visit the xdebug info at:"
echo-nl "$www_repofocus/xdebuginfo.php";
echo "and check for errors";

 	#	echo "as stated please enter the version number required eg 3.2.2 if we require xdebug-3.2.2.tgz"
	#	read xvers
	#	echo "Please enter the Zend Module Api No"
	#	echo "eg Configuring for:     Zend Module Api No:  20210902"
	#	echo "Just the number please"
	#	read zendapi_no
	#	echo "Finally enter the FULL xdebug.ini path given eg /etc/php/8.1/fpm/conf.d/99-xdebug.ini"
	#	read inipath
	#	os-download https://xdebug.org/files/xdebug-$xvers.tgz tmp/xdebug-$xvers.tgz
	#	cd ~/downloads/tmp
	#	tar -xvzf xdebug-$xvers.tgz
	#	cd xdebug-$xvers
	#	phpize
	#	./configure
	#	make
	#	#to generic echo "zend_extension = xdebug" >conf
	#	echo "zend_extension = /usr/lib/php/$zendapi_no/xdebug.so" >conf
	#	sudo cp modules/xdebug.so /usr/lib/php/$zendapi_no
	#	sudo cp conf $inipath
	#	sudo net-firewall-start
	#	echo "make sure port 9003 is enabled"
	#	read wait
	#	nginx-start
	fi
}

#create sudo user
function os-sudo-create(){
  echo "Please enter new sudo name"
  read newuser
	currentuser=$USER
	if [ "$newuser" != "$currentuser" ]; then
		sudo adduser $newuser
		sudo usermod -aG sudo $newuser
		os_status=$((os_status+1))
		bash-writesettings
		cd /home;
		sudo cp -R ~/bashtools $newuser/bashtools
		sudo cp -R ~/bashtoolscfg $newuser/bashtoolscfg
		sudo rm $newuser/.bash_profile;
  sudo cp ~/.bash_profile $newuser/.bash_profile;
  sudo chown -R $newuser:$newuser  $newuser/bashtools;
  sudo chown -R $newuser:$newuser  $newuser/bashtoolscfg;
		echo "Please log in as this user and hit ENTER to exit this shell"
		read wait
				os_status=0 #prevent root from setting up anything else
						bash-writesettings
		exit;
		fi
}

#lists and allows delete of sudoer
function os-sudo-remove(){
    shopt -s nullglob
    numfiles=(*)
    numfiles=${#numfiles[@]}
    if [ $numfiles == 1 ]; then
      echo "Only one SUDOer left, you cannot remove all, try os-sudo-create first";
    else
      echo "Current SUDOers";
      grep -Po '^sudo.+:\K.*$' /etc/group
      echo "Please enter sudo user name to delete"
      read rmuser;
      sudo userdel -rfRZ $rmuser;
    fi
}

function os-sshsecure() {
  		echo "Please write TESTED to confirm you have logged in via ssh with key access not password  - otherwise you might get blocked as we will secure ssh access in the next step"
  		read confirm
  		if [ "$confirm" != "TESTED" ]; then
  			echo "You can try running os-sshaccess again or try logging in via ssh"
  			read wait
  			bash-restart
  			fi
	echo "Between EACH, press ENTER to go to relevant line to edit ssh config"
	echo ""
	echo "1/4 Comment out the following to make this the definitive config file:"
	echo "Include/etc/ssh/sshd_config.d/*.conf":
	read wait
	sudo nano +12 /etc/ssh/sshd_config
	echo "2/4 stop ssh access via root for security set"
	echo "PermitRootLogin no"
	read wait
	sudo sudo nano +33 /etc/ssh/sshd_config
	echo "3/4 set authentication by public key only set"
	echo "PubkeyAuthentication yes"
	read wait
	sudo nano +38 /etc/ssh/sshd_config
	echo "4/4 Edit ssh to remove password access"
	echo "PasswordAuthentication no"
	read wait
	sudo nano +57 /etc/ssh/sshd_config
	os_status=$((os_status+1)) #we exit so need to update pointer here
  bash-writesettings;
  read "Can you log in using keypair y/n ?"
  read yn
  if [ "$yn" != "y" ]; then
      			echo "You can try running os-sshaccess again or try logging in via ssh"
      			read wait
      			bash-restart
  fi
	echo "Any key to restart sshd - you will get booted - make sure you set up ssh which is not root"
	read wait
	net-firewall-start
	sudo service ssh reload
	exit;
}

function os-install-composer() {
	cd ~/
	php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
	php composer-setup.php
	php -r "unlink('composer-setup.php');"
	sudo mv composer.phar /usr/local/bin/composer
	composer global require laravel/installer
	composer global require phpseclib/phpseclib:~3.0
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


function os-sshkeygen() {
  	currentuser=$USER
		touch /home/$currentuser/.ssh/authorized_keys
		echo "Do you want to generate NEW ssh keys or are you using EXISTING [new/existing]"
		read confirm
		if [ "$confirm" == "new" ]; then
			sudo apt install putty-tools;
			clear;
			echo "Now generating ssh keys, you are ok to accept defaults"
			echo "Enter your email to personalise the keys"
			read email;
			ssh-keygen -t rsa -b 4096 -C $email;

			#pubkey=$(<~/.ssh/id_rsa.pub)
			#sudo mv /home/$currentuser/.ssh/id_rsa /home/$newuser/.ssh/id_rsa
			#sudo mv /home/$currentuser/.ssh/id_rsa.pub /home/$newuser/.ssh/id_rsa.pub
		fi
		pubkey=$(<~/.ssh/id_rsa.pub)
		sudo chown -R $currentuser:$currentuser /home/$currentuser/.ssh
		echo "$pubkey" >/home/$currentuser/.ssh/authorized_keys
		puttygen /home/$currentuser/.ssh/id_rsa -o /home/$currentuser/.ssh/id_rsa.ppk
		ppk=$(</home/$currentuser/.ssh/id_rsa.ppk)
		echo ""
		echo "Public key for git for this server"
		echo $pubkey
		echo ""
		echo "For Windows ssh access paste this into a windows text file"
		 echo "with .ppk extension and tell Putty where to find it"
		 echo ""
		cat /home/$currentuser/.ssh/id_rsa.ppk
		echo ""
		wait
}


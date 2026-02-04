#!/usr/bin/env bash

declare -ag os_install_steps=(
        		"os-updatecheck" "os-sudo-create" "os-sshkeygen" "os-installssh" "os-sshsecure" "os-installphp" "os-install-dependancies"
        		"nginx-install" "nginx-cert-createselfsigned" "nginx-deploylocalserveradmin" "mysql-install"
        		"os-ddMediaInstall"
        		"echo setup finished"
)

os_install_step_size=${#os_install_steps[@]}
PHP_DD_VERSION=8.3
#defaults to use

function os-() {
	# at some point we could have a list of options here

	#echo "only available management is os-installer"
	#echo "any key to continue"
	#read wait
	os-installer
}

#installs the git mediastore repo
function os-ddMediaInstall(){
  			gitreponame="DD_media";
  			sudo rm -R $wwwroot/html/DD_media;
  			echo "installing DD_media  to $wwwroot/html/$gitreponame;"
  			git clone git@github.com:$gituname/DD_media.git $wwwroot/html/DD_media;
  			git-deploysubrepo "DD_media/public" "DD_libmedia"
  			nginx-setserverblock DD_media sslselfsigned
  			#20250110 php ~/bashtools/php_helpers/nginx/serverblock.php repo_name=DD_media sslcertificate=selfsigned app_url=mediastore247.com
  			#20250110 sudo mv /home/$USER/bashtoolscfg/tmp/serverblock_DD_media /etc/nginx/sites-enabled/DD_media
}


#select a specific os install step by index number or pick from menu
function os-installstep(){
	size=${#os_install_steps[@]}
	useindex=$1
	if [ "$useindex" == "" ]; then
		# use for loop to read all values and indexes
		for (( i=0; i<${os_install_step_size}; i++ ));
			do
				index=$((i+1))
  			echo "$index: ${os_install_steps[$i]}"
			done
		read -p "Enter step number: " os_step_num;
		os_step_num=$(($os_step_num-1))
	else
		echo "OS Setup $useindex of $size"
		os_step_num=$useindex;
	fi
		os_setupfunc="${os_install_steps[$os_step_num]}";
		echo "";
		echo "Ready to run"
		echo "$os_setupfunc";
		echo ""
		read -p "Hit enter to continue or S to skip this step: " input;
		if [ "$input" != "S" ]; then
        	eval $os_setupfunc;
		fi
		#20250811 else
			#20250811 	if [ "$useindex" != "" ]; then
			#20250811 		read -p "Enter F to finish auto setup (this might result in unstable system): " input;
			#20250811 		 os_status=$(($os_install_step_size+1))
		#20250811 		fi
		#20250811 fi

		        if [ "$useindex" != "" ]; then
        			os_status=$((os_status+1))
        		else
		        	os_status=$(($os_install_step_size+1))
        		fi
}

function os-checkstatus(){
	      if [ "$os_status" == "" ]; then
          os_status=0;
        fi
        if [ "$os_status" -lt "$os_install_step_size"  ]; then
        	os-installstep $os_status
    			osinstall=1;#whether to restart bash to continue setup
        else
        	os_status=$(($os_install_step_size+1))
        	osinstall=0;
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
	sudo apt-get -y install npm
	 sudo apt-get -y install unzip
	 sudo apt-get install memcached
	os-install-composer
}

#downloads only into user downloads dir with the sub path given
function os-download() {
	url=$1
	path=$2
	curl $url --create-dirs -o ~/downloads/$path
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

function os-updatecheck(){
sudo apt update
sudo apt upgrade -y
sudo apt -y install software-properties-common
}

# installs ssh
function os-installssh(){
	sudo apt update
	sudo apt install openssh-server
}

function os-sshsecure() {
	echo "Installing SSH"
  		echo "Please write TESTED to confirm you have logged in via ssh with key access not password  - otherwise you might get blocked as we will secure ssh access in the next step"
  		read confirm
  		if [ "$confirm" != "TESTED" ]; then
  			echo "You can try running os-sshaccess again or try logging in via ssh"
  			read wait
  			bash-restart
  			fi
	echo "Between EACH, press ENTER to go to relevant line to edit ssh config"
	echo ""
	echo "1/4 Comment out the following to make this config file the only  config file used"
	echo "Include/etc/ssh/sshd_config.d/*.conf":
	read wait
	sudo nano +12 /etc/ssh/sshd_config
	echo "2/4 stop ssh access via root for security uncomment / set"
	echo "PermitRootLogin no"
	read wait
	sudo sudo nano +33 /etc/ssh/sshd_config
	echo "3/4 set authentication by public key only uncomment / set"
	echo "PubkeyAuthentication yes"
	read wait
	sudo nano +38 /etc/ssh/sshd_config
	echo "4/4 remove password access uncomment / set"
	echo "PasswordAuthentication no"
	read wait
	sudo nano +57 /etc/ssh/sshd_config
	os_status=$((os_status+1)) #we exit so need to update pointer here
  bash-writesettings;
  read -p "Can you log in using keypair y/n ?"
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

function os-sshkeygen() {
  	currentuser=$USER
		touch /home/$currentuser/.ssh/authorized_keys
		echo "Do you want to generate NEW ssh keys or are you using EXISTING";
		echo "[new/existing]"
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
		chmod 600 ~/.ssh/id_rsa

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


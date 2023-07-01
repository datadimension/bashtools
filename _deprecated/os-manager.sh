#note this is for generating ssh key for your own repo

function devicesetup(){
  registryfile=/.device_cfg
  if test -f "$registryfile"; then
        echo "registry exists."
  else
        echo "Lets set up this device";
        sudo touch $registryfile;
        sudo chmod 777 $registryfile;
        csv="";
        sudo echo "$csv" > $registryfile;
    fi
    device_readregistry;

    echo "Please enter the device type [currently '$devicetype']:";
    echo "1:PC development machine";
    echo "2:AWS EC2 Ubuntu";
    echo "3:Dedicated ubuntu server";
    read option;
    if [ "$option" == "1" ]; then
        option="pcdev"
    elif [ "$option" == "2" ]; then
        option="ec2"
    elif [ "$option" == "3" ]; then
        option="ubuntu"
    else
        option="undefined"
    fi
    echo "Set value as: "$option;
    devicetype=$option;
    device_writeregistry;


    device_readregistry;
}

function testawsubuntu(){
    awsuser=/home/ubuntu
  if test -f "$awsuser"; then
        echo "aws user ubuntu exists."
        fi
}

function device_readregistry(){
    registryfilecsv=$(</.device_cfg)
    IFS=', ' read -r -a values <<<"$registryfilecsv" #read back in same order as written
    devicetype=${values[0]}
    initialsecured=${values[1]}
    spare=${values[2]}
    spare=${values[3]}
    spare=${values[4]}
    spare=${values[5]}
    spare=${values[6]}
    spare=${values[7]}
    spare=${values[8]}]
    spare=${values[9]}
    spare=${values[10]}
    spare=${values[11]}
   spare=${values[10]}
    spare=${values[11]}
   spare=${values[12]}
    spare=${values[13]}
   spare=${values[14]}
    spare=${values[15]}
   spare=${values[16]}
    spare=${values[17]}
   spare=${values[18]}
    spare=${values[19]}
}

function device_writeregistry(){
      sudo echo "$devicetype,$spare">/.device_cfg
}

function gitlaunch(){
#use this: https://help.github.com/en/github/authenticating-to-github/connecting-to-github-with-ssh
	sudo apt-get -y install git;
	echo "Enter email for git ssh keygen.";
	read sshemail;
	echo "";
	echo "Generating, press ENTER to accept defaults";
	echo "";
	ssh-keygen -t rsa -b 4096 -C $sshemail;
	eval "$(ssh-agent -s)";
	ssh-add ~/.ssh/id_rsa;history
	echo "Done, now add to GIT account at https://github.com/settings/keys";
	echo "";
	tail -1000 ~/.ssh/id_rsa.pub;
	echo "";
	echo "more info: https://help.github.com/en/enterprise/2.16/user/authenticating-to-github/adding-a-new-ssh-key-to-your-github-account";
	git config --global user.email $sshemail;
	git config --global user.name "admin_name_notset";
	git config --global user.email "undefined@dundefined.undefined";
	git config --global user.name "undefined";
}

#we need to change sudo access away from root as its an easy target
#so we will create a user
function setsudo(){
	echo "Add new user";
	echo "Adding user, minimums are password, other wise just enter blank and Y at the end";
	echo "Enter username";
	read newuser;
	sudo adduser $newuser;
	sudo usermod -aG sudo $newuser;
		sudo usermod -aG www-data $newuser;
  sudo usermod -a -G groupname username;
  chown $newuser:$newuser serverlaunch;
		        mkdir /home/$newuser/downloads;
		        sudo chown $newuser:$newuser /home/$newuser/downloads;
	  #20210112 usually allowed through firewall sudo ufw allow 22;
  echo "
Check can log in with new SSH user then press ENTER to edit SSH config - add line as (copy this)
to prevent root login and also to extend ssh login times to 6 hours

PermitRootLogin no
ClientAliveInterval 120
ClientAliveCountMax 180
";
  read $wait;
  sudo nano +9999 /etc/ssh/sshd_config;#add PermitRootLogin no
  #20201201 not require on change of server sudo /usr/bin/ssh-keygen -A;#https://askubuntu.com/questions/600584/error-could-not-load-host-key-when-trying-to-recreate-ssh-host-keys
  sudo /etc/init.d/ssh restart;
  echo "now run reboot to kick out other users";
}



function bashinstall(){
  sudo cp /var/www/html/serveradmin/_cli/bash/bash_profile.sh ~/.bash_profile;
  source ~/.bash_profile;
  sudo cp /var/www/html/serveradmin/_cli/templates/.bash_cfg ~/.bash_cfg;
  sudo chown ubuntu:ubuntu ~/.bash_cfg;
  bash-setwelcome;
  bash-envsetwwwroo


  t;
  bash-start;
}

function addsuperuser(){
            echo "Create new sudo user and remove default ? y/n"
        read input
        if [ "$input" == "y" ]; then
            echo "Enter new user name";
            read username;
            sudo adduser $username;
            sudo usermod -aG sudo $username;
            echo "Copy keys from another user ?";
            read input
            if [ "$input" == "y" ]; then
                sudo mkdir /home/$username/.ssh;
                sudo chmod 700 /home/$username/.ssh;
            echo "Now log in with new account and remove any unwanted users with 'removeuser'";
        fi
}

function osupdate(){
    adduser
    echo "nameserver 8.8.8.8" | sudo tee /etc/resolv.conf > /dev/null;
	cp /var/www/html/serveradmin/_cli/bash/templates/.bash_cfg ~/.bash_cfg;
	cp /var/www/html/serveradmin/_cli/bash/bash_profile.sh ~/.bash_profile;
	cp /var/www/html/serveradmin/_cli/bash/bash_logout.sh ~/.bash_logout;
	sudo mkdir /var/www/html;
	sudo chown $USER:www-data /var/www/html;
 sudo chmod -R 775 /var/www/html;
    #force utc timezone
    sudo rm -f /etc/localtime;# Delete the current time zone file
    sudo ln -s /usr/share/zoneinfo/UTC /etc/localtime;# Set it to the new value
	sudo apt-get -y update;
	sudo apt-get -y upgrade;
	sudo apt-get -f install;
	sudo apt-get -y install build-essential;
	sudo add-apt-repository -y universe;
	sudo apt-get -y install -y members;
	sudo apt-get -y remove apache2.*;
    sudo apt-get -y purge apache2;
    sudo apt-get -y autoremove;
    sudo apt-get -y autoclean;
	sudo apt-get -y install software-properties-common;
	sudo apt-get -y install jq;#terminal json processor https://stedolan.github.io/jq/
	sudo apt-get -y install tree;#https://lintut.com/use-tree-command-in-linux/
	sudo apt-get -y install curl;
	sudo apt-get -y install xclip;#allows copying of file to clipboard in the terminal
  sudo apt-get -y install figlet;
  sudo apt-get install -y nodejs;
  sudo apt install net-tools;
  sudo apt-get install -y whois;
  	cp /var/www/html/serveradmin/_cli/bash/templates/.bash_cfg ~/.bash_cfg;

}

function x20230110osupdate(){
	sudo apt-get -y install zip unzip php-zip;
	cp /var/www/html/serveradmin/_cli/bash/templates/.bash_cfg ~/.bash_cfg;
	cp /var/www/html/serveradmin/_cli/bash/bash_profile.sh ~/.bash_profile;
	cp /var/www/html/serveradmin/_cli/bash/bash_logout.sh ~/.bash_logout;
	sudo mkdir /var/www/html;
	sudo chown $USER:www-data /var/www/html;
 sudo chmod -R 775 /var/www/html;
    #force utc timezone

  installcomposer;

	echo "something is breaking DNS / ping / apt-get update with ufw here";
	echo "press enter to run ufw disable";
	read pause;
	sudo ufw enable;
	sudo ufw allow 22;
		sudo ufw allow 80;
sudo ufw allow 443;
  #20201214 sudo add-apt-repository ppa:certbot/certbot;#for self signed certification https://www.digitalocean.com/community/tutorials/how-to-set-up-let-s-encrypt-with-nginx-server-blocks-on-ubuntu-16-04
	echo "System updated";

}

function installvpn(){
  sudo apt-get -y install network-manager-openconnect-gnome;
}

function installftp(){
#serversetup of FTP https://help.ubuntu.com/lts/serverguide/ftp-server.html
	sudo apt-get -y install vsftpd;
	sudo adduser sftp_user;
	echo "Allow uploads by uncommenting #write_enable hit enter to change config file";
	read wait;
	sudo nano +31 /etc/vsftpd.conf;
	sudo service vsftpd restart;
  echo "for SFTP see service http://wiki.vpslink.com/Configuring_vsftpd_for_secure_connections_(TLS/SSL/SFTP)";
  echo "for TFTP http://askubuntu.com/questions/201505/how-do-i-install-and-run-a-tftp-server";
  echo "SSH https://gist.github.com/magnetikonline/48ce1d1dca53b44666ba9332bc41c698";
}

function installnginx(){
  sudo apt purge -y apache2;# remove apache
  #move nginxtest package to /var/www/html/nginxtest/

  sudo cp -r /var/www/html/serveradmin/_cli/templates/nginx/nginxtestwww /var/www/html;
    #move nginxtest package to /var/www/html/nginxtest/
  sudo apt install -y nginx;
  sudo rm /etc/nginx/sites-enabled/default;
  sudo rm /etc/nginx/sites-available/default;
  sudo rm /var/www/html/index.nginx-debian.html;

  sudo cp /var/www/html/serveradmin/_cli/templates/nginx/nginxtestblock /etc/nginx/sites-available/nginxtestblock;
  sudo cp /var/www/html/serveradmin/_cli/templates/nginx/nginxtestblock /etc/nginx/sites-available/nginxtestblock;

  sudo ln -s /etc/nginx/sites-available/nginxtestblock /etc/nginx/sites-enabled/nginxtestblock;

#self signed certificate#######################################################
  # https://linuxize.com/post/redirect-http-to-https-in-nginx/
#also see https://linuxize.com/post/redirect-http-to-https-in-nginx/
    #https://www.digitalocean.com/community/tutorials/how-to-create-a-self-signed-ssl-certificate-for-nginx-in-ubuntu-18-04
    echo "can leave all blank apart from"
    echo "Common Name (e.g. server FQDN or YOUR name) []:server_IP_address";
    sudo mkdir /etc/nginx;
    sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/nginx-selfsigned.key -out /etc/ssl/certs/nginx-selfsigned.crt
    sudo openssl dhparam -out /etc/nginx/dhparam.pem 4096;
 sudo cp /var/www/html/serveradmin/_cli/templates/nginx/ssl-params.conf /etc/nginx/snippets/ssl-params.conf;
 sudo cp /var/www/html/serveradmin/_cli/templates/nginx/self-signed.conf /etc/nginx/snippets/self-signed.conf;

    # #20230113
    # sudo cp /etc/nginx/snippets/phpmyadmin.conf /var/www/html/serveradmin/_cli/bash/templates/phpmyadminnginxsnippet;

  sudo service nginx stop;
  sudo service nginx start;
  echo "Now go to hosts file (we moved it to C:\www";
  echo "and add lines as appropriate for local browser address entry";
  echo "127.0.0.1    nginxtest";
  echo "127.0.0.1    mysite.local.com";``

}

function installPHPmyAdmin(){
    sudo apt install -y phpmyadmin php-gettext;
}

#install current latest supported php
function installphp(){
    sudo apt -y install software-properties-common;
    sudo add-apt-repository ppa:ondrej/php;
    sudo apt update;
    #20201226 sudo apt install -y php7.4;
    #20201226 sudo apt install -y php7.4-dev
    sudo apt install -y php7.4 php7.4-dev php7.4-soap php7.4-fpm php7.4-curl php7.4-bcmath php7.4-bz2 php7.4-curl php7.4-intl php7.4-mbstring php7.4-mysql php7.4-readline php7.4-xml php7.4-zip;
    echo "Press ENTER to open";
    echo "/etc/php/7.4/fpm/php.ini";
    echo "And for security change line to be";
    echo "cgi.fix_pathinfo=0; [eg uncomment and set value to 0]"
    read wait;
    sudo nano +798 /etc/php/7.4/fpm/php.ini;
    #https://www.digitalocean.com/community/tutorials/how-to-install-and-secure-phpmyadmin-with-nginx-on-ubuntu-16-04
}

function installxdebug(){
clear;
echo -e "Open https://nginxtest/index.php";
echo -e "for xdebug installation instruction";
echo "Then please enter xdebug version recommended without extension or name eg '3.0.1'";
read xdversion;
cd ~/downloads;
curl -o xdebug.tgz http://xdebug.org/files/xdebug-$xdversion.tgz;
sudo chmod 777 xdebug.tgz;
tar -xvzf xdebug.tgz;
cd xdebug-$xdversion;
sudo phpize;
echo "Please enter the Zend Module API No eg 20190902";
read zendNo;
echo "Please enter php version to just decimal version eg 7.4 not 7.4.26";
read phpNo;
./configure;
make;
sudo cp modules/xdebug.so /usr/lib/php/$zendNo;
sudo touch /var/log/xdebug.log;
sudo chmod 777 /var/log/xdebug.log;
sudo php /var/www/html/serveradmin/_cli/bash/helpers/phpiniaddxdebug.php $zendNo $phpNo;
echo "";
echo "Further:"
echo "see http://stackoverflow.com/questions/42656135/xdebug-breakpoint-fail for settings";
echo "Press Enter to restart webserver";
read wait;
nginx-start;
}

function installcomposer(){
	  # do not use sudo apt-get -y install composer; -- needs to be via phar
	  # https://getcomposer.org/doc/00-intro.md#installation-linux-unix-macos
	  cd ~/downloads;
	  php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
    php composer-setup.php
    php -r "unlink('composer-setup.php');";
    sudo mv composer.phar /usr/local/bin/composer;
	  composer global require laravel/installer;
}

function addsshuser(){
            echo "Create new sudo user and remove default ? y/n"
        read input
        if [ "$input" == "y" ]; then
            echo "Enter new user name";
            read username;
            sudo adduser $username;
            sudo usermod -aG sudo $username;
        fi
}

function addsshsudouser(){
            echo "Create new sudo user and remove default ? y/n"
        read input
        if [ "$input" == "y" ]; then
            echo "Enter new user name";
            read username;
            sudo adduser $username;
            sudo usermod -aG sudo $username;
            sudo cp -R /home/ubuntu/.ssh /home/$username/.ssh
            sudo chown -R $username:$username /home/$username/.ssh
            sudo cp /home/ubuntu/.bash_profile /home/$username/.bash_profile;
            sudo cp /home/ubuntu/.bash_cfg /home/$username/.bash_cfg;
            sudo chown -R $username:www-data /var/www
            echo "now log in under '$username' and run";
            echo "sudo rm -R /home/ubuntu/.ssh";
        fi
}


#need to allow input of new user to create
function installmysql(){
#https://support.rackspace.com/how-to/installing-mysql-server-on-ubuntu/
#ignore part about ufw, we will do that seperate
echo "Follow this guide for mysql8";
echo "https://tastethelinux.com/upgrade-mysql-server-from-5-7-to-8-ubuntu-18-04/";
sudo apt-get -y install mysql-server;
echo "Now set up security";
echo "Set max security password";
echo "Deny remote root access";
echo "Remove default test tables";
echo "Reload priviledges to take effect";
echo "Set Strong password with options";
read wait;

#set max security and remove min priviledges such as root access
sudo mysql_secure_installation utility;
sudo systemctl start mysql;
sudo systemctl enable mysql;

#set bind address for all ip addresses so can remote access
# bind-address            = 0.0.0.0
echo "
You need to edit mysqld.cnf
set bind address for all ip addresses so can remote access
bind-address            = 0.0.0.0
bind-address            = <wan ip address>
Enter to edit conf ....
";
read wait;
sudo nano +43 /etc/mysql/mysql.conf.d/mysqld.cnf;
sudo systemctl restart mysql;
sudo ufw allow mysql;

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
";
}

# for private vpn
# https://www.digitalocean.com/community/tutorials/how-to-set-up-an-openvpn-server-on-ubuntu-16-04

function installvpnconnect(){
sudo apt-get -y install network-manager-openconnect-gnome;
}

function wslprep(){
	mkdir /mnt/c/www;
	sudo ln -s /mnt/c/www /var/www;
	cp /mnt/c/Windows/System32/drivers/etc/hosts /mnt/c/www/hosts;
	    sudo chmod 777 /var/www/hosts;
	        mkdir ~/downloads;
	    echo "Open on Windows command prompt as Administrator";
    echo "del C:\Windows\System32\drivers\etc\hosts";
    echo "then create symlink";
    echo "mklink C:\Windows\System32\drivers\etc\hosts C:\www\hosts";
}

function productionprep(){
  echo "productionprep not implemented";
}

#gitlaunch;
#setsudo;
#osupdate;
#installssh;
#installftp;
#installnginx;
#installphp740;
#installxdebug;
#installhttpscert;
#installcomposer;
#installmysql

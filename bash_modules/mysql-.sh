#!/usr/bin/env bash

function mysql-install() {
	#https://support.rackspace.com/how-to/installing-mysql-server-on-ubuntu/
	#ignore part about ufw, we will do that seperate
	echo "Follow this guide for mysql 8"
	echo "https://tastethelinux.com/upgrade-mysql-server-from-5-7-to-8-ubuntu-18-04/"
	echo "Do you want MySQL here - if this a a dev server you might want to use production or database server"
	read -p "Y/n" confirm
	if [ "$confirm" != "Y" ]; then
		return 0
	fi
sudo apt-get -y install mysql-server

	#set max security and remove min priviledges such as root access
	sudo mysql_secure_installation utility
	sudo systemctl start mysql
	sudo systemctl enable mysql

	#set bind address for all ip addresses so can remote access
	# bind-address            = 0.0.0.0
	echo "
We need to edit /etc/mysql/mysql.conf.d/mysqld.cnf
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

function mysql-getversion(){
	if [ -f /etc/init.d/mysql* ]; then
    	MYSQL_VERSION="installed"
	else
  	  MYSQL_VERSION="not installed"
	fi
	echo $MYSQL_VERSION;
}
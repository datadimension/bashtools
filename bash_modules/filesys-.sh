#!/usr/bin/env bash

# shows disk partition usage
function fsys-disk(){
  df -H
}
#reset permission levels to minimal required
#need to check if permisions can be tightened
#https://stackoverflow.com/questions/30639174/how-to-set-up-file-permissions-for-laravel
function fsys-secure() {
	echo "Remove nginxtest ? y/n"
	read -t 3 input
	if [ "$input" == "y" ]; then
		www-nginxtest_remove
	fi
	echo "Securing file ownership" # this is after as password required first
	sudo chown -R $USER:www-data $wwwroot/html/$www_sitefocus

	echo "Securing file permissions"
	sudo find $wwwroot/html/$www_sitefocus -type f -exec chmod 644 {} \;

	echo "Securing directory permissions"
	sudo find $wwwroot/html/$www_sitefocus -type d -exec chmod 755 {} \;

	echo "Securing laravel permissions"
	sudo chmod -R 775 $wwwroot/html/$www_sitefocus/storage
	sudo chmod -R 775 $wwwroot/html/$www_sitefocus/public/downloads
	sudo chmod -R 775 $wwwroot/html/$www_sitefocus/private/downloads

	echo "Not impelemented"
	echo "FIrewall lockdown to"
	echo "SSH"l
	echo "FTP via SSH"
	echo "NGINX"
	echo "MySQL"
	echo "Xdebug (for dev only)"
}

function cd~() {
	dir=$1
	cd $dir
	ls
}

function file-showdir() {
	directory=$1
	echo-hr
	echo "Files at"
	echo "$directory"
	echo-hr
	ls $directory
	echo-hr
	echo ""
}

function ls-i() {
	ls -al
	echo "File count:"
	ls -l | wc -l
}

function ~www() {
	cd $wwwroot/html/$www_sitefocus
	ls
}
function ~home() {
  echo-h1 "home directory"
	cd ~/
	ls -al
}

function ~libapp() {
	cd $wwwroot/html/$www_sitefocus/app/DD_laravelAp
	ls -al
}

function ~libviews() {
	cd $wwwroot/html/$www_sitefocus/resources/views/DD_laraview
	ls -al
}

function ~libapp() {
	cd $wwwroot/html/$www_sitefocus/app/DD_laravelAp
	ls
}

function ~libviews() {
	cd $wwwroot/html/$www_sitefocus/resources/views/DD_laraview
	ls
}

function ~libmedia() {
	cd $wwwroot/html/$www_sitefocus/public/DD_libmedia
	ls
}

function ~libwww() {
	cd $wwwroot/html/$www_sitefocus/public/DD_libwww
	ls
}

function ~log() {
	cd $wwwroot/html/$www_sitefocus/storage/logs
	ls
}

function ~log-sys() {
	echo "/var/log"
	ls -al /var/log
}

function ~nginx() {
  echo-hr;
  echo "NGINX sites"
	cd /etc/nginx/sites-enabled
	ls
}

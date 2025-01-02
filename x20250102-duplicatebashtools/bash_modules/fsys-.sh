#!/usr/bin/env bash

# shows disk partition usage
function fsys-disk() {
	df -H
}
#reset permission levels to minimal required
#need to check if permisions can be tightened
#https://stackoverflow.com/questions/30639174/how-to-set-up-file-permissions-for-laravel
function fsys-secure() {
	echo "Securing file ownership" # this is after as password required first
	sudo chown -R $USER:www-data $wwwroot/html/$www_sitefocus

	echo "Securing file permissions"
	sudo find $wwwroot/html/$www_sitefocus -type f -exec chmod 644 {} \;

	echo "Securing directory permissions"
	sudo find $wwwroot/html/$www_sitefocus -type d -exec chmod 755 {} \;

	echo "Securing laravel permissions"
	sudo chmod -R 770 $wwwroot/html/$www_sitefocus/app
	sudo chmod -R 770 $wwwroot/html/$www_sitefocus/storage
	sudo chmod -R 770 $wwwroot/html/$www_sitefocus/public/downloads
	sudo chmod -R 770 $wwwroot/html/$www_sitefocus/private

	echo "Not impelemented"
	echo "FIrewall lockdown to" 
	echo "SSH"l
	echo "FTP via SSH"
	echo "NGINX"
	echo "MySQL"
	echo "Xdebug (for dev only)"
}

function file_exists() {
	path=$1
	if test -f $path; then
  echo "File exists: $path"
  else
  echo "File does not exist: $path"
fi
}

# combines cd and ls into a single command
function cdls() {
	mode=""
	dir=$1
	if [ "$1" == "-al" ]; then
		dir=$2
		mode="-al"
	fi
	cd $dir
	if [ "$mode" == "-al" ]; then
		ls -al
	fi
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
	echo-hr
	echo "NGINX sites"
	cd /etc/nginx/sites-enabled
	ls
}

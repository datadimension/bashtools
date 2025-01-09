#!/usr/bin/env bash

# shows disk partition usage
function fsys-disk() {
	df -H
}
#reset permission levels to minimal required
#need to check if permisions can be tightened
#https://stackoverflow.com/questions/30639174/how-to-set-up-file-permissions-for-laravel
function fsys-secure() {
		#sec644evel=644;
  	sec644evel=777;
  	sec755level=755;
  	sec770evel=770;
	dirname=$1
	if [ "$dirname" == "" ]; then
 		dirname=$www_repofocus;
 	fi
	ls -al $wwwroot/html/$dirname;

	echo "Securing bash-tools permissions"

	sudo chown -R $USER:www-data $wwwroot/html
	sudo chmod -R $sec755level $wwwroot/html/

	echo "Securing bash-tools permissions"
  sudo chmod -R $sec770evel ~/bashtools/php_helpers/bash

	echo "Reseting laravel permissions in $dirname"
	sudo chown -R $USER:www-data $wwwroot/html/$dirname

	echo "Reseting file permissions in $dirname"
	sudo find $wwwroot/html/$dirname -type f -exec chmod $sec644evel {} \;
	echo "Reseting directory permissions in $dirname"
	sudo find $wwwroot/html/$dirname -type d -exec chmod $sec755level {} \;
	echo "Securing directory permissions in $dirname"
	sudo chmod -R $sec755level $wwwroot/html/$dirname/app
	sudo chmod -R $sec770evel $wwwroot/html/$dirname/storage
	sudo chmod -R $sec770evel $wwwroot/html/$dirname/public/downloads
	sudo chmod -R $sec770evel $wwwroot/html/$dirname/private
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
	cd $wwwroot/html/$www_repofocus
	ls
}
function ~home() {
	echo-h1 "home directory"
	cd ~/
	ls -al
}

function ~libapp() {
	cd $wwwroot/html/$www_repofocus/app/DD_laravelAp
	ls -al
}

function ~libviews() {
	cd $wwwroot/html/$www_repofocus/resources/views/DD_laraview
	ls -al
}

function ~libapp() {
	cd $wwwroot/html/$www_repofocus/app/DD_laravelAp
	ls
}

function ~libviews() {
	cd $wwwroot/html/$www_repofocus/resources/views/DD_laraview
	ls
}

function ~libmedia() {
	cd $wwwroot/html/$www_repofocus/public/DD_libmedia
	ls
}

function ~libwww() {
	cd $wwwroot/html/$www_repofocus/public/DD_libwww
	ls
}

function ~log() {
	cd $wwwroot/html/$www_repofocus/storage/logs
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

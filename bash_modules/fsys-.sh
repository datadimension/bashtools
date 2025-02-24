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
	read -p "Conform file permisions at $www_repofocus ? This can take a few mines [y/n]: " -t 10 input
	if [ "$input" != "y" ]; then
		return 0
	fi
	sec644level=644
	sec755level=755
	sec770level=770
	dirname=$1
	if [ "$dirname" == "" ]; then
		dirname=$www_repofocus
	fi
	echo ""
	echo $wwwroot/html/$dirname
	ls -al $wwwroot/html/$dirname

	echo "Securing bash-tools permissions"
	sudo chown -R $USER:www-data $wwwroot/html
	sudo chmod -R $sec755level $wwwroot/html/

	echo "Securing bash-tools permissions"
	sudo chmod -R $sec770level ~/bashtools/php_helpers/bash

	echo "Reseting laravel permissions in $dirname"
	sudo chown -R $USER:www-data $wwwroot/html/$dirname
	sudo chown -R $USER:www-data $wwwroot/certs

	echo "Reseting file permissions in $dirname"
	sudo find $wwwroot/html/$dirname -type f -exec chmod $sec644level {} \;
	echo "Reseting directory permissions in $dirname"
	sudo find $wwwroot/html/$dirname -type d -exec chmod $sec755level {} \;
	echo "Securing directory permissions in $dirname"
	sudo chmod -R $sec644level $wwwroot/certs
	sudo chmod -R $sec755level $wwwroot/html/$dirname/app
	sudo chmod -R $sec770level $wwwroot/html/$dirname/storage
	sudo chmod -R $sec770level $wwwroot/html/$dirname/public/downloads
	sudo chmod -R $sec770level $wwwroot/html/$dirname/private
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

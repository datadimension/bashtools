#!/usr/bin/env bash
#bash_profile user
#test

function sessionstart() {
	source ~/bashtools/bash_modules/bash-.sh
	bash-start
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

function laravel-version() {
	echo "for all laravel functions we are going to site focus root (~www)"
	cd "$wwwroot/html/$www_sitefocus"
	php artisan --version
}

function ~www() {
	cd $wwwroot/html/$www_sitefocus
	ls
}

function ~home() {
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

function cd~() {
	dir=$1
	cd $dir
	ls
}

function ~log-sys() {
	echo "/var/log"
	ls -al /var/log
}

function git-setup() {
	echo ""
	echo "Enter GIT username (used to create urls for push / pull etc"
	read gituname
}

function ls-i() {
	ls -al
	echo "File count:"
	ls -l | wc -l
}

function hist() {
	search=$1
	if [ "$search" == "" ]; then
		history
	else
		history | grep $search
	fi
}
###############################################################

#TOP LEVEL FUNCTIONS - move elsewhere when we can compile bash from different files
function echo-h1() {
	textoutput=$1
	if [ "$platform" == "windows" ]; then # assume we are using the gitbash ming shell so sudo does not exist
		echo $textoutput
	else
		figlet $textoutput
	fi
}

function echo-hr() {
	printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -
}

function set-timestamp() {
	timestamp=$(date '+%F_%H:%M:%S')
}

function echo-now() {
	set-timestamp
	echo $timestamp
}

function ~nginx() {
	cd /etc/nginx/sites-enabled
	ls
}

function pshell() {
	echo "POWERSHELL"
	echo "Some functions only work running WSL as administrator"
	echo "so for this right click on Ubuntu icon, right click again on Ubuntu from this menu that appears and 'run as administrator'"
	echo "are you admin y/n"
	read -t 3 input
	if [ "$input" == "y" ]; then
		mkdir -p ~/.bu
		cp -p ~/bashtoolscfg/bash.env ~/.bu/bashtoolscfg/bash.env
		echo ""
		"POWERSHELL STARTED"
		echo ""
		echo "To close all Ubuntu WSL:"
		echo "run:"
		echo "Get-Service LxssManager | Restart-Service"
		echo ""
		echo "type exit to quit"
		powershell.exe
	fi
}

function logv() {
	logname=$1
	tail -f -n 100 $wwwroot/$www_sitefocus/storage/logs/$logname.log
}

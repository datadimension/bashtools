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

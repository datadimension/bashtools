#!/usr/bin/env bash

#help for this module
function log-h(){
	bash-helpformodule log
}

function log(){
		lines=$2
    	action=$3
	  std-menu nginxerror,app,laravel,xdebug,cron "Logs Available:"
	  echo "Loading log for $MENUCHOICE"
	  eval "log-$MENUCHOICE"  $lines $action
}

function log-show() {
	path=$1
	action=$3
	read -p "How many lines of $path ? [100]" lines
	if [ "$lines" == "" ]; then
		lines=100
	fi
	lines=-$lines
	echo "Showing $path with $lines lines:"
		echo-hr
	sudo tail $lines $path
	echo-hr
	read -t 2 -p "Clear log [clear/no]?" action
	if [ "$action" == "clear" ]; then
		echo "Clearing log at %pat"
		>$path
	fi
}

function log-laravel() {
	log-show $wwwroot/html/$www_repofocus/storage/logs/laravel.log $1 $2
}

function log-nginxerror() {
		log-show /var/log/nginx/error.log
}

function log-app() {
	sudo tail -30 $wwwroot/html/$www_repofocus/storage/logs/apperror.log
}

function log-cron() {
	log-show $wwwroot/html/$www_repofocus/storage/logs/cronlog.log $1 $2
}

function log-sys-php() {
	echo-h1 "PHP SYS LOG"
	sudo tail -30 /var/log/php_errors.log
}

function log-nginxaccess() {
	echo-h1 "NGINX ACCESS LOG"
	sudo tail -n 100 /var/log/nginx/access.log
}



function log-xdebug() {
	log-show /var/log/xdebug.log $1 $2
}

#https://logtail.com/tutorials/how-to-manage-log-files-with-logrotate-on-ubuntu-20-04/
function log-rotatedeploy() {
	sudo php $wwwroot/html/serveradmin/_cli/bash/helpers/logrotatedeployer.php $www_repofocus
}

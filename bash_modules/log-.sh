#!/usr/bin/env bash

#help for this module
function log-h(){
	bash-helpformodule log
}

function test-menuclient(){
			declare -A menuoptions
            menuoptions["nginxaccess"]="/var/log/nginx/access.log"
            menuoptions["nginxerror"]=" /var/log/nginx/error.log"
            test-menushow $menuoptions
}

function test-menushow(){
	menuoptions=$1
    for key in ${!menuoptions[@]}; do
        echo ${key} ${menuoptions[${key}]}
    done

}

function log(){
		declare -A options
        options["apperror"]="$wwwroot/html/$www_repofocus/storage/logs/apperror.log"
        options["cron"]="$wwwroot/html/$www_repofocus/storage/logs/cronlog.log"
        options["laravel"]="$wwwroot/html/$www_repofocus/storage/logs/laravel.log"
        options["phperror"]="/var/log/php_errors.log"
        options["phpfpm"]="/etc/php/8.3/fpm/php.ini"
        options["nginxaccess"]="/var/log/nginx/access.log"
        options["nginxerror"]=" /var/log/nginx/error.log"
        options["xdebug"]="/var/log/xdebug.log"
    	std-menu-array options "Log Viewer"
    	#std-menu nginxaccess,nginxerror,app,laravel,xdebug,cron,apperror,cron,phperror,phpfpm "Logs Available:"
    	#cfgfile=${options[$MENUCHOICE]}
    	#sudo nano $cfgfile
		logfile=$MENUCHOICE;

	  	echo "Loading log for $logfile"
	  	#eval "log-$MENUCHOICE"  $lines $action

	read -p "How many lines of $logfile ? [100]" lines
	if [ "$lines" == "" ]; then
		lines=100
	fi
	lines=-$lines
	echo "Showing $logfile with $lines lines:"
		echo-hr
	sudo tail $lines $logfile
	echo-hr
	read -t 4 -p "Clear log [clear/no]?" action
	if [ "$action" == "clear" ]; then
		echo "Clearing log at $logfile"
		>$path
	fi
}


#https://logtail.com/tutorials/how-to-manage-log-files-with-logrotate-on-ubuntu-20-04/
function log-rotatedeploy() {
	sudo php $wwwroot/html/serveradmin/_cli/bash/helpers/logrotatedeployer.php $www_repofocus
}

function log-show() {
	clear
	path=$1
	lines=$2
	action=$3
	if [ "$lines" == "" ]; then
		lines=100
	fi
	lines=-$lines
	sudo tail $lines $wwwroot/html/$www_repofocus/storage/logs/laravel.log
	if [ "$action" == "clear" ]; then
		>$wwwroot/html/$www_repofocus/storage/logs/laravel.log
	fi
}

function log-laravel() {
	log-show $wwwroot/html/$www_repofocus/storage/logs/laravel.log $1 $2
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

function log-nginxerror() {
	echo-h1 "NGINX ERROR LOG"
	sudo tail -n 100 /var/log/nginx/error.log
	set-timestamp
	sudo bash -c "echo '' >>  /var/log/nginx/error.log"
	sudo bash -c "echo '<<<-----viewed $timestamp ------' >>  /var/log/nginx/error.log"
	sudo bash -c "echo '' >>  /var/log/nginx/error.log"
}

function log-xdebug() {
	echo-h1 "XDEBUG LOG"
	sudo tail -n 100 /var/log/xdebug.log
}

#https://logtail.com/tutorials/how-to-manage-log-files-with-logrotate-on-ubuntu-20-04/
function log-rotatedeploy() {
	sudo php $wwwroot/html/serveradmin/_cli/bash/helpers/logrotatedeployer.php $www_repofocus
}

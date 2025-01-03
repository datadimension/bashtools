function log-app() {
	sudo tail -30 $wwwroot/html/$www_repofocus/storage/logs/apperror.log
}

function log-cron() {
	sudo tail -30 $wwwroot/html/$www_repofocus/storage/logs/apperror.log
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
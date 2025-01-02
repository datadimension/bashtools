#!/usr/bin/env bash

# restart nginx and php completely
function nginx-start() {
	echo "Restart Nginx ? y/n"
	read -t 3 input
	if [ "$input" == "y" ]; then
		clear
		echo-h1 "Closing Nginx / PHP"

		sudo service nginx stop
		sudo pkill php-fpm
		#sudo service php-fpm stop;
		sudo logrotate -f /etc/logrotate.d/nginx
		clear
		echo-h1 "Starting Nginx / PHP-fpm"
		env-attributerequire phpNo
		sudo service php$phpNo-fpm start
		sudo service nginx start
		sudo /etc/init.d/cron start
		ps aux | grep php
		echo ""
		if [ -e /var/run/nginx.pid ]; then
			echo "finished restart"
		else
			echo "nginx broke"
			log-nginxerror
		fi
		echo-now
		echo-hr
	fi
}

function remove-nginxtest(){
	echo "Remove nginxtest ? y/n"
	read -t 3 input
	if [ "$input" == "y" ]; then
		www-nginxtest_remove
	fi
}

function nginx-edit() {
	sudo nano /etc/nginx/sites-enabled/$www_sitefocus
	nginx-start
}
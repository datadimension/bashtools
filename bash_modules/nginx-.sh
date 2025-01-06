#!/usr/bin/env bash

#installs nginx
function nginx-install() {
	sudo apt -y install nginx
	#clear default files
	sudo rm /etc/nginx/sites-enabled/default
	sudo rm /etc/nginx/sites-available/default
	sudo rm /var/www/html/index.nginx-debian.html
	sudo mkdir -p /var/www/html
  sudo mkdir -p /var/www/certs
	net-firewall-start
}

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
			echo-h1 "NGINX FAIL"
			sudo nginx -t
			log-nginxerror
		fi
		echo-now
		echo-hr
	fi
}

# installs an nginx test page to check server is operational
function nginx-testadd(){
	#read -p "Add nginxtest ? Y/n"  input
	#if [ "$input" != "Y" ]; then
	#	return 1;
	#fi
	sudo cp -R ~/bashtools/templates/nginx/nginxtest /var/www/html
	sudo chown -R root:www-data  /var/www/html/nginxtest

	#create test block so nginx can read it
	php ~/bashtools/php_helpers/nginx/serverblock.php repo_name=nginxtest sslcertificate=selfsigned
	sudo mv /home/$USER/bashtoolscfg/tmp/serverblock_nginxtest /etc/nginx/sites-enabled/nginxtest
	sudo chown root:www-data /etc/nginx/sites-enabled/nginxtest
	#20230716 sudo cp ~/bashtools/templates/nginx/nginxsetup/nginxtestblockssl /etc/nginx/sites-enabled/nginxtest
	#20230716 sudo mkdir /etc/nginx
	echo "Now go to your local hosts file (we moved it to C:\www"
	echo "and add lines as appropriate for local browser address entry"
	echo "$ipaddr    nginxtest.$serverid.com"
		echo "then open Windows cmd and run ipconfig /flushdns"
	echo "and the test server should show online with"
	echo nginxtest.$serverid.com;
}

#remove the nginx test site
function nginx-testremove(){
	read -p "Remove nginxtest ? Y/n"  input
	if [ "$input" == "Y" ]; then
			sudo rm -R /var/www/html/nginxtest
    	sudo rm /etc/nginx/sites-enabled/nginxtest
	fi
}

#sets nginx block for current repo focus
function nginx-setcurrentrepofocusblock(){
      	php ~/bashtools/php_helpers/nginx/serverblock.php repo_name=$www_repofocus;
      	sudo mv /home/$USER/bashtoolscfg/tmp/serverblock_$www_repofocus /etc/nginx/sites-enabled/$www_repofocus
      	sudo chown $USER:www-data /etc/nginx/sites-enabled/$www_repofocus
}

# Makes self signed cert so dev server can run  HTTPS- note this is an insecure certificate and will not be valid on live server
function nginx-setselfsignedcert() {
		echo "Making self signed cert so dev server can run  HTTPS- note this is an insecure certificate and will not be valid on live server"
	# https://linuxize.com/post/redirect-http-to-https-in-nginx/
	#also see https://linuxize.com/post/redirect-http-to-https-in-nginx/
	#https://www.digitalocean.com/community/tutorials/how-to-create-a-self-signed-ssl-certificate-for-nginx-in-ubuntu-18-04
	echo "This requires a stable connection and can take a long time ~40 mins"
	echo "therefore its recommended to use a screen session for this in case of disconnect https://linuxize.com/post/how-to-use-linux-screen/?utm_content=cmp-true"
	echo-nl "when generating, can leave all blank"
	echo "This window will auto close when done, you may want to leave it running and open a new one"
	os_status=$((os_status+1)) #we exit so need to update pointer here
  bash-writesettings;
  echo-now;
	sudo mkdir /etc/nginx
	sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/nginx-selfsigned.key -out /etc/ssl/certs/nginx-selfsigned.crt
	sudo openssl dhparam -out /etc/nginx/dhparam.pem 4096
	echo-now;
	exit;
}

#copy preprepared ssl certs for testing
function nginx-copyselfsignedcert(){
	sudo cp ~/bashtools/templates/nginx/domainsetup/selfsslcert/nginx-selfsigned.crt /etc/ssl/certs/nginx-selfsigned.crt;
	sudo cp ~/bashtools/templates/nginx/domainsetup/selfsslcert/nginx-selfsigned.key /etc/ssl/private/nginx-selfsigned.key;
	sudo cp -R ~/bashtools/templates/nginx/domainsetup/selfsignedkeys/ssl-params.conf /etc/nginx/snippets/ssl-params.conf
	sudo cp ~/bashtools/templates/nginx/domainsetup/selfsslcert/dhparam.pem /etc/nginx/dhparam.pem
}

function nginx-edit() {
	sudo nano /etc/nginx/sites-enabled/$www_repofocus
	nginx-start
}
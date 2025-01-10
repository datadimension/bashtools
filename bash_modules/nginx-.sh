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
	read -t 10 input
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
function nginx-testadd() {
	#read -p "Add nginxtest ? Y/n"  input
	#if [ "$input" != "Y" ]; then
	#	return 1;
	#fi
	sudo cp -R ~/bashtools/templates/nginx/nginxtest /var/www/html
	sudo chown -R root:www-data /var/www/html/nginxtest

	#create test block so nginx can read it
	nginx-setserverblock nginxtest sslselfsigned
	#20250110 php ~/bashtools/php_helpers/nginx/serverblock.php
	#20250110 sudo mv /home/$USER/bashtoolscfg/tmp/serverblock_nginxtest /etc/nginx/sites-enabled/nginxtest
	#20250110 sudo chown root:www-data /etc/nginx/sites-enabled/nginxtest

	echo "Now go to your local hosts file (we moved it to C:\www"
	echo "and add lines as appropriate for local browser address entry"
	echo "$ipaddr    nginxtest.$serverid.com"
	echo "then open Windows cmd and run ipconfig /flushdns"
	echo "and the test server should show online with"
	echo nginxtest.$serverid.com
}

#remove the nginx test site
function nginx-testremove() {
	read -p "Remove nginxtest ? Y/n" input
	if [ "$input" != "n" ]; then
		sudo rm -R /var/www/html/nginxtest
		sudo rm /etc/nginx/sites-enabled/nginxtest
		echo "Nginx test removed"
	fi
}

#sets nginx block for current repo focus by default or specify repo name and sslcertificate repofocus will be changed if set
function nginx-setserverblock() {
	reponame=$1
	if [ "$reponame" == "" ]; then
		reponame=$www_repofocus
	else
		www_repofocus=$reponame #set focus or .env will be read wrong by php
		bash-writesettings
	fi
	sslcertificate=$2
	if [ "$sslcertificate" == "" ]; then
		sslcertificate="selfsigned"
	fi
	echo $sslcertificate
	php ~/bashtools/php_helpers/nginx/serverblock.php repo_name=$reponame sslcertificate=$sslcertificate
	sudo mv /home/$USER/bashtoolscfg/tmp/serverblock_$www_repofocus /etc/nginx/sites-enabled/$www_repofocus
	sudo chown $USER:www-data /etc/nginx/sites-enabled/$www_repofocus
	nginx-start
}

# Makes self signed cert so dev server can run  HTTPS- note this is an insecure certificate and will not be valid on live server
function nginx-createselfsignedcert() {
	echo "Making self signed cert so dev server can run  HTTPS- note this is an insecure certificate and will not be valid on live server"
	# https://linuxize.com/post/redirect-http-to-https-in-nginx/
	#also see https://linuxize.com/post/redirect-http-to-https-in-nginx/
	#https://www.digitalocean.com/community/tutorials/how-to-create-a-self-signed-ssl-certificate-for-nginx-in-ubuntu-18-04
	echo "This requires a stable connection and can take a long time ~40 mins"
	echo "therefore its recommended to use a screen session for this in case of disconnect https://linuxize.com/post/how-to-use-linux-screen/?utm_content=cmp-true"
	echo-nl "when generating, can leave all blank"
	echo "This window will auto close when done, you may want to leave it running and open a new one"
	os_status=$((os_status + 1)) #we exit so need to update pointer here
	bash-writesettings
	echo-now
	sudo mkdir /etc/nginx
	sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/nginx-selfsigned.key -out /etc/ssl/certs/nginx-selfsigned.crt
	sudo openssl dhparam -out /etc/nginx/dhparam.pem 4096
	echo-now
	nginx-copyselfsignedcert
	exit
}

#copy preprepared ssl self signed certs for testing
function nginx-copyselfsignedcert() {
	sudo cp ~/bashtools/templates/nginx/domainsetup/selfsslcert/nginx-selfsigned.crt /etc/ssl/certs/nginx-selfsigned.crt
	sudo cp ~/bashtools/templates/nginx/domainsetup/selfsslcert/nginx-selfsigned.key /etc/ssl/private/nginx-selfsigned.key
	sudo cp -R ~/bashtools/templates/nginx/domainsetup/selfsignedkeys/ssl-params.conf /etc/nginx/snippets/ssl-params.conf
	sudo cp ~/bashtools/templates/nginx/domainsetup/selfsslcert/dhparam.pem /etc/nginx/dhparam.pem
}

#install registered cert
function nginx-copyregisteredcert() {
	echo "Enter the file name associated with the cert files eg"
	read -p "example.com.key and example.com.chain.crt: " certdomain
	read -p "FTP cert files to ~/$USER/bashtoolscfg/tmp and press ENTER when done"
	sudo mkdir /var/www/certs/$certdomain
	sudo cp ~/bashtoolscfg/tmp/"$certdomain"_chain.crt /var/www/certs/$certdomain/"$certdomain"_chain.crt
	sudo cp ~/bashtoolscfg/tmp/$certdomain.key /var/www/certs/$certdomain/$certdomain.key
	nginx-setserverblock $www_repofocus $certdomain
}

function nginx-edit() {
	sudo nano /etc/nginx/sites-enabled/$www_repofocus
	nginx-start
}

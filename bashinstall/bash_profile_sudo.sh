#!/usr/bin/env bash
#bash_profile sudo

function bash-sudoers() {
	grep '^sudo:.*$' /etc/group | cut -d: -f4
}

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

function php-start() {
	clear
	echo-h1 "Closing PHP"
	ps aux | grep php
	sudo pkill php-fpm
	clear
	echo-h1 "Starting PHP"
	sudo service php7.4-fpm start
	ps aux | grep php
}

function bash-gitinstall() {
	cd $wwwroot/html/serveradmin/_cli/bash
	git pull
	sudo rm ~/.bash_profile
	sudo cp $wwwroot/html/serveradmin/_cli/bash/bash_profile.sh ~/.bash_profile
	source ~/.bash_profile
	bash-start
}

bash-hosts() {
	sudo tail /etc/resolv.conf
}

function log-app() {
	sudo tail -30 $wwwroot/html/$www_sitefocus/storage/logs/apperror.log
}

function log-cron() {
	sudo tail -30 $wwwroot/html/$www_sitefocus/storage/logs/apperror.log
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
}

function log-xdebug() {
	echo-h1 "XDEBUG LOG"
	sudo tail -n 100 /var/log/xdebug.log
}

#https://logtail.com/tutorials/how-to-manage-log-files-with-logrotate-on-ubuntu-20-04/
function log-rotatedeploy() {
	sudo php $wwwroot/html/serveradmin/_cli/bash/helpers/logrotatedeployer.php $www_sitefocus
}

function vpn() {
	echo 'Please enter the VPN url'
	read vpnurl
	echo "If not prompted for username AND password you will need to authorise local sudo permission to connect (this machines password)"
	sudo openconnect -b $vpnurl
	echo "CTRL C exits VPN setup - if connected will continue running in the background"
}

function php-edit() {
	echo "You might need the gateway ip:"
	tail /etc/resolv.conf
	read waitinput
	phproot="/etc/php/$phpNo/fpm"
	inifileName="$phproot/php.ini"
	sudo nano +9999 $inifileName
	nginx-start
}

function phpfpm-edit() {
	phproot="/etc/php/$phpNo/fpm"
	confFileName="$phproot/php-fpm.conf"
	sudo nano $confFileName
	nginx-start
}

function ~php() {
	phproot="/etc/php/$phpNo/fpm"
	ls -al $phproot
}

function ~g_drive() {
	cd $wwwroot/html/$www_sitefocus/public/g_drive
	ls
}

function bash-hosts() {
	sudo nano /etc/hosts
}

function x20230701git-deploy() {
	clear
	if [[ $environment != "production" ]]; then
		figlet "Warning"
		echo "This is not a production server"
	fi
	echo "You will overwrite local changes with current live version"
	echo "Please confirm full deployment to this server by typing the name of the repo you would like to pull"
	echo "You then will switch to that site and begin erasing local data with a fresh install from github"
	echo "Enter repo name, or just [ENTER]  to quit"
	read reponame
	if [ "reponame" == "" ]; then
		echo "Quit deployment"
		return -1
	fi
	echo "Enter DNS name eg website.com"
	read dnsname
	bash-showsettings
	echo-h1 "running deployment"
	#20201210 reponame=$www_sitefocus;
	## backup platform files
	#sudo mkdir $reponame;#make it exist if not there
	#cd $wwwroot

	backupPath="$wwwroot/htmlbackups/$reponame"
	sudo mkdir -p $backupPath
	#cd $wwwroot;

	#copy existing platform only files if we are redeploying for some reason
	sudo cp $wwwroot/html/$reponame/.env $backupPath/.env
	sudo cp -r $wwwroot/html/$reponame/apicredentials $backupPath

	#clone repo ###############################################
	sudo rm -r $wwwroot/html/$reponame
	cd $wwwroot/html/
	echo-hr
	echo-h1 "Cloning $reponame"
	git clone git@github.com:$gituname/$reponame.git $wwwroot/html/$reponame
	sudo chown $USER:www-data $wwwroot/html/$www_sitefocus

	# we can try and reinstall pre-existing platform files later, but at least have a .env and a credentials dir
	cp $wwwroot/html/$reponame/.env.example $wwwroot/html/$reponame/.env
	sudo mkdir -p $wwwroot/html/$reponame/apicredentials/google

	#move platform files back if we have deployed here before
	sudo cp $backupPath/.env $wwwroot/html/$reponame/.env
	sudo cp -r $backupPath/apicredentials $wwwroot/html/$reponame/app/DD_laravelAp/API

	www_sitefocus=$reponame
	git-deploysubrepos
	sudo php $wwwroot/html/serveradmin/_cli/bash/helpers/nginxblockdeployer.php $reponame $dnsname $environment
	sudo ln -s /etc/nginx/sites-available/$reponame /etc/nginx/sites-enabled/$reponame
	www-siteconfigupdate #sort permisions and composer out
	google-deploy
	echo "note changes to hosts will require"
	echo "ipconfig /flushdns"
	echo "on windows cmd terminal"
	echo "Press enter to restart nginx"
	read wait
	nginx-start
	echo-now
	echo-hr
	ls
	pwd
}

function x20210815google-deploy() {
	echo "
  Go to https://console.cloud.google.com/apis/credentials and download the 'client_secret' apicredentials json file.
  It should look something like this:
  {"web":{"client_id":"123456-abcdef123456.apps.googleusercontent.com","project_id":"example-123456","auth_uri":"https://accounts.google.com/o/oauth2/auth","token_uri":"https://oauth2.googleapis.com/token","auth_provider_x509_cert_url":"https://www.googleapis.com/oauth2/v1/certs","client_secret":"abcdef123456","redirect_uris":["https://example.com/auth/google/callback"]}}

  then copy and paste the contents here:

  "
	read apicreds
	sudo rm $wwwroot/html/$www_sitefocus/apicredentials/google/credentials.json
	sudo echo "$apicreds" >$wwwroot/html/$www_sitefocus/apicredentials/google/credentials.json
	sudo-bash-secure
}

function google-deploy() {
	clear
	sudo php $wwwroot/html/$www_sitefocus/app/DD_laravelAp/API/google/CLItokengen.php
}

function git-deploysubrepo() {
	subrepopath=$1
	subreponame=$2
	subrepopath="$wwwroot/html/$subrepopath"
	sudo rm -R $subrepopath/$subreponame
	echo-hr
	echo-h1 "cloning subrepo $subreponame"
	echo ""
	git clone git@github.com:$gituname/$subreponame.git $subrepopath/$subreponame
	echo ""
	echo "subrepo deployment of $subreponame finished at:"
	echo-now
	echo-hr
}

function nginx-edit() {
	sudo nano /etc/nginx/sites-enabled/$www_sitefocus
	nginx-start
}

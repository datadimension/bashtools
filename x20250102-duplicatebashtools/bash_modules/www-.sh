#!/usr/bin/env bash

# shows site selection
# list to pick from for various funcs
function www-siteshow() {
	echo ""
	echo "Current $environment site options are:"
	echo ""
	for i in {0..9}; do
		echo "$((i + 1)): ${wwwsites[$i]}"
	done
	echo ""
	echo "www-siteswitch to change / www-siteset to configure / www-siteremove to remove"
}

function www-siteremove() {
	clear
	echo-h1 "Site Removal"
	echo "To remove from this server, you will still be able to reinstate from git using www-setsite"
	www-siteshow
	echo "if not on the list you will need to assign it to an option with www-siteset"
	echo "Enter site number to remove"
	read option
	sitenumber=$(($option - 1))
	repodir=${wwwsites[$sitenumber]}
	echo "This will remove $repodir"
	echo "Please type '$repodir' to confirm"
	read confirm
	if [ "$repodir" == "$confirm" ]; then
		echo "removing"
		~nginx
		sudo rm $repodir
		cd $wwwroot/html
		sudo rm -R $repodir
		wwwsites[$sitenumber]=""
		bash-writesettings
		read wait -t 3
		bash-start
	else
		echo "cannot proceed until written confirmation"
	fi
}

# create extra requirements such as storage .env etc
function www-createnonrepofiles(){
	sudo mkdir -p $wwwroot/html/$dir/storage/framework/views/
	sudo mkdir -p $wwwroot/html/$dir/storage/framework/sessions/
	sudo mkdir -p $wwwroot/html/$dir/storage/framework/cache/
	sudo mkdir -p $wwwroot/html/$dir/storage/app/cache/

	sudo mkdir -p $wwwroot/html/$dir/storage/logs/
	sudo touch $wwwroot/html/$dir/storage/logs/cronresult.log
	sudo touch $wwwroot/html/$dir/storage/logs/apperror.log
	sudo touch $wwwroot/html/$dir/storage/logs/ssh.log

	sudo mkdir -p $wwwroot/html/$dir/bootstrap/cache
	sudo mkdir -p $wwwroot/html/$dir/public/downloads/
	sudo mkdir -p $wwwroot/html/$dir/private/

}

#creates a new website
function www-create() {
    clear
    echo "This will create a new laravel project";
  	echo "Available site directories:"
  	echo-hr
  	ls $wwwroot/html
  	echo-hr
  	www-siteshow
  	echo ""
  	echo "Please enter the index to set the new site on"
  	echo ""
  	read option
  	sitenumber=$(($option - 1))
  	echo "Enter the root DNS name eg example.com"
  	read dir;
	  wwwsites[$sitenumber]=$dir;
	  cd "$wwwroot/html"
    composer create-project laravel/laravel $dir;
    www_sitefocus=$dir
	  cd "$wwwroot/html/$www_sitefocus"
	  composer require laravel/ui
    php artisan ui bootstrap --auth
    git-deploysubrepos
    www-createnonrepofiles
	  bash-writesettings
	  #set nginx block
	  php ~/bashtools/php_helpers/nginx/serverblock.php servername=$www_sitefocus
	  sudo mv ~/bashtoolscfg/tmp/serverblock$www_sitefocus /etc/nginx/sites-enabled/$www_sitefocus
    #add required Laravel files to use DD_laravel app
    sudo cp ~/bashtools/templates/laravel/DD_laravelAppComponents/app/Http/Controller_c.php $wwwroot/html/$www_sitefocus/app/Http/Controllers/Contoller_c.php
    #set routes
    sudo cp ~/bashtools/templates/laravel/webfileinstall $wwwroot/html/$www_sitefocus/routes/web.php
	  nginx-start;
	  fsys-secure;
	  echo "Site created. If all set correctly You can test by entering";
	  echo;
	  echo "https://"$www_sitefocus"/baseservertest";
	  echo;
	  echo "Into your browser"
	  #composer require twilio/sdk
	  #20201119composer require clicksend/clicksend-php;
}

# sets up and assigns site to site index list, installing if needed
function www-siteset() {
	clear
	echo-h1 "Site Set"
	echo "Available site directories:"
	echo-hr
	ls $wwwroot/html
	echo-hr
	www-siteshow
	echo ""
	echo "NOTE: Reassigning site number will not delete the site - you will need to assign it to delete it and run www-siteremove"
	echo ""
	echo "Enter site number to change"
	read option
	sitenumber=$(($option - 1))
	echo "Enter site root directory name to set against site $option"
	read dir
	wwwsites[$sitenumber]=$dir
	if [ -d "$wwwroot/html/$dir" ]; then #just change option if repo exists
		echo "Setting $option to $dir"
		www_sitefocus=$dir
	else # need to set up repo
		#set -e #stop everything if there is a failure
		echo "Directory $dir not found so will install."
		echo "Will install under $wwwroot/html/$dir"
		echo "Please enter the git reponame to put here"
		read reponame
		echo "Installing '$reponame' under $wwwroot/html/$dir"
		git-installrepo $dir $reponame
		sudo touch $wwwroot/html/$dir/.env
		sudo chown $user:www-data $wwwroot/html/$dir/.env
		www-envinstall $dir $reponame
		sudo mkdir -p /var/www/certs/$dir
		sudo chown $user:www-data /var/www/certs/$dir
		echo "please upload ssl certs to /var/www/certs/$dir or directory pointed to by nginxblock for $dir"
		echo "if sharing certificate, please amend nginx block to point to it"
		read wait
		www-install-dependancies
		nginx-start
	fi
	cd "$wwwroot/html/$www_sitefocus"
	echo "setting site to $www_sitefocus"
	bash-writesettings
	www-siteswitch
}
function www-xsiteswitch() {
	www-siteshow
	echo "Please select a site number to chose for operations"
	read sitenumber
	echo "Auto sync with GIT ? (y/n)"
	read -t 3 input
	if [ "$input" == "y" ]; then
		git-push
	fi
	sitenumber=$((sitenumber - 1))
	www_sitefocus=${wwwsites[sitenumber]}
	cd "$wwwroot/html/$www_sitefocus"
	echo "setting site to $www_sitefocus"
	bash-writesettings
	if [ "$input" == "y" ]; then
		git-pull
	fi
	bash-start
}

#reset permission levels to minimal required
#need to check if permisions can be tightened
#https://stackoverflow.com/questions/30639174/how-to-set-up-file-permissions-for-laravel
function www-secure() {

	#sudo find /path/to/your/laravel/root/directory -type f -exec chmod 644 {} \;
	#sudo find /path/to/your/laravel/root/directory -type d -exec chmod 755 {} \;

	#20230907sudo chown -R $USER:www-data $wwwroot/html/$www_sitefocus/apicredentials/google/credentials.json
	#moving this to php sudo chmod -R 775 $wwwroot/html/$www_sitefocus/apicredentials/google/credentials.json
	sudo chmod -R 775 $wwwroot/html/$www_sitefocus/apicredentials/google/calendartoken.json
	sudo chown -R $USER:www-data $wwwroot/html/$www_sitefocus/app/DD_laravelAp/API
	sudo chmod -R 770 $wwwroot/html/$www_sitefocus/app/DD_laravelAp/API
	sudo chmod -R ug+rwx $wwwroot/html/$www_sitefocus/app/DD_laravelAp/API
	sudo chmod -R 775 $wwwroot/html/$www_sitefocus/bootstrap/cache

	sudo chown -R $USER:www-data $wwwroot/html/$www_sitefocus/public/downloads
	sudo chmod -R 775 $wwwroot/html/$www_sitefocus/public/downloads

	sudo chown -R $USER:www-data $wwwroot/html/$www_sitefocus/storage
	sudo chmod -R 775 $wwwroot/html/$www_sitefocus/storage
	#sudo chown -R $USER $HOME/.composer;#https://askubuntu.com/questions/1077879/cannot-create-cache-directory-home-user-composer-cache-repo-https-packagi
}

function www-envinstall() {
	rm $wwwroot/html/$www_sitefocus/.env
	touch $wwwroot/html/$www_sitefocus/.env
	chown $USER:www-data $wwwroot/html/$www_sitefocus/.env
	echo-h1 ".env file install"
	env-attributerequire databaseIP
	dir=$1
	appname=$2
	echo "Installing new .env file in project root $wwwroot/html/$dir"
	echo "First some required information please:"
	read -p "Database Password: " dbpword
	echo ""
	echo "Some additional information please, eg if copying from existing .env (you can skip these if you dont know):"
	echo ""
	read -p "Google Client ID:" gclient_id
	read -p "Google Client Secret:" gclient_secret
	read -p "GOOGLE_JAVASCRIPT_APIKEY:" google_jskey
	echo ""
	read -p "API User Email:" api_emai
	read -p "API Email Password:" api_emailpwd

	clear
	php ~/bashtools/php_helpers/laravel/envinstall.php api_emai=$api_emai api_emailpwd=$api_emailpwd dir=$dir appname=$appname dbpword=$dbpword gclient_id=$gclient_id gclient_secret=$gclient_secret google_jskey=$google_jskey
	echo "Will now generate user creation code to run in mysql  to use if you have not already done so"
	www-sitesqluserinstall $appname $dbpword
}

function www-sitesqluserinstall() {
	appname=$1
	dbpword=$2
	sqlusername=$appname"_php"
	echo "log in to mysql on the production server with:"
	echo ""
	echo "sudo mysql"
	echo ""
	echo "and run:"
	echo ""
	echo "CREATE USER '$sqlusername'@'%' IDENTIFIED BY '"$dbpword"';"
	echo "GRANT EXECUTE,SELECT,SHOW VIEW ON ddDB.* TO '"$sqlusername"'@'%';"
	echo "GRANT DELETE,EXECUTE,INSERT,SELECT,SHOW VIEW,UPDATE ON $appname.* TO '"$sqlusername"'@'%';"
	echo "FLUSH PRIVILEGES;"
}

# installs an nginx test page to check server is operational
function www-nginxtest_install() {
	sudo cp -R ~/bashtools/templates/nginx/nginxtest /var/www/html
	#create test block so nginx can read it
	user=$USER
	php ~/bashtools/php_helpers/nginx/serverblock.php servername=nginxtest
	sudo mv /home/$user/bashtoolscfg/tmp/serverblocknginxtest /etc/nginx/sites-enabled/nginxtest
	sudo chown root:www-data /etc/nginx/sites-enabled/nginxtest
	#20230716 sudo cp ~/bashtools/templates/nginx/nginxsetup/nginxtestblockssl /etc/nginx/sites-enabled/nginxtest
	#20230716 sudo mkdir /etc/nginx
	echo "Now go to your local hosts file (we moved it to C:\www"
	echo "and add lines as appropriate for local browser address entry"
	echo "127.0.0.1    nginxtest"
	echo "then open Windows cmd and run ipconfig /flushdns"
	echo "Enter https://nginxtest into browser"
	echo "and the test server should show online"
}

#remove the nginx test site
function www-nginxtest_remove() {
	sudo rm -R /var/www/html/nginxtest
	sudo rm /etc/nginx/sites-enabled/nginxtest
}

function www-siteswitch() {
	www-siteshow
	echo "Please select a site number to chose for operations"
	read sitenumber
	echo "Auto sync with GIT (recommended) ? n=no"
	read -t 5 input
	if [ "$environment" != "production" ]; then #never push from production
		if [ "$input" != "n" ]; then
			git-push
		fi
	fi
	sitenumber=$((sitenumber - 1))
	www_sitefocus=${wwwsites[sitenumber]}
	cd "$wwwroot/html/$www_sitefocus"
	echo "setting site to $www_sitefocus"
	bash-writesettings
	if [ "$input" != "n" ]; then
		git-pull
	fi
	bash-start
}

function www-routes() {
	php artisan route:list
}

# refreshes and installs composer dependancies
function www-install-dependancies() {
	clear
	echo-h1 "Updating Site Config"
	echo "update via composer"
	echo "This now might require manual edit of files"
	cd $wwwroot/html/$www_sitefocus
	#dev versions follow in comments
	composer dump-autoload # php 71 `which composer` dump-autoload;

	#need to detect php version here and if statements (bash switch?) to perform updates as system might be multi php

	#works: php71 -d memory_limit=-1 `which composer` update --no-scripts;
	composer update -W # php71 `which composer` update --no-scripts; or? php71 -d memory_limit=768M `which composer` update --no-scripts;(1610612736)
	composer install
	# this also generates autoload;
	php artisan key:generate #dev server php70 artisan key:generate;
	php artisan view:clear
	php artisan --version
	filesys-secure
}

function os-certificategen() {
	echo "This will install a self signed certificate"
}

#!/usr/bin/env bash
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
		www-siteconfigupdate
		nginx-start
	fi
	cd "$wwwroot/html/$www_sitefocus"
	echo "setting site to $www_sitefocus"
	bash-writesettings
	www-siteswitch
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
	read -p "API User Email:" api_emai
	read -p "API Email Password:" api_emailpwd
	echo ""
	read -p "Google Client ID:" gclient_id
	read -p "Google Client Secret:" gclient_secret
	read -p "GOOGLE_JAVASCRIPT_APIKEY:" google_jskey
	clear
	php ~/bashtools/php_laravel/envinstall.php api_emai=$api_emai api_emailpwd=$api_emailpwd dir=$dir appname=$appname dbpword=$dbpword gclient_id=$gclient_id gclient_secret=$gclient_secret google_jskey=$google_jskey
	echo "Will now generate user creation code to run in mysql  to use if you have not already done so"
	www-sitesqluserinstall $appname $dbpword
}

function www-sitesqluserinstall() {
	appname=$1
	dbpword=$2
	sqlusername=$appname"_php"
	echo "log in to mysql with:"
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

function www-siteswitch() {
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

function www-routes() {
	php artisan route:list
}

#creates a new website
function www-create() {
	composer require twilio/sdk
	#20201119composer require clicksend/clicksend-php;
}

function www-siteconfigupdate() {
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
	bash-secure
}

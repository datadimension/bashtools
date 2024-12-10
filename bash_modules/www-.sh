#!/usr/bin/env bash

# shows site selection
# list to pick from for various funcs
function www-reposhow() {
	echo-br "Current repo options are:"
	for i in {0..9}; do
		repolabel=${wwwsites[$i]};
					if [ "$repolabel" != "" ]; then
										repolabel="$repolabel  [dev URL: $repolabel.$serverid.com ]" ;
fi
		echo "$((i + 1)): $repolabel"
	done
	echo ""
	echo "www-reposwitch to change / www-reposet to configure / www-siteremove to remove"
}

function www-siteremove() {
	clear
	echo-h1 "Site Removal"
	echo "To remove from this server, you will still be able to reinstate from git using www-setsite"
	www-reposhow
	echo "if not on the list you will need to assign it to an option with www-reposet"
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
function x20241122www-createnonrepofiles(){
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
  	www-reposhow
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
    www_repofocus=$dir
	  cd "$wwwroot/html/$www_repofocus"
	  composer require laravel/ui
	  echo "/etc/php/8.3/cli/conf.d/20-xdebug.ini"
    php artisan ui bootstrap --auth
    git-deploysubrepos
    www-createnonrepofiles
		php ~/bashtools/php_laravel/composerjsonincludes.php;
	  bash-writesettings
	  #set nginx block
	  php ~/bashtools/php_nginx/serverblock.php servername=$www_repofocus
	  sudo mv ~/bashtoolscfg/tmp/serverblock$www_repofocus /etc/nginx/sites-enabled/$www_repofocus
    #add required Laravel files to use DD_laravel app
    sudo cp ~/bashtools/templates/laravel/DD_laravelAppComponents/app/Http/Controller_c.php $wwwroot/html/$www_repofocus/app/Http/Controllers/Controller_c.php
    #set routes
    sudo cp ~/bashtools/templates/laravel/webfileinstall $wwwroot/html/$www_repofocus/routes/web.php
	  nginx-start;
	  fsys-secure;
	  echo "Site created. If all set correctly You can test by entering";
	  echo;
	  echo "https://"$www_repofocus"/baseservertest";
	  echo;
	  echo "Into your browser"
	  #composer require twilio/sdk
	  #20201119composer require clicksend/clicksend-php;
}

# sets up and assigns site to site index list, installing if needed
function www-reposet() {
	clear
	echo-h1 "Repo Set"
	echo "Available Repos:"
	echo-hr
	ls $wwwroot/html
	echo-hr
	www-reposhow
	echo ""
	echo "NOTE: Reassigning repo number will not delete the repo - you will need to run www-reporemove"
	echo ""
	echo "Enter repo number to change"
	read option
	sitenumber=$(($option - 1))
	echo "Enter repo name to set against site";#[note on dev server use the url for the dev server eg liveinfo247"
	read newrepo
	wwwsites[$sitenumber]=$newrepo
	if [ -d "$wwwroot/html/$newrepo" ]; then #just change option if repo exists
		echo "Setting $option to $newrepo"
		www_repofocus=$newrepo
	else # need to set up repo
		#set -e #stop everything if there is a failure
		www_repofocus=$newrepo
				bash-writesettings;
		echo "Directory $newrepo not found so will install."
		echo "Will install under $wwwroot/html/$www_repofocus"
		echo "with dev URL: $www_repofocus.$serverid.com"
		git-installrepo $www_repofocus
		fi
}

function www-xsiteswitch() {
	www-reposhow
	echo "Please select a site number to chose for operations"
	read sitenumber
	echo "Auto sync with GIT ? (y/n)"
	read -t 3 input
	if [ "$input" == "y" ]; then
		git-push
	fi
	sitenumber=$((sitenumber - 1))
	www_repofocus=${wwwsites[sitenumber]}
	cd "$wwwroot/html/$www_repofocus"
	echo "setting site to $www_repofocus"
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
	sudo chmod -R 775 $wwwroot/html/$www_repofocus/apicredentials/google/calendartoken.json
	sudo chown -R $USER:www-data $wwwroot/html/$www_repofocus/app/DD_laravelAp/API
	sudo chmod -R 770 $wwwroot/html/$www_repofocus/app/DD_laravelAp/API
	sudo chmod -R ug+rwx $wwwroot/html/$www_repofocus/app/DD_laravelAp/API
	sudo chmod -R 775 $wwwroot/html/$www_repofocus/bootstrap/cache

	sudo chown -R $USER:www-data $wwwroot/html/$www_repofocus/public/downloads
	sudo chmod -R 775 $wwwroot/html/$www_repofocus/public/downloads

	sudo chown -R $USER:www-data $wwwroot/html/$www_repofocus/storage
	sudo chmod -R 775 $wwwroot/html/$www_repofocus/storage
	#sudo chown -R $USER $HOME/.composer;#https://askubuntu.com/questions/1077879/cannot-create-cache-directory-home-user-composer-cache-repo-https-packagi
}

function www-envinstall(){
	rm ~/bashtoolscfg/tmp/env
	touch ~/bashtoolscfg/tmp/env
	echo "Please add .env settings (press enter to accept default value if given)"
  declare -a attributes=(
"APP_ENV"
"SERVER_ID"
"TTL_CACHE"
"APP_DEBUG"
"APP_LOG_LEVEL"
""
"APP_NAME"
"APP_KEY"
"APP_URL"
"DEFAULT_TIMEZONE"
""
"GOOGLE_CLIENT_ID"
"GOOGLE_CLIENT_SECRET"
""
"GOOGLE_JAVASCRIPT_APIKEY"
""
"DD_CLIENT_SECRET"
""
"MAIL_DRIVER"
"MAIL_HOST"
"MAIL_PORT"
"MAIL_USERNAME"
"MAIL_PASSWORD"
"MAIL_ENCRYPTION"
""
"API_SMS_ACCOUNTID"
"API_SMS_KEY"
"API_SMS_FROMCLI"
""
"DB_HOST_ddDB"
"DB_PORT_ddDB"
"DB_DATABASE_ddDB"
"DB_USERNAME_ddDB"
"DB_PASSWORD_ddDB"
""
"DB_HOST_appDB"
"DB_PORT_appDB"
"DB_DATABASE_appDB"
"DB_USERNAME_appDB"
"DB_PASSWORD_appDB"
""
"BROADCAST_DRIVER"
"CACHE_DRIVER"
"SESSION_DRIVER"
"QUEUE_DRIVER"
    )

declare -a dev_defaultvals=(
$environment
$serverid
"7200"
"true"
"debug"
""
$www_repofocus
""
"$www_repofocus.$serverid.com"
"Europe/London"
""
""
""
""
""
""
""
""
"smtp"
"smtp.googlemail.com"
"465"
""
""
"ssl"
""
""
""
""
""
""
"3306"
""
""
""
""
""
"3306"
""
""
""
""
"log"
"file"
"file"
"sync"
            )

  declare -a possiblevals=(
              ""
              ""
              "7200"
              "true or false"
              "debug / error"
   )

declare -a defaultvals=("${dev_defaultvals[@]}")

size=${#defaultvals[@]}
i=0;
while [ $i -lt $size ]
		do
			prompt="${attributes[$i]}"
			possval=""
			if [ "$prompt" != "" ] && [ $i -lt 7 ] && [ "${possiblevals[$i]}" != "" ];then
			possval="<poss vals: ${possiblevals[$i]}> "
			fi
			if [ "$prompt" == "" ] ;then
				 echo "";
							echo "" >> ~/bashtoolscfg/tmp/env;
			else
			 		default="${defaultvals[$i]}"
			 		read -p "$prompt : $possval [default: $default] " value
					 value=${value:-$default}
					 echo "$prompt=$value" >> ~/bashtoolscfg/tmp/env;
		 fi
		 						i=$(($i+1))
		done
		mv ~/bashtoolscfg/tmp/env $wwwroot/html/$www_repofocus/.env
		    		sudo chown $USER:www-data $wwwroot/html/$www_repofocus/.env

}

function x20241115www-envinstall() {
	rm $wwwroot/html/$www_repofocus/.env
	touch $wwwroot/html/$www_repofocus/.env
	chown $USER:www-data $wwwroot/html/$www_repofocus/.env
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
	php ~/bashtools/php_laravel/envinstall.php api_emai=$api_emai api_emailpwd=$api_emailpwd dir=$dir appname=$appname dbpword=$dbpword gclient_id=$gclient_id gclient_secret=$gclient_secret google_jskey=$google_jskey
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
	php ~/bashtools/php_nginx/serverblock.php servername=nginxtest
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

#switch the repo to work on
function www-reposwitch() {
	www-reposhow
	echo "Please select a repo number to chose for operations"
	read sitenumber
	echo "Auto sync with GIT (recommended) ? n=no"
	read -t 5 input
	if [ "$environment" != "production" ]; then #never push from production
		if [ "$input" != "n" ]; then
			git-push
		fi
	fi
	sitenumber=$((sitenumber - 1))
	www_repofocus=${wwwsites[sitenumber]}
	www_repofocus=${wwwsites[sitenumber]}
	cd "$wwwroot/html/$www_repofocus"
	echo "setting repo to $www_repofocus"
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
	cd $wwwroot/html/$www_repofocus
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


function www-repoinstall(){
		dir=$1
  	reponame=$2
	echo "repoinstall";
			echo "Please enter the git reponame to put here"
  		read reponame
  		echo "Installing '$reponame' under $wwwroot/html/$dir"
  		git-installrepo $dir $reponame

}


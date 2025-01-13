#!/usr/bin/env bash

# shows site selection
# list to pick from for various funcs
function www-reposhow() {
	echo-br "Current repo options are:"
	for i in {0..9}; do
		repolabel=${wwwsites[$i]}
		if [ "$repolabel" != "" ]; then
			repolabel="$repolabel  [dev URL: $repolabel.$serverid.com ]"
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
function x20241122www-createnonrepofiles() {
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
	reponumber=$(($option - 1))
	echo "Enter repo name to set against site" #[note on dev server use the url for the dev server eg liveinfo247"
	read newrepo
	wwwsites[$reponumber]=$newrepo
	if [ -d "$wwwroot/html/$newrepo" ]; then #just change option if repo exists
		echo "Setting $option to existing $newrepo"
		www_repofocus=$newrepo
	else # need to set up repo
		#set -e #stop everything if there is a failure
		www_repofocus=$newrepo
		bash-writesettings
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

function php-clitest() {
	php ~/bashtools/php_helpers/envtestinstall.php
}

function www-envinstall() {
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
		$defaultDatabaseIP
		"3306"
		"ddDB"
		$www_repofocus"_php"
		""
		""
		$defaultDatabaseIP
		"3306"
		$www_repofocus
		$www_repofocus"_php"
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
	i=0
	while [ $i -lt $size ]; do
		prompt="${attributes[$i]}"
		possval=""
		if [ "$prompt" != "" ] && [ $i -lt 7 ] && [ "${possiblevals[$i]}" != "" ]; then
			possval="<poss vals: ${possiblevals[$i]}> "
		fi
		if [ "$prompt" == "" ]; then
			echo ""
			echo "" >>~/bashtoolscfg/tmp/env
		else
			default="${defaultvals[$i]}"
			read -p "$prompt : $possval [default: $default] " value
			value=${value:-$default}
			echo "$prompt=$value" >>~/bashtoolscfg/tmp/env
		fi
		i=$(($i + 1))
	done
	mv ~/bashtoolscfg/tmp/env $wwwroot/html/$www_repofocus/.env
	sudo chown $USER:www-data $wwwroot/html/$www_repofocus/.env

}

function www-sqlinstall() {
	echo-br "Create tables by pasting this in SQL IDE"
	echo "use $www_repofocus;"
	declare -a sqltables=(
		"_account"
		"_apisettings"
		"_appsettings"
		"_cron"
		"_dbTableMap"
		"_dbquery"
		"_ddapiauth"
		"_emailq"
		"_event"
		"_listplanner"
		"_location"
		"_monitor"
		"_notification"
		"_permissions"
		"_person"
		"_servernet"
		"_sessions"
		"_siteplanner"
		"_sysquery"
		"_usersettings"
		"_widgetgroups"
		"_widgets"
		"users"
	)

	size=${#sqltables[@]}
	i=0
	while [ $i -lt $size ]; do
		tablename="${sqltables[$i]}"
		echo "create table if not exists $tablename like serveradmin.$tablename;"
		i=$(($i + 1))
	done
	read -p "Press Enter when done"
	echo "now create views"
	php ~/bashtools/php_helpers/mysql/view_domainwidgets.php
	read -p "Press Enter when done"
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
	composer dump-autoload
	composer update -W
	composer install
	composer clear-cache
	# this also generates autoload;
	php artisan key:generate
	php artisan view:clear
	php artisan --version
}

function os-certificategen() {
	echo "This will install a self signed certificate"
}

function www-repoinstall() {
	dir=$1
	reponame=$2
	echo "repoinstall"
	echo "Please enter the git reponame to put here"
	read reponame
	echo "Installing '$reponame' under $wwwroot/html/$dir"
	git-installrepo $dir $reponame
}

#creates a new website
function www-repocreate() {
	#based on https://kbroman.org/github_tutorial/pages/init.html
	clear
	echo "This will create a new laravel project"
	www-reposhow
	echo-br "Please enter new repo name"
	read newrepo
	dir=$wwwroot/html/$newrepo
	if [ -d "$dir" ]; then #just change option if repo exists
		echo "Error: repo '$newrepo' already exists at $dir"
	else # need to set up repo
		echo "Please enter number to index '$newrepo' at"
		read sitenumber
		sitenumber=$((sitenumber - 1))
		wwwsites[$sitenumber]=$newrepo
		www_repofocus=$newrepo
		bash-writesettings
		cd "$wwwroot/html"
		composer create-project laravel/laravel $www_repofocus
		# https://www.appfinz.com/blogs/laravel-middleware-for-auth-admin-users-roles/
		#https://www.itsolutionstuff.com/post/laravel-11-user-roles-and-permissions-tutorialexample.html
		git-deploysubrepos
		php ~/bashtools/php_helpers/laravel/composerjsonincludes.php

		git-addlocalexcludedfiles
		www-sqlinstall
		www-envinstall

		cd "$wwwroot/html/$www_repofocus"

		#would be better here to have php func to add array element to the config file
		cd ~/bashtools/templates/laravel/config
		cp -v --update=none *.* $wwwroot/html/$www_repofocus/app/config

		cp ~/bashtools/templates/laravel/routes/web.php routes/web.php

		#add in DD  stubs
		cd ~/bashtools/templates/laravel/DD_laravelAppComponents/app/Http
		cp -v --update=none Controllers/*.* $wwwroot/html/$www_repofocus/app/Http/Controllers
		cp -v --update=none Middleware/*.* $wwwroot/html/$www_repofocus/app/Http/Middleware
		cp -v --update=none API/*.* $wwwroot/html/$www_repofocus/app/Http/API/
		cp -v --update=none Models/*.* $wwwroot/html/$www_repofocus/app/Http/Models

		cd ~/bashtools/templates/laravel/DD_laravelAppComponents/resources
		cp -v --update=none auth/*.* $wwwroot/html/$www_repofocus/resources/views/auth

		#add project files that use DD files
		cp ~/bashtools/templates/laravel/bootstrap/app.php $wwwroot/html/$www_repofocus/bootstrap/app.php

		#bootstrap/app (add middleware)
		#Http/Middleware/AccessLevel.php

		#config/app.php
		#AuthService
		composer require laravel/ui
		composer require laravel/socialite
		composer require google/apiclient

		www-install-dependancies

		cd "$wwwroot/html/$www_repofocus"
		echo "Vist https://github.com/new to create new repo under $www_repofocus"
		echo "chose":
		echo "Private"
		echo "untick readme"
		echo "Choose none for .giignore template"
		echo "No need for license"
		echo "When done enter the initial branch name eg main"
		read branchname
		git init
		git add -A
		git commit -m "first commit"
		git branch -M $branchname
		git remote add origin git@github.com:$gituname/$www_repofocus.git
		git push -u origin $branchname
		echo "Files set on server"
		ls -al
		echo "set focused repo to '$www_repofocus'"
		echo "Check list to display in browser [hit enter when checked]"
		read -p "Set server IP in hosts file for $www_repofocus.$serverid.com"
		read -p "In windows cmd ipconfig /flushdns"
		echo "Go to https://console.cloud.google.com/apis/credentials to set up OAuth access"
		read wait
		bash-writesettings
		nginx-setserverblock $www_repofocus sslselfsigned
		bash-restart
	fi
}

function www-fromrepobackup() {
	read -p "Enter backup dir " backupdir
	read -p "Enter target dir " targetdir
	cd "$wwwroot/html/"

	cp -a -v --update=none $wwwroot/html/$backupdir/private $wwwroot/html/$targetdir

	#  cp -r 2024_xonhealth/app/Http/Controllers xonhealth/app/Http/xControllers
	# cp -r 2024_xonhealth/private xonhealth/private
	# cp -r 2024_xonhealth/public xonhealth/xpublic
	# cp 2024_xonhealth/.env xonhealth/.env
	# cp 2024_xonhealth/routes/web.php xonhealth/routes/web.php
	# cp -r 2024_xonhealth/resources/views xonhealth/resources/xviews

	# * * * * * php /var/www/html/sc.liveinfo247.com/artisan schedule:run

	# * * * * * php /var/www/html/liveinfo247.com/artisan schedule:run >> /dev/null 2>&1
	# * * * * * cd /var/www/html/liveinfo247.com/app && ./cron.sh

	# * * * * * php /var/www/html/xonhealth/artisan schedule:run >> /dev/null 2>&1
}

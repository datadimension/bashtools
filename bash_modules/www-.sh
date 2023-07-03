#!/usr/bin/env bash
function www-siteshow() {
	echo ""
	echo "Current $environment sites are (run 'www-siteset' to configure / 'www-removesite' to remove) :"
	echo ""
	for i in {0..9}; do
		echo "$((i + 1)): ${wwwsites[$i]}"
	done
	echo ""
}

function www-siteremove() {
	clear
	echo-h1 "Site Removal"
	www-siteshow
}

function www-siteset() {
	echo-hr
	echo "Available site directories:"
	ls $wwwroot/html
	www-siteshow
	echo "Enter site number to change"
	read option
	sitenumber=$(($option - 1))
	echo "Enter site root directory name to set against site $option"
	read dir
	wwwsites[$sitenumber]=$dir
	if [ -d "$dir" ]; then #just change option if repo exists
		echo "Setting $option to $dir"
		www_sitefocus=$dir
	else # need to set up repo
		#set -e #stop everything if there is a failure
		echo "Directory $dir not found."
		echo "Will install under $wwwroot/html/$dir"
		echo "Please enter the git reponame to put here"
		read reponame
		echo "Installing '$reponame' under $wwwroot/html/$dir"
		git-installrepo $dir $reponame
		www-envinstall $dir $reponame
	fi
	cd "$wwwroot/html/$www_sitefocus"
	echo "setting site to $www_sitefocus"
	bash-writesettings
	www-switch
}

function www-envinstall() {
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
	clear
	php ~/bashtools/php_laravel/envinstall.php api_emai=$api_emai api_emailpwd=$api_emailpwd dir=$dir appname=$appname dbpword=$dbpword gclient_id=$gclient_id gclient_secret=$gclient_secret
}

function www-switch() {
	www-siteshow
	echo "Please select a site number to chose for operations"
	read sitenumber
	echo "Git will auto sync. Enter 'n' to prevent this"
	read -t 3 input
	if [ "$input" != "n" ]; then
		git-push
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

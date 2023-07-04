#!/usr/bin/env bash
function git-installrepo() {
	env-attributerequire gituname
	dir=$1
	reponame=$2
	user=$USER
	sudo mkdir $wwwroot/html/$dir
	sudo chown $user:www-data $wwwroot/html/$dir
	git clone git@github.com:$gituname/$reponame.git $wwwroot/html/$dir
	sudo touch /etc/nginx/sites-enabled/$dir
	sudo chown $user:www-data /etc/nginx/sites-enabled/$dir
	php ~/bashtools/php_nginx/serverblock.php servername=$dir
	www_sitefocus=$dir #do not this until now in case setting the repo dir and cloning it causes error
	git-deploysubrepos
	sudo mkdir -p $wwwroot/html/$dir/storage/framework/views/
	sudo mkdir -p $wwwroot/html/$dir/storage/framework/sessions/
	sudo mkdir -p $wwwroot/html/$dir/storage/framework/cache/
	sudo mkdir -p $wwwroot/html/$dir/storage/app/cache/
	sudo mkdir -p $wwwroot/html/$dir/storage/logs/
	sudo touch $wwwroot/html/$dir/storage/logs/cronresult.log
	sudo touch $wwwroot/html/$dir/storage/logs/apperror.log
	sudo mkdir -p $wwwroot/html/$dir/bootstrap/cache
	sudo mkdir -p $wwwroot/html/$dir/public/downloads/
}

function git-pull() {
	clear
	echo-hr
	curpwd=$(pwd)
	echo-h1 "Pulling to $www_sitefocus"
	echo "Enter a repo name"
	echo ""
	echo "1: DD_libwww"
	echo "2: DD_laravelAp"
	echo "3: DD_laraview"
	echo "or wait / hit enter for everything"
	read -t 3 option
	if [ "$option" == "1" ]; then
		git-pull-repo "DD_libwww"
	elif [ "$option" == "2" ]; then
		git-pull-repo "DD_laravelAp"
	elif [ "$option" == "3" ]; then
		git-pull-repo "DD_laraview"
	else
		git-pull-all
	fi
	cd $curpwd
}

function git-push() {
	clear
	curpwd=$(pwd)
	echo-h1 "Pushing from $www_sitefocus"
	echo "Enter a repo name"
	echo ""
	echo "1: DD_libwww"
	echo "2: DD_laravelAp"
	echo "3: DD_laraview"
	echo "or wait / hit enter for everything"
	read -t 3 option
	if [ "$option" == "1" ]; then
		git-push-repo "DD_libwww"
		git-pull-repo "DD_libwww"
	elif [ "$option" == "2" ]; then
		git-push-repo "DD_laravelAp"
		git-pull-repo "DD_laravelAp"
	elif [ "$option" == "3" ]; then
		git-push-repo "DD_laraview"
		git-pull-repo "DD_laraview"
	else
		git-push-all
	fi
	cd $curpwd
}

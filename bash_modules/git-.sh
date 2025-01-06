#!/usr/bin/env bash

function git-installrepo() {
	env-attributerequire gituname
	reponame=$1
	user=$USER
	sudo mkdir $wwwroot/html/$reponame
	sudo chown $user:www-data $wwwroot/html/$reponame
	git clone git@github.com:$gituname/$reponame.git $wwwroot/html/$reponame
	git-deploysubrepos;
	git-addlocalexcludedfiles;
  www-envinstall
  www-install-dependancies
  cd "$wwwroot/html/$www_repofocus"
  echo "set focused repo to '$www_repofocus'"
  bash-writesettings
  bash-restart
}

function git-addlocalexcludedfiles(){
	echo "Adding local non git files";
		sudo mkdir -p $wwwroot/html/$www_repofocus/storage/framework/views/
  	sudo mkdir -p $wwwroot/html/$www_repofocus/storage/framework/sessions/
  	sudo mkdir -p $wwwroot/html/$www_repofocus/storage/framework/cache/
  	sudo mkdir -p $wwwroot/html/$www_repofocus/storage/app/cache/

  	sudo mkdir -p $wwwroot/html/$www_repofocus/storage/logs/

  	sudo touch $wwwroot/html/$www_repofocus/storage/logs/laravel.log
  	sudo touch $wwwroot/html/$www_repofocus/storage/logs/cronresult.log
  	sudo touch $wwwroot/html/$www_repofocus/storage/logs/apperror.log
  	sudo touch $wwwroot/html/$www_repofocus/storage/logs/ssh.log

	sudo chown -R $USER:www-data $wwwroot/html/$www_repofocus/storage
	sudo chmod -R 770 $wwwroot/html/$www_repofocus/storage

  	sudo mkdir -p $wwwroot/html/$www_repofocus/bootstrap/cache
  	sudo mkdir -p $wwwroot/html/$www_repofocus/public/downloads/
  	sudo mkdir -p $wwwroot/html/$www_repofocus/private/


}

function x20241121git-installrepo() {
	env-attributerequire gituname
	reponame=$1
	user=$USER
	www-createnonrepofiles;
	sudo touch $wwwroot/html/$dir/.env

    		sudo mkdir -p /var/www/certs/$dir
    		sudo chown $user:www-data /var/www/certs/$dir
    		echo "please upload ssl certs to /var/www/certs/$dir or directory pointed to by nginxblock for $dir"
    		echo "if sharing certificate, please amend nginx block to point to it"
    		read wait
    		php ~/bashtools/php_helpers/laravel/composerjsonincludes.php;
    composer update
    		nginx-start
    		fsys-secure
    	cd "$wwwroot/html/$www_repofocus"
    	echo "setting site to $www_repofocus"
    	bash-writesettings
    	www-reposwitch
}

function git-pull-select(){
	clear
	echo-hr
	curpwd=$(pwd)
	echo-h1 "Pulling to $www_repofocus"
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

function git-pull() {
	clear
	echo-hr
	curpwd=$(pwd)
	echo-h1 "Pulling to $www_repofocus"
		git-pull-all
	cd $curpwd
}

function git-push-select(){
		clear
  	curpwd=$(pwd)
  	echo-h1 "Pushing from $www_repofocus"
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

function git-push() {
	clear
	curpwd=$(pwd)
	echo-h1 "Pushing from $www_repofocus"
		git-push-all
	cd $curpwd
}

function git-add() {
	git status -uno
	git add -A
	git commit -a -m update
	echo "... all files added"
}

#reset all repos
function git-reset-all() {
	git-reset-repo "DD_laraview"
	git-reset-repo "DD_libwww"
	#git-reset-repo "DD_libmedia"
	git-reset-repo "DD_laravelAp"
	git-reset-repo "$www_repofocus"
	if [ "$platform" == "ubuntu" ]; then # aimed at the ming64 shell for windows which does not have functions such as sudo
		echo "Reset file and directory permissions ? [y/n]"
		read input
		if [ "$input" == "y" ]; then
			fsys-secure
		fi
	fi
}

function git-reset() {
	clear
	curpwd=$(pwd)
	echo "Enter a repo name"
	echo ""
	echo "1: DD_libwww"
	echo "2: DD_laravelAp"
	#echo "3: DD_libmedia"
	echo "3: DD_laraview"
	echo "or hit enter for everything"
	read option
	if [ "$option" == "1" ]; then
		git-reset-repo "DD_libwww"
	elif [ "$option" == "2" ]; then
		git-reset-repo "DD_laravelAp"
	elif [ "$option" == "3" ]; then
		git-reset-repo "DD_laraview"
	else
		git-reset-all
	fi
	cd $curpwd
}

#forces file overwrite from server, untracked files remain
function git-reset-repo() {
	gitreponame=$1
	if [ "$gitreponame" == "DD_laraview" ]; then
		gitrepopath="$wwwroot/html/$www_repofocus/resources/views"
	elif [ "$gitreponame" == "DD_libwww" ]; then
		gitrepopath="$wwwroot/html/$www_repofocus/public"
	elif [ "$gitreponame" == "DD_laravelAp" ]; then
		gitrepopath="$wwwroot/html/$www_repofocus/app"
	elif [ "$gitreponame" == "DD_libmedia" ]; then
		gitrepopath="$wwwroot/html/$www_repofocus/public"
	else
		gitrepopath="$wwwroot/html"
		gitreponame=$www_repofocus
	fi
	echo-hr
	echo "reseting repo ..."
	echo-h1 "$gitreponame"
	echo "to $gitrepopath/$gitreponame;"
	cd $gitrepopath/$gitreponame
	git fetch --all
	# branchname=$(date +%Y%m%d%I%M)
	echo "Reseting to $gitreponame$branchname"
	# git branch "reset$gitreponame$branchname"
	git reset --hard origin/master
}

function git-push-all() {
	git-push-repo "DD_laraview"
	git-push-repo "DD_libwww"
	git-push-repo "DD_laravelAp"
	git-push-repo "$www_repofocus"
}

function git-push-repo() {
	gitreponame=$1
	if [ "$gitreponame" == "DD_laraview" ]; then
		gitrepopath="$wwwroot/html/$www_repofocus/resources/views"
	elif [ "$gitreponame" == "DD_libwww" ]; then
		gitrepopath="$wwwroot/html/$www_repofocus/public"
	elif [ "$gitreponame" == "DD_laravelAp" ]; then
		gitrepopath="$wwwroot/html/$www_repofocus/app"
	elif [ "$gitreponame" == "DD_libmedia" ]; then
		gitrepopath="$wwwroot/html/$www_repofocus/public"
	else
		gitrepopath="$wwwroot/html"
		gitreponame=$www_repofocus
	fi
	echo "pushing repo ..."
	echo-h1 "$gitreponame"
	echo "from $gitrepopath/$gitreponame;"
	cd $gitrepopath/$gitreponame
	git-add
	git push
	echo ""
	echo "Finished at:"
	echo-now
	echo-hr
}

function git-pull-repo() {
	gitreponame=$1
	if [ "$gitreponame" == "DD_laraview" ]; then
		gitrepopath="$wwwroot/html/$www_repofocus/resources/views"
	elif [ "$gitreponame" == "DD_libwww" ]; then
		gitrepopath="$wwwroot/html/$www_repofocus/public"
	elif [ "$gitreponame" == "DD_laravelAp" ]; then
		gitrepopath="$wwwroot/html/$www_repofocus/app"
	elif [ "$gitreponame" == "DD_libmedia" ]; then
		gitrepopath="$wwwroot/html/$www_repofocus/public"
	else
		gitrepopath="$wwwroot/html"
		gitreponame=$www_repofocus
	fi
	echo "pulling repo ..."
	echo-h1 "$gitreponame"
	echo "to $gitrepopath/$gitreponame;"
	cd $gitrepopath/$gitreponame
	git-add
	git pull
	echo ""
	echo "Finished at:"
	echo-now
	echo-hr
}

function git-pull-all() {
	git-pull-repo "DD_laraview"
	git-pull-repo "DD_libwww"
	git-pull-repo "DD_laravelAp"
	git-pull-repo "$www_repofocus"
}

function git-setup() {
	echo ""
	echo "Enter GIT username (used to create urls for push / pull etc"
	read gituname
}

function git-deploysubrepos() {
	git-deploysubrepo "$www_repofocus/public" "DD_libwww"
	git-deploysubrepo "$www_repofocus/app" "DD_laravelAp"
	git-deploysubrepo "$www_repofocus/resources/views" "DD_laraview"
}

function git-deploysubrepo() {
	subrepopath=$1
	subreponame=$2
	subrepopath="$wwwroot/html/$subrepopath"
	rm -R $subrepopath/$subreponame
	echo-hr
	echo-h1 "cloning subrepo $subreponame"
	echo ""
	git clone git@github.com:$gituname/$subreponame.git $subrepopath/$subreponame
	echo ""
	echo "subrepo deployment of $subreponame finished at:"
	echo-now
	echo-hr
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
	sudo chown $USER:www-data $wwwroot/html/$www_repofocus

	# we can try and reinstall pre-existing platform files later, but at least have a .env and a credentials dir
	cp $wwwroot/html/$reponame/.env.example $wwwroot/html/$reponame/.env
	sudo mkdir -p $wwwroot/html/$reponame/apicredentials/google

	#move platform files back if we have deployed here before
	sudo cp $backupPath/.env $wwwroot/html/$reponame/.env
	sudo cp -r $backupPath/apicredentials $wwwroot/html/$reponame/app/DD_laravelAp/API

	www_repofocus=$reponame
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

#!/usr/bin/env bash
#bash_profile user
#test
function bash-start() {
  	source ~/bashtools/bash_modules/os-.sh
  	source ~/bashtools/bash_modules/www-.sh
  	source ~/bashtools/bash_modules/bash-.sh

	clear
	bash-readsettings
	env-attributerequire "welcomemsg"
	env-attributerequire "environment"
	env-attributerequire "wwwroot"
	echo "Welcome"
	echo-h1 $welcomemsg
	echo ""
	# sudo /etc/init.d/cron start;
	echo "Use 'env-about' for more info, 'bash-help' for more functions"
	www-showsites
	#bash-showsettings
	startdir="$wwwroot/html/$www_sitefocus"
	cd $startdir
	file-showdir $startdir
}

file-showdir() {
	directory=$1
	echo-hr
	echo "$directory"
	echo-hr
	ls $directory
	echo-hr
	echo ""
}


function laravel-version() {
	echo "for all laravel functions we are going to site focus root (~www)"
	cd "$wwwroot/html/$www_sitefocus"
	php artisan --version
}

env-setwwwroot() {
	echo "Please set www root directory"
	read wwwroot
	bash-writesettings
	env-attributerequire "wwwroot"
}


function env-about() {
	clear
	echo-h1 "About this system"
	echo "System Time:"
	echo-now
	if [ "$platform" == "ubuntu" ]; then
		echo "Current Environment (development/ production):$environment use 'env-setservertype' to change"
		ipaddr=$(hostname --all-ip-addresses)
		cat /etc/lsb-release
		echo "IP : $ipaddr"
		# echo |  Gateway: $ipgateway  |
		echo "PHP Version: $phpNo"
		echo "GIT username: $gituname"
	else
		echo $platform
	fi
	echo-hr
	echo "www root: $wwwroot"
	echo "Available SSH (bash-ssh): $ssh1 | $ssh2"
	echo-hr
}

function env-attributerequire() {
	varname=$1
	if [ "$varname" == "environment" ]; then
		if [ "$environment" == "" ]; then
			env-setservertype
		fi
	elif [ "$varname" == "gituname" ]; then
		if [ "$gituname" == "" ]; then
			echo "Please enter your git username and ensure you have set up ssh access"
			read gituname
			bash-writesettings
		fi
	elif [ "$varname" == "wwwroot" ]; then
		if [ "$wwwroot" == "" ]; then
			env-setwwwroot
		fi
	elif [ "$varname" == "phpNo" ]; then
		if [ "$phpNo" == "" ]; then
			echo ""
			echo "PHP check:"
			php -v
			echo ""
			echo ""
			echo "Please confirm the php version to 1 decimal place shown above eg 7.1 or 8.1"
			read phpNo
			bash-writesettings
		fi
	elif [ "$varname" == "welcomemsg" ]; then
		if [ "$welcomemsg" == "" ]; then
			echo "Please enter Welcome Message / server name"
			read welcomemsg
			bash-writesettings
		fi
	fi
}

#for per machine settings that do not change
function env-setservertype() {
	#bash-envsetwwwroot
	echo "Enter environment (production / development)"
	read environment
	if [ "$environment" == "development" ]; then
		environment="development"
	else
		environment="production"
	fi
	echo "Environment set to $environment"
	bash-writesettings
	#echo "Enter dev site project names ? y/n"
	#read doset
	# if [ "$doset" = "y" ]; then
	#   www-setsites
	# fi
	# cd $wwwroot
}

function env-setattribute() {
	varname=$1
	echo "Attempting to reset $varname"
	if [ "$varname" == "phpNo" ]; then
		phpNo=""
		bash-writesettings
		env-attributerequire $varname
	fi
}

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
	www_sitefocus=$dir #only do this now in case setting the repo dir and cloning it causes error
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
	echo "Please paste a .env file if you wish to set this, or hit enter";
	read dotenv;
		if [ "$dotenv" != "" ]; then
		  echo "dotenv";
	fi
}

function ~www() {
	cd $wwwroot/html/$www_sitefocus
	ls
}

function ~home() {
	cd ~/
	ls -al
}

function ~libapp() {
	cd $wwwroot/html/$www_sitefocus/app/DD_laravelAp
	ls -al
}

function ~libviews() {
	cd $wwwroot/html/$www_sitefocus/resources/views/DD_laraview
	ls -al
}

function ~libapp() {
	cd $wwwroot/html/$www_sitefocus/app/DD_laravelAp
	ls
}

function ~libviews() {
	cd $wwwroot/html/$www_sitefocus/resources/views/DD_laraview
	ls
}

function ~libmedia() {
	cd $wwwroot/html/$www_sitefocus/public/DD_libmedia
	ls
}

function ~libwww() {
	cd $wwwroot/html/$www_sitefocus/public/DD_libwww
	ls
}

function ~log() {
	cd $wwwroot/html/$www_sitefocus/storage/logs
	ls
}

function cd~() {
	dir=$1
	cd $dir
	ls
}

function ~log-sys() {
	echo "/var/log"
	ls -al /var/log
}

function git-setup() {
	echo ""
	echo "Enter GIT username (used to create urls for push / pull etc"
	read gituname
}

function git-deploysubrepos() {
	git-deploysubrepo "$www_sitefocus/public" "DD_libwww"
	#20230701 this has its own repo now git-deploysubrepo "$www_sitefocus/public" "DD_libmedia"
	git-deploysubrepo "$www_sitefocus/app" "DD_laravelAp"
	git-deploysubrepo "$www_sitefocus/resources/views" "DD_laraview"
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
	git-reset-repo "$www_sitefocus"
	if [ "$platform" == "ubuntu" ]; then # aimed at the ming64 shell for windows which does not have functions such as sudo
		echo "Reset file and directory permissions ? [y/n]"
		read input
		if [ "$input" == "y" ]; then
			bash-secure
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
		gitrepopath="$wwwroot/html/$www_sitefocus/resources/views"
	elif [ "$gitreponame" == "DD_libwww" ]; then
		gitrepopath="$wwwroot/html/$www_sitefocus/public"
	elif [ "$gitreponame" == "DD_laravelAp" ]; then
		gitrepopath="$wwwroot/html/$www_sitefocus/app"
	elif [ "$gitreponame" == "DD_libmedia" ]; then
		gitrepopath="$wwwroot/html/$www_sitefocus/public"
	else
		gitrepopath="$wwwroot/html"
		gitreponame=$www_sitefocus
	fi
	echo-hr
	echo "reseting repo ..."
	echo-h1 "$gitreponame"
	echo "to $gitrepopath/$gitreponame;"
	cd $gitrepopath/$gitreponame
	#git remote set-url origin git@github.com:datadimension/$gitreponame
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
	git-push-repo "$www_sitefocus"
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

function git-push-repo() {
	gitreponame=$1
	if [ "$gitreponame" == "DD_laraview" ]; then
		gitrepopath="$wwwroot/html/$www_sitefocus/resources/views"
	elif [ "$gitreponame" == "DD_libwww" ]; then
		gitrepopath="$wwwroot/html/$www_sitefocus/public"
	elif [ "$gitreponame" == "DD_laravelAp" ]; then
		gitrepopath="$wwwroot/html/$www_sitefocus/app"
	elif [ "$gitreponame" == "DD_libmedia" ]; then
		gitrepopath="$wwwroot/html/$www_sitefocus/public"
	else
		gitrepopath="$wwwroot/html"
		gitreponame=$www_sitefocus
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
		gitrepopath="$wwwroot/html/$www_sitefocus/resources/views"
	elif [ "$gitreponame" == "DD_libwww" ]; then
		gitrepopath="$wwwroot/html/$www_sitefocus/public"
	elif [ "$gitreponame" == "DD_laravelAp" ]; then
		gitrepopath="$wwwroot/html/$www_sitefocus/app"
	elif [ "$gitreponame" == "DD_libmedia" ]; then
		gitrepopath="$wwwroot/html/$www_sitefocus/public"
	else
		gitrepopath="$wwwroot/html"
		gitreponame=$www_sitefocus
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
	git-pull-repo "$www_sitefocus"
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

function ls-i() {
	ls -al
	echo "File count:"
	ls -l | wc -l
}

function hist() {
	search=$1
	if [ "$search" == "" ]; then
		history
	else
		history | grep $search
	fi
}
###############################################################

#TOP LEVEL FUNCTIONS - move elsewhere when we can compile bash from different files
function echo-h1() {
	textoutput=$1
	if [ "$platform" == "windows" ]; then # assume we are using the gitbash ming shell so sudo does not exist
		echo $textoutput
	else
		figlet $textoutput
	fi
}

function echo-hr() {
	printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -
}

function set-timestamp() {
	timestamp=$(date '+%F_%H:%M:%S')
}

function echo-now() {
	set-timestamp
	echo $timestamp
}

function ~nginx() {
	cd /etc/nginx/sites-enabled
	ls
}

function pshell() {
	echo "POWERSHELL"
	echo "Some functions only work running WSL as administrator"
	echo "so for this right click on Ubuntu icon, right click again on Ubuntu from this menu that appears and 'run as administrator'"
	echo "are you admin y/n"
	read -t 3 input
	if [ "$input" == "y" ]; then
		mkdir -p ~/.bu
		cp -p ~/bashtoolscfg/bash.env ~/.bu/bashtoolscfg/bash.env
		echo ""
		"POWERSHELL STARTED"
		echo ""
		echo "To close all Ubuntu WSL:"
		echo "run:"
		echo "Get-Service LxssManager | Restart-Service"
		echo ""
		echo "type exit to quit"
		powershell.exe
	fi
}

function logv() {
	logname=$1
	tail -f -n 100 $wwwroot/$www_sitefocus/storage/logs/$logname.log
}

#!/usr/bin/env bash

# initialises the bash shell #
function bash-start() {
	source ~/bashtools/bash_modules/std-.sh #standard for a platforms
	source ~/bashtools/bash_modules/os-.sh
		source ~/bashtools/bash_modules/mysql-.sh
	source ~/bashtools/bash_modules/fsys-.sh
	source ~/bashtools/bash_modules/env-.sh
	source ~/bashtools/bash_modules/nginx-.sh
	source ~/bashtools/bash_modules/php-.sh
	source ~/bashtools/bash_modules/www-.sh
	source ~/bashtools/bash_modules/git-.sh
	source ~/bashtools/bash_modules/net-.sh
	source ~/bashtools/bash_modules/log-.sh
	source ~/bashtools/bash_modules/laravel-.sh

	mysql-getversion;

	clear
	bash-readsettings
	osinstall=0;
	os-checkstatus
	if [ $osinstall == 1 ]; then
		read -p "Any key to restart" wait;
		bash-restart
	fi

	env-attributerequire "serverid"
	env-attributerequire "environment"
	env-attributerequire "wwwroot"
	env-attributerequire "defaultDatabaseIP"

	MENUCHOICE="" #reserved as a global for menu function
	PHP_VERSION=`php -r 'echo PHP_VERSION;'`

	#env-attributerequire "welcomemsg"

	echo "Welcome to"
	echo-h1 $serverid
	echo $welcomemsg
	echo "Your session IP detected as:"
  	echo $SSH_CLIENT | awk '{ print $1}'
	# sudo /etc/init.d/cron start;
	echo "Use 'env-about' for more info, 'bash-help' for more functions"
	www-reposhow
	#bash-showsettings
	startdir="$wwwroot/html/$www_repofocus"
	cd $startdir
	echo ""
	laravel-showversion;
	echo "Recommended URL"
	echo "$www_repofocus.$serverid.com"
	echo ""
	file-showdir $startdir
	net-ssh-log-session
	laravel-configcheck
}

function bash-push(){
	git-push-repo bashtools
	~www
}

function bash-pull(){
	echo "updating bash";
	git-pull-repo bashtools
	bash-install
}

# installs the enhanced bash functionality provided by Bashtools
function bash-install() {
	#detect ubuntu or MINW64
	homepath=${HOME:0:6}
	if [ "$homepath" == "/home/" ]; then
		username=${HOME:6}
		platform="ubuntu"
		wwwroot="/var/www"
		echo -e "Detected:\nPlatform=$platform\nUser=$username\nwwwroot=$wwwroot"
        rm ~/.bash_profile
      	cp ~/bashtools/bashinstall/bash_profile_head.sh ~/.bash_profile
        if [ "$platform" == "ubuntu" ]; then # aimed at the ming64 shell for windows which does not have functions such as sudo
        	# cat ~/bashtools/bashinstall/bash_profile_sudo.sh >>~/.bash_profile
        	noop=1
    	fi
       	# cat ~/bashtools/bashinstall/bash_profile_multiplatform.sh >>~/.bash_profile
      	cat ~/bashtools/bashinstall/bash_profile_foot.sh >>~/.bash_profile
       	mkdir -p ~/bashtoolscfg/tmp
       	bash-writesettings
       	echo "Restarting shell ..."
       	read -t 2 input
       	source ~/.bash_profile
	else
		bash-installforwindows
	fi
}

function bash-installforwindows(){
	echo "bash install for windows";
}

# shows bash function categories and functions
function bash-help() {
	std-menu std,bash,env,fsys,git,log,net,os,nginx,php,www "Help Categories:"
	echo "Loading help for $MENUCHOICE ...";
	php ~/bashtools/php_helpers/bash/bash-help.php helptype=$MENUCHOICE
}

#restarts bash shell
function bash-restart() {
	bash-writesettings
	clear
	source ~/.bash_profile # this restarts bash as well
}

function bash-who() {
	echo "I am"
	echo-h1 $welcomemsg
}

function bash-logout() {
	bash-writesettings
	echo "Written out settings, press enter to exit"
	read waitb
	clear
	source ~/.bash_profile  # this restarts bash as well
}

# Show history or search in history
function bash-h() {
	search=$1
	if [ "$search" == "" ]; then
		echo "enter search text"
		read search
	fi
	clear
	echo "history search:"
	echo "$search"
	echo-hr
	if [ "$search" == "" ]; then
		history
	else
		history | grep $search
	fi
	echo-hr
}

function bash-sudoers() {
	grep '^sudo:.*$' /etc/group | cut -d: -f4
}

# displays the current bashtoolscfg files
function bash-cfg() {
	echo-b "bash.env"
	echo ""
	tail ~/bashtoolscfg/bash.env
	echo -e "\n"
	echo-b "os_status"
	echo ""
	tail ~/bashtoolscfg/os_status
	echo -e "\n"
	echo-b "os_status.env"
	echo ""
	tail ~/bashtoolscfg/os_status.env
	echo -e "\n"
	echo-b "wwwsites"
	echo ""
	tail ~/bashtoolscfg/wwwsites
}

function bash-writesettings() {
	csv=""
	for i in {0..9}; do
		csv+="${wwwsites[$i]},"
	done
	#20230629echo $csv;
	echo "$csv" >~/bashtoolscfg/wwwsites
		echo "$csv" >~/bashtoolscfg/wwwrepos
	echo "$os_status,$sshsecure" >~/bashtoolscfg/os_status
	echo "$git_ssh" >~/bashtoolscfg/gitcfg
	echo "$environment,$www_repofocus,$ssh1,$ssh2,$defaultDatabaseIP,$serverid,,$gituname,$phpNo,$ipgateway,$welcomemsg,$wwwroot,$platform,$wwwrepos,$www_repofocus" >~/bashtoolscfg/bash.env
}

function bash-readsettings() {
	wwwsites=$(<~/bashtoolscfg/wwwsites)
	wwwrepos=$(<~/bashtoolscfg/wwwrepos)

	IFS=', ' read -r -a wwwsites <<<"$wwwsites" #read back in same order as written

	csv=$(<~/bashtoolscfg/os_status)
	IFS=', ' read -r -a values <<<"$csv" #read back in same order as written
	os_status=${values[0]}
	sshsecure=${values[1]}

	csv=$(<~/bashtoolscfg/gitcfg)
	IFS=', ' read -r -a values <<<"$csv" #read back in same order as written
	git_ssh=${values[0]}

	csv=$(<~/bashtoolscfg/bash.env)
	IFS=', ' read -r -a values <<<"$csv" #read back in same order as written
	serverid=${values[5]}
	environment=${values[0]}
	www_repofocus=${values[1]}
	ssh1=${values[2]}
	ssh2=${values[3]}
	defaultDatabaseIP=${values[4]}
	gituname=${values[7]}
	phpNo=${values[8]}
	ipgateway=${values[9]}
	welcomemsg=${values[10]}
	wwwroot=${values[11]}
	platform=${values[12]}
	wwwrepos=${values[13]}
	www_repofocus=${values[14]}
}

#!/usr/bin/env bash

# initialises the bash shell #
function bash-start() {
	source ~/bashtools/bash_modules/std-.sh #standard for a platforms
	source ~/bashtools/bash_modules/os-.sh
	source ~/bashtools/bash_modules/fsys-.sh
	source ~/bashtools/bash_modules/env-.sh
	source ~/bashtools/bash_modules/nginx-.sh
	source ~/bashtools/bash_modules/php-.sh
	source ~/bashtools/bash_modules/www-.sh
	source ~/bashtools/bash_modules/git-.sh
	source ~/bashtools/bash_modules/net-.sh
	source ~/bashtools/bash_modules/log-.sh

	clear
	bash-readsettings

	env-attributerequire "os_status"
	env-attributerequire "serverid"
	env-attributerequire "environment"
	env-attributerequire "wwwroot"
	MENUCHOICE="" #reserved as a global for menu function

	#env-attributerequire "welcomemsg"

	echo "Welcome to"
	echo-h1 $serverid
	echo $welcomemsg
	echo "Your session IP detected as:"
	echo $SSH_CLIENT | awk '{ print $1}'
	# sudo /etc/init.d/cron start;
	echo "Use 'env-about' for more info, 'bash-help' for more functions"
	www-siteshow
	#bash-showsettings
	startdir="$wwwroot/html/$www_sitefocus"
	cd $startdir
	file-showdir $startdir
	net-ssh-log-session
}

# this comment will be ignored for now as no closure #
function bash-push() {
	echo-h1 "pushing bash repo"
	cd ~/bashtools
	git add -A
	git commit -a -m update
	git push
	bash-pull
	~www
}

function bash-pull() {
	clear
	echo-h1 "Updating BASH"
	cd ~/bashtools
	git pull
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
	else
		username=${HOME:9}
		platform="windows"
		wwwroot="/c/Users/$username/www"
	fi
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
}

# shows bash function categories and functions
function bash-help() {
	std-menu std,bash,env,fsys,git,log,net,os,nginx,php,www "Help Categories:"
	php ~/bashtools/php_helpers/bash/bash-help.php helptype=$MENUCHOICE
}

#restarts bash shell
function bash-restart() {
	bash-writesettings
	clear
	source ~/.bash_profile
	bash-start
}

function bash-writesettings() {
	csv=""
	for i in {0..9}; do
		csv+="${wwwsites[$i]},"
	done
	#20230629echo $csv;
	echo "$csv" >~/bashtoolscfg/wwwsites
	echo "$os_status,$sshsecure" >~/bashtoolscfg/os_status
	echo "$git_ssh" >~/bashtoolscfg/gitcfg
	echo "$environment,$www_sitefocus,$ssh1,$ssh2,$databaseIP,$serverid,,$gituname,$phpNo,$ipgateway,$welcomemsg,$wwwroot,$platform" >~/bashtoolscfg/bash.env
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
	source ~/.bash_profile
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

function bash-readsettings() {
	wwwsites=$(<~/bashtoolscfg/wwwsites)
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
	www_sitefocus=${values[1]}
	ssh1=${values[2]}
	ssh2=${values[3]}
	databaseIP=${values[4]}
	gituname=${values[7]}
	phpNo=${values[8]}
	ipgateway=${values[9]}
	welcomemsg=${values[10]}
	wwwroot=${values[11]}
	platform=${values[12]}
}

#!/usr/bin/env bash
function bash-start() {
	source ~/bashtools/bash_modules/os-.sh
	source ~/bashtools/bash_modules/filesys-.sh
	source ~/bashtools/bash_modules/env-.sh
	source ~/bashtools/bash_modules/php-.sh
	source ~/bashtools/bash_modules/www-.sh
	source ~/bashtools/bash_modules/git-.sh
	clear
	bash-readsettings
	env-attributerequire "os_status"
	env-attributerequire "serverid"
	env-attributerequire "environment"
	env-attributerequire "wwwroot"
	#env-attributerequire "welcomemsg"

	echo "Welcome to"
	echo-h1 $serverid
	echo $welcomemsg
	# sudo /etc/init.d/cron start;
	echo "Use 'env-about' for more info, 'bash-help' for more functions"
	www-siteshow
	#bash-showsettings
	startdir="$wwwroot/html/$www_sitefocus"
	cd $startdir
	file-showdir $startdir
}

function bash-push() {
	echo-h1 "pushing bash repo"
	cd ~/bashtools
	git add -A
	git commit -a -m update
	git push
	echo "Any key to return to current project"
	read -t 3 input
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
		cat ~/bashtools/bashinstall/bash_profile_sudo.sh >>~/.bash_profile
	fi
	cat ~/bashtools/bashinstall/bash_profile_user.sh >>~/.bash_profile
	cat ~/bashtools/bashinstall/bash_profile_foot.sh >>~/.bash_profile
	mkdir -p ~/bashtoolscfg
	bash-writesettings
	echo "Restarting shell ..."
	read -t 2 input
	head -20 ~/.bash_profile
	source ~/.bash_profile
}

function bash-restart() {
	bash-writesettings
	clear
	source ~/.bash_profile
	bash-start
}

function bash-sshcheck() {
	echo 'Current sessions are:'
	ps -ef | grep ssh
	echo "use sudo kill -9 <processid />" to end it
	echo "or enter 'ok' to kill all ssh - including this one and reboot server"
	read option
	if [ "$option" == "ok" ]; then
		sudo pkill ssh
		sudo reboot
	fi
}

function bash-sshcheck() {
	echo 'Current sessions are:'
	ps -A | grep ssh
}

function bash-writesettings() {
	csv=""
	for i in {0..9}; do
		csv+="${wwwsites[$i]},"
	done
	#20230629echo $csv;
	echo "$csv" >~/bashtoolscfg/wwwsites
	echo "$os_status,$sshsecure" >~/bashtoolscfg/os_status
	echo "$environment,$www_sitefocus,$ssh1,$ssh2,$databaseIP,$serverid,,$gituname,$phpNo,$ipgateway,$welcomemsg,$wwwroot,$platform" >~/bashtoolscfg/bash.env
}

function bash-readsettings() {
	wwwsites=$(<~/bashtoolscfg/wwwsites)
	IFS=', ' read -r -a wwwsites <<<"$wwwsites" #read back in same order as written

	csv=$(<~/bashtoolscfg/os_status)
	IFS=', ' read -r -a values <<<"$csv" #read back in same order as written
	os_status=${values[0]}
	sshsecure=${values[1]}

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

function bash-who() {
	echo "I am"
	echo-h1 $welcomemsg
}

bash-envsetphp() {
	php -v
	echo "Please enter php version to 1 decimal place eg 7.4"
	read phpNo
	bash-writesettings
	#bash-sets
}

function bash-ssh() {
	echo "Enter server to access:"
	echo "1. $ssh1"
	echo "2. $ssh2"
	echo ""
	read server
	if [ "$server" == "1" ]; then
		ssh $ssh1
	else
		ssh $ssh2
	fi
	bash-readsettings
}

function bash-setssh() {
	echo "Please enter ssh servers in format <username />@<ipaddress /> eg myuser@123.123.123.123"
	echo "Enter ssh server 1"
	read ssh1
	echo "Enter ssh server 2"
	read ssh2
	bash-writesettings
}

function bash-logout() {
	bash-writesettings
	echo "Written out settings, press enter to exit"
	read waitb
	clear
	source ~/.bash_profile
}

function bash-h() {
	search=$1
	if [ "$search" == "" ]; then
		echo "enter search text"
		read search
	fi
	clear
	echo "history search:";
	echo-hr;
	echo "$search"
	echo-hr;
	if [ "$search" == "" ]; then
		history
	else
		history | grep $search
	fi
	echo-hr
}

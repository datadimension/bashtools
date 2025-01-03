#!/usr/bin/env bash


function env-setwwwroot() {
	echo "Please set www root directory eg /var/www"
	read wwwroot
	bash-writesettings
	env-attributerequire "wwwroot"
}

function env-about() {
	clear
	echo-h1 "About this system"
	echo "Server name: $serverid"
	echo "Server environment [ production / local ]: $environment"
	echo-nl "System Time:"
	echo-now
		ipaddr=$(hostname --all-ip-addresses)
		cat /etc/lsb-release
		echo "IP : $ipaddr"
		# echo |  Gateway: $ipgateway  |
		echo "PHP Version: $phpNo"
		echo "GIT username: $gituname"
	echo-hr
	echo "Default Database IP: $defaultDatabaseIP"
	echo "www root: $wwwroot"
	echo "Available SSH (bash-ssh): $ssh1 | $ssh2"
	echo "System settings:"
	echo-hr
}

#for per machine settings that do not change
function env-setservertype() {
	#bash-envsetwwwroot
	echo "Enter environment (production / local)"
	read environment
	if [ "$environment" == "local" ]; then
		environment="local"
		os-install-xdebug;
	else
		environment="production"
	fi
	echo "Environment set to $environment"
	bash-writesettings
	#echo "Enter dev site project names ? y/n"
	#read doset
	# if [ "$doset" = "y" ]; then
	#   www-reposet
	# fi
	# cd $wwwroot
}

function env-setattribute() {
	varname=$1
	echo "Attempting to reset $varname"
	if [ "$varname" == "phpNo" ]; then
		phpNo=""
		bash-writesettings
	elif [ "$varname" == "os_status" ]; then
		os_status=""
		bash-writesettings
	elif [ "$varname" == "gituname" ]; then
		gituname=""
		bash-writesettings
	fi
	env-attributerequire $varname
}

function env-attributerequire () {
	# shellcheck disable=SC2317
	varname=$1
	if [ "$varname" == "os_status" ]; then
    if [ "$os_status" == "" ]; then
      os_status=1;
    fi
    if [ "$os_status" != "0"  ]; then
    declare -a os_steps=("echo 'setup for this login is done';read wait;;" "os-sudo-create" "os-sshkeygen" "os-sshsecure" "os-install-dependancies")
    os_setupfunc="${os_steps[$os_status]}";
        clear;
    echo "Currenty OS Stepup stage:"
    echo "$os_setupfunc";
    echo "";
    eval $os_setupfunc;
		os_status=$((os_status+1))
		fi
	elif [ "$varname" == "environment" ]; then
		if [ "$environment" == "" ]; then
			env-setservertype
		fi
	elif [ "$varname" == "serverid" ]; then
		if [ "$serverid" == "" ]; then
			echo "Please enter name of this server"
			read serverid
			bash-writesettings
		fi
	elif [ "$varname" == "gituname" ]; then
		if [ "$gituname" == "" ]; then
			echo "Please enter your git username and ensure you have set up ssh access"
			read gituname
			bash-writesettings
		fi
	elif [ "$varname" == "defaultDatabaseIP" ]; then
		if [ "$defaultDatabaseIP" == "" ]; then
			echo "Please enter main database IP address"
			read defaultDatabaseIP
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
		if [ "$welcomemsg" != "" ]; then
			echo "Please enter Welcome Message / server name"
			read welcomemsg
			bash-writesettings
		fi
	fi
	clear
}

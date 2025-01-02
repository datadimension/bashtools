#!/usr/bin/env bash
function env-attributerequire() {
	varname=$1
	if [ "$varname" == "os_status" ]; then
		if [ "$os_status" == "" ]; then
			echo "Status: $os_status"
			os-install-dependancies
			os_status="1"
			bash-restart
		elif [ "$os_status" == "1" ]; then
			echo "Status: $os_status installing ssh access"
			os-sshaccess
			os_status="2"
			echo "Press any key to exit and then log in as this user using ssh key"
			read wait
			bash-writesettings
			exit
		fi
	elif [ "$os_status" == "2" ]; then
		echo "Status: $os_status securing ssh access"
		echo "Please write TESTED to confirm you have logged in via ssh with key access not password  - otherwise you might get blocked as we will secure ssh access in the next step"
		read confirm
		if [ "$confirm" != "TESTED" ]; then
			echo "You can try running os-sshaccess again or try logging in via ssh"
			read wait
			bash-restart
		fi
		os-sshsecure
		os_status="3"
		bash-writesettings
		echo "Press any key to exit and then log in as this user using ssh key"
		wait
		exit
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
	elif [ "$varname" == "databaseIP" ]; then
		if [ "$databaseIP" == "" ]; then
			echo "Please enter main database IP address"
			read databaseIP
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

function env-setwwwroot() {
	echo "Please set www root directory"
	read wwwroot
	bash-writesettings
	env-attributerequire "wwwroot"
}

function env-about() {
	clear
	echo-h1 "About this system"
	echo "Server name: $servername"
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
	echo "Main Database IP: $databaseIP"
	echo "www root: $wwwroot"
	echo "Available SSH (bash-ssh): $ssh1 | $ssh2"
	echo "System settings:"
	echo-hr
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
	#   www-siteset
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

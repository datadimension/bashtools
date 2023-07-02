#!/usr/bin/env bash
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
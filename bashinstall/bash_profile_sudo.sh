#!/usr/bin/env bash
#bash_profile sudo

function vpn() {
	echo 'Please enter the VPN url'
	read vpnurl
	echo "If not prompted for username AND password you will need to authorise local sudo permission to connect (this machines password)"
	sudo openconnect -b $vpnurl
	echo "CTRL C exits VPN setup - if connected will continue running in the background"
}

function ~g_drive() {
	cd $wwwroot/html/$www_sitefocus/public/g_drive
	ls
}

function google-deploy() {
	clear
	sudo php $wwwroot/html/$www_sitefocus/app/DD_laravelAp/API/google/CLItokengen.php
}



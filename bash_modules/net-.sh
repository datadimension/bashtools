#!/usr/bin/env bash

#locks down firewall to only specified ports and services
function net-firewall-start() {
	sudo ufw reset
	sudo ufw enable
	sudo ufw allow ssh
ufw allow 3306
	sudo ufw allow 'Nginx Full'
	sudo ufw allow 9003
	sudo ufw reload
	sudo ufw status
}

function net-firewall-status() {
	sudo ufw status
}

function vpn() {
	echo 'Please enter the VPN url'
	read vpnurl
	echo "If not prompted for username AND password you will need to authorise local sudo permission to connect (this machines password)"
	sudo openconnect -b $vpnurl
	echo "CTRL C exits VPN setup - if connected will continue running in the background"
}

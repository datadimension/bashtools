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

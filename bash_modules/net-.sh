#!/usr/bin/env bash

#locks down firewall to only specified ports and services
function net-firewall-start() {
  sudo ufw --force reset
  sudo ufw enable
  sudo ufw allow ssh
  sudo ufw allow 3306 #mysql database
  sudo ufw allow 'Nginx Full'
  sudo ufw allow 9003
  sudo ufw reload
  sudo ufw status
}

#show history for user ssh sessions
function net-ssh-history() {
  echo "History for your ssh sessions:"
  tail -1000 ~/bashtoolscfg/sshclient.log
}

#SYSTEM FUNC stores info about the current ssh client details
function net-ssh-log-session() {
  echo-now >>~/bashtoolscfg/sshclient.log
  echo $SSH_CLIENT | awk '{ print $1}' >>~/bashtoolscfg/sshclient.log
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

function net-hosts() {
  sudo nano /etc/hosts
  sudo resolvectl flush-caches
}

function net-sshcheck() {
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

function net-wanIP() {
  ip=$(hostname --all-ip-addresses)
  echo $ip
}

function net-sshIP() {
  echo $SSH_CLIENT | awk '{ print $1}'
}

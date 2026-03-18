#!/usr/bin/env bash

# installs ssh
function net-installssh() {
  sudo apt update
  sudo apt install openssh-server
  sudo apt install putty-tools
}

#creates a new keypair on the server
function net-sshkeygen() {
  currentuser=$USER
  echo "Do you want to generate NEW ssh keys ? [y/n]"
  read confirm
  if [ "$confirm" != "y" ]; then
    return 0
  fi
  echo "Now generating ssh keys, you are ok to accept defaults"
  input-required "Enter your email to personalise the key file content" email
  input-required "Enter a prefix to label the key file names" filelabel
  sshdir=~/.ssh
  mkdir -p $sshdir
  cd $sshdir

  touch authorized_keys

  timestamp=$(date +%Y%m%d%H%M)
  keyidprefix=$filelabel"_"$timestamp"_"
  serverkeyname=$keyidprefix"server_rsakey"
  keystamp=$keyidprefix$email

  ssh-keygen -t rsa -f $serverkeyname -C $keystamp

  sharedkeyname=$keyidprefix"shared_rsakey"

  mv $serverkeyname $sharedkeyname

  chmod 600 $serverkeyname.pub
  chmod 600 $sharedkeyname

  cat $serverkeyname.pub >>authorized_keys
  echo "" >>authorized_keys

  clear
  puttykeyname=$keyidprefix"putty_rsakey"
  puttygen $sharedkeyname -o $puttykeyname.ppk

  echo "Putty desktop .ppk key"
  echo "copy this below output between the lines. Navigate to where you want it on your PC and 'right click, new notepad."
  echo "Paste in to this and save as $puttykeyname.ppk"
  echo "Tell Putty where to find it"
  echo-hr
  cat $puttykeyname.ppk
  echo-hr
  wait

  echo-hr
  echo "Shared key (eg for git) for this server"
  echo-hr
  cat $sharedkeyname
  echo-hr
  wait
  cd ~/
}

#secures ssh settings
function net-sshsecure() {
  echo "Installing SSH"
  echo "Please write TESTED to confirm you have logged in via ssh with key access not password  - otherwise you might get blocked as we will secure ssh access in the next step"
  read confirm
  if [ "$confirm" != "TESTED" ]; then
    echo "You can try running os-sshaccess again or try logging in via ssh"
    read wait
    bash-restart
  fi
  echo "Between EACH, press ENTER to go to relevant line to edit ssh config"
  echo ""
  echo "1/4 Comment out the following to make this config file the only  config file used"
  echo "Include/etc/ssh/sshd_config.d/*.conf":
  read wait
  sudo nano +12 /etc/ssh/sshd_config
  echo "2/4 stop ssh access via root for security uncomment / set"
  echo "PermitRootLogin no"
  read wait
  sudo sudo nano +33 /etc/ssh/sshd_config
  echo "3/4 set authentication by public key only uncomment / set"
  echo "PubkeyAuthentication yes"
  read wait
  sudo nano +38 /etc/ssh/sshd_config
  echo "4/4 remove password access uncomment / set"
  echo "PasswordAuthentication no"
  read wait
  sudo nano +57 /etc/ssh/sshd_config
  os_status=$((os_status + 1)) #we exit so need to update pointer here
  bash-writesettings
  read -p "Can you log in using keypair y/n ?"
  read yn
  if [ "$yn" != "y" ]; then
    echo "You can try running os-sshaccess again or try logging in via ssh"
    read wait
    bash-restart
  fi
  echo "Any key to restart sshd - you will get booted - make sure you set up ssh which is not root"
  read wait
  net-firewall start
  sudo service ssh reload
  exit
}

#locks down firewall to only specified ports and services
function net-firewall-start() {
  sudo ufw --force reset
  sudo ufw enable
  sudo ufw allow ssh
  sudo ufw allow 3306 #mysql database
  sudo ufw allow 'Nginx Full'
  sudo ufw allow 9003
  sudo ufw allow 9003
  sudo ufw reload
  sudo ufw status
}

function net-rdp() {
  mode=$1
  if [ "$mode" == "on" ]; then
    sudo ufw allow 3389
    sudo ufw reload
    sudo ufw status
  else
    net-firewall start
  fi
}

#show firewall status, optional argument of 'start' to restart firewall locked down to only specified ports and services
function net-firewall() {
  #https://phoenixnap.com/kb/ubuntu-remote-desktop-from-windows
  mode=$1
  if [ "$mode" == "start" ]; then
    sudo ufw --force reset
    sudo ufw enable
    sudo ufw allow ssh
    sudo ufw allow 3306 #mysql database
    sudo ufw allow 'Nginx Full'
    sudo ufw allow 9003
    sudo ufw allow 9003
    sudo ufw reload
    sudo ufw status
  else
    sudo ufw status
  fi
}

#flush dns cache
function net-dnsflush() {
  sudo resolvectl flush-caches
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

#installs vpn functionality
function net-vpninstall() {
  sudo apt-get install openconnect network-manager-openconnect network-manager-openconnect-gnome
}

function vpn() {
  echo 'Please enter the VPN url'
  read vpnurl
  echo "If not prompted for username AND password you will need to authorise local sudo permission to connect (this machines password)"
  sudo openconnect -b $vpnurl
  echo "CTRL C exits VPN setup - if connected will continue running in the background"
}

#show hosts file, append edit to edit it eg 'net-hosts edit'
function net-hosts() {
  mode=$1
  if [ "$mode" == "edit" ]; then
    sudo nano /etc/hosts
    sudo net-dnsflush
  else
    tail -1000 /etc/hosts
  fi
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

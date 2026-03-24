#!/usr/bin/env bash

# installs ssh
function net-installssh() {
  sudo apt update
  sudo apt install openssh-server
  sudo apt install putty-tools
}

#empties .ssh of all keys except the current one
net-sshkeyclean() {
  cd ~/
  echo "Do you want to remove existing key access ? [y/n]"
  read confirm
  if [ "$confirm" != "y" ]; then
    return 0
  fi
  cd ~/
  bukeypre=$(cat .ssh/currentkeypre)
  mkdir -p sshbu
  rm sshbu/*
  cp .ssh/$bukeypre* sshbu
  cp .ssh/id_rsa sshbu
  cp .ssh/id_rsa.pub sshbu
  cp .ssh/authorized_keys sshbu
  cp .ssh/known_hosts* sshbu
  rm .ssh/*
  cp sshbu/* .ssh
}

#creates a new keypair on the server
function net-sshkeygen() {
  currentuser=$USER
  clear
  echo "New SSH Keygen"
  echo "only do this with 2 sessions open in case something goes wrong and you get lockked out of server"
  echo "please enter your email to personalise (required at least by GITHUB)"
  echo "or ENTER to exit"
  read email
  if [ "$email" == "" ]; then
    echo "EXIT"
    return 0
  fi
  #20260318input-required "Enter text to personalise the key file content" email
  #20260318input-required "Enter a prefix to label the key file names" filelabel
  sshdir=~/.ssh
  mkdir -p $sshdir
  cd $sshdir

  touch authorized_keys

  #20260318 serverkeyname=$timestamp"_SharedRSAkey_"$keyidprefix # rename shared - private - key for clarity
  #20260318  serverkeyname=$keyidprefix"ServerRsaKey:"
  #20260318keystamp=$keyidprefix

  timestamp=$(date +%y%m%d%H%M)
  keypre=$timestamp$serverid

  serverkeyname=$keypre"_svr_"$USER
  sharedkeyname=$keypre"_shr_"$USER
  puttykeyname=$keypre"_pty_"$USER
  keycomment=$timestamp"_"$email

  passphrase=""
  ssh-keygen -b 4096 -t rsa -f $serverkeyname -P "$passphrase" -C $keycomment
  echo $keypre >currentkeypre

  cat $serverkeyname.pub >>authorized_keys
  echo "" >>authorized_keys

  cp $serverkeyname $sharedkeyname
  puttygen $sharedkeyname -o $puttykeyname.ppk

  chmod 600 $serverkeyname
  chmod 600 $serverkeyname.pub
  chmod 600 $sharedkeyname
  chmod 600 $puttykeyname.ppk

  clear
  echo "Putty desktop .ppk key"
  echo-hr
  echo "copy this below output between the lines. Navigate to where you want it on your PC and 'right click, new notepad."
  echo "HINT: create a permantent .txt file called eg keychange.txt which can be reused"
  echo "Paste in to the textfile and save as $puttykeyname.ppk"
  echo "Tell Putty where to find it"
  echo-hr
  cat $puttykeyname.ppk
  echo-hr
  wait
  echo "Now to generate GIT key"
  rm id_rsa
  rm id_rsa.pub
  ssh-keygen -b 4096 -t rsa -f id_rsa -P "$passphrase" -C $keycomment
  clear
  echo "GIT shared key"
  echo-hr
  echo "go to https://github.com/settings/keys"
  echo "Suggest naming it as $sharedkeyname"
  echo ""
  echo "Just hit enter for defaults"
  echo-hr
  tail -1000 id_rsa.pub
  echo ""
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

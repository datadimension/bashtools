#!/usr/bin/env bash

function bash-start() {
  #load modules optimised for all os
  source ~/bashtools/bash_modules/std-.sh #standard for a platforms
  source ~/bashtools/bash_modules/env-.sh
  source ~/bashtools/bash_modules/www-.sh
  bash-readsettings
  env-attributerequire "welcomemsg"
  if [ "$platform" == "ubuntu" ]; then
    bash-start-ubuntu
  else
    bash-start-windows
  fi
}

function bash-start-windows() {
  source ~/bashtools/bash_modules/windows/git-.sh
  source ~/bashtools/bash_modules//windows/fsys-.sh
  echo "BashTools [Windows IDE version]"
  if [ "$welcomemsg" != "" ]; then
    echo "$welcomemsg"
  fi
 file-cdrepo
}

# initialises the bash shell #
function bash-start-ubuntu() {
  source ~/bashtools/bash_modules/os-.sh
  source ~/bashtools/bash_modules/mysql-.sh
  source ~/bashtools/bash_modules/nginx-.sh
  source ~/bashtools/bash_modules/php-.sh
  source ~/bashtools/bash_modules/git-.sh
  source ~/bashtools/bash_modules/net-.sh
  source ~/bashtools/bash_modules/log-.sh
  source ~/bashtools/bash_modules/laravel-.sh
  source ~/bashtools/bash_modules/fsys-.sh
  source ~/bashtools/bash_modules/composer-.sh

  bash-start-ubuntu-osconfigcheck
  echo "BashTools [$platform - $serverid]"
  echo-hr
  if [ "$welcomemsg" != "" ]; then
    echo "$welcomemsg"
  fi
file-cdrepo
}

bash-start-ubuntu-osconfigcheck() {
  mysql-getversion
osinstall=0 #control bool to restart bash to loop through setup
  os-checkstatus
  if [ $osinstall == 1 ]; then
    read -p "Any key to restart" wait
    bash-restart
  fi
  env-attributerequire "serverid"
  env-attributerequire "environment"
  env-attributerequire "wwwroot"
  env-attributerequire "defaultDatabaseIP"

  MENUCHOICE="" #reserved as a global for menu function
  PHP_VERSION=$(php -r 'echo PHP_VERSION;')
  #env-attributerequire "welcomemsg"
}

function bash-push() {
  git-push-repo bashtools
  bash-pull
  ~www
}

function bash-pull() {
  echo "updating bash"
  git-pull-repo bashtools
  bash-install
}

# installs the enhanced bash functionality provided by Bashtools
function bash-install() {
  rm ~/.bash_profile
  mkdir -p ~/bashtoolscfg/tmp
  homepath=${HOME:0:6}
  #detect ubuntu or MINW64 - keeping seperate functions for future proofing, even though very similar
  if [ "$homepath" == "/home/" ]; then
    bash-install-ubuntu
  else
    bash-install-windows
  fi
}

function bash-install-ubuntu() {
  platform="ubuntu"
  username=${HOME:6}
  wwwroot="/var/www"
  echo -e "Detected:\nPlatform=$platform\nUser=$username\nwwwroot=$wwwroot"
  cp ~/bashtools/templates/bash/bash_profile.sh ~/.bash_profile #overwrite with potention changes
  bash-writesettings
  source ~/.bash_profile
}

function bash-install-windows() {
  platform="windows"
  username=${HOME:9}
  wwwroot="${HOME}/www"
  echo -e "Detected:\nPlatform=$platform\nUser=$username\nwwwroot=$wwwroot"
  cp ~/bashtools/templates/bash/bash_profile.sh ~/.bash_profile #overwrite with potention changes
  bash-writesettings
  source ~/.bash_profile
}

# shows bash function categories and functions
function bash-help() {
  std-menu std,bash,env,fsys,git,log,net,os,nginx,php,www,composer,mysql,laravel,google "Help Categories:"
  echo "Loading help for $MENUCHOICE ..."
  php ~/bashtools/php_helpers/bash/bash-help.php helptype=$MENUCHOICE
}

#restarts bash shell
function bash-restart() {
  bash-writesettings
  clear
  source ~/.bash_profile # this restarts bash as well
}

function bash-who() {
  echo "I am"
  echo-h1 $welcomemsg
}

function bash-logout() {
  bash-writesettings
  echo "Written out settings, press enter to exit"
  read waitb
  clear
  source ~/.bash_profile # this restarts bash as well
}

# Show history or search in history
function bash-h() {
  search=$1
  if [ "$search" == "" ]; then
    echo "enter search text"
    read search
  fi
  clear
  echo "history search:"
  echo "$search"
  echo-hr
  if [ "$search" == "" ]; then
    history
  else
    history | grep $search
  fi
  echo-hr
}

function bash-sudoers() {
  grep '^sudo:.*$' /etc/group | cut -d: -f4
}

# displays the current bashtoolscfg files
function bash-cfg() {
  echo-b "bash.env"
  echo ""
  tail ~/bashtoolscfg/bash.env
  echo -e "\n"
  echo-b "os_status"
  echo ""
  tail ~/bashtoolscfg/os_status
  echo -e "\n"
  echo-b "os_status.env"
  echo ""
  tail ~/bashtoolscfg/os_status.env
  echo -e "\n"
  echo-b "wwwsites"
  echo ""
  tail ~/bashtoolscfg/wwwsites
}

function bash-writesettings() {
  csv=""
  for i in {0..9}; do
    csv+="${wwwrepos[$i]},"
  done
  #20230629echo $csv;
  #20250224echo "$csv" >~/bashtoolscfg/wwwsites
  echo "$csv" >~/bashtoolscfg/wwwrepos
  echo "$os_status,$sshsecure" >~/bashtoolscfg/os_status
  echo "$git_ssh" >~/bashtoolscfg/gitcfg
  echo "$environment,$www_repofocus,$ssh1,$ssh2,$defaultDatabaseIP,$serverid,,$gituname,$phpNo,$ipgateway,$welcomemsg,$wwwroot,$platform,$wwwrepos,$www_repofocus,$db_app" >~/bashtoolscfg/bash.env
}

function bash-readsettings() {
  #20250224wwwsites=$(<~/bashtoolscfg/wwwsites})
  wwwrepos=$(<~/bashtoolscfg/wwwrepos)

  IFS=', ' read -r -a wwwrepos <<<"$wwwrepos" #read back in same order as written

  csv=$(<~/bashtoolscfg/os_status)
  IFS=', ' read -r -a values <<<"$csv" #read back in same order as written
  os_status=${values[0]}
  sshsecure=${values[1]}

  csv=$(<~/bashtoolscfg/gitcfg)
  IFS=', ' read -r -a values <<<"$csv" #read back in same order as written
  git_ssh=${values[0]}

  csv=$(<~/bashtoolscfg/bash.env)
  IFS=', ' read -r -a values <<<"$csv" #read back in same order as written
  serverid=${values[5]}
  environment=${values[0]}
  www_repofocus=${values[1]}
  ssh1=${values[2]}
  ssh2=${values[3]}
  defaultDatabaseIP=${values[4]}
  gituname=${values[7]}
  phpNo=${values[8]}
  ipgateway=${values[9]}
  welcomemsg=${values[10]}
  wwwroot=${values[11]}
  platform=${values[12]}
  wwwrepos=${values[13]}
  www_repofocus=${values[14]}
}

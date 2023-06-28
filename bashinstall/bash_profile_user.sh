#!/usr/bin/env bash
#bash_profile user

function bash-install() {
  #detect ubuntu or MINW64
  homepath=${HOME:0:6}
  if [ "$homepath" == "/home/" ]; then
    username=${HOME:6}
    platform="ubuntu"
    wwwroot="/var/www"
  else
    username=${HOME:9}
    platform="windows"
    wwwroot="/c/Users/$username/www"
  fi
  echo -e "Detected:\nPlatform=$platform\nUser=$username\nwwwroot=$wwwroot"
  rm ~/.bash_profile
  cp ~/bashtools/bashinstall/bash_profile_head.sh ~/.bash_profile
  if [ "$platform" == "ubuntu" ]; then # aimed at the ming64 shell for windows which does not have functions such as sudo
    cat ~/bashtools/bashinstall/bash_profile_sudo.sh >>~/.bash_profile
  fi
  cat ~/bashtools/bashinstall/bash_profile_user.sh >>~/.bash_profile
  cat ~/bashtools/bashinstall/bash_profile_foot.sh >>~/.bash_profile
  mkdir -p ~/bashtoolscfg
  csv="";
  for i in {0..9}; do
    csv+="${wwwsites[$i]},";
  done
  echo $csv;
  echo "$csv" >~/bashtoolscfg/wwwsites
  echo "$environment,$www_sitefocus,$ssh1,$ssh2,,,,$gituname,$phpNo,$ipgateway,$welcomemsg,$wwwroot,$platform" >~/.bash_cfg
  echo "Restarting shell ..."
  read -t 2 input
  head -20 ~/.bash_profile
  source ~/.bash_profile
}

function bash-restart() {
  bash-writesettings
  clear
  source ~/.bash_profile
  bash-start
}

function bash-sshcheck(){
  echo 'Current sessions are:';
    ps -ef | grep ssh;
    echo "use sudo kill -9 <processid />" to end it;
    echo "or enter 'ok' to kill all ssh - including this one and reboot server";
      read option
  if [ "$option" == "ok" ]; then
        sudo pkill ssh;
        sudo reboot;
  fi
}

function bash-writesettings() {
  csv="";
  for i in {0..9}; do
    csv+="${wwwsites[$i]},";
  done
  echo $csv;
  echo "$csv" >~/bashtoolscfg/wwwsites
  echo "$environment,$www_sitefocus,$ssh1,$ssh2,,,,$gituname,$phpNo,$ipgateway,$welcomemsg,$wwwroot,$platform" >~/.bash_cfg
}

function bash-start() {
  clear
  bash-readsettings
  echo-h1 $welcomemsg
  echo-now
  env-attributerequire "environment"
  # sudo /etc/init.d/cron start;
  www-showcfg
  bash-showsettings
  echo "Use 'env-about' for more info";
  cd "$wwwroot/html/$www_sitefocus"
}

function bash-showsettings() {
  echo-hr
  echo "www root: $wwwroot"
  echo "Available SSH (bash-ssh): $ssh1 | $ssh2"
  echo-hr
}

function laravel-version() {
  echo "for all laravel functions we are going to site focus root (~www)"
  cd "$wwwroot/html/$www_sitefocus"
  php artisan --version
}

function bash-sshcheck(){
  echo 'Current sessions are:';
    ps -A | grep ssh
}

function bash-readsettings() {
  wwwsites=$(<~/bashtoolscfg/wwwsites)
  IFS=', ' read -r -a wwwsites <<<"$wwwsites" #read back in same order as written
  csv=$(<~/.bash_cfg)
  IFS=', ' read -r -a values <<<"$csv" #read back in same order as written
  environment=${values[0]}
  www_sitefocus=${values[1]}
  ssh1=${values[2]}
  ssh2=${values[3]}
  gituname=${values[7]}
  phpNo=${values[8]}
  ipgateway=${values[9]}
  welcomemsg=${values[10]}
  wwwroot=${values[11]}
  platform=${values[12]}
}

function bash-setwelcome() {
  echo "Please enter Welcome Message"
  read welcomemsg
  bash-writesettings
}

function bash-who() {
  echo "I am"
  echo-h1 $welcomemsg
}

bash-envsetwwwroot() {
  echo "Please set www root directory"
  echo "or just enter for default of '/var/www'"
  read wwwroot
  if [ "$wwwroot" == "" ]; then
    wwwroot="/var/www"
  fi
  bash-writesettings
}

bash-envsetphp() {
  php -v
  echo "Please enter php version to 1 decimal place eg 7.4"
  read phpNo
  bash-writesettings
  #bash-sets

}

function env-about(){
    clear;
    echo-h1 "About this system";
    if [ "$platform" == "ubuntu" ]; then
      echo "Current Environment (development/ production):$environment use 'env-setservertype' to change";
      ipaddr=$(hostname --all-ip-addresses)
      cat /etc/lsb-release;
      echo "IP : $ipaddr";
      # echo |  Gateway: $ipgateway  |
      echo "PHP Version: $phpNo";
      echo "GIT username: $gituname";
    else
        echo $platform;
    fi
}

function env-attributerequire(){
  varname=$1;
  if [ "$varname" == "environment" ]; then
       if [ "$environment" == "" ]; then
          env-setservertype;
       fi
  elif [ "$varname" == "phpNo" ]; then
    if [ "$phpNo" == "" ]; then
      echo ""
      echo "PHP check:";
      php -v;
      echo ""
      echo ""
      echo "Please confirm the php version to 1 decimal place shown above eg 7.1 or 8.1";
      read phpNo
      bash-writesettings;
    fi
    elif [ "$varname" == "welcomemsg" ]; then
       if [ "$welcomemsg" == "" ]; then
          bash-setwelcome
       fi
    fi

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
 #   www-setsites
 # fi
 # cd $wwwroot
}

function env-setattribute(){
  varname=$1;
  echo "Attempting to reset $varname";
  if [ "$varname" == "phpNo" ]; then
    phpNo="";
    bash-writesettings;
    env-attributerequire $varname;
  fi
}

function bash-ssh() {
  echo "Enter server to access:"
  echo "1. $ssh1"
  echo "2. $ssh2"
  echo ""
  read server
  if [ "$server" == "1" ]; then
    ssh $ssh1
  else
    ssh $ssh2
  fi
  bash-readsettings
}

function bash-setssh() {
  echo "Please enter ssh servers in format <username />@<ipaddress /> eg myuser@123.123.123.123"
  echo "Enter ssh server 1"
  read ssh1
  echo "Enter ssh server 2"
  read ssh2
  bash-writesettings
}

function bash-logout() {
  bash-writesettings
  echo "Written out settings, press enter to exit"
  read waitb
  clear
  source ~/.bash_profile
}

function www-showsites() {
  echo ""
  echo "Current $environment sites are:"
  echo ""
  for i in {0..9}; do
      echo "$((i + 1)): ${wwwsites[$i]}"
  done
  echo ""
}

function www-setsites() {
  echo-hr
  echo "Available sites:"
  ls $wwwroot/html
  www-showsites
  echo "Enter site number to change"
  read sitenumber
  sitenumber=$((sitenumber - 1))
  echo "Enter site root directory name to set against site $sitenumber"
  read wwwsites[$sitenumber]
  www-switch
  bash-writesettings
}

function www-switch() {
  www-showsites
  echo "Please select a site number to chose for operations"
  read sitenumber
    echo "Git will auto sync. Enter 'n' to prevent this"
  read -t 3 input
  if [ "$input" != "n" ]; then
    git-push;
  fi
  sitenumber=$((sitenumber - 1))
  www_sitefocus=${wwwsites[sitenumber]}
  cd "$wwwroot/html/$www_sitefocus"
  echo "setting site to $www_sitefocus"
  bash-writesettings
    if [ "$input" != "n" ]; then
    git-pull;
  fi
}

function ~www() {
  cd $wwwroot/html/$www_sitefocus
  ls
}

function ~home() {
  cd ~/
  ls -al
}

function ~libapp() {
  cd $wwwroot/html/$www_sitefocus/app/DD_laravelAp
  ls -al
}

function ~libviews() {
  cd $wwwroot/html/$www_sitefocus/resources/views/DD_laraview
  ls -al
}

function ~libapp() {
  cd $wwwroot/html/$www_sitefocus/app/DD_laravelAp
  ls
}

function ~libviews() {
  cd $wwwroot/html/$www_sitefocus/resources/views/DD_laraview
  ls
}

function ~libmedia() {
  cd $wwwroot/html/$www_sitefocus/public/DD_libmedia
  ls
}

function ~libwww() {
  cd $wwwroot/html/$www_sitefocus/public/DD_libwww
  ls
}

function ~log() {
  cd $wwwroot/html/$www_sitefocus/storage/logs
  ls
}

function cd~() {
  dir=$1
  cd $dir
  ls
}

function ~log-sys() {
  echo "/var/log"
  ls -al /var/log
}

function www-showcfg() {
  www-showsites
  echo "Current Selected Site for operations: $www_sitefocus"
  echo ""
  ls
  echo-hr
}

function www-routes() {
  php artisan route:list
}

function git-setup() {
  echo ""
  echo "Enter GIT username (used to create urls for push / pull etc"
  read gituname
}

function git-deploysubrepos() {
  git-deploysubrepo "$www_sitefocus/public" "DD_libwww"
  git-deploysubrepo "$www_sitefocus/public" "DD_libmedia"
  git-deploysubrepo "$www_sitefocus/app" "DD_laravelAp"
  git-deploysubrepo "$www_sitefocus/resources/views" "DD_laraview"
}

function git-add() {
  git status -uno
  git add -A
  git commit -a -m update
  echo "... all files added"

}

#reset all repos
function git-reset-all() {
  git-reset-repo "DD_laraview"
  git-reset-repo "DD_libwww"
  #git-reset-repo "DD_libmedia"
  git-reset-repo "DD_laravelAp"
  git-reset-repo "$www_sitefocus"
  if [ "$platform" == "ubuntu" ]; then # aimed at the ming64 shell for windows which does not have functions such as sudo
    echo "Reset file and directory permissions ? [y/n]"
    read input
    if [ "$input" == "y" ]; then
      bash-secure
    fi
  fi
}

function git-reset() {
  clear
  curpwd=$(pwd)
  echo "Enter a repo name"
  echo ""
  echo "1: DD_libwww"
  echo "2: DD_laravelAp"
  #echo "3: DD_libmedia"
  echo "3: DD_laraview"
  echo "or hit enter for everything"
  read option
  if [ "$option" == "1" ]; then
    git-reset-repo "DD_libwww"
  elif [ "$option" == "2" ]; then
    git-reset-repo "DD_laravelAp"
  elif [ "$option" == "3" ]; then
    git-reset-repo "DD_laraview"
  else
    git-reset-all
  fi
  cd $curpwd
}

#forces file overwrite from server, untracked files remain
function git-reset-repo() {
  gitreponame=$1
  if [ "$gitreponame" == "DD_laraview" ]; then
    gitrepopath="$wwwroot/html/$www_sitefocus/resources/views"
  elif [ "$gitreponame" == "DD_libwww" ]; then
    gitrepopath="$wwwroot/html/$www_sitefocus/public"
  elif [ "$gitreponame" == "DD_laravelAp" ]; then
    gitrepopath="$wwwroot/html/$www_sitefocus/app"
  elif [ "$gitreponame" == "DD_libmedia" ]; then
    gitrepopath="$wwwroot/html/$www_sitefocus/public"
  else
    gitrepopath="$wwwroot/html"
    gitreponame=$www_sitefocus
  fi
  echo-hr
  echo "reseting repo ..."
  echo-h1 "$gitreponame"
  echo "to $gitrepopath/$gitreponame;"
  cd $gitrepopath/$gitreponame
  #git remote set-url origin git@github.com:datadimension/$gitreponame
  git fetch --all
  # branchname=$(date +%Y%m%d%I%M)
  echo "Reseting to $gitreponame$branchname"
  # git branch "reset$gitreponame$branchname"
  git reset --hard origin/master
}

function git-push-all() {
  git-push-repo "DD_laraview"
  git-push-repo "DD_libwww"
  git-push-repo "DD_laravelAp"
  git-push-repo "$www_sitefocus"
}

function git-push() {
  clear
  curpwd=$(pwd)
    echo-h1 "Pushing from $www_sitefocus";
  echo "Enter a repo name"
  echo ""
  echo "1: DD_libwww"
  echo "2: DD_laravelAp"
  echo "3: DD_laraview"
  echo "or wait / hit enter for everything"
  read -t 3 option
  if [ "$option" == "1" ]; then
    git-push-repo "DD_libwww"
    git-pull-repo "DD_libwww"
  elif [ "$option" == "2" ]; then
    git-push-repo "DD_laravelAp"
    git-pull-repo "DD_laravelAp"
  elif [ "$option" == "3" ]; then
    git-push-repo "DD_laraview"
    git-pull-repo "DD_laraview"
  else
    git-push-all
  fi
  cd $curpwd
}

function git-push-repo() {
  gitreponame=$1
  if [ "$gitreponame" == "DD_laraview" ]; then
    gitrepopath="$wwwroot/html/$www_sitefocus/resources/views"
  elif [ "$gitreponame" == "DD_libwww" ]; then
    gitrepopath="$wwwroot/html/$www_sitefocus/public"
  elif [ "$gitreponame" == "DD_laravelAp" ]; then
    gitrepopath="$wwwroot/html/$www_sitefocus/app"
  elif [ "$gitreponame" == "DD_libmedia" ]; then
    gitrepopath="$wwwroot/html/$www_sitefocus/public"
  else
    gitrepopath="$wwwroot/html"
    gitreponame=$www_sitefocus
  fi
  echo "pushing repo ..."
  echo-h1 "$gitreponame"
  echo "from $gitrepopath/$gitreponame;"
  cd $gitrepopath/$gitreponame
  git-add
  git push
  echo ""
  echo "Finished at:"
  echo-now
  echo-hr
}

function git-pull-repo() {
  gitreponame=$1
  if [ "$gitreponame" == "DD_laraview" ]; then
    gitrepopath="$wwwroot/html/$www_sitefocus/resources/views"
  elif [ "$gitreponame" == "DD_libwww" ]; then
    gitrepopath="$wwwroot/html/$www_sitefocus/public"
  elif [ "$gitreponame" == "DD_laravelAp" ]; then
    gitrepopath="$wwwroot/html/$www_sitefocus/app"
  elif [ "$gitreponame" == "DD_libmedia" ]; then
    gitrepopath="$wwwroot/html/$www_sitefocus/public"
  else
    gitrepopath="$wwwroot/html"
    gitreponame=$www_sitefocus
  fi
  echo "pulling repo ..."
  echo-h1 "$gitreponame"
  echo "to $gitrepopath/$gitreponame;"
  cd $gitrepopath/$gitreponame
  git-add
  git pull
  echo ""
  echo "Finished at:"
  echo-now
  echo-hr
}

function git-pull-all() {
  git-pull-repo "DD_laraview"
  git-pull-repo "DD_libwww"
  git-pull-repo "DD_laravelAp"
  git-pull-repo "$www_sitefocus"
}

function git-pull() {
  clear
  echo-hr
  curpwd=$(pwd)
  echo-h1 "Pulling to $www_sitefocus";
  echo "Enter a repo name"
  echo ""
  echo "1: DD_libwww"
  echo "2: DD_laravelAp"
  echo "3: DD_laraview"
  echo "or wait / hit enter for everything"
  read -t 3 option
  if [ "$option" == "1" ]; then
    git-pull-repo "DD_libwww"
  elif [ "$option" == "2" ]; then
    git-pull-repo "DD_laravelAp"
  elif [ "$option" == "3" ]; then
    git-pull-repo "DD_laraview"
  else
    git-pull-all
  fi
  cd $curpwd
}

function bash-push() {
  echo-h1 "pushing bash repo"
  cd ~/bashtools
  git add -A
  git commit -a -m update
  git push
  ~www
}

function bash-pull() {
  echo-h1 "pulling bash repo"
  cd ~/bashtools
  git pull
  bash-install
}

function ls-i() {
  ls -al
  echo "File count:"
  ls -l | wc -l
}

function hist() {
  search=$1
  if [ "$search" == "" ]; then
    history
  else
    history | grep $search
  fi
}
###############################################################

#TOP LEVEL FUNCTIONS - move elsewhere when we can compile bash from different files
function echo-h1() {
  textoutput=$1
  if [ "$platform" == "windows" ]; then # assume we are using the gitbash ming shell so sudo does not exist
    echo $textoutput
  else
    figlet $textoutput
  fi
}

function echo-hr() {
  printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -
}

function set-timestamp() {
  timestamp=$(date '+%F_%H:%M:%S')
}

function echo-now() {
  set-timestamp
  echo $timestamp
}

function ~nginx() {
  cd /etc/nginx/sites-enabled
  ls
}

function bash-hint() {
  echo "GIT"
  echo "force reset head / pull of repo:"
  echo "git fetch --all"
  echo "git reset --hard origin/master"
  echo "git pull"
  echo "www-update"
}

function pshell() {
  echo "POWERSHELL"
  echo "Some functions only work running WSL as administrator"
  echo "so for this right click on Ubuntu icon, right click again on Ubuntu from this menu that appears and 'run as administrator'"
  echo "are you admin y/n"
  read -t 3 input
  if [ "$input" == "y" ]; then
    mkdir -p ~/.bu
    cp -p ~/.bash_cfg ~/.bu/.bash_cfg
    echo ""
    "POWERSHELL STARTED"
    echo ""
    echo "To close all Ubuntu WSL:"
    echo "run:"
    echo "Get-Service LxssManager | Restart-Service"
    echo ""
    echo "type exit to quit"
    powershell.exe
  fi
}

function logv() {
  logname=$1
  tail -f -n 100 $wwwroot/$www_sitefocus/storage/logs/$logname.log
}

function bash-help() {
  php ~/bashtools/php/bash-help.php
}


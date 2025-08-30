#!/usr/bin/env bash

# shows disk partition usage
function fsys-disk() {
  df -H
}
#reset permission levels to minimal required
#need to check if permisions can be tightened
#https://stackoverflow.com/questions/30639174/how-to-set-up-file-permissions-for-laravel
function fsys-secure() {
  dirname=$1
  if [ "$dirname" == "" ]; then
    dirname=$www_repofocus
  fi
  targetroot=$wwwroot/html/$dirname
  www-reposhow
  clear
  read -p "Conform file permisions at $targetroot ? This can take a few mines [y/n]: " -t 10 input
  if [ "$input" != "y" ]; then
    return 0
  fi
  sec644level=644
  sec755level=755
  sec770level=770
  echo ""
  ls -al $wwwroot/html/$dirname

  #20250304 move this tol localserver_admin project
  #20250304 echo "Securing bash-tools permissions"
  #20250304 sudo chown -R $USER:www-data $wwwroot/html
  #20250304 sudo chmod -R $sec755level $wwwroot/html/

  #20250304 echo "Securing bash-tools permissions"
  #20250304 sudo chmod -R $sec770level ~/bashtools/php_helpers/bash

  #20250304 move this tol localserver_admin project
  #20250304 sudo chown -R $USER:www-data $wwwroot/certs
  #20250304 ssudo chmod -R $sec644level $wwwroot/certs

  echo "Reseting global ownership in $targetroot"
  sudo chown -R $USER:www-data $targetroot
  echo "Reseting file permissions in $targetroot"
  sudo find $targetroot -type f -exec chmod $sec644level {} \;
  echo "Reseting directory permissions in $targetroot"
  sudo find $targetroot -type d -exec chmod $sec755level {} \;

  # relax some permissions for laravel
  echo "Securing laravel directory permissions in $targetroot"
  sudo chmod -R $sec755level $targetroot/app
  sudo chmod -R $sec770level $targetroot/storage
  sudo chmod -R $sec770level $targetroot/public/downloads
  sudo chmod -R $sec770level $targetroot/private
}

function file_exists() {
  path=$1
  if test -f $path; then
    echo "File exists: $path"
  else
    echo "File does not exist: $path"
  fi
}

# change current directory to current focused repo
function file-cdrepo(){
	startdir="$wwwroot/html/$www_repofocus"
	if [ -d "$startdir" ]; then
        echo ""
    else
    	echo ""
    	echo "Error: Current reponame set at '$www_repofocus'"
    	echo "Directory: $startdir does not exist";
    	 echo "Reseting www_repofocus"
    	www_repofocus=""
    	bash-writesettings;
    fi
	www-reposhow
	 if [ "$www_repofocus" == "" ]; then
    	echo "";
    	echo "NOTE:"
    	echo "If your repo list is empty you can add the nginx test repo with"
    	echo "nginx-testrepoadd";
    	echo "and remove later with"
    	echo "nginx-testreporemove"
    	echo ""
else
echo ""
cd $startdir
ls
    fi
}

# combines cd and ls into a single command
function cdls() {
  mode=""
  dir=$1
  if [ "$1" == "-al" ]; then
    dir=$2
    mode="-al"
  fi
  cd $dir
  if [ "$mode" == "-al" ]; then
    ls -al
  fi
  ls
}

function file-showdir() {
  directory=$1
  echo-hr
  echo "$directory"
  echo-hr
  ls $directory
  echo-hr
}

function ls-i() {
  ls -al
  echo "File count:"
  ls -l | wc -l
}

function ~www() {
  cd $wwwroot/html/$www_repofocus
  ls
}
function ~home() {
  echo-h1 "home directory"
  cd ~/
  ls -al
}

function ~libapp() {
  cd $wwwroot/html/$www_repofocus/app/DD_laravelAp
  ls -al
}

function ~libviews() {
  cd $wwwroot/html/$www_repofocus/resources/views/DD_laraview
  ls -al
}

function ~libapp() {
  cd $wwwroot/html/$www_repofocus/app/DD_laravelAp
  ls
}

function ~libviews() {
  cd $wwwroot/html/$www_repofocus/resources/views/DD_laraview
  ls
}

function ~libmedia() {
  cd $wwwroot/html/$www_repofocus/public/DD_libmedia
  ls
}

function ~libwww() {
  cd $wwwroot/html/$www_repofocus/public/DD_libwww
  ls
}

function ~log() {
  cd $wwwroot/html/$www_repofocus/storage/logs
  ls
}

function ~log-sys() {
  echo "/var/log"
  ls -al /var/log
}

function ~nginx() {
  echo-hr
  echo "NGINX sites"
  cd /etc/nginx/sites-enabled
  ls
}

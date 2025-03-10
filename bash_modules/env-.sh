#!/usr/bin/env bash
function env-setwwwroot() {
  echo "Please set www root directory eg /var/www"
  read wwwroot
  bash-writesettings
  env-attributerequire "wwwroot"
}

function env-about() {
  clear
  echo-h1 "About Server"
  echo-now
  echo ""
  echo "Name: $serverid"
  echo "OS:"
  cat /etc/lsb-release
  echo ""
  echo "Environment: (production/local)"
  echo-nl "$environment"
  ipaddr=$(hostname --all-ip-addresses)
  echo "IP : $ipaddr"
  echo-nl "Default Database IP: $defaultDatabaseIP"
  echo "Your session IP detected as:"
  echo $SSH_CLIENT | awk '{ print $1}'
  echo "PHP Version: $phpNo"
  echo-nl "MYSQL Version: $MYSQL_VERSION"

  # echo |  Gateway: $ipgateway  |
  echo "GIT username: $gituname"
  echo "www root: $wwwroot"
  echo "Available SSH (bash-ssh) 1:$ssh1 | 2:$ssh2"
  echo-hr
}

#for per machine settings that do not change
function env-setservertype() {
  #bash-envsetwwwroot
  echo "Enter environment (production / local)"
  read environment
  if [ "$environment" == "local" ]; then
    environment="local"
    os-install-xdebug
  else
    environment="production"
  fi
  echo "Environment set to $environment"
  bash-writesettings
  #echo "Enter dev site project names ? y/n"
  #read doset
  # if [ "$doset" = "y" ]; then
  #   www-reposet
  # fi
  # cd $wwwroot
}

function env-setattribute() {
  varname=$1
  echo "Attempting to reset $varname"
  if [ "$varname" == "phpNo" ]; then
    phpNo=""
    bash-writesettings
  elif [ "$varname" == "os_status" ]; then
    os_status=""
    bash-writesettings
  elif [ "$varname" == "gituname" ]; then
    gituname=""
    bash-writesettings
  fi
  env-attributerequire $varname
}

function env-attributerequire() {
  # shellcheck disable=SC2317
  varname=$1
  if [ "$varname" == "environment" ]; then
    if [ "$environment" == "" ]; then
      env-setservertype
    fi
  elif [ "$varname" == "serverid" ]; then
    if [ "$serverid" == "" ]; then
      echo "Please enter name of this server"
      read serverid
      bash-writesettings
    fi
  elif [ "$varname" == "gituname" ]; then
    if [ "$gituname" == "" ]; then
      echo "Please enter your git username and ensure you have set up ssh access"
      read gituname
      bash-writesettings
    fi
  elif [ "$varname" == "defaultDatabaseIP" ]; then
    if [ "$defaultDatabaseIP" == "" ]; then
      echo "Please enter main database IP address"
      read defaultDatabaseIP
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
    if [ "$welcomemsg" != "" ]; then
      echo "Please enter Welcome Message / server name"
      read welcomemsg
      bash-writesettings
    fi
  fi
  clear
}

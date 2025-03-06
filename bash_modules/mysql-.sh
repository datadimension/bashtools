#!/usr/bin/env bash

function mysql-install() {
  #https://support.rackspace.com/how-to/installing-mysql-server-on-ubuntu/
  #ignore part about ufw, we will do that seperate
  echo "Follow this guide for mysql 8"
  echo "https://tastethelinux.com/upgrade-mysql-server-from-5-7-to-8-ubuntu-18-04/"
  echo "Do you want MySQL here - if this a a dev server you might want to use production or database server"
  read -p "Y/n" confirm
  if [ "$confirm" != "Y" ]; then
    return 0
  fi
  sudo apt-get -y install mysql-server

  #set max security and remove min priviledges such as root access
  sudo mysql_secure_installation utility
  sudo systemctl start mysql
  sudo systemctl enable mysql

  #set bind address for all ip addresses so can remote access
  # bind-address            = 0.0.0.0
  echo "
We need to edit /etc/mysql/mysql.conf.d/mysqld.cnf
set bind address for all ip addresses so can remote access
bind-address            = 0.0.0.0 #remove 127.0.0.1
bind-address            = <wan ip address>
Enter to edit conf ....
"
  read wait
  sudo nano +31 /etc/mysql/mysql.conf.d/mysqld.cnf
  sudo systemctl restart mysql
  sudo ufw allow mysql
  echo "Now to CREATE sql script to add new user"
  echo "NOTE YOU WILL HAVE TO RUN IT TO ADD THE USER"
  echo "Enter new SQL admin username"
  read sqluser
  echo "Enter new SQL admin password"
  read -s pword
  echo ""
  echo "log in to mysql using sudo mysql and run:"
  echo "CREATE USER '"$sqluser"'@'%' IDENTIFIED BY '"$pword"';"
  echo "GRANT ALL PRIVILEGES ON *.* TO '"$sqluser"'@'%' WITH GRANT OPTION;"
  echo "FLUSH PRIVILEGES;"
  echo "select host, user from mysql.user;"
  echo ""
  echo "
Note if something breaks or password is lost:
sudo mysql --no-defaults --force --user=root --host=localhost --database=mysql
add user
"
}

function mysql-getversion() {
  if [ -f /etc/init.d/mysql* ]; then
    MYSQL_VERSION=$(mysql -V)
  else
    MYSQL_VERSION="not installed"
  fi
  echo $MYSQL_VERSION
}

#generates users and permissions php and admin, note the users are named after the focused repo, however if a schema argument is supplied then this is used for the appschema
function mysql-createrepousers() {
  clear
  if [ "$environment" != "production" ]; then
    echo-h1 "YOU ARE NOT"
    echo "RUNNING THIS ON PRODUCTION SERVER"
  fi
  echo "MYSQL scripts will be generated to copy"
  echo-h1 "RUN ON DATABASE SERVER"
  echo "Not the DEV server"
  wait clear
  app_schema=$1
  if [ "$www_repofocus" == "" ] && [ "$app_schema" == "" ]; then
    read -p "You need to have a focused repo to do this" wait
    return 1
  fi
  if [ "$app_schema" == "" ]; then
    app_schema=$www_repofocus
  fi
  echo "Generating scripts for $app_schema"
  newpassword="PWD_$(uuidgen)_"
  echo "YOU WILL HAVE TO RUN SQL TO ACTUALLY ADD THE USER"
  echo "Password will initially be set as random to avoid unsecurely showing it in script"
  echo-nl "The script will ask you to change this immediately"
  echo-nl "SQL Script:"
  echo-hr
  echo "DROP USER IF EXISTS '"$www_repofocus"_admin';"
  echo "CREATE USER '"$www_repofocus"_admin'@'%' IDENTIFIED BY '$newpassword';"
  echo "GRANT SELECT,EXECUTE, SHOW VIEW ON ddDB.* TO '"$www_repofocus"_admin'@'%';"
  echo-nl "GRANT ALL PRIVILEGES ON $app_schema.* TO '"$www_repofocus"_admin'@'%' WITH GRANT OPTION;"

  echo "DROP USER IF EXISTS '"$www_repofocus"_php';"
  echo "CREATE USER '"$www_repofocus"_php'@'%' IDENTIFIED BY '$newpassword';"
  echo "GRANT SELECT,EXECUTE on ddDB.* TO '"$www_repofocus"_php'@'%';"
  echo-nl "GRANT SELECT, INSERT, UPDATE, DELETE, EXECUTE ON $app_schema.* TO '"$www_repofocus"_php'@'%' WITH GRANT OPTION;"
  echo-hr
  echo "now to set actual passwords:"
  echo-hr
  echo-nl "ALTER USER '"$www_repofocus"_admin'@'%' IDENTIFIED BY 'New-Password-Here"
  echo-nl "ALTER USER '"$www_repofocus"_php'@'%' IDENTIFIED BY 'New-Password-Here"
  echo "FLUSH PRIVILEGES;"
  echo-hr
  echo "Now logging into MYSQL"
  sudo mysql
}

function mysql-createrepodatabase() {
  clear
  echo "Create database by pasting the following scripts"
  echo-h1 "in the SQL IDE"
  wait clear
  echo "create database $www_repofocus;"
  echo "use $www_repofocus;"
  wait clear
  mysql-createrepousers $www_repofocus
  wait clear
  echo "Create tables by pasting the following scripts"
  echo-h1 "in the SQL IDE"
  declare -a sqltables=(
    "_account"
    "_apisettings"
    "_appsettings"
    "_cron"
    "_dbTableMap"
    "_dbquery"
    "_ddapiauth"
    "_emailq"
    "_iCalendar_event"
    "_iCalendar_eventadditional"
    "_iCalendar_usereventadditional"
    "_listplanner"
    "_location"
    "_monitor"
    "_notification"
    "_permissions"
    "_person"
    "_servernet"
    "_sessions"
    "_siteplanner"
    "_sysquery"
    "_usersettings"
    "_widgetgroups"
    "_widgets"
    "users"
  )

  size=${#sqltables[@]}
  i=0
  while [ $i -lt $size ]; do
    tablename="${sqltables[$i]}"
    echo "create table if not exists $tablename like localserver_admin.$tablename;"
    i=$(($i + 1))
  done
  wait clear
  echo "now create views"
  php ~/bashtools/php_helpers/mysql/view_domainwidgets.php
}

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
  wait
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
    __RESULT=$(mysql -V)
  else
    __RESULT="not installed"
  fi
}

function mysql-login() {
  mysql-getversion
  if [ "$__RESULT" == "not installed" ]; then #abort if no new reponame given
    exception "cannot log in, MYSQL not installed"
  fi
  echo ""
  echo-hr
  echo "Running MySQL login"
  echo "opening MYSQL [exit to return] ---->"
  sudo mysql
}

function mysql-projectsetupguide() {
  echo "ssh to PRODUCTION database server and run as directed"
  echo-b "mysql-projectcreate $db_app"
  wait "Finished database ? Enter to continue"
}

function mysql-projectcreate() {
  app_schema=$1
  mysql-createrepodatabase $app_schema
  mysql-setrepoaccess_admin_php $app_schema
}

function mysql-createrepodatabase() {
  app_schema=$1
  if [ "$app_schema" == "" ]; then
    exception "You need to specify a repo name to create a database for it"
  fi
  mysql-scriptgen_messageheader
  echo "create database $app_schema;"
  echo "use $app_schema;"
  echo-hr
  mysql-login
}

#generates user and permissions php and mysql admin log on for current bash user, reseting all permissions for previous user
function mysql-setrepoaccess_admin_php() {
  app_schema=$1
  if [ "$app_schema" == "" ]; then
    exception "You need to specify a repo name to create users for it"
  fi
  read -p "Confirm you want to set / reset mysql priviledges for $app_schema [y/n]" app_schema_permission_reset
  if [ "$app_schema_permission_reset" != "y" ]; then
    exception "cancelled reset mysql permissions"
  fi
  newmysqlpassword="PWD_$(uuidgen)_"
  clear
  mysql-scriptgen_messageheader
  echo "DROP USER IF EXISTS '"$app_schema"_admin';"
  echo "CREATE USER '"$app_schema"_admin'@'%' IDENTIFIED BY '$newpassword';"
  echo "GRANT SELECT,EXECUTE, SHOW VIEW ON ddDB.* TO '"$www_repofocus"_admin'@'%';"
  echo-nl "GRANT ALL PRIVILEGES ON $app_schema.* TO '"$app_schema"_admin'@'%' WITH GRANT OPTION;"

  echo "DROP USER IF EXISTS '"$app_schema"_php';"
  echo "CREATE USER '"$app_schema"_php'@'%' IDENTIFIED BY '$newpassword';"
  echo "GRANT SELECT,EXECUTE on ddDB.* TO '"$app_schema"_php'@'%';"
  echo-nl "GRANT SELECT, INSERT, UPDATE, DELETE, EXECUTE ON $app_schema.* TO '"$app_schema"_php'@'%' WITH GRANT OPTION;"
  #echo-hr
  #echo "now to set actual passwords:"
  #echo-hr
  #echo-nl "ALTER USER '"$app_schema"_admin'@'%' IDENTIFIED BY 'New-Password-Here"
  #echo-nl "ALTER USER '"$app_schema"_php'@'%' IDENTIFIED BY 'New-Password-Here"
  echo "FLUSH PRIVILEGES;"
  mysql-login
}

function mysql-createnewtables() {
  mysql-scriptgen_messageheader
  mysql-setrepo_admin $app_schema
  echo-hr
  mysql-scriptgen_messageheader
  echo-hr
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
    "_iconsource"
    "_libmedia"
    "_listplanner"
    "_location"
    "_geolocation"
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
  echo "use $app_schema;"
  while [ $i -lt $size ]; do
    tablename="${sqltables[$i]}"
    echo "create table if not exists $tablename like liveinfo247.$tablename;"
    i=$(($i + 1))
  done
  echo "-- type exit when done"
  mysql-login
  mysql-scriptgen_messageheader
  echo "now create view_domainwidgets"
  echo-hr
  php ~/bashtools/php_helpers/mysql/view_domainwidgets.php app_schema=$app_schema
  echo-hr
  echo "Then type exit when done"
  mysql-login
  mysql-scriptgen_messageheader
  echo "now create view_domainmedia"
  php ~/bashtools/php_helpers/mysql/view_domainmedia.php app_schema=$app_schema
  mysql-login
}

function mysql-scriptgen_messageheader() {
  clear
  echo "MYSQL script generator"
  echo "you will need to copy and run SQL script"
  echo "ON THE DATABASE PRODUCTION SERVER"
  echo "and then type exit at each stage"
  echo ""
  echo-hr
  echo "MySQL script:"
  echo-hr
}

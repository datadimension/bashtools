#!/usr/bin/env bash

function www-siteremove() {
  clear
  echo-h1 "Site Removal"
  echo "To remove from this server, you will still be able to reinstate from git using www-setsite"
  repo-show
  echo "if not on the list you will need to assign it to an option with repo-set"
  echo "Enter site number to remove"
  read option
  sitenumber=$(($option - 1))
  repodir=${wwwsites[$sitenumber]}
  echo "This will remove $repodir"
  echo "Please type '$repodir' to confirm"
  read confirm
  if [ "$repodir" == "$confirm" ]; then
    echo "removing"
    ~nginx
    sudo rm $repodir
    cd $wwwroot/html
    sudo rm -R $repodir
    wwwsites[$sitenumber]=""
    bash-writesettings
   wait -t 3
    bash-start
  else
    echo "cannot proceed until written confirmation"
  fi
}

# create extra requirements such as storage .env etc
function x20241122www-createnonrepofiles() {
  sudo mkdir -p $wwwroot/html/$dir/storage/framework/views/
  sudo mkdir -p $wwwroot/html/$dir/storage/framework/sessions/
  sudo mkdir -p $wwwroot/html/$dir/storage/framework/cache/
  sudo mkdir -p $wwwroot/html/$dir/storage/app/cache/

  sudo mkdir -p $wwwroot/html/$dir/storage/logs/
  sudo touch $wwwroot/html/$dir/storage/logs/cronresult.log
  sudo touch $wwwroot/html/$dir/storage/logs/apperror.log
  sudo touch $wwwroot/html/$dir/storage/logs/ssh.log

  sudo mkdir -p $wwwroot/html/$dir/bootstrap/cache
  sudo mkdir -p $wwwroot/html/$dir/public/downloads/
  sudo mkdir -p $wwwroot/html/$dir/private/
}

function www-sitesqluserinstall() {
  appname=$1
  dbpword=$2
  sqlusername=$appname"_php"
  echo "log in to mysql on the production server with:"
  echo ""
  echo "sudo mysql"
  echo ""
  echo "and run:"
  echo ""
  echo "CREATE USER '$sqlusername'@'%' IDENTIFIED BY '"$dbpword"';"
  echo "GRANT EXECUTE,SELECT,SHOW VIEW ON ddDB.* TO '"$sqlusername"'@'%';"
  echo "GRANT DELETE,EXECUTE,INSERT,SELECT,SHOW VIEW,UPDATE ON $appname.* TO '"$sqlusername"'@'%';"
  echo "FLUSH PRIVILEGES;"
}

function www-routes() {
  php artisan route:list
}

function os-certificategen() {
  echo "This will install a self signed certificate"
}

#help for this module
function www-h(){
	bash-helpformodule www
}

function www-oauthcreate() {
  clear
  echo-br "now to set up in Google Developer Console ... visit ..."
  echo-br "https://console.cloud.google.com/projectcreate"
  echo "and set up project for $www_repofocus"
  echo "note it will advise removing special characters from project name"
  echo "then configure OAuth screen"
  echo "https://console.cloud.google.com/apis/credentials/consent"
  echo "and Create OAuth client ID"
  echo-nl "https://console.cloud.google.com/auth/clients/create"
  echo-nl "and add as per these examples as seperate entries, eg for dev server:"
  echo "https://$dev_url"
  echo "https://$dev_url/auth/google/callback"
  echo-nl "https://$dev_url/google/api_getauth"
echo "also add for production server at some point"
}

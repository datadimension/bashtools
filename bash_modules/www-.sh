#!/usr/bin/env bash

#removes a site from this server, nginx and logs but will not remove repo from git
function www-remove() {
  clear
  echo-h1 "Site Removal"
  echo "To remove from this server, you will still be able to reinstate from git using www-setsite"
  repo-show
  echo "if not on the list you will need to assign it to an option with repo-set"
  echo "Enter site number to remove"
  read option
  sitenumber=$(($option - 1))
  repodir=${wwwrepos[$sitenumber]}
  echo-warn "This will remove $repodir"
  echo "Please type '$repodir' to confirm"
  read confirm
  if [ "$repodir" == "$confirm" ]; then
    echo "removing"
    ~nginx

    sudo rm $repodir
    cd $wwwroot/html
    sudo rm -R $repodir
    wwwrepos[$sitenumber]=""
    bash-writesettings
    wait -t 3
    bash-start
  else
    echo-error "cannot proceed until written confirmation"
  fi
}

# create extra requirements such as storage .env etc

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
function www-h() {
  bash-helpformodule www
}

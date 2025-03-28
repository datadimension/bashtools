#!/usr/bin/env bash

# shows site selection
# list to pick from for various funcs
function www-reposhow() {
  echo-br "Current repos are:"
  for i in {0..9}; do
    repolabel=${wwwrepos[$i]}
    if [ "$repolabel" != "" ]; then
      repolabel="$repolabel  [dev URL: $repolabel.$serverid.com ]"
    fi
    echo "$((i + 1)): $repolabel"
  done
  echo ""
  echo "www-reposwitch to change / www-reposet to configure "
}

function www-siteremove() {
  clear
  echo-h1 "Site Removal"
  echo "To remove from this server, you will still be able to reinstate from git using www-setsite"
  www-reposhow
  echo "if not on the list you will need to assign it to an option with www-reposet"
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
    read wait -t 3
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

# sets up and assigns site to site index list, installing if needed
function www-reposet() {
  clear
  echo-h1 "Repo Set"
  echo "Available Repos:"
  echo-hr
  ls $wwwroot/html
  echo-hr
  www-reposhow
  echo ""
  echo "NOTE: Reassigning repo number will not delete the repo - you will need to run www-reporemove"
  echo ""
  echo "Enter repo number to change"
  read option
  reponumber=$(($option - 1))
  read -p "Enter repo name to set against #$option: " newrepo #[note on dev server use the url for the dev server eg liveinfo247"
  wwwrepos[$reponumber]=$newrepo
  if [ -d "$wwwroot/html/$newrepo" ]; then #just change option if repo exists
    echo "Setting $option to existing $newrepo"
    www_repofocus=$newrepo
    bash-writesettings
    bash-restart
  else # need to set up repo
    #set -e #stop everything if there is a failure
    www_repofocus=$newrepo
    bash-writesettings
    echo "Directory $newrepo not found so will install."
    echo "Will install under $wwwroot/html/$www_repofocus"
    echo "with dev URL: $www_repofocus.$serverid.com"
    git-installrepo $www_repofocus
  fi
}

#reset permission levels to minimal required
#need to check if permisions can be tightened
#https://stackoverflow.com/questions/30639174/how-to-set-up-file-permissions-for-laravel
function www-secure() {

  #sudo find /path/to/your/laravel/root/directory -type f -exec chmod 644 {} \;
  #sudo find /path/to/your/laravel/root/directory -type d -exec chmod 755 {} \;

  #20230907sudo chown -R $USER:www-data $wwwroot/html/$www_sitefocus/apicredentials/google/credentials.json
  #moving this to php sudo chmod -R 775 $wwwroot/html/$www_sitefocus/apicredentials/google/credentials.json
  sudo chmod -R 775 $wwwroot/html/$www_repofocus/apicredentials/google/calendartoken.json
  sudo chown -R $USER:www-data $wwwroot/html/$www_repofocus/app/DD_laravelAp/API
  sudo chmod -R 770 $wwwroot/html/$www_repofocus/app/DD_laravelAp/API
  sudo chmod -R ug+rwx $wwwroot/html/$www_repofocus/app/DD_laravelAp/API
  sudo chmod -R 775 $wwwroot/html/$www_repofocus/bootstrap/cache

  sudo chown -R $USER:www-data $wwwroot/html/$www_repofocus/public/downloads
  sudo chmod -R 775 $wwwroot/html/$www_repofocus/public/downloads

  sudo chown -R $USER:www-data $wwwroot/html/$www_repofocus/storage
  sudo chmod -R 775 $wwwroot/html/$www_repofocus/storage
  #sudo chown -R $USER $HOME/.composer;#https://askubuntu.com/questions/1077879/cannot-create-cache-directory-home-user-composer-cache-repo-https-packagi
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

#switch the repo to work on
function www-reposwitch() {
  www-reposhow
  echo "Please select a repo number to chose for operations"
  read option
  reponumber=$(($option - 1))
  echo "Auto sync with GIT (recommended) ? n=no"
  read -t 5 input
  if [ "$environment" != "production" ]; then #never push from production
    if [ "$input" != "n" ]; then
      git-push
    fi
  fi
  www_repofocus=${wwwrepos[reponumber]}
  cd "$wwwroot/html/$www_repofocus"
  echo "setting repo to $www_repofocus"
  bash-writesettings
  if [ "$input" != "n" ]; then
    git-pull
  fi
  bash-start
}

function www-routes() {
  php artisan route:list
}

function os-certificategen() {
  echo "This will install a self signed certificate"
}

function www-repoinstall() {
  dir=$1
  reponame=$2
  echo "repoinstall"
  echo "Please enter the git reponame to put here"
  read reponame
  echo "Installing '$reponame' under $wwwroot/html/$dir"
  git-installrepo $dir $reponame
}

#creates a new website eg localserver_admin
function www-repocreate() {
  #based on https://kbroman.org/github_tutorial/pages/init.html
  clear
  echo "This will create a new laravel project"
  www-reposhow
  echo-br "Please enter new repo name (no special chars / underscore)"
  read newrepo
  read -p "Please enter index for '$newrepo' : " reponumber
  laravel-create $newrepo
  cd "$wwwroot/html"
  reponumber=$((reponumber - 1))
  wwwrepos[$reponumber]=$newrepo
  bash-writesettings
  echo "ssh database server and run mysql-createrepodatabase $www_repofocus"
  wait "Finished database ? Enter to continue"
  www-oauthcreate
}

function www-oauthcreate() {
  clear
  echo "now to set up in Google Developer Console ..."
  echo "visit https://console.cloud.google.com/projectcreate"
  echo "and set up project for $www_repofocus"
  echo "note it will advise removing special characters from project name"
  echo "then configure OAuth screen"
  echo "https://console.cloud.google.com/apis/credentials/consent"
  echo "and Create OAuth client ID"
  echo-nl "https://console.cloud.google.com/auth/clients/create"
  echo-nl "and add as per these examples as seperate entries:"
  echo "https://$www_repofocus"
  echo "https://$www_repofocus/auth/google/callback"
  echo-nl "https://$www_repofocus/google/api_getauth"
  echo-br "also add dev server entries similar to"
  echo "https://$www_repofocus.devserver"
  echo "https://$www_repofocus.devserver/auth/google/callback"
  echo "https://$www_repofocus.devserver/google/api_getauth"
}

function www-fromrepobackup() {
  read -p "Enter backup dir " backupdir
  read -p "Enter target dir " targetdir
  cd "$wwwroot/html/"

  cp -a -v --update=none $wwwroot/html/$backupdir/private $wwwroot/html/$targetdir

  #  cp -r 2024_xonhealth/app/Http/Controllers xonhealth/app/Http/xControllers
  # cp -r 2024_xonhealth/private xonhealth/private
  # cp -r 2024_xonhealth/public xonhealth/xpublic
  # cp 2024_xonhealth/.env xonhealth/.env
  # cp 2024_xonhealth/routes/web.php xonhealth/routes/web.php
  # cp -r 2024_xonhealth/resources/views xonhealth/resources/xviews

  # * * * * * php /var/www/html/sc.liveinfo247.com/artisan schedule:run

  # * * * * * php /var/www/html/liveinfo247.com/artisan schedule:run >> /dev/null 2>&1
  # * * * * * cd /var/www/html/liveinfo247.com/app && ./cron.sh

  # * * * * * php /var/www/html/xonhealth/artisan schedule:run >> /dev/null 2>&1
}

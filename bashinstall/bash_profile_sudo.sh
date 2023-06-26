#!/usr/bin/env bash
#bash_profile sudo

function bash-sudoers(){
  grep '^sudo:.*$' /etc/group | cut -d: -f4;
}

#reset permission levels to minimal required
#need to check if permisions can be tightened
#https://stackoverflow.com/questions/30639174/how-to-set-up-file-permissions-for-laravel
function bash-secure() {
sudo chown -R $USER:www-data $wwwroot/html/$www_sitefocus
  echo "Setting file ownership";# this is after as password required first

  echo "Setting file permissions";
sudo find $wwwroot/html/$www_sitefocus -type f -exec chmod 644 {} \;

  echo "Setting directory permissions";
sudo find $wwwroot/html/$www_sitefocus -type d -exec chmod 755 {} \;

  echo "Setting laravel permissions";
sudo chmod -R 775 $wwwroot/html/$www_sitefocus/storage
sudo chmod -R 775 $wwwroot/html/$www_sitefocus/public/downloads


#legacy
    #sudo chown -R $USER:www-data $wwwroot/html/$www_sitefocus/apicredentials/google/credentials.json
    #sudo chmod -R 775 $wwwroot/html/$www_sitefocus/apicredentials/google/credentials.json
    #sudo chmod -R 775 $wwwroot/html/$www_sitefocus/apicredentials/google/calendartoken.json
    #sudo chown -R $USER:www-data $wwwroot/html/$www_sitefocus/app/DD_laravelAp/API
    #sudo chmod -R 770 $wwwroot/html/$www_sitefocus/app/DD_laravelAp/API
    #sudo chmod -R ug+rwx $wwwroot/html/$www_sitefocus/app/DD_laravelAp/API
    #sudo chmod -R 775 $wwwroot/html/$www_sitefocus/bootstrap/cache

    #sudo chown -R $USER:www-data $wwwroot/html/$www_sitefocus/public/downloads
    #

    #sudo chown -R $USER:www-data $wwwroot/html/$www_sitefocus/storage
    #sudo chmod -R 775 $wwwroot/html/$www_sitefocus/storage
    #sudo chown -R $USER $HOME/.composer;#https://askubuntu.com/questions/1077879/cannot-create-cache-directory-home-user-composer-cache-repo-https-packagi
}

function nginx-start() {
    echo "Restart Nginx ? y/n"
    read -t 3 input
    if [ "$input" == "y" ]; then
        clear
        echo-h1 "Closing Nginx / PHP"

        sudo service nginx stop
        sudo service php7.4-fpm stop
        sudo pkill php-fpm
        sudo logrotate -f /etc/logrotate.d/nginx
        clear
        echo-h1 "Starting Nginx / PHP"
        sudo service php7.4-fpm start
        sudo service nginx start
        sudo /etc/init.d/cron start
        ps aux | grep php
        echo ""
        echo "finished restart"
        echo-now
        echo-hr
    fi
}

function php-start() {
    clear
    echo-h1 "Closing PHP"
    ps aux | grep php
    sudo pkill php-fpm
    clear
    echo-h1 "Starting PHP"
    sudo service php7.4-fpm start
    ps aux | grep php
}

function bash-gitinstall() {
    cd $wwwroot/html/serveradmin/_cli/bash
    git pull
    sudo rm ~/.bash_profile
    sudo cp $wwwroot/html/serveradmin/_cli/bash/bash_profile.sh ~/.bash_profile
    source ~/.bash_profile
    bash-start
}

bash-hosts() {
    sudo tail /etc/resolv.conf
}


function log-app() {
    sudo tail -30 $wwwroot/html/$www_sitefocus/storage/logs/apperror.log
}

function log-cron() {
    sudo tail -30 $wwwroot/html/$www_sitefocus/storage/logs/apperror.log
}

function log-sys-php() {
    echo-h1 "PHP SYS LOG"
    sudo tail -30 /var/log/php_errors.log
}

function log-nginxaccess() {
    echo-h1 "NGINX ACCESS LOG"
    sudo tail -n 100 /var/log/nginx/access.log
}

function log-nginxerror() {
    echo-h1 "NGINX ERROR LOG"
    sudo tail -n 100 /var/log/nginx/error.log
}

#https://logtail.com/tutorials/how-to-manage-log-files-with-logrotate-on-ubuntu-20-04/
function log-rotatedeploy() {
    sudo php $wwwroot/html/serveradmin/_cli/bash/helpers/logrotatedeployer.php $www_sitefocus
}

function vpn() {
    echo 'Please enter the VPN url'
    read vpnurl
    echo "If not prompted for username AND password you will need to authorise local sudo permission to connect (this machines password)"
    sudo openconnect -b $vpnurl
    echo "CTRL C exits VPN setup - if connected will continue running in the background"
}

function php-edit() {
    echo "You might need the gateway ip:"
    tail /etc/resolv.conf
    read waitinput
    phproot="/etc/php/$phpNo/fpm"
    inifileName="$phproot/php.ini"
    sudo nano +9999 $inifileName
    nginx-start
}

function phpfpm-edit() {
    phproot="/etc/php/$phpNo/fpm"
    confFileName="$phproot/php-fpm.conf"
    sudo nano $confFileName
    nginx-start
}

function ~php() {
    phproot="/etc/php/$phpNo/fpm"
    ls -al $phproot
}

function ~g_drive() {
    cd $wwwroot/html/$www_sitefocus/public/g_drive
    ls
}

function bash-hosts() {
    sudo nano /etc/hosts
}

#creates a new website
function www-create() {
    composer require twilio/sdk
    #20201119composer require clicksend/clicksend-php;
}


function www-envinstall() {
    sudo rm $wwwroot/html/$www_sitefocus/.env
    sudo nano $wwwroot/html/$www_sitefocus/.env
    nginx-start
}

function www-update() {
    bash-secure;
    echo "update composer";
    cd $wwwroot/html/$www_sitefocus
    #dev versions follow in comments
    composer dump-autoload;# php 71 `which composer` dump-autoload;

    #need to detect php version here and if statements (bash switch?) to perform updates as system might be multi php

    #works: php71 -d memory_limit=-1 `which composer` update --no-scripts;
    composer update -W # php71 `which composer` update --no-scripts; or? php71 -d memory_limit=768M `which composer` update --no-scripts;(1610612736)
    composer install
    # this also generates autoload;
    php artisan key:generate #dev server php70 artisan key:generate;
    php artisan view:clear
    php artisan --version
}


function git-deploy() {
    clear
    if [[ $environment != "production" ]]; then
        figlet "Warning"
        echo "This is not a production server"
    fi
    echo "You will overwrite local changes with current live version"
    echo "Please confirm full deployment to this server by typing the name of the repo you would like to pull"
    echo "You then will switch to that site and begin erasing local data with a fresh install from github"
    echo "Enter repo name, or just [ENTER]  to quit"
    read reponame
    if [ "reponame" == "" ]; then
        echo "Quit deployment"
        return -1
    fi
    echo "Enter DNS name eg website.com"
    read dnsname
    bash-showsettings
    echo-h1 "running deployment"
    #20201210 reponame=$www_sitefocus;
    ## backup platform files
    #sudo mkdir $reponame;#make it exist if not there
    #cd $wwwroot

    backupPath="$wwwroot/htmlbackups/$reponame"
    sudo mkdir -p $backupPath
    #cd $wwwroot;

    #copy existing platform only files if we are redeploying for some reason
    sudo cp $wwwroot/html/$reponame/.env $backupPath/.env
    sudo cp -r $wwwroot/html/$reponame/apicredentials $backupPath

    #clone repo ###############################################
    sudo rm -r $wwwroot/html/$reponame
    cd $wwwroot/html/
    echo-hr
    echo-h1 "Cloning $reponame"
    git clone git@github.com:$gituname/$reponame.git $wwwroot/html/$reponame
    sudo chown $USER:www-data $wwwroot/html/$www_sitefocus
    sudo mkdir -p $wwwroot/html/$reponame/storage/framework/views/
    sudo mkdir -p $wwwroot/html/$reponame/storage/framework/sessions/
    sudo mkdir -p $wwwroot/html/$reponame/storage/framework/cache/
    sudo mkdir -p $wwwroot/html/$reponame/storage/app/cache/
    sudo mkdir -p $wwwroot/html/$reponame/storage/logs/
    sudo touch $wwwroot/html/$reponame/storage/logs/cronresult.log
    sudo mkdir -p $wwwroot/html/$reponame/bootstrap/cache
    sudo mkdir -p $wwwroot/html/$reponame/public/downloads/

    # we can try and reinstall pre-existing platform files later, but at least have a .env and a credentials dir
    cp $wwwroot/html/$reponame/.env.example $wwwroot/html/$reponame/.env
    sudo mkdir -p $wwwroot/html/$reponame/apicredentials/google

    #move platform files back if we have deployed here before
    sudo cp $backupPath/.env $wwwroot/html/$reponame/.env
    sudo cp -r $backupPath/apicredentials $wwwroot/html/$reponame/app/DD_laravelAp/API

    www_sitefocus=$reponame
    git-deploysubrepos
    sudo php $wwwroot/html/serveradmin/_cli/bash/helpers/nginxblockdeployer.php $reponame $dnsname $environment
    sudo ln -s /etc/nginx/sites-available/$reponame /etc/nginx/sites-enabled/$reponame
    www-update #sort permisions and composer out
    google-deploy
    echo "note changes to hosts will require"
    echo "ipconfig /flushdns"
    echo "on windows cmd terminal"
    echo "Press enter to restart nginx"
    read wait
    nginx-start
    echo-now
    echo-hr
    ls
    pwd
}

function x20210815google-deploy() {
    echo "
  Go to https://console.cloud.google.com/apis/credentials and download the 'client_secret' apicredentials json file.
  It should look something like this:
  {"web":{"client_id":"123456-abcdef123456.apps.googleusercontent.com","project_id":"example-123456","auth_uri":"https://accounts.google.com/o/oauth2/auth","token_uri":"https://oauth2.googleapis.com/token","auth_provider_x509_cert_url":"https://www.googleapis.com/oauth2/v1/certs","client_secret":"abcdef123456","redirect_uris":["https://example.com/auth/google/callback"]}}

  then copy and paste the contents here:

  "
    read apicreds
    sudo rm $wwwroot/html/$www_sitefocus/apicredentials/google/credentials.json
    sudo echo "$apicreds" >$wwwroot/html/$www_sitefocus/apicredentials/google/credentials.json
    sudo-bash-secure
}

function google-deploy() {
    clear
    sudo php $wwwroot/html/$www_sitefocus/app/DD_laravelAp/API/google/CLItokengen.php
}


function git-deploysubrepo() {
    subrepopath=$1
    subreponame=$2
    subrepopath="$wwwroot/html/$subrepopath"
    sudo rm -R $subrepopath/$subreponame
    echo-hr
    echo-h1 "cloning subrepo $subreponame"
    echo ""
    git clone git@github.com:$gituname/$subreponame.git $subrepopath/$subreponame
    echo ""
    echo "subrepo deployment of $subreponame finished at:"
    echo-now
    echo-hr
}

function nginx-edit() {
    sudo nano /etc/nginx/sites-enabled/$www_sitefocus
    nginx-start
}

function os-manage(){
  source ~/bashtools/bash_modules/os-manager.sh;
  os-main;
}

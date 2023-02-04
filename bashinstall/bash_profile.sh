#!/usr/bin/env bash

export VISUAL="nano"
export EDITOR="nano"

#keep this at top, so if other functions have bugs we can easily correct .bash_profile
function bash-install() {
    #20221031sudo rm -r ~/.bash_profile
    sudo cp $wwwroot/html/serveradmin/_cli/bash/bash_profile.sh $wwwroot/html/serveradmin/_cli/bash/bash_profile.bu
    sudo rm -r $wwwroot/html/serveradmin/_cli/bash/bash_profile.sh
    mkdir -p $wwwroot/html/serveradmin/_cli/bash
    sudo nano $wwwroot/html/serveradmin/_cli/bash/bash_profile.sh
    sudo cp $wwwroot/html/serveradmin/_cli/bash/bash_profile.sh ~/.bash_profile
    source ~/.bash_profile
    #  if [ "$environment" == "development" ]; then
    #        bash-push
    #   fi
    #bash-restart
}

function bash-install-user(){
      sudo cp $wwwroot/html/serveradmin/_cli/bash/bash_profile.sh $wwwroot/html/serveradmin/_cli/bash/bash_profile.bu;
}

  function bash-restore-user(){
    cp ~/.bu/.bash_cfg ~/.bash_cfg
    rm ~/.bash_profile;
    cp $wwwroot/html/serveradmin/_cli/bash/bash_profile_head.sh ~/.bash_profile;
    if [ $(getent group sudo) ]; then #some shells such as gitbash windows has limited functions, so no sudo
      echo "#sudo group exists."
        cat $wwwroot/html/serveradmin/_cli/bash/bash_profile_sudo.sh >> ~/.bash_profile;
    fi
    cat $wwwroot/html/serveradmin/_cli/bash/bash_profile_user.sh >> ~/.bash_profile;
    cat $wwwroot/html/serveradmin/_cli/bash/bash_profile_foot.sh >> ~/.bash_profile;
        bash-readsettings
      bash-showsettings
    tail -10000 ~/.bash_profile;
  }

function bash-restart() {
    bash-writesettings
    clear
    sudo cp $wwwroot/html/serveradmin/_cli/bash/bash_profile.sh ~/.bash_profile
    source ~/.bash_profile
}

function bash-writesettings() {
    sudo echo "$environment,$www_sitefocus,$ssh1,$ssh2,$wwwsite1,$wwwsite2,$wwwsite3,$gituname,$phpNo,$ipgateway,$welcomemsg,$wwwroot" >~/.bash_cfg
}

function bash-start() {
    clear
    bash-readsettings
    echo-h1 $welcomemsg
    echo-now
    # sudo /etc/init.d/cron start;
    www-showcfg
    bash-showsettings
    cd "$wwwroot/html/$www_sitefocus"
}

function bash-gitinstall() {
    cd $wwwroot/html/serveradmin/_cli/bash
    git pull
    sudo rm ~/.bash_profile
    sudo cp $wwwroot/html/serveradmin/_cli/bash/bash_profile.sh ~/.bash_profile
    source ~/.bash_profile
    bash-restart
}

function bash-showsettings() {
    echo-hr
    ipaddr=$(hostname --all-ip-addresses)
    echo "IP : $ipaddr  |  Gateway: $ipgateway  |  PHP Version: $phpNo | GIT username: $gituname"
    echo "www root: $wwwroot"
    echo "Available SSH (bash-ssh): $ssh1 | $ssh2"
    echo-hr
}

bash-hosts() {
    sudo tail /etc/resolv.conf
}

function laravel-version() {
    echo "for all laravel functions we are going to site focus root (~www)"
    cd "$wwwroot/html/$www_sitefocus"
    php artisan --version
}

function bash-readsettings() {
    csv=$(<~/.bash_cfg)
    IFS=', ' read -r -a values <<<"$csv" #read back in same order as written
    environment=${values[0]}
    www_sitefocus=${values[1]}
    ssh1=${values[2]}
    ssh2=${values[3]}
    wwwsite1=${values[4]}
    wwwsite2=${values[5]}
    wwwsite3=${values[6]}
    gituname=${values[7]}
    phpNo=${values[8]}
    ipgateway=${values[9]}
    welcomemsg=${values[10]}
    wwwroot=${values[11]}
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

#for per machine settings that do not change
function bash-envset() {
    bash-envsetwwwroot
    bash-envsetphp
    echo "Enter environment (production / development)"
    read environment
    if [ "$environment" == "development" ]; then
        environment="development"
    else
        environment="production"
    fi
    echo "Environment set to $environment"
    bash-writesettings
    echo "Enter dev site project names ? y/n"
    read doset
    if [ "$doset" = "y" ]; then
        www-setsites
    fi
    cd $wwwroot
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
    echo "Current sites:"
    echo ""
    echo "1: $wwwsite1"
    echo "2: $wwwsite2"
    echo "3: $wwwsite3"
    echo ""
}

function www-setsites() {
    echo-hr
    echo "Available sites:"
    ls $wwwroot/html
    www-showsites
    echo "Enter site number to change"
    read sitenumber
    echo "Enter site root directory name to set against site $sitenumber"
    if [ "$sitenumber" == "1" ]; then
        read wwwsite1
    elif [ "$sitenumber" == "2" ]; then
        read wwwsite2
    elif [ "$sitenumber" == "3" ]; then
        read wwwsite3
    fi
    www-switch
    bash-writesettings
}

function www-switch() {
    www-showsites
    echo "Please select a site number to chose for operations"
    read site
    if [ "$site" == "2" ]; then
        site=$wwwsite2
    elif [ "$site" == "3" ]; then
        site=$wwwsite3
    else
        site=$wwwsite1
    fi
    www_sitefocus=$site
    cd "$wwwroot/html/"
    echo "setting site to $www_sitefocus"
    bash-writesettings
    bash-restart
}

function ~www() {
    cd $wwwroot/html/$www_sitefocus
    ls
}
function ~libapp() {
    cd $wwwroot/html/$www_sitefocus/app/DD_laravelAp
    ls
}

function ~libviews() {
    cd $wwwroot/html/$www_sitefocus/resources/views/DD_laraview
    ls
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

function ~log-sys() {
    echo "/var/log"
    ls -al /var/log
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

function www-showcfg() {
    echo "Current Environment: "$environment
    echo ""
    www-showsites
    echo "Current Selected Site for operations: $www_sitefocus"
    echo ""
    ls
    echo-hr
}

function www-envinstall() {
    sudo rm $wwwroot/html/$www_sitefocus/.env
    sudo nano $wwwroot/html/$www_sitefocus/.env
    nginx-start
}

function www-update() {
    bash-setpermissions
    cd $wwwroot/html/$www_sitefocus
    #dev versions follow in comments
    #composer dump-autoload;# php 71 `which composer` dump-autoload;

    #need to detect php version here and if statements (bash switch?) to perform updates as system might be multi php

    #works: php71 -d memory_limit=-1 `which composer` update --no-scripts;
    composer update -W # php71 `which composer` update --no-scripts; or? php71 -d memory_limit=768M `which composer` update --no-scripts;(1610612736)
    composer install
    # this also generates autoload;
    php artisan key:generate #dev server php70 artisan key:generate;
    php artisan view:clear
    php artisan --version
}

function www-routes() {
    php artisan route:list
}

function git-setup() {
    echo ""
    echo "Enter GIT username (used to create urls for push / pull etc"
    read gituname
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
    bash-setpermissions
}

function google-deploy() {
    clear
    sudo php $wwwroot/html/$www_sitefocus/app/DD_laravelAp/API/google/CLItokengen.php
}

#reset permission levels to minimal required
#need to check if permisions can be tightened
function bash-setpermissions() {
    sudo chown -R $USER:www-data $wwwroot/html/$www_sitefocus/apicredentials/google/credentials.json
    sudo chmod -R 775 $wwwroot/html/$www_sitefocus/apicredentials/google/credentials.json
    sudo chmod -R 775 $wwwroot/html/$www_sitefocus/apicredentials/google/calendartoken.json
    sudo chown -R $USER:www-data $wwwroot/html/$www_sitefocus/app/DD_laravelAp/API
    sudo chmod -R 770 $wwwroot/html/$www_sitefocus/app/DD_laravelAp/API
    sudo chmod -R ug+rwx $wwwroot/html/$www_sitefocus/app/DD_laravelAp/API
    sudo chmod -R 775 $wwwroot/html/$www_sitefocus/bootstrap/cache

    sudo chown -R $USER:www-data $wwwroot/html/$www_sitefocus/public/downloads
    sudo chmod -R 775 $wwwroot/html/$www_sitefocus/public/downloads

    sudo chown -R $USER:www-data $wwwroot/html/$www_sitefocus/storage
    sudo chmod -R 775 $wwwroot/html/$www_sitefocus/storage
    #sudo chown -R $USER $HOME/.composer;#https://askubuntu.com/questions/1077879/cannot-create-cache-directory-home-user-composer-cache-repo-https-packagi
}

function git-deploysubrepos() {
    git-deploysubrepo "$www_sitefocus/public" "DD_libwww"
    git-deploysubrepo "$www_sitefocus/public" "DD_libmedia"
    git-deploysubrepo "$www_sitefocus/app" "DD_laravelAp"
    git-deploysubrepo "$www_sitefocus/resources/views" "DD_laraview"
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
    git-reset-repo "DD_libmedia"
    git-reset-repo "DD_laravelAp"
    git-reset-repo "$www_sitefocus"
}

function git-reset() {
    clear
    curpwd=$(pwd)
    echo "Enter a repo name"
    echo ""
    echo "1: DD_libwww"
    echo "2: DD_laravelAp"
    echo "3: DD_libmedia"
    echo "4: DD_laraview"
    echo "or hit enter for everything"
    read option
    if [ "$option" == "1" ]; then
        git-reset-repo "DD_libwww"
    elif [ "$option" == "2" ]; then
        git-reset-repo "DD_laravelAp"
    elif [ "$option" == "3" ]; then
        git-reset-repo "DD_libmedia"
    elif [ "$option" == "4" ]; then
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
    git remote set-url origin git@github.com:datadimension/$gitreponame
    git fetch --all
    branchname=$(date +%Y%m%d%I%M)
    echo "Reseting to $gitreponame$branchname"
    git branch "reset$gitreponame$branchname"
    git reset --hard origin/master
}

function git-push-all() {
    git-push-repo "DD_laraview"
    git-push-repo "DD_libwww"
    git-push-repo "DD_libmedia"
    git-push-repo "DD_laravelAp"
    git-push-repo "$www_sitefocus"
}

function git-push() {
    clear
    curpwd=$(pwd)
    echo "Enter a repo name"
    echo ""
    echo "1: DD_libwww"
    echo "2: DD_laravelAp"
    echo "3: DD_libmedia"
    echo "4: DD_laraview"
    echo "or hit enter for everything"
    read option
    if [ "$option" == "1" ]; then
        git-push-repo "DD_libwww"
        git-pull-repo "DD_libwww"
    elif [ "$option" == "2" ]; then
        git-push-repo "DD_laravelAp"
        git-pull-repo "DD_laravelAp"
    elif [ "$option" == "3" ]; then
        git-push-repo "DD_libmedia"
        git-pull-repo "DD_libmedia"
    elif [ "$option" == "4" ]; then
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
    git-pull-repo "DD_libmedia"
    git-pull-repo "DD_laravelAp"
    git-pull-repo "$www_sitefocus"
}

function git-pull() {
    clear
    echo-hr
    curpwd=$(pwd)

    echo "Enter a repo name"
    echo ""
    echo "1: DD_libwww"
    echo "2: DD_laravelAp"
    echo "3: DD_libmedia"
    echo "4: DD_laraview"
    echo "or hit enter for everything"
    read option
    if [ "$option" == "1" ]; then
        git-pull-repo "DD_libwww"
    elif [ "$option" == "2" ]; then
        git-pull-repo "DD_laravelAp"
    elif [ "$option" == "3" ]; then
        git-pull-repo "DD_libmedia"
    elif [ "$option" == "4" ]; then
        git-pull-repo "DD_laraview"
    else
        git-pull-all
    fi
    cd $curpwd
}

function bash-push() {
    echo-h1 "pushing bash repo"
    cd $wwwroot/html/serveradmin
    git add -A
    git commit -a -m update
    git push
    ~www
}

function bash-pull() {
    echo-h1 "pulling bash repo"
    cd $wwwroot/html/serveradmin
    git pull
    ~www
    bash-restart
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
    figlet $textoutput
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

function nginx-edit() {
    sudo nano /etc/nginx/sites-enabled/$www_sitefocus
    nginx-start
}

function ~nginx() {
    cd /etc/nginx/sites-enabled
    ls
}

function nginx-start() {
    echo "Restart Nginx ? y/n"
    read -t 3 input
    if [ "$input" == "y" ]; then
        clear
        echo-h1 "Closing Nginx / PHP"
        ps aux | grep php
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

function logv() {
    logname=$1
    tail -f -n 100 $wwwroot/$www_sitefocus/storage/logs/$logname.log
}

function bash-help() {
    php $wwwroot/html/serveradmin/_cli/php/helpers/bash-help.php
}

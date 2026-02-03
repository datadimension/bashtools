#!/usr/bin/env bash

#installs nginx
function nginx-install() {
  sudo apt -y install nginx
  #clear default files
  sudo rm /etc/nginx/sites-enabled/default
  sudo rm /etc/nginx/sites-available/default
  sudo rm /var/www/html/index.nginx-debian.html
  sudo mkdir -p /var/www/html
  sudo mkdir -p /var/www/certs
  php-install
  net-firewall-start
}

# restart nginx and php completely
function nginx-start() {
  read -p "Restart Nginx ? y/n" -t 10 input
  if [ "$input" == "n" ]; then
    return 0
  fi
  fsys-secure
  clear
  echo-hr "Closing Nginx / PHP"
  sudo service nginx stop
  sudo pkill -f nginx & wait $!

  sudo logrotate -f /etc/logrotate.d/nginx
echo-hr
  echo "Starting Nginx / PHP-fpm"
  php-restart
  sudo service nginx start
  sudo /etc/init.d/cron start
  if [ -e /var/run/nginx.pid ]; then
    echo "finished restart"
  else
    echo-h1 "NGINX FAIL"
    sudo nginx -t
    log-nginxerror
  fi
  echo-now
  echo-hr
}

function nginx-deploylocalserveradmin(){
	sudo chown datadimension:www-data /etc/nginx/sites-enabled
	git-repo_install localserveradmin;
}

#deprecated in favour of installing localserveradmin by defaul  installs an nginx test page to check server is operational
function nginx-testadd() {
  #read -p "Add nginxtest ? Y/n"  input
  #if [ "$input" != "Y" ]; then
  #	return 1;
  #fi
  sudo cp -R ~/bashtools/templates/nginx/nginxtest /var/www/html
  sudo chown -R $USER:www-data /var/www/html/nginxtest

  #create test block so nginx can read it
  nginx-setserverblock nginxtest sslselfsigned
  #20250110 php ~/bashtools/php_helpers/nginx/serverblock.php
  #20250110 sudo mv /home/$USER/bashtoolscfg/tmp/serverblock_nginxtest /etc/nginx/sites-enabled/nginxtest
  #20250110 sudo chown root:www-data /etc/nginx/sites-enabled/nginxtest

  echo "Now go to your local hosts file (we moved it to C:\www"
  echo "and add lines as appropriate for local browser address entry"
  echo "$ipaddr    nginxtest.$serverid.com"
  echo "then open Windows cmd and run ipconfig /flushdns"
  echo "and the test server should show online with"
  echo nginxtest.$serverid.com
}

#remove the nginx test site
function nginx-testremove() {
    echo "Nginx test removed"
}

function nginx-testfunc(){
    reponame=$www_repofocus
      php ~/bashtools/php_helpers/nginx/serverblock.php repo_name=$reponame sslcertificate=$sslcertificate APP_URL=$localurl

}

#sets nginx block for current repo focus by default or specify repo name and sslcertificate repofocus will be changed if set
function nginx-setserverblock() {
  reponame=$1
  if [ "$reponame" == "" ]; then
    reponame=$www_repofocus
  else
    www_repofocus=$reponame #set focus or .env will be read wrong by php
    bash-writesettings
  fi
  sslcertificate=$2
  if [ "$sslcertificate" == "" ]; then
    sslcertificate="sslselfsigned"
  fi
  echo-newpage "Setting up NGINX Server block"
  echo "Using $www_repofocus.$serverid.com with certificate $sslcertificate"
  echo ""
  echo "Add a line to your local hosts file: "
  localurl="$www_repofocus.$serverid.com"
  echo "$('net-wanIP')   $localurl"
  echo "and run this in windows CMD terminal where applicable (eg on dev laptop)"
  echo "ipconfig /flushdns"
  wait clear
  echo "Creating NGINX server block"
  echo-hr
  echo ""
  php ~/bashtools/php_helpers/nginx/serverblock.php repo_name=$reponame sslcertificate=$sslcertificate APP_URL=$localurl
  cat /etc/nginx/sites-enabled/$www_repofocus
  echo ""
  echo-hr
  echo "setting file permissions for server block and restarting nginx"
  sudo chown $USER:www-data /etc/nginx/sites-enabled/$www_repofocus
  nginx-start
}

function nginx-testfunc(){

}

#help for this module
function nginx-h(){
	bash-helpformodule nginx
}

function nginx.h(){
	bash-helpformodule nginx
}

# Makes self signed cert so dev server can run  HTTPS- note this is an insecure certificate and will not be valid on live server
function nginx-cert-createselfsigned() {
  echo "Making self signed cert so dev server can run  HTTPS- note this is an insecure certificate and will not be valid on live server"
  # https://linuxize.com/post/redirect-http-to-https-in-nginx/
  #also see https://linuxize.com/post/redirect-http-to-https-in-nginx/
  #https://www.digitalocean.com/community/tutorials/how-to-create-a-self-signed-ssl-certificate-for-nginx-in-ubuntu-18-04
  echo "This requires a stable connection and can take a long time ~40 mins"
  echo "therefore its recommended to use a screen session for this in case of disconnect https://linuxize.com/post/how-to-use-linux-screen/?utm_content=cmp-true"
  echo-nl "when generating, can leave all blank"
  echo "This window will auto close when done, you may want to leave it running and open a new one"
  os_status=$((os_status + 1)) #we exit so need to update pointer here
  bash-writesettings
  echo-now
  sudo mkdir /etc/nginx
  sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/nginx-selfsigned.key -out /etc/ssl/certs/nginx-selfsigned.crt
  sudo openssl dhparam -out /etc/nginx/dhparam.pem 4096
  echo-now
  nginx-copyselfsignedcert
  exit
}

#copy preprepared ssl self signed certs for testing
function nginx-cert-copyselfsigned() {
  sudo cp ~/bashtools/templates/nginx/domainsetup/selfsslcert/nginx-selfsigned.crt /etc/ssl/certs/nginx-selfsigned.crt
  sudo cp ~/bashtools/templates/nginx/domainsetup/selfsslcert/nginx-selfsigned.key /etc/ssl/private/nginx-selfsigned.key
  sudo cp -R ~/bashtools/templates/nginx/domainsetup/selfsslcert/ssl-params.conf /etc/nginx/snippets/ssl-params.conf
  sudo cp ~/bashtools/templates/nginx/domainsetup/selfsslcert/dhparam.pem /etc/nginx/dhparam.pem
}

#guides on creation and install registered cert - namecheap was used for certificate
function nginx-cert-createregistered() {
  echo "check this works after updates"
  return 0
  echo-nl "Run this on your actual live server, not the test"
  echo "This may take an hour whereby this ssh window should be kept open, as we will need to request ssl key from third party"
  read -p "Enter main domain name the ssl cert will be againts eg example_com: " certdomain
  mkdir -p ~/sslfiles/$certdomain
  cd ~/sslfiles/$certdomain
  echo "Now to generate private keys to use for ssl cert"
  read -p "Country code [eg GB for Great Britain]: " CC
  read -p "State [eg Surrey]: " ST
  read -p "Locality [eg London]: " LO

  openssl req -nodes -newkey rsa:2048 -keyout $certdomain.key -out $certdomain.csr -subj "/C=$CC/ST=$ST/L=$LO/O=NA/OU=NA/CN=$certdomain"

  echo "Now go to your certificate supplier and enter this as the Certificate Signing Request"
  echo-nl
  cat $certdomain.csr
  echo ""
  read -p "Use CNAME validation and ensure this passes and hit enter when certificate is issued" wait

  cd ~/sslfiles/$certdomain

  read -p "FTP cert files or zip to ~/$USER/sslfiles/$certdomain and press ENTER when done"
  read -p "Is it a single zip file [y/n]: " input
  if [ "$input" == "y" ]; then
    mv *.zip $certdomain.zip #conform file names
    unzip $certdomain.zip
    rm $certdomain.zip
  fi
  mv *.crt $certdomain.crt #conform file names
  mv *.ca-bundle $certdomain.ca-bundle

  cat $certdomain.crt >"$certdomain"_chain.crt
  echo >>"$certdomain"_chain.crt#add a new line under cert, so can add .crt below
  cat $certdomain.ca-bundle >>"$certdomain"_chain.crt

  sudo mkdir -p /var/www/certs/$certdomain

  sudo cp "$certdomain"_chain.crt /var/www/certs/$certdomain/"$certdomain"_chain.crt
  sudo cp "$certdomain".key /var/www/certs/$certdomain/"$certdomain".key
  nginx-setserverblock $www_repofocus $certdomain
}

#edit current repo block
function nginx-edit() {
  sudo nano /etc/nginx/sites-enabled/$www_repofocus
  nginx-start
}

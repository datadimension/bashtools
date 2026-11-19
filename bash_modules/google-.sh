#!/usr/bin/env bash

function google-deploy() {
	clear
	sudo php $wwwroot/html/$www_repofocus/app/DD_laravelAp/API/google/CLItokengen.php
}

function g-drive() {
	cd $wwwroot/html/$www_repofocus/public/g_drive
	ls
}

#store external ssh access details
function set-ssh() {
	echo "Please enter ssh servers in format <username />@<ipaddress /> eg myuser@123.123.123.123"
	echo "Enter ssh server 1"
	read ssh1
	echo "Enter ssh server 2"
	read ssh2
	bash-writesettings
}

function google-projectcreate() {
	clear
	echo "Go to"
	echo "https://console.cloud.google.com/projectcreate"
	echo "Create a new project for $www_repofocus and once created, go to its project page"
	echo "https://console.cloud.google.com/apis/credentials/consent"
	echo "set up OAuth screen, Create OAuth client ID as a web application"
	echo "also Create Credential > API key for javascript and enable eg maps"
	echo ""
	echo-nl "https://console.cloud.google.com/auth/clients/create"
	echo-nl "and check console configuration:"
	google-redirect-URIs
	echo ""
	wait "make a note of these for .env install when project is created"
	google-getcredentials
}

#helper to direct for details for google API credentials
function google-getcredentials() {
	echo "Get 3 required credentials from here for .env files"
	echo "GOOGLE_CLIENT_ID (click the edit icon on the oauth screen to see )"
	echo "GOOGLE_CLIENT_SECRET(click the edit icon on the oauth screen to see )"
	echo "GOOGLE_JAVASCRIPT_APIKEY"
}

#helper to display details for google auth
function google-redirect-URIs() {
	echo "Under Authorised redirect URIs for every production server / test server"
	echo "make sure of the following entries (run google-redirect-URIs in a terminal on the server to get the entries) :"
	echo ""
	echo "https://$LOCAL_URL"
	echo "https://$LOCAL_URL/auth/google/callback"
	echo-nl "https://$LOCAL_URL/google/api_getauth"
}

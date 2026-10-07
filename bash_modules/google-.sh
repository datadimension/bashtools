function google-deploy() {
	clear
	sudo php $wwwroot/html/$www_repofocus/app/DD_laravelAp/API/google/CLItokengen.php
}

function ~g_drive() {
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

function google-projectcreate(){
	echo "Go to https://console.cloud.google.com/"
	echo "Create a new project, and once created, go to its project page"
	echo "set up OAuth screen, Create OAuth client ID as a web application"
	echo "also Create Credential > API key for javascript and enable eg maps"
	echo "you will need to create and get 3 credentials from here"
	echo "GOOGLE_CLIENT_ID (click the edit icon on the oauth screen to see )"
	echo "GOOGLE_CLIENT_SECRET(click the edit icon on the oauth screen to see )"
	echo "GOOGLE_JAVASCRIPT_APIKEY"
	wait "make a note of these for .env install when project is created"
}

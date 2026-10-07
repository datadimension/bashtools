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
	clear
	echo "Go to"
	echo "https://console.cloud.google.com/projectcreate"
	echo "Create a new project for $www_repofocus and once created, go to its project page"
	echo "https://console.cloud.google.com/apis/credentials/consent"
	echo "set up OAuth screen, Create OAuth client ID as a web application"
	echo "also Create Credential > API key for javascript and enable eg maps"
	echo ""
	echo-nl "https://console.cloud.google.com/auth/clients/create"
	echo-nl "and add as per these examples as seperate entries, eg for dev server:"
	echo "https://$LOCAL_URL"
	echo "https://$LOCAL_URL/auth/google/callback"
	echo-nl "https://$LOCAL_URL/google/api_getauth"
	echo "also add for production server at some point"
	echo ""
	echo "you will need to create and get 3 credentials from here"
	echo "GOOGLE_CLIENT_ID (click the edit icon on the oauth screen to see )"
	echo "GOOGLE_CLIENT_SECRET(click the edit icon on the oauth screen to see )"
	echo "GOOGLE_JAVASCRIPT_APIKEY"
	wait "make a note of these for .env install when project is created"
}

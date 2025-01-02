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

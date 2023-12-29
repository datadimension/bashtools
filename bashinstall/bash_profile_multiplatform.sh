#!/usr/bin/env bash
#bash_profile user
#test

function sessionstart() {
	source ~/bashtools/bash_modules/bash-.sh
	bash-start
}

function laravel-version() {
	echo "for all laravel functions we are going to site focus root (~www)"
	cd "$wwwroot/html/$www_sitefocus"
	php artisan --version
}

###############################################################
#TOP LEVEL FUNCTIONS - move elsewhere when we can compile bash from different files

# allow a list of options, then selection via number, the menu value being stored in MENUCHOICE
# call:
# menu a,b,c,d
# echo MENUCHOICE
# would give 'c' if option 3 selected
function menu(){
  options=$1;
  IFS=',' read -r -a values <<<"$options";
  optioncount=${#values[@]};#note no space in assignation
  optioncount=$optioncount-1;
  #for i in {0..$optioncount}; do
  start=0;
  for (( i=$start; i<=$optioncount; i++ ));do
    	echo "$((i + 1)): ${values[$i]}"
  done
  echo-b "Enter Choice:";
  read choice
  choice=$choice-1;
  MENUCHOICE=${values[$choice]};
}

function fun(){
START=1
END=5
echo "Countdown"

for (( c=$START; c<=$END; c++ ))
do
    echo -n "$c "
    sleep 1
done
}


function echo-h1() {
	textoutput=$1
	if [ "$platform" == "windows" ]; then # assume we are using the gitbash ming shell so sudo does not exist
		echo $textoutput
	else
		figlet $textoutput
	fi
}

function echo-hr() {
	printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -
}

function echo-b(){
  	textoutput=$1
  echo -e "\e[1m$textoutput\e[0m";
}

function set-timestamp() {
	timestamp=$(date '+%F_%H:%M:%S')
}

function echo-now() {
	set-timestamp
	echo $timestamp
}

function pshell() {
	echo "POWERSHELL"
	echo "Some functions only work running WSL as administrator"
	echo "so for this right click on Ubuntu icon, right click again on Ubuntu from this menu that appears and 'run as administrator'"
	echo "are you admin y/n"
	read -t 3 input
	if [ "$input" == "y" ]; then
		mkdir -p ~/.bu
		cp -p ~/bashtoolscfg/bash.env ~/.bu/bashtoolscfg/bash.env
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

function logv() {
	logname=$1
	tail -f -n 100 $wwwroot/$www_sitefocus/storage/logs/$logname.log
}

#!/usr/bin/env bash
###############################################################
#TOP LEVEL FUNCTIONS - move elsewhere when we can compile bash from different files

font_reset='\x1b[2m\033[00m' #https://unix.stackexchange.com/questions/37260/change-font-in-echo-command
color_red='\033[01;31m'
color_green='\033[01;32m'
color_yellow='\033[01;33m'
color_purple='\033[01;35m'
color_cyan='\033[01;36m'
color_white='\033[01;37m'
weight_bold='\033[1m'
decoration_underline='\033[4m'

#echo -e "\x1b[0m io-std"
#echo -e "\x1b[1m bold"
#echo -e "\x1b[2m normal"
#and from the comments, thanks manatwork and GypsyCosmonaut:

#echo -e "\x1b[3m italic"
#echo -e "\x1b[4m underlined"
#echo -e "\x1b[5m blinking"
#echo -e "\x1b[7m inverted"

#prompts a user for input and returns that, or default value if nothing entered
function read_default(){
	prompt="$1"
	defaultval="$2"
	read -p $prompt $_DEFAULT
	if [ "$_DEFAULT" == "" ]; then # assume we are using the gitbash ming shell so sudo does not exist
        _DEFAULT="$defaultval"
    fi
}

#outputs big text with the text as supplied argument
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

#output with a line break after;
function echo-br() {
  textoutput=""$1""
  echo $textoutput
  echo ""
}

#output with a line break after;
function echo-nl() {
  textoutput=""$1""
  echo $textoutput
  echo ""
}

function echo-newpage() {
  textoutput=""$1""
  clear
  printf "${weight_bold}${color_cyan}"
  echo-hr
  echo $textoutput
  echo-hr
  echo -e "${font_reset}"
}

function echo-b() {
  textoutput=""$1""
  printf "\e[1m$textoutput\e[0m"
  echo ""
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
  tail -f -n 100 $wwwroot/$www_repofocus/storage/logs/$logname.log
}

## allow a list of options, then selection via number, the menu value being stored in MENUCHOICE
# example call:
# menu a,b,c,d "Menu Title Text"
# echo MENUCHOICE
# would give 'c' if option 3 selected
function std-menu() {
  options=""$1""
  title=""$2""
  if [ "$title" != "" ]; then
    echo ""
    echo-b "$title"
    echo ""
  fi
  IFS=',' read -r -a values <<<"$options"
  optioncount=${#values[@]} #note no space in assignation
  optioncount=$optioncount-1
  #for i in {0..$optioncount}; do
  start=0
  for ((i = $start; i <= $optioncount; i++)); do
    echo "$((i + 1)): ${values[$i]}"
  done
  echo ""
  echo-b "Enter Choice:"
  read choice
  choice=$choice-1
  MENUCHOICE=${values[$choice]}
}

# shows bashtools function categories and functions
function h-(){
	  std-menu std,bash,env,repo,fsys,git,log,net,os,nginx,php,www,composer,mysql,laravel,google "Help Categories:"
      echo "Loading help for $MENUCHOICE ..."
      php ~/bashtools/php_helpers/bash/bash-help.php helptype=$MENUCHOICE
}

# Show history or search in history
function hist() {
  search=$1
  clear
  echo-hr
  echo "HISTORY"
  clear
  echo "history search:"
  echo "$search"
  echo-hr
  if [ "$search" == "" ]; then
    history
  else
    history | grep $search
  fi
  echo-hr
  read -t 4 -p "Filter: " filter
    if [ "$filter" != "" ]; then
      hist $filter
      else
      	echo "none"
  echo "Use !<number> to execute history item <number>"
  fi
}

function uuid() {
  uuid=$(uuidgen)
}

#wait for execution, use 'clear' for argument 1 to clear screen and msg for argument 2 to title the cleared screen
function wait() {
  arg1=$1
  arg2=$2
  action="none"
  prompt="${weight_bold}${color_cyan}[ENTER]${font_reset} -> ${weight_bold}${color_green}CONTINUE${font_reset}"
  if [ "$arg1" != "" ]; then
    if [ "$arg1" == "clear" ]; then
      	if [ "$arg2" != "" ]; then
      		clear
       	 echo-hr
       	 echo -e "${weight_bold}${color_green}$arg2${font_reset}"
       	        	     			echo -e $prompt
       	        	     			       	 echo-hr
       	  		read wait
    	else
    			echo -e $prompt
	 			read wait
	 			clear
 		fi
	fi
 		else
 			echo -e $prompt
 			read wait
fi
}

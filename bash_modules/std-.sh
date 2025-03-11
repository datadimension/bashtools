#!/usr/bin/env bash
###############################################################
#TOP LEVEL FUNCTIONS - move elsewhere when we can compile bash from different files

NONE='\033[00m'
RED='\033[01;31m'
GREEN='\033[01;32m'
fontYELLOW='\033[01;33m'
PURPLE='\033[01;35m'
CYAN='\033[01;36m'
WHITE='\033[01;37m'
BOLD='\033[1m'
UNDERLINE='\033[4m'

function laravel-version() {
  echo "for all laravel functions we are going to site focus root (~www)"
  cd "$wwwroot/html/$www_repofocus"
  php artisan --version
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

function uuid() {
  uuid=$(uuidgen)
}

#wait for execution, use 'clear' for argument 1 to clear screen and msg for argument 2 to change prompt, or simply give a prompt for argument 1 that is not 'clear'
function wait() {
  arg1=$1
  arg2=$2
  action="none"
  prompt="Press Enter to continue"
  if [ "$arg1" != "" ]; then
    if [ "$arg1" == "clear" ]; then
      action="clear"
      if [ "$arg2" != "" ]; then
        prompt=$arg2
      fi
    else
      prompt=$arg1
    fi
  fi
  echo ""
  read -p "$prompt" wait
  echo ""
  if [ "$action" == "clear" ]; then
    clear
  fi
}

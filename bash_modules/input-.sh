#!/bin/bash

#ensure input is not blank
#the second argument is the variable to put the input into, also the value is available as $INPUT
function input-required() {
  prompt="$1"
  returnvar="$2"
  if [[ -z "$prompt" ]]; then
    prompt='Enter a value'
  fi
  while true; do
    # if counter is equal to 2 exit
    read -p "$prompt : " INPUT
    if [[ -z "$INPUT" ]]; then
      echo "Error! Input cannot be empty"
      continue
    fi
    break
  done
  # this lines will be executed only if the conditions passed - https://unix.stackexchange.com/questions/670755/bash-while-loop-for-user-input-and-error-prompt-with-a-counter-for-max-tries
  evalcmd="$returnvar=$INPUT"
  eval "$evalcmd"
}

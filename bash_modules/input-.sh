#!/bin/bash

#ensure input is not blank, returns the input as the STD variable __RESULT
function input-required() {
  prompt="$1"
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
  __RESULT=$INPUT
}

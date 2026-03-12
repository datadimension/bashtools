#!/bin/bash

#ensure input is not blank
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
    # this lines will be executed only if the conditions passed
    break
  done
  echo "Value : "$INPUT
}

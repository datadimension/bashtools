#!/usr/bin/env bash

function file-showdir() {
  directory=$1
  echo-hr
  echo "$directory "
  echo-hr
  ls $directory
  echo-hr
  echo ""
}

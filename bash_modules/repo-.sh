#!/usr/bin/env bash

# shows site selection
# list to pick from for various funcs
function repo-show() {
  echo-br "Current repos are:"
  for i in {0..9}; do
    repolabel=${wwwrepos[$i]}
    if [ "$repolabel" != "" ]; then
    	repodevurl="${repolabel//[^[:alnum:]]}.$serverid.com"
      repolabel="$repolabel  [dev URL: $repodevurl ]"
    fi
    echo "$((i + 1)): $repolabel"
  done
  echo ""
  echo "www-reposwitch to change / www-reposet to configure "
  echo ""
  echo "selected DEV URL:"
  echo "$dev_url"
  echo ""
}
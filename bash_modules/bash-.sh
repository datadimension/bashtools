#!/usr/bin/env bash
function bash-push() {
	echo-h1 "pushing bash repo"
	cd ~/bashtools
	git add -A
	git commit -a -m update
	git push
	echo "Any key to return to current project"
	read -t 3 input
	bash-pull
	~www
}
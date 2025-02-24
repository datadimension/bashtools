#!/usr/bin/env bash
#bash_profile head
export VISUAL="nano"
export EDITOR="nano"

tabs 4

function sessionstart() {
	source ~/bashtools/bash_modules/bash-.sh
	bash-start
}
sessionstart
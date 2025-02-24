#!/usr/bin/env bash

function git-installrepo() {
	env-attributerequire gituname
	reponame=$1
	user=$USER
	rm -R -f $wwwroot/html/$reponame
	mkdir $wwwroot/html/$reponame
	git clone git@github.com:$gituname/$reponame.git $wwwroot/html/$reponame
	git-deploysubrepos
	cd "$wwwroot/html/$www_repofocus"
	echo "set focused repo to '$www_repofocus'"
	bash-writesettings
	bash-restart
}

function git-deploysubrepos() {
	git-deploysubrepo "$www_repofocus/public" "DD_libwww"
	git-deploysubrepo "$www_repofocus/app" "DD_laravelAp"
	git-deploysubrepo "$www_repofocus/resources/views" "DD_laraview"
	echo-hr
}

function git-deploysubrepo() {
	subrepopath=$1
	subreponame=$2
	subrepopath="$wwwroot/html/$subrepopath"
	rm -R $subrepopath/$subreponame
	echo-hr
	echo "cloning subrepo $subreponame"
	echo-hr
	echo ""
	git clone git@github.com:$gituname/$subreponame.git $subrepopath/$subreponame
	echo ""
	echo "subrepo deployment of $subreponame finished at:"
	echo-now
	echo ""
}
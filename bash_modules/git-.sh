#!/usr/bin/env bash
function git-installrepo() {
	env-attributerequire gituname
	dir=$1
	reponame=$2
	user=$USER
	sudo mkdir $wwwroot/html/$dir
	sudo chown $user:www-data $wwwroot/html/$dir
	git clone git@github.com:$gituname/$reponame.git $wwwroot/html/$dir
	sudo touch /etc/nginx/sites-enabled/$dir
	sudo chown $user:www-data /etc/nginx/sites-enabled/$dir
	php ~/bashtools/php_nginx/serverblock.php servername=$dir
	www_sitefocus=$dir #do not this until now in case setting the repo dir and cloning it causes error
	git-deploysubrepos
	sudo mkdir -p $wwwroot/html/$dir/storage/framework/views/
	sudo mkdir -p $wwwroot/html/$dir/storage/framework/sessions/
	sudo mkdir -p $wwwroot/html/$dir/storage/framework/cache/
	sudo mkdir -p $wwwroot/html/$dir/storage/app/cache/
	sudo mkdir -p $wwwroot/html/$dir/storage/logs/
	sudo touch $wwwroot/html/$dir/storage/logs/cronresult.log
	sudo touch $wwwroot/html/$dir/storage/logs/apperror.log
	sudo mkdir -p $wwwroot/html/$dir/bootstrap/cache
	sudo mkdir -p $wwwroot/html/$dir/public/downloads/
}

function git-pull() {
	clear
	echo-hr
	curpwd=$(pwd)
	echo-h1 "Pulling to $www_sitefocus"
	echo "Enter a repo name"
	echo ""
	echo "1: DD_libwww"
	echo "2: DD_laravelAp"
	echo "3: DD_laraview"
	echo "or wait / hit enter for everything"
	read -t 3 option
	if [ "$option" == "1" ]; then
		git-pull-repo "DD_libwww"
	elif [ "$option" == "2" ]; then
		git-pull-repo "DD_laravelAp"
	elif [ "$option" == "3" ]; then
		git-pull-repo "DD_laraview"
	else
		git-pull-all
	fi
	cd $curpwd
}

function git-push() {
	clear
	curpwd=$(pwd)
	echo-h1 "Pushing from $www_sitefocus"
	echo "Enter a repo name"
	echo ""
	echo "1: DD_libwww"
	echo "2: DD_laravelAp"
	echo "3: DD_laraview"
	echo "or wait / hit enter for everything"
	read -t 3 option
	if [ "$option" == "1" ]; then
		git-push-repo "DD_libwww"
		git-pull-repo "DD_libwww"
	elif [ "$option" == "2" ]; then
		git-push-repo "DD_laravelAp"
		git-pull-repo "DD_laravelAp"
	elif [ "$option" == "3" ]; then
		git-push-repo "DD_laraview"
		git-pull-repo "DD_laraview"
	else
		git-push-all
	fi
	cd $curpwd
}


function git-add() {
	git status -uno
	git add -A
	git commit -a -m update
	echo "... all files added"

}

#reset all repos
function git-reset-all() {
	git-reset-repo "DD_laraview"
	git-reset-repo "DD_libwww"
	#git-reset-repo "DD_libmedia"
	git-reset-repo "DD_laravelAp"
	git-reset-repo "$www_sitefocus"
	if [ "$platform" == "ubuntu" ]; then # aimed at the ming64 shell for windows which does not have functions such as sudo
		echo "Reset file and directory permissions ? [y/n]"
		read input
		if [ "$input" == "y" ]; then
			bash-secure
		fi
	fi
}

function git-reset() {
	clear
	curpwd=$(pwd)
	echo "Enter a repo name"
	echo ""
	echo "1: DD_libwww"
	echo "2: DD_laravelAp"
	#echo "3: DD_libmedia"
	echo "3: DD_laraview"
	echo "or hit enter for everything"
	read option
	if [ "$option" == "1" ]; then
		git-reset-repo "DD_libwww"
	elif [ "$option" == "2" ]; then
		git-reset-repo "DD_laravelAp"
	elif [ "$option" == "3" ]; then
		git-reset-repo "DD_laraview"
	else
		git-reset-all
	fi
	cd $curpwd
}

#forces file overwrite from server, untracked files remain
function git-reset-repo() {
	gitreponame=$1
	if [ "$gitreponame" == "DD_laraview" ]; then
		gitrepopath="$wwwroot/html/$www_sitefocus/resources/views"
	elif [ "$gitreponame" == "DD_libwww" ]; then
		gitrepopath="$wwwroot/html/$www_sitefocus/public"
	elif [ "$gitreponame" == "DD_laravelAp" ]; then
		gitrepopath="$wwwroot/html/$www_sitefocus/app"
	elif [ "$gitreponame" == "DD_libmedia" ]; then
		gitrepopath="$wwwroot/html/$www_sitefocus/public"
	else
		gitrepopath="$wwwroot/html"
		gitreponame=$www_sitefocus
	fi
	echo-hr
	echo "reseting repo ..."
	echo-h1 "$gitreponame"
	echo "to $gitrepopath/$gitreponame;"
	cd $gitrepopath/$gitreponame
	#git remote set-url origin git@github.com:datadimension/$gitreponame
	git fetch --all
	# branchname=$(date +%Y%m%d%I%M)
	echo "Reseting to $gitreponame$branchname"
	# git branch "reset$gitreponame$branchname"
	git reset --hard origin/master
}

function git-push-all() {
	git-push-repo "DD_laraview"
	git-push-repo "DD_libwww"
	git-push-repo "DD_laravelAp"
	git-push-repo "$www_sitefocus"
}


function git-push-repo() {
	gitreponame=$1
	if [ "$gitreponame" == "DD_laraview" ]; then
		gitrepopath="$wwwroot/html/$www_sitefocus/resources/views"
	elif [ "$gitreponame" == "DD_libwww" ]; then
		gitrepopath="$wwwroot/html/$www_sitefocus/public"
	elif [ "$gitreponame" == "DD_laravelAp" ]; then
		gitrepopath="$wwwroot/html/$www_sitefocus/app"
	elif [ "$gitreponame" == "DD_libmedia" ]; then
		gitrepopath="$wwwroot/html/$www_sitefocus/public"
	else
		gitrepopath="$wwwroot/html"
		gitreponame=$www_sitefocus
	fi
	echo "pushing repo ..."
	echo-h1 "$gitreponame"
	echo "from $gitrepopath/$gitreponame;"
	cd $gitrepopath/$gitreponame
	git-add
	git push
	echo ""
	echo "Finished at:"
	echo-now
	echo-hr
}

function git-pull-repo() {
	gitreponame=$1
	if [ "$gitreponame" == "DD_laraview" ]; then
		gitrepopath="$wwwroot/html/$www_sitefocus/resources/views"
	elif [ "$gitreponame" == "DD_libwww" ]; then
		gitrepopath="$wwwroot/html/$www_sitefocus/public"
	elif [ "$gitreponame" == "DD_laravelAp" ]; then
		gitrepopath="$wwwroot/html/$www_sitefocus/app"
	elif [ "$gitreponame" == "DD_libmedia" ]; then
		gitrepopath="$wwwroot/html/$www_sitefocus/public"
	else
		gitrepopath="$wwwroot/html"
		gitreponame=$www_sitefocus
	fi
	echo "pulling repo ..."
	echo-h1 "$gitreponame"
	echo "to $gitrepopath/$gitreponame;"
	cd $gitrepopath/$gitreponame
	git-add
	git pull
	echo ""
	echo "Finished at:"
	echo-now
	echo-hr
}

function git-pull-all() {
	git-pull-repo "DD_laraview"
	git-pull-repo "DD_libwww"
	git-pull-repo "DD_laravelAp"
	git-pull-repo "$www_sitefocus"
}


function git-deploysubrepos() {
	git-deploysubrepo "$www_sitefocus/public" "DD_libwww"
	#20230701 this has its own repo now git-deploysubrepo "$www_sitefocus/public" "DD_libmedia"
	git-deploysubrepo "$www_sitefocus/app" "DD_laravelAp"
	git-deploysubrepo "$www_sitefocus/resources/views" "DD_laraview"
}

function git-deploysubrepo() {
	subrepopath=$1
	subreponame=$2
	subrepopath="$wwwroot/html/$subrepopath"
	rm -R $subrepopath/$subreponame
	echo-hr
	echo-h1 "cloning subrepo $subreponame"
	echo ""
	git clone git@github.com:$gituname/$subreponame.git $subrepopath/$subreponame
	echo ""
	echo "subrepo deployment of $subreponame finished at:"
	echo-now
	echo-hr
}

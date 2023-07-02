#!/usr/bin/env bash
function www-showsites() {
	echo ""
	echo "Current $environment sites are (run 'www-setsites' to configure) :"
	echo ""
	for i in {0..9}; do
		echo "$((i + 1)): ${wwwsites[$i]}"
	done
	echo ""
}

function www-setsites() {
	echo-hr
	echo "Available site directories:"
	ls $wwwroot/html
	www-showsites
	echo "Enter site number to change"
	read option
	sitenumber=$(($option - 1))
	echo "Enter site root directory name to set against site $option"
	read dir
	wwwsites[$sitenumber]=$dir
	if [ -d "$dir" ]; then #just change option if repo exists
		echo "Setting $option to $dir"
		www_sitefocus=$dir
	else    # need to set up repo
		set -e #stop everything if there is a failure
		echo "Directory $dir not found."
		echo "Will install under $wwwroot/html/$dir"
		echo "Please enter the git reponame to put here"
		read reponame
		echo "Installing '$reponame' under $wwwroot/html/$dir"
		git-installrepo $dir $reponame
	fi
	cd "$wwwroot/html/$www_sitefocus"
	echo "setting site to $www_sitefocus"
	bash-writesettings
	www-switch
}

function www-switch() {
	www-showsites
	echo "Please select a site number to chose for operations"
	read sitenumber
	echo "Git will auto sync. Enter 'n' to prevent this"
	read -t 3 input
	if [ "$input" != "n" ]; then
		git-push
	fi
	sitenumber=$((sitenumber - 1))
	www_sitefocus=${wwwsites[sitenumber]}
	cd "$wwwroot/html/$www_sitefocus"
	echo "setting site to $www_sitefocus"
	bash-writesettings
	if [ "$input" != "n" ]; then
		git-pull
	fi
	bash-start
}

function www-setenv(){
	env-attributerequire databaseIP

	#php ~/bashtools/php_nginx/serverblock.php servername=$dir

}

function www-routes() {
	php artisan route:list
}


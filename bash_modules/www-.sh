#!/usr/bin/env bash
function www-showsites() {
	echo "new www"
	echo "Current $environment sites are (run 'www-setsites' to configure) :"
	echo ""
	for i in {0..9}; do
		echo "$((i + 1)): ${wwwsites[$i]}"
	done
	echo ""
}
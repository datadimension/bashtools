#!/usr/bin/env bash
function laravel-showversion() {
	php artisan --version
}

function laravel-configcheck() {
	echo "config check"
}

function laravel-getenv_value() {
	key=$1
	echo "getting $key"
}

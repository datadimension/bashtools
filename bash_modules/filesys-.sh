#!/usr/bin/env bash


function cd~() {
	dir=$1
	cd $dir
	ls
}

function ls-i() {
	ls -al
	echo "File count:"
	ls -l | wc -l
}

function ~www() {
	cd $wwwroot/html/$www_sitefocus
	ls
}
function ~home() {
	cd ~/
	ls -al
}

function ~libapp() {
	cd $wwwroot/html/$www_sitefocus/app/DD_laravelAp
	ls -al
}

function ~libviews() {
	cd $wwwroot/html/$www_sitefocus/resources/views/DD_laraview
	ls -al
}

function ~libapp() {
	cd $wwwroot/html/$www_sitefocus/app/DD_laravelAp
	ls
}

function ~libviews() {
	cd $wwwroot/html/$www_sitefocus/resources/views/DD_laraview
	ls
}

function ~libmedia() {
	cd $wwwroot/html/$www_sitefocus/public/DD_libmedia
	ls
}

function ~libwww() {
	cd $wwwroot/html/$www_sitefocus/public/DD_libwww
	ls
}

function ~log() {
	cd $wwwroot/html/$www_sitefocus/storage/logs
	ls
}

function ~log-sys() {
	echo "/var/log"
	ls -al /var/log
}

function ~nginx() {
	cd /etc/nginx/sites-enabled
	ls
}

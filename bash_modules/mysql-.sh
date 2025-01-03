#!/usr/bin/env bash

function mysql-getversion(){
	if [ -f /etc/init.d/mysql* ]; then
    	MYSQL_VERSION="installed"
	else
  	  MYSQL_VERSION="not installed"
	fi
	echo $MYSQL_VERSION;
}
<?php
include(getenv('HOME') . "/bashtools/php_helpers/bash/_phpbashclientincludes.php");

if ($SERVER_ENVTYPE != "production") {//for test servers
      $appdebug = "true";
      $apploglevel = "debug";
      $mysqlIP = $defaultDatabaseIP;
}
else {//for production server
      $appdebug = "false";
      $apploglevel = "error";
      $mysqlIP = "localhost";
}

$envcontent =

    "#app details" . "\n" .
    "APP_NAME: " . $reponame . "\n" .
    "APP_SCREEN_NAME: " . $reponame . "\n" .
    "APP_KEY: " . $appkey . "\n" .
    "APP_URL: " . $reponame . "." . $serverid . ".com" . "\n" .
    "DATA_CONTROLLER_EMAIL: " . $email . "\n" .

    "\n" .
    "#server details" . "\n" .
    "APP_ENV: " . $SERVER_ENVTYPE . "\n" .
    "SERVER_ID: " . $serverid . "\n" .
    "DEFAULT_TIMEZONE: " . "Europe/London" . "\n" .
    "APP_DEBUG: " . $appdebug . "\n" .
    "APP_LOG_LEVEL: " . $apploglevel . "\n" .
    "GIT_SYNC_TIMESTAMP: " . "0" . "\n" .
    "TTL_CACHE: " . "7200" . "\n" .

    "\n" .
    "#google api details" . "\n" .
    "GOOGLE_CLIENT_ID: " . $google_CID . "\n" .
    "GOOGLE_CLIENT_SECRET: " . $google_SEC . "\n" .
    "GOOGLE_JAVASCRIPT_APIKEY: " . $google_JS . "\n" .

    "\n" .
    "#email details" . "\n" .
    "MAIL_DRIVER: " . "smtp" . "\n" .
    "MAIL_HOST: " . "smtp.googlemail.com" . "\n" .
    "MAIL_PORT: " . "465" . "\n" .
    "MAIL_USERNAME: " . "" . "\n" .
    "MAIL_PASSWORD: " . "" . "\n" .
    "MAIL_ENCRYPTION: " . "ssl" . "\n" .

    "\n" .
    "#database details" . "\n" .
    "DB_HOST_ddDB: " . $mysqlIP . "\n" .
    "DB_PORT_ddDB: " . "3306" . "\n" .
    "DB_DATABASE_ddDB: " . "ddDB" . "\n" .
    "DB_USERNAME_ddDB: " . $db_usr . "\n" .
    "DB_PASSWORD_ddDB: " . $ddDB_pwd . "\n" .
    "\n" .
    "DB_HOST_appDB: " . $mysqlIP . "\n" .
    "DB_PORT_appDB: " . "3306" . "\n" .
    "DB_DATABASE_appDB: " . $reponame . "\n" .
    "DB_USERNAME_appDB: " . $db_usr . "\n" .
    "DB_PASSWORD_appDB: " . $appDB_pwd . "\n" .

    "\n" .
    "#misc details" . "\n" .
    "BROADCAST_DRIVER: " . "" . "\n" .
    "CACHE_DRIVER: " . "" . "\n" .
    "SESSION_DRIVER: " . "" . "\n" .
    "QUEUE_DRIVER: " . "" . "\n" .

    "API_SMS_ACCOUNTID: " . "" . "\n" .
    "API_SMS_KEY: " . "" . "\n" .
    "API_SMS_FROMCLI: " . "" . "\n" .

    "";


echo $envcontent;
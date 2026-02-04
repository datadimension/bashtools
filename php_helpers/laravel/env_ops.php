<?php
include(getenv('HOME') . "/bashtools/php_helpers/bash/repoenvfiletoarray.php");
include(getenv('HOME') . "/bashtools/php_helpers/php_cli.php");

if ($args["method"] == "env_getvalue") {
      echo "get " . $args["key"] . "value";
}

if ($args["method"] == "env_generate") {
      $autovals = [
	  "APP_NAME" => $www_repofocus,
	  "APP_KEY" => "",
	  "APP_URL" => $www_repofocus . "." . $serverid . ".com",
	  "TTL_CACHE" => 7200,
	  "APP_ENV" => $SERVER_ENVTYPE,
	  "GIT_SYNC_TIMESTAMP" => 0,
	  "SERVER_ID" => ["production" => $serverid, "local" => $serverid],
	  "DEFAULT_TIMEZONE" => "Europe/London",
	  "APP_DEBUG" => ["production" => "false", "local" => "true"],
	  "APP_LOG_LEVEL" => ["production" => "error", "local" => "debug"],

	  "MAIL_DRIVER" => "smtp",
	  "MAIL_HOST" => "smtp.googlemail.com",
	  "MAIL_PORT" => 465,
	  "MAIL_USERNAME" => "",
	  "MAIL_PASSWORD" => "",
	  "MAIL_ENCRYPTION" => "ssl",

	  "API_SMS_ACCOUNTID" => "",
	  "API_SMS_KEY" => "",
	  "API_SMS_FROMCLI" => "",

	  "DB_HOST_ddDB" => ["production" => "localhost", "local" => $defaultDatabaseIP],
	  "DB_PORT_ddDB" => 3306,
	  "DB_DATABASE_ddDB" => "ddDB",
	  "DB_USERNAME_ddDB" => $db_app . "_php",

	  "DB_HOST_appDB" => ["production" => "localhost", "local" => $defaultDatabaseIP],
	  "DB_PORT_appDB" => 3306,
	  "DB_DATABASE_appDB" => $db_app,
	  "DB_USERNAME_appDB" => $db_app . "_php",

	  "BROADCAST_DRIVER" => "log",
	  "CACHE_DRIVER" => "file",
	  "SESSION_DRIVER" => "file",
	  "QUEUE_DRIVER" => "sync"
      ];

      $keys = [
	  "#app details" => "",
	  "APP_NAME" => $www_repofocus,
	  "DATA_CONTROLLER_EMAIL" => "",//full controller for this domain
	  "APP_KEY" => "",
	  "APP_URL" => $www_repofocus . "." . $serverid . ".com",
	  "TTL_CACHE" => 7200,

	  "#server details" => "",
	  "APP_ENV" => $SERVER_ENVTYPE,
	  "SERVER_ID" => ["production" => $serverid, "local" => $serverid],
	  "DEFAULT_TIMEZONE" => "Europe/London",
	  "APP_DEBUG" => ["production" => "false", "local" => "true"],
	  "APP_LOG_LEVEL" => ["production" => "error", "local" => "debug"],

	  "#google api details" => "",
	  "GOOGLE_CLIENT_ID" => "",
	  "GOOGLE_CLIENT_SECRET" => "",
	  "GOOGLE_JAVASCRIPT_APIKEY" => "",

	  "#gmail api" => "",
	  "MAIL_DRIVER" => "smtp",
	  "MAIL_HOST" => "smtp.googlemail.com",
	  "MAIL_PORT" => 465,
	  "MAIL_USERNAME" => "",
	  "MAIL_PASSWORD" => "",
	  "MAIL_ENCRYPTION" => "ssl",

	  "#sms api" => "",
	  "API_SMS_ACCOUNTID" => "",
	  "API_SMS_KEY" => "",
	  "API_SMS_FROMCLI" => "",

	  "#ddDB connection" => "",
	  "DB_HOST_ddDB" => ["production" => "localhost", "local" => $defaultDatabaseIP],
	  "DB_PORT_ddDB" => 3306,
	  "DB_DATABASE_ddDB" => "ddDB",
	  "DB_USERNAME_ddDB" => $www_repofocus . "_php",
	  "DB_PASSWORD_ddDB" => "",

	  "#appDB connection" => "",
	  "DB_HOST_appDB" => ["production" => "localhost", "local" => $defaultDatabaseIP],
	  "DB_PORT_appDB" => 3306,
	  "DB_DATABASE_appDB" => $db_app,
	  "DB_USERNAME_appDB" => $db_app . "_php",
	  "DB_PASSWORD_appDB" => "",

	  "#misc" => "",
	  "BROADCAST_DRIVER" => "log",
	  "CACHE_DRIVER" => "file",
	  "SESSION_DRIVER" => "file",
	  "QUEUE_DRIVER" => "sync"
      ];
      $envpath = $wwwroot . "/html/" . $www_repofocus . "/.env";
      echo "Putting .env at " . $envpath . "\n";
      $goauto = getinput("Would you like to use autovals to generate .env [y/n]", "y");
      if ($goauto == "y") {
	    echo "Autogenerate active" . PHP_EOL;
	    $envminimums = true;
      }
      else {
	    echo "Autogenerate disabled" . PHP_EOL;
	    $envminimums = false;
      }
      echo "";

      $envfile = "";
      foreach ($keys as $key => $default) {
	    if (substr($key, 0, 1) != "#") {
		  if ($envminimums && array_key_exists($key, $autovals)) {
			if (is_array($autovals[$key])) {
			      $autoval = $autovals[$key][$SERVER_ENVTYPE];
			}
			else {
			      $autoval = $autovals[$key];
			}
			$value = $autoval;
		  }
		  else {
			if (is_array($default)) {
			      $default = $default[$SERVER_ENVTYPE];
			}
			$value = getinput($key, $default);
		  }
		  $envfile .= $key . "=" . $value . "\n";
	    }
	    else {
		  $envfile .= "\n" . $key . "\n";
	    }
      }
      echo $envfile;
      file_put_contents($envpath, $envfile);
}

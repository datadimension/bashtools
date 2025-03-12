<?php
/**
 * used by shel script laravel-envinstall
 */
include(getenv('HOME') . "/bashtools/php_helpers/bash/bash.env.php");
//args to $_GET https://www.php.net/manual/en/features.commandline.php#:~:text=Even%20better%2C%20instead%20of%20putting%20that%20line%20in%20every%20file%2C%20take%20advantage%20of%20PHP%27s%20auto_prepend_file%20directive.%C2%A0%20Put%20that%20line%20in%20its%20own%20file%20and%20set%20the%20auto_prepend_file%20directive%20in%20your%20cli%2Dspecific%20php.ini%20like%20so%3A
parse_str(implode('&', array_slice($argv, 1)), $args);

$envtemplate = file_get_contents(getenv('HOME') . "/bashtools/templates/laravel/env");//dont use

if ($environment == "development") {
      $envtemplate = str_replace("<environment />", "local", $envtemplate);
      $envtemplate = str_replace("<appdebug />", "true", $envtemplate);
}
else {
      $envtemplate = str_replace("<environment />", $environment, $envtemplate);
      $envtemplate = str_replace("<appdebug />", "false", $envtemplate);
}
$envtemplate = str_replace("<serverid />", $serverid, $envtemplate);

$envtemplate = str_replace("<appname />", $args["appname"], $envtemplate);

$envtemplate = str_replace("<googleclient_id />", $args["gclient_id"], $envtemplate);
$envtemplate = str_replace("<googleclient_secret />", $args["gclient_secret"], $envtemplate);
$envtemplate = str_replace("<google_jskey />", $args["google_jskey"], $envtemplate);


$envtemplate = str_replace("<api_emai />", $args["api_emai"], $envtemplate);
$envtemplate = str_replace("<api_emailpwd />", $args["api_emailpwd"], $envtemplate);

$envtemplate = str_replace("<dir />", $args["dir"], $envtemplate);

$envtemplate = str_replace("<databaseIP />", defaultDatabaseIP, $envtemplate);
$envtemplate = str_replace("<databasePassword />", $args["dbpword"], $envtemplate);

$installfile = $wwwroot . "/html/" . $args["dir"] . "/.env";
echo $envtemplate;
file_put_contents($installfile, $envtemplate);
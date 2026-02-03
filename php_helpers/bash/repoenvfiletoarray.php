<?php
/**
 * reads the bash cli variables into php
 */
parse_str(implode('&', array_slice($argv, 1)), $args);

$csv = file_get_contents(getenv('HOME') . "/bashtoolscfg/bash.env");
$csv = explode(",", $csv);
$environment = $csv[0];
$www_repofocus = $csv[1];
$ssh1 = $csv[2];
$ssh2 = $csv[3];
$defaultDatabaseIP = $csv[4];
$serverid = $csv[5];

$gituname = $csv[7];
$PHP_VERSION = $csv[8];
$ipgateway = $csv[9];
$welcomemsg = $csv[10];
$wwwroot = $csv[11];
$platform = $csv[12];
//$wwwrepos=$csv[13];
//$www_repofocus=$csv[14];
$db_app = $csv[15];
$dev_url = $csv[16];

if (file_exists($wwwroot . "/html/" . $www_repofocus . "/.env")) {
      $repo_env_file = explode(PHP_EOL, file_get_contents($wwwroot . "/html/" . $www_repofocus . "/.env"));
}
else {
      $repo_env_file = [];
}
$repo_env = [];
foreach ($repo_env_file as $line) {
      $value = explode("=", $line);
      //20250326 $key = substr($line, 0, 1) == "#" ? null : $value[0];
      $key = $value[0];
      if ($key) {
	    if (count($value) > 1) {
		  $value = $value[1];
	    }
	    else {
		  $value = "";
	    }
	    $repo_env[$key] = $value;
      }
}
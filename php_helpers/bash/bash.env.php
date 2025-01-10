<?php
/**
 * reads the bash cli variables into php
 */
parse_str(implode('&', array_slice($argv, 1)), $args);

$csv = file_get_contents(getenv('HOME') . "/bashtoolscfg/bash.env");
$csv = explode(",", $csv);

$serverid = $csv[5];
$environment = $csv[0];
$www_repofocus = $csv[1];
$ssh1 = $csv[2];
$ssh2 = $csv[3];
$defaultDatabaseIP = $csv[4];
$gituname = $csv[7];
$phpNo = $csv[8];
$ipgateway = $csv[9];
$welcomemsg = $csv[10];
$wwwroot = $csv[11];
$platform = $csv[12];
$repo_env_file = explode(PHP_EOL,file_get_contents($wwwroot."/html/".$www_repofocus."/.env"));
$repo_env=[];
foreach($repo_env_file as $line){
      $value=explode("=",$line);
      $key=$value[0];
      if(count($value)>1) {
	    $value = $value[1];
      }
      else{
	    $value="";
      }
      $repo_env[$key]=$value;
      echo PHP_EOL;
}
var_dump($repo_env);

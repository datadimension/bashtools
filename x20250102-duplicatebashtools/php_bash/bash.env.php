<?php
/**
 * reads the bash cli variables into php
 */
parse_str(implode('&', array_slice($argv, 1)), $args);
$csv = file_get_contents(getenv('HOME') . "/bashtoolscfg/bash.env");
$csv = explode(",", $csv);

$serverid = $csv[5];
$environment = $csv[0];
$www_sitefocus = $csv[1];
$ssh1 = $csv[2];
$ssh2 = $csv[3];
$databaseIP = $csv[4];
$gituname = $csv[7];
$phpNo = $csv[8];
$ipgateway = $csv[9];
$welcomemsg = $csv[10];
$wwwroot = $csv[11];
$platform = $csv[12];
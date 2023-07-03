<?php
/**
 * reads the bash cli variables into php
 */
$csv = file_get_contents(getenv('HOME') . "/bashtoolscfg/bash.env");
$csv = explode(",", $csv);

$environment = $csv[0];
$www_sitefocus = $csv[1];
$ssh1 = $csv[2];
$ssh2 = $csv[3];
$databaseIP = $csv[4];
$serverid = $csv[5];
$gituname = $csv[7];
$phpNo = $csv[8];
$ipgateway = $csv[9];
$welcomemsg = $csv[10];
$wwwroot = $csv[11];
$platform = $csv[12];

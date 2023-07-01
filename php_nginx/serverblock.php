<?php

include("../php_bash/bash.env.php");
//echo $environment;
//args to $_GET https://www.php.net/manual/en/features.commandline.php#:~:text=Even%20better%2C%20instead%20of%20putting%20that%20line%20in%20every%20file%2C%20take%20advantage%20of%20PHP%27s%20auto_prepend_file%20directive.%C2%A0%20Put%20that%20line%20in%20its%20own%20file%20and%20set%20the%20auto_prepend_file%20directive%20in%20your%20cli%2Dspecific%20php.ini%20like%20so%3A
//parse_str(implode('&', array_slice($argv, 1)), $_GET);


//echo "\n";
//echo $_GET["wwwroot"];
//echo "\n";
//echo $_GET["servername"];
$blocktemplate = file_get_contents( "../templates/nginx/domainsetup/nginxdevblock");


echo $blocktemplate;
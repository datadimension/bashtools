<?php
include(getenv('HOME') . "/bashtools/php_helpers/bash/repoenvfiletoarray.php");
include(getenv('HOME') . "/bashtools/php_helpers/bash/env-parse.php");

//20241103args to $_GET https://www.php.net/manual/en/features.commandline.php#:~:text=Even%20better%2C%20instead%20of%20putting%20that%20line%20in%20every%20file%2C%20take%20advantage%20of%20PHP%27s%20auto_prepend_file%20directive.%C2%A0%20Put%20that%20line%20in%20its%20own%20file%20and%20set%20the%20auto_prepend_file%20directive%20in%20your%20cli%2Dspecific%20php.ini%20like%20so%3A
parse_str(implode('&', array_slice($argv, 1)), $args);

$template = file_get_contents(getenv('HOME') . "/bashtools/templates/php/phpsetup/xdebug.ini");
$filename = $args["xdebugpath"];
echo $filename;
var_dump($template);

//file_put_contents($filename, $template);

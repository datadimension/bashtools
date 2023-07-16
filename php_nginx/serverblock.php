<<<<<<< HEAD
<?php
include(getenv('HOME') . "/bashtools/php_bash/bash.env.php");
//args to $_GET https://www.php.net/manual/en/features.commandline.php#:~:text=Even%20better%2C%20instead%20of%20putting%20that%20line%20in%20every%20file%2C%20take%20advantage%20of%20PHP%27s%20auto_prepend_file%20directive.%C2%A0%20Put%20that%20line%20in%20its%20own%20file%20and%20set%20the%20auto_prepend_file%20directive%20in%20your%20cli%2Dspecific%20php.ini%20like%20so%3A
parse_str(implode('&', array_slice($argv, 1)), $args);

if ($environment == "production") {
      $template = "nginxproductionblock";
}
else {
      $template = "nginxdevblock";
}

$blocktemplate = file_get_contents(getenv('HOME') . "/bashtools/templates/nginx/domainsetup/" . $template);
$blocktemplate = str_replace("<servername />", $args["servername"], $blocktemplate);
$blocktemplate = str_replace("<wwwroot />", $wwwroot, $blocktemplate);
$blocktemplate = str_replace("<phpNo />", $phpNo, $blocktemplate);
file_put_contents(getenv('HOME') . "/bashtoolscfg/tmp/serverblock" . $args["servername"], $blocktemplate);

=======
<?php
include(getenv('HOME') . "/bashtools/php_bash/bash.env.php");
//args to $_GET https://www.php.net/manual/en/features.commandline.php#:~:text=Even%20better%2C%20instead%20of%20putting%20that%20line%20in%20every%20file%2C%20take%20advantage%20of%20PHP%27s%20auto_prepend_file%20directive.%C2%A0%20Put%20that%20line%20in%20its%20own%20file%20and%20set%20the%20auto_prepend_file%20directive%20in%20your%20cli%2Dspecific%20php.ini%20like%20so%3A
parse_str(implode('&', array_slice($argv, 1)), $args);

if ($environment == "production") {
      $template = "nginxproductionblock";
}
else {
      $template = "nginxdevblock";
}

$blocktemplate = file_get_contents(getenv('HOME') . "/bashtools/templates/nginx/domainsetup/" . $template);
$blocktemplate = str_replace("<servername />", $args["servername"], $blocktemplate);
$blocktemplate = str_replace("<wwwroot />", $wwwroot, $blocktemplate);
$blocktemplate = str_replace("<phpNo />", $phpNo, $blocktemplate);
file_put_contents(getenv('HOME') . "/bashtoolscfg/tmp/serverblock" . $args["servername"], $blocktemplate);

>>>>>>> 2b6639839e3f26d81482966251a3a15cc1c30b95

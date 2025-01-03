<?php
include(getenv('HOME') . "/bashtools/php_helpers/bash/bash.env.php");
//20241103args to $_GET https://www.php.net/manual/en/features.commandline.php#:~:text=Even%20better%2C%20instead%20of%20putting%20that%20line%20in%20every%20file%2C%20take%20advantage%20of%20PHP%27s%20auto_prepend_file%20directive.%C2%A0%20Put%20that%20line%20in%20its%20own%20file%20and%20set%20the%20auto_prepend_file%20directive%20in%20your%20cli%2Dspecific%20php.ini%20like%20so%3A
parse_str(implode('&', array_slice($argv, 1)), $args);
if ($environment == "production") {
      $template = "nginxproductionblock";
}
else {
      $template = "nginxdevblock";
}
$root_repo_url=$args["repo_name"].".".$serverid.".com";

$blocktemplate = file_get_contents(getenv('HOME') . "/bashtools/templates/nginx/domainsetup/" . $template);
$blocktemplate = str_replace("<root_repo_url />", $root_repo_url, $blocktemplate);
$blocktemplate = str_replace("<repo_name />", $args["repo_name"], $blocktemplate);

$blocktemplate = str_replace("<wwwroot />", $wwwroot, $blocktemplate);
$blocktemplate = str_replace("<phpNo />", $phpNo, $blocktemplate);

echo $blocktemplate;
file_put_contents(getenv('HOME') . "/bashtoolscfg/tmp/serverblock_" .$args["repo_name"] ,$blocktemplate);

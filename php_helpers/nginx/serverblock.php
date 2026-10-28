<?php
include(getenv('HOME') . "/bashtools/php_helpers/bash/_phpbashclientincludes.php");
$template = file_get_contents(getenv('HOME') . "/bashtools/templates/nginx/domainsetup/nginxblock");

echo "PHP_DD_VERSION:";
echo "\n";
echo $PHP_DD_VERSION;
echo "\n";
echo "\n";
$template = str_replace("<PHP_DIR_VERSION />", $PHP_DD_VERSION, $template);

echo "APP_URL:";
echo "\n";
echo $APP_URL;
echo "\n";
echo "\n";
$template = str_replace("<app_url />", $APP_URL, $template);

echo "WWW_ROOT:";
echo "\n";
echo $wwwroot;
echo "\n";
echo "\n";
$template = str_replace("<wwwroot />", $wwwroot, $template);

echo "REPO_NAME:";
echo "\n";
echo $repo_name;
echo "\n";
echo "\n";
$template = str_replace("<repo_name />", $repo_name, $template);

if ($sslcertificate != "selfsigned") {//real certificate
      $sslcertificate = "registered";
      $certs =
	  "ssl_certificate /var/www/certs/" . $repo_name . "/" . $repo_name . "_chain.crt;" . PHP_EOL .
	  "	ssl_certificate_key /var/www/certs/" . $repo_name . "/" . $repo_name . ".key;" . PHP_EOL .
	  "	ssl_stapling on;" . PHP_EOL .
	  "	ssl_stapling_verify on;";
}
else {//self signed certificate
      $certs =
	  "include snippets/self-signed.conf;" . PHP_EOL .
	  "	include snippets/ssl-params.conf;" . PHP_EOL .
	  "	ssl_stapling off;" . PHP_EOL .
	  "	ssl_stapling_verify off;";
}

echo "CERTS:";
echo "\n";
echo $certs;
echo "\n";
echo "\n";
$template = str_replace("<ssl_cert_type />", $sslcertificate, $template);
$template = str_replace("<ssl_certs />", $certs, $template);

echo "\n";
echo "\n";

$filename = "/etc/nginx/sites-enabled/" . $args["repo_name"];
echo "RESULT for " . $filename . ":";
echo "\n";
echo $template;
echo "\n";
echo "\n";


/*
parse_str(implode('&', array_slice($argv, 1)), $args);

if ($args["APP_URL"]) {
      $app_url = $args["APP_URL"];
}
else {
      if (isset($repo_env["APP_URL"])) {
	    $app_url = $repo_env["APP_URL"];
      }
      else {
	    $app_url = $args["repo_name"] . "." . $serverid . ".com";
      }
}

$template = str_replace("<app_url />", $app_url, $template);
$template = str_replace("<repo_name />", $args["repo_name"], $template);

$template = str_replace("<wwwroot />", $wwwroot, $template);

$template = str_replace("<ssl_certs />", $certs, $template);

//x20260203$dec1 = strpos($PHP_VERSION, '.');
//x20260203$$dec2 = strpos($PHP_VERSION, '.', $dec1 + 1);
//x20260203$$fpmlocation = "/run/php/";
//x20260203$$fpmversion = substr($PHP_VERSION, 0, $dec2);
//x20260203$$fpmsockfile = $fpmlocation . "php" . $fpmversion . "-fpm.sock";
$template = str_replace("<PHP_DIR_VERSION />", $PHP_DIR_VERSION, $template);
//var_dump($template);
$filename = "/etc/nginx/sites-enabled/" . $args["repo_name"];

file_put_contents($filename, $template);
*/
<?php
include(getenv('HOME') . "/bashtools/php_helpers/bash/bash.env.php");
$jsonpath = $wwwroot . "/html/" . $www_repofocus . "/composer.json";

$json = json_decode(file_get_contents($jsonpath), true);

$includes=[
    "app/DD_laravelAp/Helpers/php_extend/php_extend.php",
    "app/DD_laravelAp/Helpers/php_extend/array_extend.php",
    "app/DD_laravelAp/Helpers/php_extend/string_extend.php",
    ];



if(!array_key_exists("files",$json['autoload'])){
      $json['autoload']['files']=[];
}
foreach ($includes as $path) {
      if(!in_array($path,$json['autoload']['files'])) {
	    array_push($json['autoload']['files'], $path);
      }
}
$json=json_encode($json, JSON_UNESCAPED_SLASHES | JSON_PRETTY_PRINT);
file_put_contents($jsonpath, $json);
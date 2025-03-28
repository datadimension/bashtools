<?php
include(getenv('HOME') . "/bashtools/php_helpers/bash/repoenvfiletoarray.php");
if (!isset($args["reponame"])) {
      die("no repo name specified in setreponame.php" . PHP_EOL);
}
if ($args["key"] == "GIT_SYNC_TIMESTAMP") {
      $repo_env["GIT_SYNC_TIMESTAMP"] = date("YmdHis");
}
$envfile = "";
foreach ($repo_env as $key => $value) {
      if (substr($key, 0, 1) != "#") {
	    $envfile .= $key . "=" . $value . PHP_EOL;
      }
      else {
	    $envfile .= "#------------------------------------------" . PHP_EOL . PHP_EOL;
	    $envfile .= $key . PHP_EOL . PHP_EOL;
      }
}
echo $envfile;
$envfilepath = "$wwwroot/html/$www_repofocus/.env";
echo $envfilepath;
file_put_contents($envfilepath, $envfile);

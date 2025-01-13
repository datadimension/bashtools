<?php
include(getenv('HOME') . "/bashtools/php_helpers/bash/bash.env.php");
include("php_cli.php");
echo "Server Environment: " . $environment . "\n";
echo "Enter production / dev: ";
$input = getinput();
echo $input;
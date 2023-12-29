<?php
/**
 * used by shel script bash-help
 */
include(getenv('HOME') . "/bashtools/php_bash/bash.env.php");
parse_str(implode('&', array_slice($argv, 1)), $args);

$home = getenv('HOME');
echo "\033[1mBASH helper functions for " . $args["helptype"] . ":\033[0m\n\n";

$bashprof = file_get_contents($home . "/bashtools/bash_modules/" . $args["helptype"] . "-.sh");

$lines = explode("\n", $bashprof);//split inc bracket as never argmuents https://stackoverflow.com/questions/4654700/what-are-the-parentheses-used-for-in-a-bash-shell-script-function-definition-lik#:~:text=The%20keyword-,function,-has%20been%20deprecated
$prevline = "";
$output = [];
foreach ($lines as $i => $line) {
      $line = trim($line);
      $comment = "";
      if (substr($prevline, 0, 1) == "#") {
	    $comment = " \t\t" . trim(substr($prevline, 1));
      }
      $prevline = $line;
      if (substr($line, 0, 9) == "function ") {
	    $funcname = substr($line, 9, strpos($line, "(") - 9);
	    if (strlen($funcname) < 7) {
		  $comment = "\t" . $comment;
	    }
	    $output[$funcname] = $funcname . $comment;
	    //echo $funcname . $comment;
	    //echo "\n";
      }
}

ksort($output);
foreach ($output as $line) {
      echo $line;
      echo "\n";
}
echo "\n";
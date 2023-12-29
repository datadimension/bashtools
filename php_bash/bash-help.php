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
foreach ($lines as $i => $line) {
      $line = trim($line);
      $comment = "";
      if (substr($prevline, 0, 1) == "#") {
	    $comment = " \t\t" . trim(substr($prevline, 1));
      }
      $prevline = $line;
      if (substr($line, 0, 9) == "function ") {
	    $funcname = substr($line, 9, strpos($line, "(") - 9);
	    echo $funcname . $comment;
	    echo "\n";
      }
}
echo "\n";

/*20231229
$functions = explode("function(", $bashprof);//split inc bracket as never argmuents https://stackoverflow.com/questions/4654700/what-are-the-parentheses-used-for-in-a-bash-shell-script-function-definition-lik#:~:text=The%20keyword-,function,-has%20been%20deprecated
$funclist = [];
foreach ($functions as $row => $f) {
      $funcname = trim(substr($f, 0, strpos($f, ")")));
      $funcname .= " len " . strlen($funcname);
      if ($row > 0) {
	    $comment = $functions[$row - 1];
	    $commentindex = strrpos($comment, PHP_EOL, -2);
	    $comment = trim(substr($comment, $commentindex + 1));
	    if (substr($comment, 0, 1) == "#") {
		  $comment = substr($comment, 0);
		  $funcname .= "  " . $comment;
	    }
      }
      if ($funcname) {
	    array_push($funclist, $funcname);
      }
}
sort($funclist);
$curprefix = "";
$fcount = 0;
foreach ($funclist as $f) {
      $prefix = substr($f, 0, strpos($f, "-"));
      if ($prefix != $curprefix) {
	    $curprefix = $prefix;
	    $sep = "\n";
	    $fcount = 0;
      }
      else {
	    $sep = "\n";
      }
      $fcount++;
      if ($fcount >= 5) {
	    $sep = "\n";
	    $fcount = 0;
      }
      echo $sep;
      echo $f;
}
echo "\n\n";
*/
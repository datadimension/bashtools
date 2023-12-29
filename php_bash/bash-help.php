<?php
/**
 * used by shel script bash-help
 */
include(getenv('HOME') . "/bashtools/php_bash/bash.env.php");
parse_str(implode('&', array_slice($argv, 1)), $args);

$home = getenv('HOME');
#$bashprof = file_get_contents($home . "/.bash_profile");

$bashprof = file_get_contents($home . "/bashtools/bash_modules/" . $args["helptype"] . "-.sh");
$functions = explode("function ", $bashprof);
$funclist = [];
echo "\nBASH helper functions for " . $args["helptype"] . ":\n";
foreach ($functions as $row => $f) {
      $funcname = substr($f, 0, strpos($f, "("));
      if ($row > 0) {
	    $comment = $functions[$row - 1];
	    $commentindex = strrpos($comment, PHP_EOL, -2);
	    $comment = substr($comment, $commentindex);
//	    $funcname .= "  -  " . $commentindex . " " . $comment;

	    if (substr($comment, 0, 1) != "") {
		  $comment = substr($comment, 0, 10);
		  $funcname .= "  -  |" . $comment . "|";
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

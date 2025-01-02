<?php
/**
 * used by shel script bash-help
 * test:
 * php ~/bashtools/php_helpers/bash/bash-help.php helptype=www
 */
include(getenv('HOME') . "/bashtools/php_helpers/bash/bash.env.php");;
parse_str(implode('&', array_slice($argv, 1)), $args);
$home = getenv('HOME');
echo "\033[1mBASH helper functions for " . $args["helptype"] . ":\033[0m\n\n";

$bashprof = file_get_contents($home . "/bashtools/bash_modules/" . $args["helptype"] . "-.sh");

$lines = explode("\n", $bashprof);//split inc bracket as never argmuents https://stackoverflow.com/questions/4654700/what-are-the-parentheses-used-for-in-a-bash-shell-script-function-definition-lik#:~:text=The%20keyword-,function,-has%20been%20deprecated
$output = [];
foreach ($lines as $i => $line) {
      $line = trim($line);
      if (substr($line, 0, 9) == "function ") {
	    $comments = [];
	    $lineoffset = -1;
	    while ($i + $lineoffset > 0) {
		  //$comment = trim(substr($lines[$i - $lineoffset], 1));
		  // echo $lines[$i + $lineoffset] . "\n";
		  $comment = trim(substr($lines[$i + $lineoffset], 0));
		  if (substr($comment, 0, 1) == "#") {
			$comment = trim(substr($lines[$i + $lineoffset], 1));
			array_unshift($comments, $comment);
		  }
		  else {
			break;
		  }
		  $lineoffset--;
	    }
	    $funcname = substr($line, 9, strpos($line, "(") - 9);
	    $tabs = "\t\t\t\t\t\t\t";
	    $tabcount = ceil((24 - strlen($funcname)) / 4);
	    $tab = substr($tabs, 0, $tabcount);//not tabcount times 2 as the '\t' is a control character representing 1 char
	    $output[$funcname] = [
		"comments" => $comments,
		"tabline1" => "\t" . $tab . "- "
	    ];
      }
}

ksort($output);
foreach ($output as $funcname => $line) {
      echo $funcname;
      $tab = $line["tabline1"];
      if (count($line["comments"]) > 0) {
	    foreach ($line["comments"] as $comment) {
		  echo $tab . $comment;
		  echo "\n";
		  $tab = $tabs . "  ";
	    }
      }
      else {
	    echo "\n";
      }
      //echo $funcname . "\t" . $line;
}
echo "\n";
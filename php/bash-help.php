<?php

$home = getenv('HOME');
$bashprof = file_get_contents($home . "/.bash_profile");
$functions = explode("function ", $bashprof);
$funclist = [];
echo "\nBASH helper functions:\n";
foreach ($functions as $f) {
      array_push($funclist, substr($f, 0, strpos($f, "(")));
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
	    $sep = " ";
      }
      $fcount++;
      if ($fcount >= 5) {
	    $sep = "\n";
	    $fcount = 0;
      }
      echo $sep;
      echo $f;
}
echo "\n";

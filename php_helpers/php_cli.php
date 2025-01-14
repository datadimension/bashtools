<?php
function getinput($prompt, $default) {
      if ($default) {
	    $prompt .= " [default: " . $default . "] ";
      }
      echo $prompt . ": ";
      $fin = fopen("php://stdin", "r");
      $line = fgets($fin);
      if ($line == PHP_EOL) {
	    $line = "";
      }
      if ($line == "") {
	    $line = $default;
	    if ($default) {
		  echo "default used ---> : " . $default . PHP_EOL;
	    }
      }
      return $line;
}

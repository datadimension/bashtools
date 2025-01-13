<?php
function getinput() {
      $fin = fopen("php://stdin", "r");
      $line = fgets($fin);
      return $line;
}

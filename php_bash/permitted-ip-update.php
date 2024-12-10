<?php

$log=file_get_contents("/var/log/auth.log");

exec ("sudo awk '/Accepted publickey/ {print $6,$7,$8,$9,$10,$11,$12,$13,\"at\",$3,\"on\",$1,$2}' /var/log/auth.log | sudo tee -a /var/www/security/ssh_ips.log
");
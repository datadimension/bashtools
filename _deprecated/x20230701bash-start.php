<?php
$home = getenv('HOME');
$cfgpath=$home . "/.bash_cfg";
//echo "cfgpath: ".$cfgpath;
echo "";
$bashprof = file_get_contents($cfgpath);
$hosts = file_get_contents("/etc/resolv.conf");

$gateway=substr($hosts,strpos($hosts,"nameserver ")+11);
$gateway=str_replace("\n","",$gateway);

$bashprof=explode(",",$bashprof);
$bashprof[9]=$gateway;
$phpNo=$bashprof[8];

$phpinipath="/etc/php/".$phpNo."/fpm/php.ini";
$phpini = file_get_contents($phpinipath);

$editindexstart=strpos($phpini,"xdebug.client_host");
$editindexend=strpos($phpini,"\n",$editindexstart);

$updatedini=substr($phpini,0,$editindexstart);
$updatedini.="xdebug.client_host = ".$gateway;
$updatedini.=substr($phpini,$editindexend);

//var_dump($bashprof);
//echo $updatedini;
#echo substr($phpini,$editindexstart,$editindexend-$editindexstart);

$bashprof=implode(",",$bashprof);
file_put_contents($cfgpath,$bashprof);
file_put_contents($phpinipath,$updatedini);

<?php
include(getenv('HOME') . "/bashtools/php_helpers/bash/repoenvfiletoarray.php");
$view =
    "
CREATE 
    ALGORITHM = UNDEFINED 
    DEFINER = `" . $args["app_schema"] . "_php`@`%`
    SQL SECURITY INVOKER
VIEW `_domainmedia` AS
    SELECT 
        `ddDB`.`_libmedia`.`pk` AS `pk`,
        `ddDB`.`_libmedia`.`name` AS `name`,
        `ddDB`.`_libmedia`.`type` AS `type`,
        `ddDB`.`_libmedia`.`source_dir` AS `source_dir`,
        `ddDB`.`_libmedia`.`server_uri` AS `server_uri`,
        `ddDB`.`_libmedia`.`UUID` AS `UUID`,
        `ddDB`.`_libmedia`.`parentUUID` AS `parentUUID`
    FROM
        `ddDB`.`_libmedia` 
    UNION SELECT 
        `_libmedia`.`pk` AS `pk`,
        `_libmedia`.`name` AS `name`,
        `_libmedia`.`type` AS `type`,
        `_libmedia`.`source_dir` AS `source_dir`,
        `_libmedia`.`server_uri` AS `server_uri`,
        `_libmedia`.`source_uri` AS `source_uri`,
        `_libmedia`.`UUID` AS `UUID`,
        `_libmedia`.`parentUUID` AS `parentUUID`
    FROM
        `_libmedia`;
";

echo "\n";
//$view = str_replace("<viewdefiner />", $args["app_schema"], $view);
$view = str_replace("\n", " ", $view);
$view = str_replace("\r", "  ", $view);
$view = str_replace("\t", "  ", $view);
$view = preg_replace('!\s+!', ' ', $view);
$view = trim($view);
echo "use " . $args["app_schema"] . ";\n";
echo $view;
echo "\n";

<?php
include(getenv('HOME') . "/bashtools/php_helpers/bash/repoenvfiletoarray.php");
$view =
    "
CREATE 
    ALGORITHM = UNDEFINED 
    DEFINER = `" . $args["app_schema"] . "_php`@`%`
    SQL SECURITY INVOKER
VIEW `_domain_icons` AS
    SELECT 
        `ddDB`.`_iconsource`.`pk` AS `pk`,
        `ddDB`.`_iconsource`.`name` AS `name`,
        `ddDB`.`_iconsource`.`type` AS `type`,
        `ddDB`.`_iconsource`.`source_path` AS `source_path`,
        `ddDB`.`_iconsource`.`source_dir` AS `source_dir`,
        `ddDB`.`_iconsource`.`pref_filter_order_1` AS `pref_filter_order_1`,
        `ddDB`.`_iconsource`.`pref_filter_order_2` AS `pref_filter_order_2`,
        `ddDB`.`_iconsource`.`pref_filter_order_3` AS `pref_filter_order_3`,
        `ddDB`.`_iconsource`.`server_uri` AS `server_uri`,
        `ddDB`.`_iconsource`.`source_uri` AS `source_uri`,
        `ddDB`.`_iconsource`.`UUID` AS `UUID`,
        `ddDB`.`_iconsource`.`parentUUID` AS `parentUUID`
    FROM
        `ddDB`.`_iconsource` 
    UNION SELECT 
        `_iconsource`.`pk` AS `pk`,
        `_iconsource`.`name` AS `name`,
        `_iconsource`.`type` AS `type`,
        `_iconsource`.`source_path` AS `source_path`,
        `_iconsource`.`source_dir` AS `source_dir`,
        `_iconsource`.`pref_filter_order_1` AS `pref_filter_order_1`,
        `_iconsource`.`pref_filter_order_2` AS `pref_filter_order_2`,
        `_iconsource`.`pref_filter_order_3` AS `pref_filter_order_3`,
        `_iconsource`.`server_uri` AS `server_uri`,
        `_iconsource`.`source_uri` AS `source_uri`,
        `_iconsource`.`UUID` AS `UUID`,
        `_iconsource`.`parentUUID` AS `parentUUID`
    FROM
        `_iconsource`
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

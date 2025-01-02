<?php
include(getenv('HOME') . "/bashtools/php_helpers/bash/bash.env.php");

$view=
"    			CREATE
              ALGORITHM = UNDEFINED
              DEFINER = `<viewdefiner />_php`@`%`
              SQL SECURITY DEFINER
          VIEW `_domainwidgets` AS
              SELECT
                  `ddDB`.`_widgets`.`pk` AS `pk`,
                  `ddDB`.`_widgets`.`name` AS `name`,
                  `ddDB`.`_widgets`.`parentgroup` AS `parentgroup`,
                  `ddDB`.`_widgets`.`parentview` AS `parentview`,
                  `ddDB`.`_widgets`.`label_1` AS `label_1`,
                  `ddDB`.`_widgets`.`label_2` AS `label_2`,
                  `ddDB`.`_widgets`.`labelinfo` AS `labelinfo`,
                  `ddDB`.`_widgets`.`tooltip` AS `tooltip`,
                  `ddDB`.`_widgets`.`type` AS `type`,
                  `ddDB`.`_widgets`.`placement` AS `placement`,
                  `ddDB`.`_widgets`.`preaction` AS `preaction`,
                  `ddDB`.`_widgets`.`changeaction` AS `changeaction`,
                  `ddDB`.`_widgets`.`action` AS `action`,
                  `ddDB`.`_widgets`.`attributes` AS `attributes`,
                  `ddDB`.`_widgets`.`postaction` AS `postaction`,
                  `ddDB`.`_widgets`.`value` AS `value`,
                  `ddDB`.`_widgets`.`isActive` AS `isActive`,
                  `ddDB`.`_widgets`.`isDisabled` AS `isDisabled`,
                  `ddDB`.`_widgets`.`isDev` AS `isDev`,
                  `ddDB`.`_widgets`.`widgetclass` AS `widgetclass`,
                  `ddDB`.`_widgets`.`showlabel` AS `showlabel`,
                  `ddDB`.`_widgets`.`grouporder` AS `grouporder`,
                  `ddDB`.`_widgets`.`icon` AS `icon`,
                  `ddDB`.`_widgets`.`user_fk` AS `user_fk`,
                  `ddDB`.`_widgets`.`UUID` AS `UUID`,
                  `ddDB`.`_widgets`.`constraint` AS `constraint`,
                  `ddDB`.`_widgets`.`target` AS `target`
              FROM
                  `ddDB`.`_widgets`
              UNION ALL SELECT
                  `_widgets`.`pk` AS `pk`,
                  `_widgets`.`name` AS `name`,
                  `_widgets`.`parentgroup` AS `parentgroup`,
                  `_widgets`.`parentview` AS `parentview`,
                  `_widgets`.`label_1` AS `label_1`,
                  `_widgets`.`label_2` AS `label_2`,
                  `_widgets`.`labelinfo` AS `labelinfo`,
                  `_widgets`.`tooltip` AS `tooltip`,
                  `_widgets`.`type` AS `type`,
                  `_widgets`.`placement` AS `placement`,
                  `_widgets`.`preaction` AS `preaction`,
                  `_widgets`.`changeaction` AS `changeaction`,
                  `_widgets`.`action` AS `action`,
                  `_widgets`.`attributes` AS `attributes`,
                  `_widgets`.`postaction` AS `postaction`,
                  `_widgets`.`value` AS `value`,
                  `_widgets`.`isActive` AS `isActive`,
                  `_widgets`.`isDisabled` AS `isDisabled`,
                  `_widgets`.`isDev` AS `isDev`,
                  `_widgets`.`widgetclass` AS `widgetclass`,
                  `_widgets`.`showlabel` AS `showlabel`,
                  `_widgets`.`grouporder` AS `grouporder`,
                  `_widgets`.`icon` AS `icon`,
                  `_widgets`.`user_fk` AS `user_fk`,
                  `_widgets`.`UUID` AS `UUID`,
                  `_widgets`.`constraint` AS `constraint`,
                  `_widgets`.`target` AS `target`
              FROM
                  `_widgets`
";

echo "\n";
$view = str_replace("<viewdefiner />", $www_repofocus, $view);
echo $view;
echo "\n";

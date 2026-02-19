<?php

namespace App\BizClasses;

use App\DD_laravelAp\BizClasses;

class WidgetHandler extends BizClasses\BaseWidgetHandler {

      public static function widget_update($widget_UUID, $updater) {
	    parent:: widget_update($widget_UUID, $updater);//remove to override
      }
}
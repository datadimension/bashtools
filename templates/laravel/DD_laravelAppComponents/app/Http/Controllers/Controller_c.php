<?php

namespace App\Http\Controllers;

use App\DD_laravelAp\Controllers\BaseController_c;
use App\DD_laravelAp\Helpers\CacheHandler;
use App\DD_laravelAp\Helpers\DataB;
use Illuminate\Support\Facades\Cache;

class Controller_c extends BaseController_c {
      protected function __subconstruct() {
	    $noop = 1;
      }

      protected function start() {
	    $this->_postconstruct();
      }

}

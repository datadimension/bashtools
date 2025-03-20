<?php


namespace app\Http\Controllers;

use App\DD_laravelAp\Helpers\DataB;

class Monitor_c extends Controller_c {

      public function start() {
	    $this->viewdata ["monitorpages"] = DataB::select("datadimension._monitor", "*", ["isActive" => 1]);
	    return $this->showView("monitor_v");
      }
}

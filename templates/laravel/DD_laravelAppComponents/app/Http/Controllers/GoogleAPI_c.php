<?php

namespace App\Http\Controllers;

use App\DD_laravelAp\Controllers\API\google\BaseGoogleAPI_c;
use App\DD_laravelAp\Helpers\DataB;


/**
 * local class that inherits base api functionality from BaseGoogleAPI_c
 * class is initiated with a user id from Laravel _users table in parent class
 */
class GoogleAPI_c extends BaseGoogleAPI_c {
      /**
       * this is designed to be overriden by child class, but as we use intermediate controller class for some GoogleAPI routes, such as getting
       * a log in its not possible to have this as abstract
       * @return mixed|void
       */
      protected function __subconstruct() {
      }

      protected function set_server_user_id($userid = null) {
	    $userid = DataB::selectSingleValue("_appsettings", "value", ["type" => "g_server_user_id"]);
	    $this->server_user_id = $userid;
      }

}
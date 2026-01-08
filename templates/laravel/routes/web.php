<?php

require(app_path("DD_laravelAp/Framework/php/web.php"));

use Illuminate\Support\Facades\Route;
use App\Http\Controllers as Controllers;

/*
 *
 * the site is current using a template setup, when the site is set up with database access, remove all but this
 require(app_path("DD_laravelAp/Framework/php/web.php"));
 */

Route::any('/servertest', function () {
      return view('DD_laraview.servertest');
});


<?php

namespace app\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class Home_c extends Controller_c {
    /**
     * Create a new controller instance.
     *
     * @return void
     */
    public function __subconstruct() {
        $this->middleware('auth');
    }

    public function start() {
        return $this->showView('home');
    }
}

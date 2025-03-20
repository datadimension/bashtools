<?php

namespace app\Http\Controllers;

use App\DD_laravelAp\Controllers\BaseController_AjaxForm;
use App\DD_laravelAp\Helpers\DataB;
use App\DD_laravelAp\Helpers\File_Ops;
use App\DD_laravelAp\Models\DateTime_m;
use Cache;
use phpseclib3\Net\SSH2;

@session_start();

class AjaxForm_c extends BaseController_AjaxForm {
      private $wwwroot="/var/www/html";
      protected function createsite(){
	    $path=$this->wwwroot."/".$this->ajaxform["fields"]["rooturl"];
	    //debug
	    $path="/var/www/html/serveradmin.com";
	    if(!File_Ops::exists($path)) {
		  File_Ops::createDir($path);
	    }
	    /*run this

	    echo "# serveradmin" >> README.md
git init
git add README.md
git commit -m "first commit"
git branch -M main
git remote add origin git@github.com:datadimension/serveradmin.git
git push -u origin main

	    */
      }
}

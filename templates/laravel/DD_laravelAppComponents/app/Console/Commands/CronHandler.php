<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use Illuminate\Support\Facades\Http;

//https://medium.com/@techsolutionstuff/laravel-11-cron-job-task-scheduling-example-b58da7687b38
class CronHandler extends Command
{
      /**
       * The name and signature of the console command.
       *
       * @var string
       */
      protected $signature = 'CronHandler:cron';

      /**
       * The console command description.
       *
       * @var string
       */
      protected $description = 'Command description';

      /**
       * Execute the console command.
       */
      public function handle()
      {
	    info("Cron Job running at ". now());
	    try {
		  $response = Http::get('https://sc.liveinfo247.com/cron');
	    } catch (\Exception $ex) {
		  $response=$ex;
	    }
	    var_dump($response);
      }
}

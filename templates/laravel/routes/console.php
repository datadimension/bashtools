<?php

use Illuminate\Support\Facades\Schedule;

//Schedule::command('CronHandler:cron')->everySecond();
Schedule::command('CronHandler:cron')->everyMinute();
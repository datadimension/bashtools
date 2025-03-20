<?php

namespace app\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Symfony\Component\HttpFoundation\Response;

class AccessLevel {
      /**
       * Handle an incoming request.
       *
       * @param \Closure(\Illuminate\Http\Request): (\Symfony\Component\HttpFoundation\Response) $next
       */
      public function handle(Request $request, Closure $next, $level): Response {
	    if (Auth::user() && Auth::user()->role == $level) {
		  return $next($request);
	    }
	    return redirect('/error/403/Forbidden');
      }
}

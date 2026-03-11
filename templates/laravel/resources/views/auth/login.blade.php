@extends('DD_laraview.authentication.BaseLogin')
@section('sub_pagehead')
	<style>
	  html, body {
		background-color: #000000;
		color: #ffffff;
	  }

	  subpagehead {
	  }
	</style>
@endsection
@section("sitelogo")
	<img class='loginlogo' src="{{Cache('appsettings')['site_image_login_icon']['value']}}"/><br/>
@endsection
@section("sitename")
@endsection
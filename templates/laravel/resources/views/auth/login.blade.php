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
	<img class='loginlogo' src="{{Cache('appconfig')['UI']['login_icon']}}"/><br/>
@endsection
@section("sitename")
@endsection
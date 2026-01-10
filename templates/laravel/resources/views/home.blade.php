@php
	$required_apis="gmaps";
@endphp
@extends('DD_laraview.layouts.5section')
@section('title',Config::get('app.name')." / Home")

@section('page_head')
	<!--extend MVC for this blade -->
	<script src="/js/sitepagescript.js{{Cache("cacheversion")}}"></script>
	<script src="/js/Ctrl.js{{Cache("cacheversion")}}"></script>
@endsection

@section('body-pre')
	<div id="logoframe">
		<a href="/" target="_blank">
			<img class='icon-5' src="/img/nav_sitelogo.jpg"/><br/>
		</a>
		{{Config::get('app.name')}}
	</div>
	<br/>
	<div id="groupselect" style="border-bottom:1px solid #000000" class="combobuttonpanel"></div>
	<div id="dashboard" class="combobuttonpanel"></div>
	<br/>
@endsection

@section('body-aft')
	testing
@endsection

@section('footer')
@endsection

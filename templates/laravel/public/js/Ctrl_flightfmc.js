class Controller extends BaseJS_Ctrl {
      __subconstruct() {
	    this.departICAO = getCookie("fmc_departICAO", 'EGLL');
	    //20240517 this.departairport = airports[this.departICAO];
	    this.arriveICAO = getCookie("fmc_arriveICAO", 'EGLL');
	    this.standbyflightplan = null;
	    this.departHTMLid = null;
	    this.arriveHTMLid = null;
	    GMap.createMap("flightmap", "mapframe", {mapType: "terrain", "createCallback": "ctrl.mapCreated", "mapChangeCallback": "ctrl.mapChangeEvent"});
      }

      start() {
	    this.ajaxclient.setAjaxRoute("ajaxflightfmc");
	   // alert({title: "WARNING", content: "For Flight Sim apps only DO NOT USE FOR REAL WORLD FLIGHT OPS", timeout: 1});
      }

      /* SETUP VALS */
      selectinit_depart(args) {
	    if (!this.departHTMLid) {
		  this.departHTMLid = args.tagid;
	    }
	    view.formhandler.selectPicker_setoptions_array(this.departHTMLid, airports, {
		  selected: this.departICAO, optionkeys_seperator: " - ",
		  optionkeys: ["ICAO", "NAME"],
	    });
      }

      init_minrwy(eventobj) {
	    let minrwy = _usersettings.flightfmc.minrwy;
	    view.formhandler.selectPicker_setoptions_array(eventobj.tagid, eventobj.value, {selected: minrwy});
      }

      selectinit_arrive(args) {
	    if (!this.arriveHTMLid) {
		  this.arriveHTMLid = args.tagid;
	    }
	    view.formhandler.selectPicker_setoptions_array(this.arriveHTMLid, airports, {
		  selected: this.arriveICAO, optionkeys_seperator: " - ",
		  optionkeys: ["ICAO", "NAME"],
	    });
      }

      /* END SETUP VALS */

      ICAO_markerclick(markerdata) {
	    this.getAirportData(markerdata.ICAO);
	    this.sideview_setView("airportData", "AIRPORT INSPECT");
      }

      sideview_setView(view, title = "") {
	    $("#sideviewtitle").html(title);
	    this.hideSideViewSections();
	    switch (view) {
		  case "airportData":
			$("#airportData").show();
			break;
		  case "mapctrl":
			this.sideview_showFlightPlan();
			this.hideSideViewSections();
			$("#mapctrl").show();
			break;
		  case "flightPlan":
			$("#sideviewtitle").html("FLIGHT PLAN");
			$("#flightPlan").show();
			break;
	    }

      }

      hideSideViewSections() {
	    $("#airportData").hide();
	    $("#flightPlan").hide();
	    $("#mapctrl").hide();
      }

      sideview_showDeparture() {
	    this.getAirportData(this.departICAO);
	    this.sideview_setView("airportData", "DEPARTURE");
      }

      flightMapMarkerICAO_setArrival(data) {
	    this.ICAO_setArrival(data.ICAO);
	    this.sideview_showFlightPlan();
	    let noop = 1;
      }

      sideview_showArrival() {
	    this.getAirportData(this.arriveICAO);
	    this.sideview_setView("airportData", "ARRIVAL");
	    $("#sideviewtitle").html("ARRIVAL");
      }

      sideview_showFlightPlan() {
	    this.sideview_setView("flightPlan", "FLIGHT PLAN");
	    GMap.clearPolylines();
	    GMap.drawPolyLine([
		      {
			    location: {lat: airports[this.departICAO].lat, lng: airports[this.departICAO].lng},
		      },
		      {
			    location: {lat: airports[this.arriveICAO].lat, lng: airports[this.arriveICAO].lng},
			    style: {
				  color: '#DB25D3', weight: 3,
			    },
		      },
		],
		{zIndex_current: 1000},
	    );
	    GMap.set_zoomBounds(
		{lat: airports[this.departICAO].lat, lng: airports[this.departICAO].lng},
		{lat: airports[this.arriveICAO].lat, lng: airports[this.arriveICAO].lng},
	    );
      }

      getMapMarkerAirportData(mapdata) {
	    this.sideview_setView("airportData");
	    this.getAirportData(mapdata);
      }

      getAirportData(airportdata) {
	    let ICAO;
	    if (typeof airportdata == "string") {
		  ICAO = airportdata;
	    }
	    else {
		  ICAO = airportdata.ICAO;
	    }
	    this.ajaxclient.ajax("getAirportData", {"ICAO": ICAO}, "ctrl.display_airport", {msg: "getting airport info", ajaxRoute: "ajaxflightfmc"});
      }

      /**
       *  get the airport data from given ICAO
       * @param ICAO
       * @returns {*}
       */
      getAirportByICAO(ICAO) {
	    return airports[ICAO];
      }

      mapCreated(args) {
	    $("#sidesections").removeClass("invisible");
	    this.sideview_setView("flightPlan");
	    this.sideview_showFlightPlan();
	    this.ICAO_showinrange();
      }

      mapChangeEvent(mapdata) {
	    this.ICAO_showinrange();
      }

      ICAO_showinrange(ajaxresponse) {
	    if (!ajaxresponse) {
		  let zoombounds = GMap.get_zoomBounds();
		  this.ajaxclient.ajax("getICAOInRange", {"range": zoombounds, "minrwy": _usersettings.flightfmc["minrwy"], "departICAO": this.departICAO, "arriveICAO": this.arriveICAO, "rwy_challenge": _usersettings.flightfmc["rwy_challenge"]}, "ctrl.ICAO_showinrange",
		      {
			    ajaxRoute: "ajaxflightfmc", silent: true,
		      });
	    }
	    else {
		  let ICAOs = ajaxresponse.data.inrange_ICAOs.split(",");
		  if (ICAOs.length == 0 || ICAOs[0] == "") {//kill empty array
			ICAOs = null;
		  }
		  for (let i in ICAOs) {
			let icao = ICAOs[i];
			let airport = airports[icao];
			let markeroptionswindow = {
			      title: airport.NAME + " Airport [" + icao + "]",
			      openzoom: false,
			      widgetgroup: 'fc6641c5-33e1-11ef-a265-fa163e4337e0',
			};
			let marker = {
			      UUID: icao,
			      location: {lat: airport.lat, lng: airport.lng},
			      icon: "https://mediastore247.com/DD_libmedia/iconpacks/datadimension/maps/airplane.png",
			      infowindow: markeroptionswindow,
			      onclick: 'ctrl.ICAO_markerclick',
			      attached_data: {ICAO: icao, location_name: airport.NAME + " Airport"},
			};
			if (icao == this.departICAO) {
			      marker.icon_backgroundColor = "#00ff00";
			      marker.zIndex = 100;
			}
			if (icao == this.arriveICAO) {
			      marker.icon_backgroundColor = "#ff0000";
			      marker.zIndex = 100;
			}
			if (airport.exceptions == "warning") {
			      marker.icon_backgroundColor = "#FF7300FF";
			      marker.zIndex = 100;
			}
			GMap.marker_set(marker);
		  }
	    }
      }

      flight_filterchanged(serverdata) {
	    GMap.clearMarkers();
	    this.ICAO_showinrange();
      }

      display_airport(serverdata) {//used after get airpot info
	    //this.sideview_setView("airportData");
	    let ICAO = serverdata.data.ICAO;
	    let metarstring = serverdata.data.metar;
	    // metarstring =
	    //"EGLL 240950Z 34008KT 300V030 9999 SCT042 BKN049 09/M02 Q1017";
	    //   metarstring =
	    //"EGLC 240950Z AUTO 35009KT 300V050 9999 SCT043 09/M02 Q1017";
	    metarhandler.setmetar(metarstring);
	    $("#icaotitle").html(ICAO);
	    $("#dataMETAR").html(metarhandler.getVerbose());
	    let airport = airports[ICAO];
	    GMap.panTo({lat: airport.lat, lng: airport.lng});
	    $("#airportname").html(airport["NAME"]);
	    $("#airportelevation").html(airport["ELEVATION"]);
	    $("#airportatis").html(airport["atis"]);
	    let runwaydhtml = "<hr />";
	    for (let i in airport.runways) {
		  let rwy = airport.runways[i];
		  let id = rwy.BEZ;
		  let ils = "";
		  if (rwy.ILSFREQ != "0.000") {
			ils = "ILS: " + rwy.ILSFREQ + "<br />";
		  }
		  let bearing = rwy.grad;
		  let length = rwy.length;
		  let rwydhtml =
		      id +
		      " Bearing: " + bearing +
		      "<br />" +
		      ils +
		      "Length: " + length + " FT" +
		      "<br />" +
		      "<br />";
		  runwaydhtml += rwydhtml;
	    }
	    $("#dataRWY").html(runwaydhtml);
      }

      /**
       * used on selection chenge for departure
       * @param args
       */
      selected_airportdepart(args) {
	    this.ICAO_setDeparture(args.value);
	    this.sideview_showDeparture();
      }

      /** set the departure airport
       *
       * @param ICAO
       */
      ICAO_setDeparture(ICAO) {
	    this.departICAO = ICAO;
	    setCookie("fmc_departICAO", this.departICAO);
	    view.formhandler.selectPicker_setSelected(this.departHTMLid, this.departICAO);
      }

      /**
       * used on selection chenge for arrival
       * @param args
       */
      selected_airportarrive(args) {
	    this.ICAO_setArrival(args.value);
	    this.sideview_showArrival();
      }

      /** set the departure airport
       *
       * @param ICAO
       */
      ICAO_setArrival(ICAO) {
	    this.arriveICAO = ICAO;
	    setCookie("fmc_arriveICAO", this.arriveICAO);
	    view.formhandler.selectPicker_setSelected(this.arriveHTMLid, this.arriveICAO);
      }

      flightplan_save() {//used by flightplan form submit button
	    this.ajaxclient.ajax("fileFlightPlan", {"departICAO": this.departICAO, "arriveICAO": this.arriveICAO}, "ctrl.display_airport", {ajaxRoute: "ajaxflightfmc"});
      }

      selectinit_flightplans(args) {
	    let optionscfg = {options: []};
	    let i;
	    for (let i in flightplans) {
		  if (!this.standbyflightplan) {
			this.standbyflightplan = i;
		  }
		  let depart = this.getAirportByICAO(flightplans[i].departICAO);
		  let arrive = this.getAirportByICAO(flightplans[i].arriveICAO);
		  depart.NAME = depart.NAME.wordCapitalise();
		  arrive.NAME = arrive.NAME.wordCapitalise();
		  let label = depart.ICAO + " [" + depart.NAME + "] > " + arrive.ICAO + " [" + arrive.NAME + "]";

		  // let label = flightplans[i].departICAO + " > " + flightplans[i].arriveICAO;
		  optionscfg.options[i] = label;
	    }
	    view.formhandler.selectPicker_setoptions(args.tagid, optionscfg);
      }

      form_flightplanner(args) {
	    let depart = this.getAirportByICAO(this.departICAO);
	    let arrive = this.getAirportByICAO(this.arriveICAO);
	    depart.NAME = depart.NAME.wordCapitalise();
	    arrive.NAME = arrive.NAME.wordCapitalise();
	    let label = depart.ICAO + " [" + depart.NAME + "] > " + arrive.ICAO + " [" + arrive.NAME + "]";
	    let noop = 1;
	    $("#" + args.tagid).html("<div class='combowidget_txt '>Current Route:</div>" + label + "<br /><hr />");
      }

      setstandbyflightplan(selectionobj) {
	    this.standbyflightplan = selectionobj.value;
      }

      /**swap destination and arrival
       *
       */
      airportSwap() {
	    let tempArrive = this.arriveICAO;
	    this.ICAO_setArrival(this.departICAO);
	    this.ICAO_setDeparture(tempArrive);
	    this.sideview_showFlightPlan();
      }

      activateFLightPlan() {
	    let flightplan = flightplans[this.standbyflightplan];
	    this.ICAO_setDeparture(flightplan.departICAO);
	    this.sideview_showDeparture();
	    this.ICAO_setArrival(flightplan.arriveICAO);
	    this.ajaxclient.ajax("flightPlanUpdate", {"action": "flightPlanUsed", "UUID": flightplan.UUID}, '',
		{
		      ajaxRoute: "ajaxflightfmc", silent: true,
		});
      }

}

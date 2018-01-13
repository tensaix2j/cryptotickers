

function SimpleList() {

	//---------------
	this.get_exchange_rates = function() {

		var sl = this;
		this.loadJSON("/cryptotickers.json", function( obj ) {

			sl.exchange_rates = {}
			for ( i = 0 ; i < obj.data.length ; i++ ) {
				sl.exchange_rates[ obj.data[i].symbol ] = obj.data[i]; 
			}
	        sl.last_updated = obj.last_updated;

	        var profile = sl.get_querystring_value("profile") ;
	        var server  = sl.get_querystring_value("server");

	        if ( !server ) {
	        	server = "jsonblob";
	        }

	        if ( profile ) {
				

				sl.get_holdings(profile, server);
				// Render list at the callback of get_holdings

			} else { 
				sl.render_list();
			}

		}, function(xhr) {
			console.log("Error!");
	    });
	}

	//-----------
	// Get user's holding from profile
	this.get_holdings = function( profile_name , server ) {
		
		console.log( "get_holdings", profile_name , server );

		var useurl ;
		if ( server == "myjson" ) { 
			useurl = "https://api.myjson.com/bins/" + profile_name;
		} else if ( server == "jsonblob" ) {
			useurl = "https://jsonblob.com/api/jsonBlob/" + profile_name;
		} else if ( server == "local" ) {
			useurl = profile_name
		}

		var sl = this;


		sl.total_usd = 0.0;
		sl.total_sgd = 0.0;
		sl.total_btc = 0.0;
		sl.total_eth = 0.0;


		this.profile_name = profile_name;
		this.loadJSON(useurl, function( obj ) {
			for (curr in obj ) {
				if ( typeof sl.exchange_rates[curr] != "undefined" ) {
					sl_obj = sl.exchange_rates[curr];
					sl_obj.own = obj[curr];
					sl_obj.total_usd = sl_obj.own * sl_obj.usd;
					sl_obj.total_sgd = sl_obj.own * sl_obj.sgd;
					sl_obj.total_btc = sl_obj.own * sl_obj.btc;
					sl_obj.total_eth = sl_obj.own * sl_obj.eth;

					sl.total_usd += sl_obj.total_usd ;
					sl.total_sgd += sl_obj.total_sgd ;
					sl.total_btc += sl_obj.total_btc ;
					sl.total_eth += sl_obj.total_eth ;
						
				}
			}
			sl.render_list();
            	    	
	    }, function(xhr) {
	    	console.log("Error!");
	    });
	}




	//--------------------------
	this.loadJSON = function( path, success, error ) {
	    
	    var xhr = new XMLHttpRequest();
	    xhr.onreadystatechange = function() {
	        if (xhr.readyState === XMLHttpRequest.DONE) {
	            if (xhr.status === 200) {
	                if (success)
	                    success(JSON.parse(xhr.responseText));
	            } else {
	                if (error)
	                    error(xhr);
	            }
	        }
	    };
	    xhr.open("GET", path, true);
	    xhr.send();
	}


	//-------------
	this.get_querystring_value = function( name ) {

		var url = window.location.href;
		name = name.replace(/[\[\]]/g, "\\$&");
		var regex = new RegExp("[?&]" + name + "(=([^&#]*)|&|#|$)");
		results = regex.exec(url);
		if (!results) { 
			return null;
		}
		if (!results[2]) { 
			return '';
		}
		return decodeURIComponent(results[2].replace(/\+/g, " "));
	}


	//--------
	this.sprintf = function( ) {
		
		var str = arguments[0];
		for ( var i = 1 ; i < arguments.length ; i++ ) {
			str = str.replace("%s", arguments[i]);
		}
		return str;
	}


	//-----
	this.render_list = function() {
		
		console.log("render_list");

		var sl = this;

		
		var mylist = document.getElementById("threadindex_list");
		var str = ""

		if ( typeof sl.total_usd != "undefined" ) {
			str += "<li id='li_profile'>";
			str += "<div>";
			str += this.sprintf( "<div class='profile_header'>%s</div>", this.profile_name );
			str += this.sprintf( "<div class='curr_rate_holding'>Total USD: <br/>%s </div>", this.numberWithCommas( sl.total_usd.toFixed(2) ));
			str += this.sprintf( "<div class='curr_rate_holding'>Total SGD: <br/>%s </div>", this.numberWithCommas( sl.total_sgd.toFixed(2) ));
			str += this.sprintf( "<div class='curr_rate_holding'>Total BTC: <br/>%s </div>", this.numberWithCommas( sl.total_btc.toFixed(4) ));
			str += this.sprintf( "<div class='curr_rate_holding'>Total ETH: <br/>%s </div>", this.numberWithCommas( sl.total_eth.toFixed(4) ));
			str += "</div>";
			str += "</li>";
		}
		

		var sorted_list = []
		for ( symbol in sl.exchange_rates ) {
			var sl_obj = sl.exchange_rates[symbol] 
			if ( typeof sl_obj.total_usd == "undefined" ) {
				sl_obj.total_usd = 0.0;
				sl_obj.total_sgd = 0.0;
				sl_obj.total_btc = 0.0;
				sl_obj.total_eth = 0.0;
				sl_obj.own = 0.0;
			}
			sorted_list.push( sl_obj );
		}
		sorted_list.sort( sl.compare );




		for ( i = 0 ; i < sorted_list.length ; i++ ) {
			
			str += "<li>";

				var symbol 		= sorted_list[i].symbol;
				var sl_obj 		= sl.exchange_rates[symbol];
				var provider 	= sl_obj.provider;

				
				var pair   		= this.sprintf("%sBTC", symbol );
				if ( symbol == "BTC" ) {
					pair = "BTCUSDT"
				}


				var chart_url = this.sprintf("http://tradingview.com/e?symbol=BINANCE:%s", pair );	
				if ( provider == "hitbtc" ) {
					var chart_url = this.sprintf("https://hitbtc.com/chart/%s", pair );	
				}

				str += "<div class='curr_rate_header'>"
					str += this.sprintf( "<div class='curr_rate_symbol'><a href='%s' target='_blank'>%s</a></div>", chart_url, symbol );

				str += "</div>"
				str += "<div class='curr_rate'>";
					str += this.sprintf("<div class='curr_rate_inner'>%s USD</div>", sl_obj.usd.toFixed(4) );
					str += this.sprintf("<div class='curr_rate_inner'>%s BTC</div>", sl_obj.btc.toFixed(8) );
					str += this.sprintf("<div class='curr_rate_inner'>%s SGD</div>", sl_obj.sgd.toFixed(4) );
					str += this.sprintf("<div class='curr_rate_inner'>%s ETH</div>", sl_obj.eth.toFixed(8) );
					
				str += "</div>";
				
				if ( typeof sl_obj.total_usd != "undefined" ) {
					str += "<div>";
					str += this.sprintf( "<hr /><div class='curr_rate_holding_title'>You Own:  %s %s</div>", sl_obj.own, symbol );
					str += this.sprintf( "<div class='curr_rate_holding' id='curr_rate_holding_usd_%s'>%s USD</div>", symbol, this.numberWithCommas( sl_obj.total_usd.toFixed(2) ) );
					str += this.sprintf( "<div class='curr_rate_holding' id='curr_rate_holding_sgd_%s'>%s SGD</div>", symbol, this.numberWithCommas( sl_obj.total_sgd.toFixed(2) ) );
					str += this.sprintf( "<div class='curr_rate_holding' id='curr_rate_holding_btc_%s'>%s BTC</div>", symbol, this.numberWithCommas( sl_obj.total_btc.toFixed(4) ) );
					str += this.sprintf( "<div class='curr_rate_holding' id='curr_rate_holding_eth_%s'>%s ETH</div>", symbol, this.numberWithCommas( sl_obj.total_eth.toFixed(4) ) );
					str += "</div>"
				}
			str += "</li>";

		}
		str += this.sprintf("<li>Last Updated: %s</li>", this.last_updated );
		


		mylist.innerHTML = str;
	}




	//-------------
	this.compare = function( a, b) {

		if ( a.total_usd < b.total_usd ) {
	    	return 1;
	    }
		if ( a.total_usd > b.total_usd ) {
			return -1;
		}
		return 0;
	
	}


	

	//--------------
	this.numberWithCommas = function(x) {
    	var parts = x.toString().split(".");
    	parts[0] = parts[0].replace(/\B(?=(\d{3})+(?!\d))/g, ",");
    	return parts.join(".");
	}

	//-------------
	this.init = function() {
		this.get_exchange_rates();

	}

}

document.addEventListener("DOMContentLoaded", function() {
	sl = new SimpleList();
	sl.init();
});


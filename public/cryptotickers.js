

function SimpleList() {

	//---------------
	this.get_exchange_rates = function() {

		var sl = this;
		this.loadJSON("/cryptotickers.json", function( obj ) {
			sl.exchange_rates = obj;
            sl.render_list();
            var profile = sl.get_querystring_value("profile") ;
            if ( profile ) {
				sl.get_holdings(profile);
			}	    	
	    }, function(xhr) {
	    	console.log("Error!");
	    });
	}

	//-----------
	// Get user's holding from profile
	this.get_holdings = function( profile_name ) {
			
		var sl = this;
		this.profile_name = profile_name;
		this.loadJSON("/" + profile_name + ".json", function( obj ) {
			sl.profile = obj;
            sl.render_profile();
            	    	
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
			
		var mylist = document.getElementById("threadindex_list");
		this.coin_usdval = {};
		this.coin_sgdval = {};
		this.coin_btcval = {};
		this.coin_ethval = {};

		var str = ""
		if ( typeof this.exchange_rates != 'undefined' ) {
			var data = this.exchange_rates["data"];

			str += "<li id='li_profile'></li>";

			for ( var i = 0 ; i < data.length ; i++ ) {
				str += "<li>";

					var symbol 		= data[i]["symbol"];
					var provider 	= data[i]["provider"];

					this.coin_usdval[symbol] = data[i]["usd"];
					this.coin_sgdval[symbol] = data[i]["sgd"];
					this.coin_btcval[symbol] = data[i]["btc"];
					this.coin_ethval[symbol] = data[i]["eth"];


					var pair   		= this.sprintf("%sBTC", symbol );
					if ( symbol == "BTC" ) {
						pair = "BTCUSD"
					}

					var chart_url = this.sprintf("http://tradingview.com/e?symbol=%s", pair );	
					if ( provider == "binance" ) {

						var chart_url = this.sprintf("https://www.binance.com/tradeDetail.html?symbol=%s", symbol + "_BTC" );	
					
					} else if ( provider == "hitbtc" ) {
					
						var chart_url = this.sprintf("https://hitbtc.com/chart/%s", pair );	
					}

					str += "<div class='curr_rate_header'>"
						str += this.sprintf( "<div class='curr_rate_symbol'><a href='%s' target='_blank'>%s</a></div>", chart_url, symbol );

					str += "</div>"
					str += "<div class='curr_rate'>";
						str += this.sprintf("<div class='curr_rate_inner'>%s USD</div>", data[i]["usd"].toFixed(4) );
						str += this.sprintf("<div class='curr_rate_inner'>%s BTC</div>", data[i]["btc"].toFixed(8) );
						str += this.sprintf("<div class='curr_rate_inner'>%s SGD</div>", data[i]["sgd"].toFixed(4) );
						str += this.sprintf("<div class='curr_rate_inner'>%s ETH</div>", data[i]["eth"].toFixed(8) );
						
					str += "</div>";
					str += "<div>";
						str += this.sprintf( "<div class='curr_rate_holding' id='curr_rate_holding_symbol_%s'></div>", symbol );
						str += this.sprintf( "<div class='curr_rate_holding' id='curr_rate_holding_usd_%s'></div>", symbol );
						str += this.sprintf( "<div class='curr_rate_holding' id='curr_rate_holding_sgd_%s'></div>", symbol );
						str += this.sprintf( "<div class='curr_rate_holding' id='curr_rate_holding_btc_%s'></div>", symbol );
						str += this.sprintf( "<div class='curr_rate_holding' id='curr_rate_holding_eth_%s'></div>", symbol );
												
					str += "</div>"

				str += "</li>";

			}
			str += this.sprintf("<li>Last Updated: %s</li>", this.exchange_rates["last_updated"] );
		}	
		mylist.innerHTML = str;
	}

	//------------
	this.render_profile = function() {
		
		if ( typeof this.profile != 'undefined' ) {
			
			this.total_usd = 0.0;
			this.total_sgd = 0.0;
			this.total_btc = 0.0;
			this.total_eth = 0.0;

			for ( var key in this.profile ) {
				
				var symbol 		= key;
				var own 		= this.profile[key];

				var dom = document.getElementById("curr_rate_holding_symbol_"+ symbol ) ;
				if ( dom ) {
					dom.innerHTML = "You Own : " + own + " " + symbol;
				
					var own_usd 	= own * this.coin_usdval[symbol];
					this.total_usd += own_usd;
					var dom_usd 	= document.getElementById("curr_rate_holding_usd_" + symbol );
					if ( dom_usd ) {
						dom_usd.innerHTML = this.numberWithCommas( own_usd.toFixed(2)  ) + " USD";
					} 

					var own_sgd 	= own * this.coin_sgdval[symbol];
					this.total_sgd += own_sgd;
					var dom_sgd 	= document.getElementById("curr_rate_holding_sgd_" + symbol );
					if ( dom_sgd ) {
						dom_sgd.innerHTML = this.numberWithCommas( own_sgd.toFixed(2) ) + " SGD";
					}

					var own_btc 	= own * this.coin_btcval[symbol];
					this.total_btc += own_btc;
					var dom_btc 	= document.getElementById("curr_rate_holding_btc_" + symbol );
					if ( dom_btc ) {
						dom_btc.innerHTML = this.numberWithCommas( own_btc.toFixed(4) ) + " BTC";
					}

					var own_eth 	= own * this.coin_ethval[symbol];
					this.total_eth += own_eth;
					var dom_eth 	= document.getElementById("curr_rate_holding_eth_" + symbol );
					if ( dom_eth ) {
						dom_eth.innerHTML = this.numberWithCommas( own_eth.toFixed(4) ) + " ETH";
					}	

				}		
			}

			var str = "<div>";
				str += this.sprintf( "<div class='profile_header'>%s</div>", this.profile_name );
				str += this.sprintf( "<div class='curr_rate_holding'>Total USD: %s </div>", this.numberWithCommas( this.total_usd.toFixed(2) ));
				str += this.sprintf( "<div class='curr_rate_holding'>Total SGD: %s </div>", this.numberWithCommas( this.total_sgd.toFixed(2) ));
				str += this.sprintf( "<div class='curr_rate_holding'>Total BTC: %s </div>", this.numberWithCommas( this.total_btc.toFixed(2) ));
				str += this.sprintf( "<div class='curr_rate_holding'>Total ETH: %s </div>", this.numberWithCommas( this.total_eth.toFixed(2) ));
				
			str += "</div>";

			document.getElementById("li_profile").innerHTML = str;
		}
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


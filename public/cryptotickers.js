

function SimpleList() {

	//---------------
	this.get_data = function() {

		var xhr = new XMLHttpRequest();
		var sl = this;

	    xhr.onreadystatechange = function() {
	        if (xhr.readyState === XMLHttpRequest.DONE) {
	            if (xhr.status === 200) {
	                sl.responseJSON = JSON.parse(xhr.responseText);
	                sl.render();
	            } else {
	            	console.log( "Error." );
	            }
	        }
	    };
	    xhr.open("GET", "/cryptotickers.json", true);
	    xhr.send();

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
	this.render = function() {
		
		var mylist = document.getElementById("threadindex_list");
		
		var str = ""
		if ( typeof this.responseJSON != 'undefined' ) {
			var data = this.responseJSON["data"];
			for ( var i = 0 ; i < data.length ; i++ ) {
				str += "<li>";

					var symbol 		= data[i]["symbol"];
					var provider 	= data[i]["provider"];

					var pair   		= this.sprintf("%sBTC", symbol );
					if ( symbol == "BTC" ) {
						pair = "BTCUSD"
					}

					var chart_url = this.sprintf("http://tradingview.com/e?symbol=%s", pair );	
					if ( provider == "binance" ) {
						var chart_url = this.sprintf("https://www.binance.com/tradeDetail.html?symbol=%s", pair.slice(0,3) + "_" + pair.slice(3,6) );	
					} else if ( provider == "hitbtc" ) {
						var chart_url = this.sprintf("https://hitbtc.com/chart/%s", pair );	
					}

					str += this.sprintf( "<div class='curr_rate_symbol'><a href='%s' target='_blank'>%s</a></div>", chart_url, symbol );
					str += "<div class='curr_rate'>";
						str += this.sprintf("<div class='curr_rate_inner'>%s USD</div>", data[i]["usd"].toFixed(4) );
						str += this.sprintf("<div class='curr_rate_inner'>%s BTC</div>", data[i]["btc"].toFixed(8) );
						str += this.sprintf("<div class='curr_rate_inner'>%s ETH</div>", data[i]["eth"].toFixed(8) );
						str += this.sprintf("<div class='curr_rate_inner'>%s SGD</div>", data[i]["sgd"].toFixed(4) );
						
					str += "</div>";
				str += "</li>";

			}
			str += this.sprintf("<li>Last Updated: %s</li>", this.responseJSON["last_updated"] );
		}	
		mylist.innerHTML = str;
	}

	//-------------
	this.init = function() {
		this.get_data();
	}

}

document.addEventListener("DOMContentLoaded", function() {
	sl = new SimpleList();
	sl.init();
});


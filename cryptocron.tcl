

package require http
package require tls
package require json

tls::init -tls1 true -ssl2 false -ssl3 false -tls1 true -ssl2 false -ssl3 false
::http::register https 443 ::tls::socket


#------------------------
# BTCUSD only
proc get_from_bitstamp { } {

	if { [ catch {
	
		set url "https://www.bitstamp.net/api/v2/ticker/BTCUSD"
		set responseData [ http::data [ http::geturl $url -headers [list Accept-Encoding ""]  ]]
		
		puts "Bitstamp returned |$responseData|"
		set json [ ::json::json2dict $responseData ]
		set ::rate(last,BTCUSD) [ dict get $json last ]

	} err ] } {
		puts "Error $err."
	} 
}

#----------------------
# Other coins
proc get_from_bittrex { } {

	foreach pair [ list \
			GNTBTC \
			DGBBTC \
			XLMBTC \
			CVCBTC \
			STEEMBTC \
			XRPBTC \
			SCBTC \
			ARKBTC \
			SYSBTC \
			BCCBTC \
			 ] { 

		if { ![ info exists ::rate(last,$pair) ] } {
			if { [ catch {
				
					set pair_len 	[ string length $pair ]
					set base_curr  	[ string range $pair $pair_len-3 $pair_len-1 ]
					set curr  	    [ string range $pair 0   $pair_len-4 ]

					set bittrex_pair "$base_curr-$curr"
					set url "https://bittrex.com/api/v1.1/public/getticker?market=$bittrex_pair"
					set responseData [ http::data [ http::geturl $url -headers [list Accept-Encoding ""]  ]]
					
					puts "Bittrex returned |$responseData|"
					set json [ ::json::json2dict $responseData ]
					set ::rate(last,$pair) [ dict get [ dict get $json result ] Last ]


			} err ] } {
				puts "Error $pair, $err."
			} 
		}
	}	

}

#-----------------
proc get_from_binance { } {

	if { [ catch {
		
		set url "https://www.binance.com/api/v1/ticker/allPrices"
		set responseData [ http::data [ http::geturl $url -headers [list Accept-Encoding ""]  ]]
				
		#puts "Binance returned |$responseData|"
		set json [ ::json::json2dict $responseData ]
		foreach pairitem $json {
		
			set pair  [ dict get $pairitem symbol ]
			set price [ dict get $pairitem price ]
			set ::rate(last,$pair) $price
		}	

	} err ] } {
		puts "Error $err."
	} 	
}


#-------------------
proc get_from_hitbtc { } {

	
	if { [ catch {
		
		set url "https://api.hitbtc.com/api/1/public/ticker"
		set responseData [ http::data [ http::geturl $url -headers [list Accept-Encoding ""]  ]]
				
		#puts "Hitbtc returned |$responseData|"
		set json [ ::json::json2dict $responseData ]
		foreach pair [ dict keys $json ] {
			set price [ dict get [ dict get $json $pair ] last ]
			set ::rate(last,$pair) $price
		}	

	} err ] } {
		puts "Error $err."
	} 		

}

#------------------------
array set ::rate {}
proc get_rate { } {

	puts "get_rate"

	array unset ::rate *
	get_from_hitbtc 
	get_from_binance
	get_from_bittrex

	set ::rate(updated) [ clock seconds ]
	
	parray ::rate
	puts "get_rate completed $::rate(updated). \n\n\n"
}







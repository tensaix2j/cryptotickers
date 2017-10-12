

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
		
		#puts "Bitstamp returned |$responseData|"

		set json [ ::json::json2dict $responseData ]
		set ::rate_buffer(last,BTCUSD) [ dict get $json last ]

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
			NAVBTC \
			 ] { 

		if { ![ info exists ::rate_buffer(last,$pair) ] } {
			if { [ catch {
				
					set pair_len 	[ string length $pair ]
					set base_curr  	[ string range $pair $pair_len-3 $pair_len-1 ]
					set curr  	    [ string range $pair 0   $pair_len-4 ]

					set bittrex_pair "$base_curr-$curr"
					set url "https://bittrex.com/api/v1.1/public/getticker?market=$bittrex_pair"
					set responseData [ http::data [ http::geturl $url -headers [list Accept-Encoding ""]  ]]
					
					#puts "Bittrex returned |$responseData|"
					puts "Bittrex OK"
					set json [ ::json::json2dict $responseData ]
					
					set success [ dict get $json success ]
					set rate 	[ dict get [ dict get $json result ] Last ]

					if { $success == "true" } {
						set ::rate_buffer(last,$pair) $rate
						set ::rate_buffer(provider,$pair) 	bittrex
					}

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
		puts "Binance OK"
					
		set json [ ::json::json2dict $responseData ]
		foreach pairitem $json {
		
			set pair  [ dict get $pairitem symbol ]
			set price [ dict get $pairitem price ]
			set ::rate_buffer(last,$pair) 		$price
			set ::rate_buffer(provider,$pair) 	binance	
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
		puts "Hitbtc OK"

		set json [ ::json::json2dict $responseData ]
		foreach pair [ dict keys $json ] {
			set price [ dict get [ dict get $json $pair ] last ]
			if { $price != "null" } {
				set ::rate_buffer(last,$pair) 		$price
				set ::rate_buffer(provider,$pair) 	hitbtc
		
			}	
		}	

	} err ] } {
		puts "Error $err."
	} 		

}

#-------------------------------
proc get_from_fixer { } {

	if { [ catch {
		
		set url "http://api.fixer.io/latest?base=USD&symbols=SGD"
		set responseData [ http::data [ http::geturl $url -headers [list Accept-Encoding ""]  ]]
		puts "fixer OK"

		set json [ ::json::json2dict $responseData ]
		set ::rate_buffer(last,USDSGD) [ dict get [ dict get $json rates ] SGD ]
		set ::rate_buffer(provider,USDSGD) fixer
				

	} err ] } {
		puts "Error $err."
	} 
}


#------------------------
array set ::rate {}
array set ::rate_buffer {}
proc get_rate { } {

	puts "get_rate"

	array unset ::rate_buffer *
	get_from_hitbtc 
	get_from_binance
	get_from_bittrex
	get_from_fixer 

	set ::rate_buffer(updated) [ clock seconds ]
	puts "get_rate completed $::rate_buffer(updated). \n\n\n"
	array set ::rate [ array get ::rate_buffer ]
	
	array unset ::rate_buffer *
}

proc test { } {
	get_rate 
	parray ::rate last,*
}










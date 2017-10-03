


#---------------------
proc response { sock } {

	
	puts $sock "HTTP/1.0 200 OK"
	puts $sock "Content-Type: text/html"
	puts $sock ""
	
	puts $sock "<table border=1px style=\"width:400px;\">"
	puts $sock "<tr>"
		puts $sock "<th>Coin</th>"
		puts $sock "<th>USD</th>"
		puts $sock "<th>BTC</th>"
		puts $sock "<th>ETH</th>"
	puts $sock "</tr>"

	foreach curr [ list \
			BTC \
			ETH \
			NEO \
			BNB \
			WTC \
			DICE \
			GNT \
			OAX \
			DGB \
			CVC \
			XLM \
			STEEM \
			XRP \
			SC \
			BET \
			EOS \
			SYS \
			OMG \
			PLR \
			ETC \
			SALT \
			QTUM \
			ARK \
			BCC \
			PAY \
			XMR \
			] { 

		set price_in_btc 0.00000000
		set price_in_usd 0.00
		set price_in_eth 0.00000000
		
		if { $curr == "BTC" && [ info exists ::rate(last,BTCUSDT) ] } {

			set price_in_btc  1.0
			set price_in_usd  $::rate(last,BTCUSDT)
			set price_in_eth  [ expr 1.0 / $::rate(last,ETHBTC) ]

		} elseif { [ info exists ::rate(last,${curr}BTC) ] } {
			set price_in_btc  $::rate(last,${curr}BTC)
			set price_in_usd  [ expr $price_in_btc * $::rate(last,BTCUSDT) ]
			set price_in_eth  [ expr $price_in_btc / $::rate(last,ETHBTC) ]
				
		} elseif { [ info exists ::rate(last,${curr}ETH) ] } {

			set price_in_eth  $::rate(last,${curr}ETH)
			set price_in_btc  [ expr $price_in_eth * $::rate(last,ETHBTC) ]
			set price_in_usd  [ expr $price_in_btc * $::rate(last,BTCUSDT) ]
			
		}	

		
		

		puts $sock "<tr>"
		puts $sock "<td>$curr</td>"
		puts $sock "<td>[ format %.4f $price_in_usd ]</td>"
		puts $sock "<td>[ format %.8f $price_in_btc ]</td>"
		puts $sock "<td>[ format %.8f $price_in_eth ]</td>"
			
		puts $sock "</tr>"
				
	}
	puts $sock "</table>"
	puts $sock "<br/><br/>"
	puts $sock "Last Updated: [ clock format $::rate(updated) -format "%Y%m%d.%H%M%S"  ]"	
		
}


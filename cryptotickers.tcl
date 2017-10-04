


#---------------------
proc response { sock } {

	
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

		if { [ info exists ::rate(last,BTCUSD) ] } {
			set BTCUSD  $::rate(last,BTCUSD)
		} elseif { [ info exists ::rate(last,BTCUSDT) ] } {
			set BTCUSD  $::rate(last,BTCUSDT)
		}

		if { [ info exists ::rate(last,ETHBTC) ] } {
			set ETHBTC  $::rate(last,ETHBTC)
		} 

		if { [ info exists BTCUSD ] } {

			if { $curr == "BTC"  } {

				set price_in_btc  1.0
				set price_in_usd  $BTCUSD
				set price_in_eth  [ expr 1.0 / $ETHBTC ]

			} elseif { [ info exists ::rate(last,${curr}BTC) ] } {

				set price_in_btc  $::rate(last,${curr}BTC)
				set price_in_usd  [ expr $price_in_btc * $BTCUSD ]
				set price_in_eth  [ expr $price_in_btc / $ETHBTC ]
					
			} elseif { [ info exists ::rate(last,${curr}ETH) ] } {

				set price_in_eth  $::rate(last,${curr}ETH)
				set price_in_btc  [ expr $price_in_eth * $ETHBTC ]
				set price_in_usd  [ expr $price_in_btc * $BTCUSD ]
				
			}	
		}
		lappend arr "{\"symbol\":\"$curr\",\"usd\":[ format %.4f $price_in_usd ],\"btc\":[ format %.8f $price_in_btc ],\"eth\":[ format %.8f $price_in_eth ]}"
				
	}
	set data 				"\[[ join $arr , ]\]"
	set last_updated_ts 	""
	if { [info exists ::rate(updated) ] } {
		set last_updated_ts [ clock format $::rate(updated) -format "%Y%m%d.%H%M%S"  ]
	}
	set response "{\"data\":$data,\"last_updated\":\"$last_updated_ts\"}"

	puts $sock $response
			
}


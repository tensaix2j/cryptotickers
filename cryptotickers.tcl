


#---------------------
proc response { sock } {

	
	foreach curr [ list \
			BTC \
			USDT \
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
			LTC \
			SALT \
			QTUM \
			ARK \
			BCH \
			PAY \
			POWR \
			NAV \
			LINK \
			XMR \
			BTG \
			KCS \
			CLUB \
			ENJ \
			OST \
			ADA \
			CND \
			BCN \
			] { 

		set price_in_btc 0.00000000
		set price_in_usd 0.00
		set price_in_eth 0.00000000
		set price_in_sgd 0.00

		if { [ info exists ::rate(last,BTCUSD) ] } {
			set BTCUSD  $::rate(last,BTCUSD)
		} elseif { [ info exists ::rate(last,BTCUSDT) ] } {
			set BTCUSD  $::rate(last,BTCUSDT)
		}

		if { [ info exists ::rate(last,ETHBTC) ] } {
			set ETHBTC  $::rate(last,ETHBTC)
		} 

		if { [ info exists ::rate(provider,${curr}BTC) ] } {
			set provider $::rate(provider,${curr}BTC)
		} elseif {  [ info exists ::rate(provider,${curr}ETH) ] } {	
			set provider $::rate(provider,${curr}ETH)
		} elseif { $curr == "BTC" } {
			set provider "bittrex"
		}
			

		if { [ info exists BTCUSD ] } {

			if { $curr == "BTC"  } {

				set price_in_btc  1.0
				set price_in_usd  $BTCUSD
				set price_in_eth  [ expr 1.0 / $ETHBTC ]
				

			} elseif { $curr == "USDT" } {

				set price_in_btc [ expr 1.0 / $BTCUSD ] 
				set price_in_usd  1.0
				set price_in_eth [ expr 1.0 / ( $BTCUSD * $ETHBTC)  ]

			} elseif { [ info exists ::rate(last,${curr}BTC) ] } {

				set price_in_btc  $::rate(last,${curr}BTC)
				set price_in_usd  [ expr $price_in_btc * $BTCUSD ]

				if { [ info exists ::rate(last,${curr}ETH) ] } {
					set price_in_eth  $::rate(last,${curr}ETH)
				} else {
					set price_in_eth  [ expr $price_in_btc / $ETHBTC ]
				}
				
			} elseif { [ info exists ::rate(last,${curr}ETH) ] } {

				set price_in_eth  $::rate(last,${curr}ETH)
				set price_in_btc  [ expr $price_in_eth * $ETHBTC ]
				set price_in_usd  [ expr $price_in_btc * $BTCUSD ]
				
			}	

			# Need to know in term of SGD too
			if { [ info exists ::rate(last,USDSGD) ] } {
				set price_in_sgd   [ expr $price_in_usd * $::rate(last,USDSGD) ]
			} else {
				#in case fixer.io is down, use hardcoded rate
				set price_in_sgd   [ expr $price_in_usd * 1.35 ]
			}
			
		}
		lappend arr "{\"symbol\":\"$curr\",\"provider\":\"$provider\",\"usd\":[ format %.4f $price_in_usd ],\"btc\":[ format %.8f $price_in_btc ],\"eth\":[ format %.8f $price_in_eth ],\"sgd\":[ format %.8f $price_in_sgd ]}"
				
	}
	set data 				"\[[ join $arr , ]\]"
	set last_updated_ts 	""
	if { [info exists ::rate(updated) ] } {
		set last_updated_ts [ clock format $::rate(updated) -format "%Y%m%d.%H%M%S"  ]
	}
	set response "{\"data\":$data,\"last_updated\":\"$last_updated_ts\"}"

	puts $sock $response
			
}


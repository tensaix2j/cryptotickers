



#-----------
proc on_error { sock err } {

	puts "$sock:$err"
}

#-----------
proc on_data { sock msg } {

	puts "$sock:$msg"
	foreach { action path protocol } $msg {

		puts "ACTION: $action"
		puts "PATH: $path"
		puts "PROTOCOL: $protocol"

		puts $sock "HTTP/1.0 200 OK"
		
		if { [ file extension $path ] == ".css" } {
			puts $sock "Content-Type: text/css"
		} else {
			puts $sock "Content-Type: text/html"
		}
		puts $sock ""
		
		if { [ catch {
				
			if { $path == "/cryptotickers.json" } {

				# Dynamic content
				source "cryptotickers.tcl"
				response $sock
				 
			} else {
				# Static content
				set filename [ file tail $path ]
				if { $filename == "" || [ string match index* $filename ] } {
					set filename "cryptotickers.html"
				}
				set fullpath "./public/$filename"
				if { ![ file exists $fullpath ] } {
					puts $sock "No such file"
				}

				if { [ file exists $fullpath ] } {
					set fp [ open $fullpath ]
					set content [ read $fp ]
					close $fp 
					puts $sock $content
				}
			}

		} err ] } {
			set errmsg "Error occured. $err"
			puts $sock $errmsg
			puts $errmsg
		}	

		close $sock
		puts "\n\n"
		break
	}

}

#-----------
proc on_close { sock } {

	puts "$sock closed"
}

#-----------
proc on_readable { sock } {

	if { [ catch { set input [gets $sock] } err ] } {
		on_error $sock $err
	}
		
	if { [eof $sock] } {  
		on_close $sock
	    close $sock

	} else {
	    on_data $sock $input 
	}
}

#-----------
proc on_connected { sock addr port } {

	fileevent $sock readable [list on_readable $sock ]
	fconfigure $sock -translation auto -buffering line
		
}


#---------------------------
proc do_cron { } {

	get_rate
	after $::config(-cron_interval) ::do_cron 
}


#----------------
array set ::config { 
	-port 10000
	-cron_interval 60000
}

#-----------
proc main { argc argv } {

	array set ::config $argv

	if { [ info exists ::config(-p) ] } {
		set ::config(-port) $::config(-p)
	}

	socket -server on_connected $::config(-port)
	puts "Server started at port $::config(-port)"

	source "cryptocron.tcl"
	do_cron 

	vwait forever	
}


main $argc $argv












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

		source "cryptotickers.tcl"
		if { [ catch {
			response $sock
		} err ] } {
			puts $sock "Error in cryotptickers.tcl $err"
			puts $err
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

	socket -server on_connected $::config(-port)
	puts "Server started at port $::config(-port)"

	source "cryptocron.tcl"
	do_cron 

	vwait forever	
}


main $argc $argv








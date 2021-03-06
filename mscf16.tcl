#Some procedures to format data and commands for the mesytec mscf-16
#
#There are three modes of operation: Front Panel(FP), USB, and "rc bus" 
#("rc bus" and "event bus" both are used in the manual.
#
#mesytec MSCF-16 has two sets of parameters. One for the front panel,
#and the other for remote control (rc). Most operations will require 
#"single channel mode" while operating on it.
#
#(This next statement probably in need of revision... maybe omissions
#in the manuals!).
#There are many operations for the FP or USB modes that are unavailable
#for the rc bus.  There is no access to FP data from the rc bus, and
#the operations for copying to, or from the FP are absent.
#
#The manuals list commands with channels and groups numbering starting
#with ONE.  I observe this convention.  The "usb" namespace correspond
#to native operations (usb connection directly to module).  The "rcbus"
#namespace operations correspond to operations passed through on
#a serial bus from an mrc-1 module.  Which namespace is used is switched
#with the "devset" parameter.  When the rc bus is used, there are
#TWO additional parameters used to specify the device being addressed!
#    bus (0 or 1)
#    address (0-15)
#the bus depends on where the coax cable is plugged in, and the address
#is selected on the back of the module.
#
#
#continuing problem... timeouts are returned without an error! Of course
#the timeout should be set at least double the expected response time
#the longest is for the rcbus, and it is about 50ms).
#

namespace eval mscf16 {

    variable channels 16
    variable threshlimit 256
    variable pzlimit 16

    variable gaingroups 4
    variable gainlimit 16

    variable shapinggroups 4
    variable shapinglimit 4
    
    variable blrlimit 256
    variable coinc_limit 256

    variable threshoff 100
    variable threshoff_limit 256

    variable shaperoff 100
    variable shaperoff_limit 256

    variable devset "usb"
    variable deverror 0

    namespace eval usb {
        variable device "/dev/ttyUSB0"
	variable termstring "mscf-RC>"
	variable termstringon "mscf-RC>"
	variable termstringoff "mscf>"
	variable errstring "ERROR"
    }
    namespace eval rcbus {
        variable device "/dev/ttyUSB0"
        variable address 0
	variable bus 0
	variable termstring "mrc-1>"
#the mrc1 uses variable error strings!  however "ERR" is common
	variable errstring "*ERR*"
	variable limitData 55

	variable startgainadr 0
	variable startthreshadr 5
	variable startpzadr 22
	variable startshapingadr 39
	variable startmultadr 44
	variable monitoradr 46
	variable ctlmodeadr 47
	variable rcadr 48
	variable veradr 49
	variable blrthrshadr 50
	variable blradr 51
	variable coincadr 52
	variable thrshoffadr 53
	variable shproffadr 54
	variable ecladr 57
	variable tfadr 58

    }

    
    variable FPthresholds {0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0}
    variable FPgains {0 0 0 0 0}
    variable FPctlmode 0
    variable FPmonitor 0
    variable FPmultlimits {0 0}
    variable FPshapetimes {0 0 0 0 0}
    variable FPpolezeros {0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0}
    
#    variable remote
    variable rc 0
    variable blrthreshold 0
    variable blractive 0
    variable ecldelay 0
    variable tfint 0
    variable coinc_time 0
    variable version
    variable fwversion
    variable flashversion

    variable thresholds {0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0}
    variable gains      {0 0 0 0 0}
    variable ctlmode 0
    variable monitor 0
    variable multlimits {0 0}
    variable shapetimes {0 0 0 0 0}
    variable polezeros  {0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0}

#end mscf16 namespace
}

#general procedures
#
#return the channel, in 1..17 range.
proc mscf16::channel { chan } {
    variable channels
    return [expr ($chan-1)%($channels + 1)+1]
}

#return the group to which a channel belongs for the gain setting
proc mscf16::group { chan } {
    variable gaingroups
    variable channels
    set chnpergrp [expr $channels/$gaingroups]
    set inrangechan [ eval channel $chan ]
#    return [expr ($inrangechan-1)/$gaingroups + 1]
    return [expr ($inrangechan-1)/$chnpergrp + 1]
}

#return the group to which a channel belongs for the shapingtime setting
proc mscf16::shpgroup { chan } {
    variable shapinggroups
    variable channels

    set inrangechan [ eval channel $chan ]
    set chnpergrp [expr $channels/$shapinggroups]
#    return [expr ($inrangechan-1)/$shapinggroups + 1]
    return [expr ($inrangechan-1)/$chnpergrp + 1]
}

#return the new list if the value is different from the list
#OR it returns and EMPTY list
proc mscf16::add_if_new { origlist channel newval {offset 0} } {

    set ind [expr $channel - $offset]
    set oldval [lindex $origlist $ind]
    
    if { $newval == $oldval } { return {} }
    
    set newlist [lreplace $origlist $ind $ind $newval ]

    return $newlist
}

#this function calls the appropriate proc to read ALL values.
proc mscf16::getall { handle } {
    variable devset
    ${devset}::getall $handle
}

#this function calls the appropriate proc to set the gain values.
proc mscf16::setgain { handle channel value } {
    variable devset
    variable gains

    set thegroup [group $channel]
    set newgains [ add_if_new $gains $thegroup $value 1 ]

    if { $newgains != {} } {
	${devset}::setgain $handle $thegroup $value
	set gains $newgains
    }

    return
}

#this function calls the appropriate proc to set the shapetime values.
proc mscf16::setshape { handle channel value } {
    variable devset
    variable shapetimes


    set thegroup [shpgroup $channel]
    set newshapes [ add_if_new $shapetimes $thegroup $value 1 ]

    if { $newshapes != {} } {
	${devset}::setshape $handle $thegroup $value
	set shapetimes $newshapes
    }

    return
}

proc mscf16::setthreshold { handle channel value } {
    variable devset
    variable thresholds

    set newthreshs [ add_if_new $thresholds $channel $value 1 ]

    if { $newthreshs != {} } {
	${devset}::setthreshold $handle $channel $value
	set thresholds $newthreshs
    }

    return
}


proc mscf16::setpz { handle channel value } {
    variable devset
    variable polezeros

    set newpolezeros [ add_if_new $polezeros $channel $value 1 ]
    
    if { $newpolezeros != {} } {
	${devset}::setpz $handle $channel $value
        set polezeros $newpolezeros
    }

    return
}


proc mscf16::setrc { handle value } {
    variable devset
    variable rc

#turn remote control on (value 1) or off (value 0)
    ${devset}::setrc $handle $value
    set rc [expr $value % 2]    
}



proc mscf16::setmonitor { handle value } {

    variable devset
    variable monitor

    set value [ expr $value % 17 ]
    ${devset}::setmonitor $handle $value

    set monitor $value

    return

}

proc mscf16::setmode { handle value } {

    variable devset
    variable ctlmode

    set value [ expr $value % 2 ]
    ${devset}::setmode $handle $value

    set ctlmode $value

    return

}

proc mscf16::setmultlimits { handle low high } {

    variable devset
    variable multlimits

    set limit 8
    set low [ expr (($low-1) % $limit + 1) ]
    set high [ expr (($high-1) % $limit + 1) ]

#note! the list of multiplicity limits is HIGH then LOW
    set value [ list $high $low ]
    ${devset}::setmultlimits $handle $value

    set multlimits $value

    return

}

#setblrthresh
#sets the blrthreshold in the range.
proc mscf16::setblrthresh { handle value } {

    variable devset
    variable blrthreshold
    variable blrlimit

    set value [ expr $value % $blrlimit ]
    ${devset}::setblrthresh $handle $value

    set blrthreshold $value

    return

}

#setblr
#turns on (1) and off (0) the baseline restoration
proc mscf16::setblr { handle value } {

    variable devset
    variable blractive

    set value [ expr $value % 2 ]
    ${devset}::setblr $handle $value

    set blractive $value

    return

}


#setecl
#turns on (1) and off (0) the ecl delay
proc mscf16::setecl { handle value } {

    variable devset
    variable ecldelay

    set value [ expr $value % 2 ]
    ${devset}::setecl $handle $value

    set ecldelay $value

    return

}

#settf
#sets timing filter integration
proc mscf16::settfint { handle value } {

    variable devset
    variable tfint

    set value [ expr $value % 4 ]
    ${devset}::settfint $handle $value

    set tfint $value

    return

}

#setcoinctime
#sets the coincidence time in the range.
proc mscf16::setcoinctime { handle value } {

    variable devset
    variable coinc_time
    variable coinc_limit

    set value [ expr $value % $coinc_limit ]
    ${devset}::setcoinctime $handle $value

    set coinc_time $value

    return

}


#
#setrcbus
#checks, and sets the rcbus parameters.  Note that there
#are not separate procedures for this since there is no
#analog for the "usb" device.
#
proc mscf16::setrcbus { nextbus nextaddress } {

    variable rcbus::bus
    variable rcbus::address

    set bus [ expr $nextbus % 2 ]
    set address [ expr $nextaddress % 16 ]

    return

}

#copy common to single.  For the USB bus this is done by the module (at this time,
#appears not to be the case for rc bus)
proc mscf16::cpyc { handle } {

    variable devset
    variable ctlmode

    ${devset}::cpyc $handle

    return

}


#copy FP to RC parameters.  For the USB bus this is done by the module (at this time,
#appears to be unimplemented for rc bus)
proc mscf16::cpyf { handle } {

    variable devset
    variable ctlmode

    ${devset}::cpyf $handle

    return

}


#copy RC to FP parameters.  For the USB bus this is done by the module (at this time,
#appears to be unimplemented for rc bus)
proc mscf16::cpyr { handle } {

    variable devset
    variable ctlmode

    ${devset}::cpyr $handle

    return

}

#--------some utility functions
#found useful... return list of gains for the _channels_
proc mscf16::channel_gains {} {
    variable gains
    variable gaingroups
    variable channels
    set chanlist {}
    set chnpergrp [expr $channels/$gaingroups]
    for {set i 0} {$i<$channels} {incr i} {
#	lappend chanlist [lindex $gains [expr $i/$gaingroups]]
	lappend chanlist [lindex $gains [expr $i/$chnpergrp]]
    }
    lappend chanlist [lindex $gains end]
    return $chanlist
}

#found useful... return list of shapingtimes for the _channels_
proc mscf16::channel_shapetimes {} {
    variable shapetimes
    variable shapinggroups
    variable channels
    set chanlist {}
    set chnpergrp [expr $channels/$shapinggroups]
    for {set i 0} {$i<$channels} {incr i} {
#	lappend chanlist [lindex $shapetimes [expr $i/$shapinggroups]]
	lappend chanlist [lindex $shapetimes [expr $i/$chnpergrp]]
    }
    lappend chanlist [lindex $shapetimes end]
    return $chanlist
}


#procedures for usb bus

proc mscf16::usb::getall { handle } {
    variable termstring
    variable ::mscf16::deverror

    set result ""
    set deverror [ catch { serialusb::send $handle "ds" } ]
    if { $deverror } { return $result }
    set deverror [ catch { serialusb::receive $handle $termstring 2000 } result ]
    if { $deverror } { return $result }
#check for a module error
    set deverror [string match "*ERROR*" $result]
#check for a timeout...
    if { $serialusb::timeError } { set deverror 1 }

    ::mscf16::interpall $result

    return $result
}

proc mscf16::usb::setgain { handle group value } {
    return [ execcmd $handle "sg $group $value" ] 
}

proc mscf16::usb::setshape { handle group value } {
    return [ execcmd $handle "ss $group $value" ] 
}

proc mscf16::usb::setthreshold { handle chan value } {
    return [ execcmd $handle "st $chan $value" ] 
}

proc mscf16::usb::setpz { handle chan value } {
    return [ execcmd $handle "sp $chan $value" ] 
}

proc mscf16::usb::setrc { handle value } {
#turn remote control on (value 1) or off (value 0)
    variable termstring
    variable termstringon
    variable termstringoff

    set rcon [expr $value % 2 ]
    if { $rcon == 1 } {
	set termstring $termstringon
	return [ execcmd $handle "ON" ] 
    } else {
	set termstring $termstringoff
	return [ execcmd $handle "OFF" ] 
    }
}

#setmultlimits
#"value" is a list of the high and low limits
proc mscf16::usb::setmultlimits { handle value } {
    return [ execcmd $handle "sm $value" ]
}

proc mscf16::usb::setblrthresh { handle value } {
    return [ execcmd $handle "sbt $value" ] 
}

proc mscf16::usb::setcoinctime { handle value } {
    return [ execcmd $handle "sc $value" ] 
}

proc mscf16::usb::setblr { handle value } {
    return [ execcmd $handle "sbl $value" ] 
}

proc mscf16::usb::setecl { handle value } {
    return [ execcmd $handle "se $value" ] 
}

proc mscf16::usb::settfint { handle value } {
    return [ execcmd $handle "sf $value" ] 
}

proc mscf16::usb::setmonitor { handle value } {
    return [ execcmd $handle "mc $value" ] 
}

proc mscf16::usb::setmode { handle value } {
#go to single channel on (value 1) or common mode (value 0)
    return [ execcmd $handle "si $value" ] 
}

proc mscf16::usb::cpyc { handle } {
    return [ execcmd $handle "cpy c" ] 
}

proc mscf16::usb::cpyf { handle } {
    return [ execcmd $handle "cpy f" ] 
}

proc mscf16::usb::cpyr { handle } {
    return [ execcmd $handle "cpy r" ] 
}

proc mscf16::usb::execcmd { handle cmd } {
    variable termstring
    variable ::mscf16::deverror

    set result ""

    set deverror [ catch { serialusb::send $handle $cmd } result ]
    if { $deverror } { return $result }

    set deverror [ catch { serialusb::receive $handle $termstring 100  } result ]

#check for a module error:
    set deverror [string match "*ERROR*" $result]

#check for a timeout...
    if { $serialusb::timeError } { set deverror 1 }

    return $result
}

#interpall
#this a utility procedure, to decode the results, from the formated
#ouput from the module.  It is NOT used for the rcbus, as there is
#no analog to the 'ds' command on the rc bus
# 
proc mscf16::interpall { ds_results } {
#    
#need to parse the ascii results from the module to get out settings.
#this is more involved for the usb controls (for which this is only
#applicable).  Here, there are TWO sets of parameters for most variables:
#"front panel" and "remote control"
#   
    variable FPthresholds
    variable FPgains
    variable FPctlmode
    variable FPmonitor
    variable FPmultlimits
    variable FPshapetimes
    variable FPpolezeros
    
    variable rc
    variable blrthreshold
    variable blractive
    variable coinc_time
    variable version
    variable fwversion
    variable flashversion

    variable thresholds
    variable gains
    variable ctlmode
    variable monitor
    variable multlimits
    variable shapetimes
    variable polezeros
    variable tfint
    variable ecldelay

#first get rid of "c:" from the string.
    
    set myresult [ string map -nocase { c: "" } $ds_results ]

#create a list of everything, with fields split by ':' or linefeeds

    set mylist [ split $myresult ":\n" ]

#go through the list and keep the relevent stuff

#-----begin finding indexes to each "group" of controls.
    set rcstart [ lsearch -exact  $mylist "MSCF-16 rc settings" ]
    if { $rcstart == -1 } { return "No MSCF-16 RC settings" }

    set commonstart [ lsearch -exact $mylist "MSCF-16 general settings" ]
    if { $commonstart == -1 } { return "No MSCF-16 general settings" }

    set fpstart [ lsearch -exact $mylist "MSCF-16 Panel settings" ]
    if { $fpstart == -1 } { return "No MSCF-16 Panel settings" }

#-----then get rc settings.
    set i [ lsearch -start $rcstart -exact  $mylist "gains" ]
    if { $i == -1 } { puts "No gains!" } else { set gains [ lindex $mylist [expr $i+1] ] }

    set i [ lsearch -start $rcstart -exact  $mylist "threshs" ]
    if { $i == -1 } { puts "No thresholds!" } else { set thresholds [ lindex $mylist [expr $i+1] ] }

    set i [ lsearch -start $rcstart -exact  $mylist "pz" ]
    if { $i == -1 } { puts "No polezeros!" } else { set polezeros [ lindex $mylist [expr $i+1] ] }

    set i [ lsearch -start $rcstart -exact  $mylist "shts" ]
    if { $i == -1 } { puts "No shapetimes!" } else { set shapetimes [ lindex $mylist [expr $i+1] ] }

    set i [ lsearch -start $rcstart -exact  $mylist "mult" ]
    if { $i == -1 } { puts "No multiplicities!" } else { set multlimits [ lindex $mylist [expr $i+1] ] }

    set i [ lsearch -start $rcstart -exact  $mylist "monitor" ]
    if { $i == -1 } { 
	puts "No monitor!" 
    } else { 
	set monitor [ lindex $mylist [expr $i+1] ] 
    }

    if {  [string equal $monitor " off"] } {
	set monitor 0
    }

    set i [ lsearch -start $rcstart -exact  $mylist "TF int" ]
    if { $i == -1 } { 
	puts "No TF integration!" 
    } else { 
	set tfint [ lindex $mylist [expr $i+1] ] 
	puts "Found TF integration: $tfint" 
    }


    set i [ lsearch -start $rcstart -exact  $mylist "ECL delay" ]
    if { $i == -1 } { 
	puts "No ECL delay!" 
    } else { 
	set ecldelay [ lindex $mylist [expr $i+1] ] 
	puts "Found ECL delay: $ecldelay"
    }

    if {  [string equal $ecldelay " on"] } {
	set ecldelay 1
    } else {
	set ecldelay 0
    }


#blractive in newer versions has been given a FP control (moved from "common"
#section).  This search for blractive will give the rc value if this is
#the case, or the common case from earlier version, since the common settings
#follow the RC settings.  I leave it this not quite knowing how it will be
#broken next

    set i [ lsearch -start $rcstart -exact  $mylist "BLR active" ]
    if { $i == -1 } { set blractive "0" } else { set blractive "1" }
    
#    if { [ string equal $blractive "BLR active" ] } {
#	set blractive "1"
#    } else { set blractive "0" }

#    incr i

    set i [ lsearch -start $rcstart -exact  $mylist "common mode" ]
    if { $i == -1 } { set ctlmode "1" } else { set ctlmode "0" }

#are we in remote control? either "rc on" or "rc off"

    set i [ lsearch -start $rcstart -exact  $mylist "rc on" ]
    if { $i == -1 } { set rc "0" } else { set rc "1" }


#--------done getting the rc settings

#--------begin getting common settings.


    set i [ lsearch -start $commonstart -exact  $mylist "BLR thresh" ]
    if { $i == -1 } { 
	puts "No BLR threshold!" 
    } else { 
	set blrthreshold [ lindex $mylist [expr $i+1] ] 
    }

    set i [ lsearch -start $commonstart -exact  $mylist "Coincidence time" ]
    if { $i == -1 } { 
	puts "No coincidence time!" 
    } else { 
	set coinc_time [ lindex $mylist [expr $i+1] ] 
    }

#all version info...

    set i [ lsearch -start $commonstart -regexp  $mylist {(flash)}  ]
    if { $i == -1 } { 
	set flashversion "" 
    } else {
	set flashversion [ lindex $mylist [expr $i+1] ] 
    }


    set i [ lsearch -start $commonstart -regexp $mylist {(software version)}  ]
    if { $i == -1 } { 
	set version "" 
    } else {
	set version [ lindex $mylist [expr $i+1] ] 
    }


    set i [ lsearch -start $commonstart -regexp $mylist {(firmware version)} ]
    if { $i == -1 } { 
	set fwversion "" 
    } else {
	set fwversion [ lindex $mylist [expr $i+1] ] 
    }
   

#---done getting common settings    

#---begin gettin the front panel settings.  These actually occur FIRST in the
# text...

    set i [ lsearch -start $fpstart -exact  $mylist "gains" ]
    if { $i == -1 } { puts "No gains!" } else { set FPgains [ lindex $mylist [expr $i+1] ] }



    set i [ lsearch -start $fpstart -exact  $mylist "threshs" ]
    if { $i == -1 } { puts "No thresholds!" } else { set FPthresholds [ lindex $mylist [expr $i+1] ] }



    set i [ lsearch -start $fpstart -exact  $mylist "pz" ]
    if { $i == -1 } { puts "No polezeros!" } else { set FPpolezeros [ lindex $mylist [expr $i+1] ] }


    set i [ lsearch -start $fpstart -exact  $mylist "shts" ]
    if { $i == -1 } { puts "No shapetimes!" } else { set FPshapetimes [ lindex $mylist [expr $i+1] ] }


    set i [ lsearch -start $fpstart -exact  $mylist "mult" ]
    if { $i == -1 } { puts "No multiplicities!" } else { set FPmultlimits [ lindex $mylist [expr $i+1] ] }



    set i [ lsearch -start $fpstart -exact  $mylist "monitor" ]
    if { $i == -1 } { 
	puts "No monitor!" 
    } else { 
	set FPmonitor [ lindex $mylist [expr $i+1] ] 
    }

    if {  [string equal $FPmonitor " off"] } {
	set FPmonitor 0
    }


    set i [ lsearch -start $fpstart -exact  $mylist "common mode" ]
    if { $i == -1 } { set FPctlmode "1" } else { set FPctlmode "0" }

#ctrlmode is either "single mode" or "common mode"
    if { [ string equal $FPctlmode "single mode" ] } {
	set FPctlmode "1"
    } else { set FPctlmode "0" }

    return ""
#--whew done

}


#procedures for rc bus
#######
#General note... remember most parameters have indexes that START
#with ONE.  So ONE must be subtracted to get the offset from starting
#addresses when computing the index
#
proc mscf16::rcbus::setgain { handle group value } {
    variable bus
    variable address
    variable startgainadr

    set varadr [expr $group + $startgainadr - 1]
    return [ execcmd $handle "se $bus $address $varadr $value" ] 
}

proc mscf16::rcbus::setshape { handle group value } {
    variable bus
    variable address
    variable startshapingadr

    set varadr [expr $group + $startshapingadr - 1]
    return [ execcmd $handle "se $bus $address $varadr $value" ] 
}

proc mscf16::rcbus::setthreshold { handle chan value } {
    variable bus
    variable address
    variable startthreshadr

    set varadr [expr $chan + $startthreshadr - 1]
    return [ execcmd $handle "se $bus $address $varadr $value" ] 

}

proc mscf16::rcbus::setpz { handle chan value } {
    variable bus
    variable address
    variable startpzadr

    set varadr [expr $chan + $startpzadr - 1]
    return [ execcmd $handle "se $bus $address $varadr $value" ] 

}
###########
#turn on and off the rc parameters.
#HAH.  According to the manual, a write to the rcaddress should be
#able to set the module on or off, but it fails!  Have to use the 
#mrc-1 modules "on" and "off" commands.
proc mscf16::rcbus::setrc { handle value } {
    variable bus
    variable address
    variable rcadr
#turn remote control on (value 1) or off (value 0)

    set rcon [expr $value % 2 ]
    if { $rcon } {
	return [ execcmd $handle "on $bus $address" ] 
    } else {
	return [ execcmd $handle "off $bus $address" ] 
    }

}

#setmultlimits
#"value" is a list of the high and low limits
proc mscf16::rcbus::setmultlimits { handle value } {
    variable bus
    variable address
    variable startmultadr

    set i 0
    set results ""
    foreach limit $value {
	set addr [expr $startmultadr + $i]
	append results [execcmd $handle "se $bus $address $addr $limit"]
	incr i
	if { $i > 1 } { break }
    }
    return $results
}


proc mscf16::rcbus::setcoinctime { handle value } {
    variable bus
    variable address
    variable coincadr

    return [ execcmd $handle "se $bus $address $coincadr $value" ] 

}


proc mscf16::rcbus::setblrthresh { handle value } {
    variable bus
    variable address
    variable blrthrshadr

    return [ execcmd $handle "se $bus $address $blrthrshadr $value" ] 

}

proc mscf16::rcbus::setblr { handle value } {
    variable bus
    variable address
    variable blradr

    return [ execcmd $handle "se $bus $address $blradr $value" ] 

}

proc mscf16::rcbus::setecl { handle value } {
    variable bus
    variable address
    variable ecladr

    return [ execcmd $handle "se $bus $address $ecladr $value" ] 

}


proc mscf16::rcbus::settfint { handle value } {
    variable bus
    variable address
    variable tfadr

    return [ execcmd $handle "se $bus $address $tfadr $value" ] 

}

proc mscf16::rcbus::setmonitor { handle value } {
    variable bus
    variable address
    variable monitoradr

    return [ execcmd $handle "se $bus $address $monitoradr $value" ] 
}

proc mscf16::rcbus::setmode { handle value } {
    variable bus
    variable address
    variable ctlmodeadr
#go to single channel on (value 1) or common mode (value 0)
    set mode [expr $value % 2 ]
    return [ execcmd $handle "se $bus $address $ctlmodeadr $mode" ] 

}


proc mscf16::rcbus::cpyf { handle } {
    variable bus
    variable address
    return [ execcmd $handle "se $bus $address 99 1 " ] 
}

proc mscf16::rcbus::cpyr { handle } {
    variable bus
    variable address
    return [ execcmd $handle "se $bus $address 99 2 " ] 
}


proc mscf16::rcbus::cpyc { handle } {
    variable bus
    variable address
    return [ execcmd $handle "se $bus $address 99 3 " ] 
}

#this is my implementations of 'copy common' when I thought the
#module function was not available (I've renamed from cpyc to  cpycc)
proc mscf16::rcbus::cpycc { handle } {
    variable bus
    variable address
    variable startgainadr
    variable startthreshadr
    variable startpzadr
    variable startshapingadr

    variable ::mscf16::gains
    variable ::mscf16::shapetimes
    variable ::mscf16::thresholds
    variable ::mscf16::polezeros
    variable ::mscf16::deverror

    set gaincomind [ expr [llength $gains] - 1 ]
    set gaincom [ lindex $gains $gaincomind ]

    for {set i 0} {$i < $gaincomind} {incr i} {
	set ind [expr $i + $startgainadr]
	execcmd $handle "se $bus $address $ind $gaincom" 
        if { $deverror } return
    }


    set shapecomind [ expr [llength $shapetimes] - 1 ]
    set shapecom [ lindex $shapetimes $shapecomind ]

    for {set i 0} {$i < $shapecomind} {incr i} {
	set ind [expr $i + $startshapingadr]
	execcmd $handle "se $bus $address $ind $shapecom" 
        if { $deverror } return
    }


    set threshcomind [ expr [llength $thresholds] - 1 ]
    set threshcom [ lindex $thresholds $threshcomind ]

    for {set i 0} {$i < $threshcomind} {incr i} {
	set ind [expr $i + $startthreshadr]
	execcmd $handle "se $bus $address $ind $threshcom" 
        if { $deverror } return
    }

    set pzcomind [ expr [llength $polezeros] - 1 ]
    set pzcom [ lindex $polezeros $pzcomind ]

    for {set i 0} {$i < $pzcomind} {incr i} {
	set ind [expr $i + $startpzadr]
	execcmd $handle "se $bus $address $ind $pzcom" 
        if { $deverror } return
    }

    return
}


########
proc mscf16::rcbus::getall { handle } {
    variable bus
    variable address
    variable termstring
    variable errstring
    variable limitData

    variable startgainadr
    variable startthreshadr
    variable startpzadr
    variable startshapingadr
    variable startmultadr
    variable monitoradr
    variable ctlmodeadr
    variable rcadr
    variable veradr
    variable blrthrshadr
    variable blradr
    variable coincadr
    variable thrshoffadr
    variable shproffadr

    set modns [namespace parent]
#start
    variable ${modns}::channels
    variable ${modns}::gaingroups
    variable ${modns}::shapinggroups

    variable ${modns}::rc
    variable ${modns}::blrthreshold
    variable ${modns}::blractive
    variable ${modns}::coinc_time
    variable ${modns}::version

    variable ${modns}::thresholds
    variable ${modns}::gains
    variable ${modns}::ctlmode
    variable ${modns}::monitor
    variable ${modns}::multlimits
    variable ${modns}::shapetimes
    variable ${modns}::polezeros

#hmm missing in 'interpall' !!
    variable ${modns}::threshoff
    variable ${modns}::shaperoff

#end
    variable ::mscf16::deverror

    set result ""
    set cmdresult ""
    set lresults {}

    for { set i 0 } { $i < $limitData } {incr i} {
	
	set deverror [ catch { serialusb::send $handle "re $bus $address $i" } ]
	if { $deverror } { return $result }
	set deverror [ catch { serialusb::receive $handle $termstring 200 } cmdresult ]
	if { $deverror } { return $result }
#check for a module error
	set deverror [string match $errstring $cmdresult]
#check for a timeout...
	if { $serialusb::timeError } { set deverror 1 }

	if { $deverror } { return $result }
	set cmdlist [ split $cmdresult " \r\n" ]
	lappend lresults [ lindex $cmdlist 9 ]
	append result $cmdresult
    }
#
#note.. when computing the index to the last element of the list, you would 
#expect it to be (startindex + number_of_elements - 1).  You don't see
#a "-1" because the number_of_elements includes the "common mode" channel
#(this is not true for the multiplicity limits).
#
    set gains [lrange $lresults $startgainadr \
		   [expr $startgainadr + $gaingroups]]
    set thresholds [lrange $lresults $startthreshadr \
			[expr $startthreshadr + $channels]]
    set polezeros [lrange $lresults $startpzadr \
		       [expr $startpzadr + $channels]]
    set shapetimes [lrange $lresults $startshapingadr \
			[expr $startshapingadr + $shapinggroups]]
    set multlimits [lrange $lresults $startmultadr [expr $startmultadr + 1]]
    set monitor [lindex $lresults $monitoradr ]
    set ctlmode [lindex $lresults $ctlmodeadr ]
    set rc [lindex $lresults $rcadr ]
    set blrthreshold [lindex $lresults $blrthrshadr ]
    set blractive [lindex $lresults $blradr ]
    set coinc_time [lindex $lresults $coincadr ]

    set threshoff [lindex $lresults $thrshoffadr ]
    set shaperoff [lindex $lresults $shproffadr ]

    return $lresults


}

#for the rcbus, there are really only two commands to use:
# to read:  re b a m  
# to write: se b a m value
#however, to stay as close to the original intent (and in case it
#is ever necessary to use other commands) an execcmd is
#used as before, and it is up to the calling procedure to
#format the command.

proc mscf16::rcbus::execcmd { handle cmd } {
    variable termstring
    variable ::mscf16::deverror
    variable errstring

    set result ""

    set deverror [ catch { serialusb::send $handle $cmd } result ]
    if { $deverror } { return $result }

    set deverror [ catch { serialusb::receive $handle $termstring 200  } result ]

#check for a module error:
    set deverror [string match $errstring $result]

#check for a timeout...
    if { $serialusb::timeError } { set deverror 1 }

    return $result

}


#test function
proc testlist { handle loops } {
    set lastlist [ mscf16::rcbus::getall $handle ]
    puts $lastlist
    for { set i 0 } { $i<$loops } { incr i } {
	puts "$i"
	set thislist [ mscf16::rcbus::getall $handle ]
	if { $thislist != $lastlist } { break }
    }
}


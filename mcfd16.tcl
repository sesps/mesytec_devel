#Some procedures to format data and commands for the mesytec mcfd-16
#
#For the mcfd-16 there are only TWO front panel settings...
#There are (will be) two modes of operation: USB and "rc bus" 
#("rc bus" and "event bus" both are used in the manual. Unlike the mscf-16,
#there are NOT separate values for front panel operations vs rc EXCEPT
#for cfd and bwl mode (these are the only ones I am aware of).
#
#The manuals list commands with channels and groups numbering starting
#with ZERO.  I observe THIS convention for calling procedures.  

#The "usb" namespace correspond
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

namespace eval mcfd16 {

    variable channels 16
    variable threshlimit 256

    variable gaingroups 8
    variable gainlimit 11
    variable gainvalues {1 3 10}

    variable widthgroups 8
    variable widthlimit 256
    variable widthextrema {11 217}
    variable widthvalues {
	-1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 8 9 -1 10 11 -1 12   \
	-1 13 14 -1 15 16 -1 17 18 -1 19 20 -1 21 22 23 -1 24 \
	25 -1 26 27 -1 28 29 30 -1 31 32 33 -1 34 35 36 -1 37 \
        38 39 -1 40 41 42 43 -1 44 45 46 47 -1 48 49 50 51 52 \
        -1 53 54 55 56 57 58 -1 59 60 61 62 63 64 65 66 67 -1 \
        68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 \
        86 87 89 90 91 92 93 94 95 96 97 99 100 101 102 103 104  \
        106 107 108 109 111 112 113 114 116 117 118 120 121 122  \
        124 125 126 128 129 130 132 133 135 136 138 139 141 142  \
        144 145 147 149 150 152 154 155 157 159 160 162 164 166  \
        167 169 171 173 175 177 179 181 183 185 187 189 191 193  \
        195 198 200 202 204 207 209 212 214 217 219 222 224 227  \
        230 233 235 238 241 244 247 251 254 257 260 264 267 271  \
        275 278 282 286 290 294 299 303 308 \
	    -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 \
	    -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 \
	    -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 \
	    -1 -1 -1 -1 -1 -1 -1 -1
    }

    variable deadgroups 8
    variable deadlimit 256
    variable deadextrema {17 221}
    variable deadvalues {
	    -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 \
	    -1 25 26 27 28 -1 29 31 32 33 34 35 37 38 39 40 42 43 45 46  \
	    48 49 51 52 54 56 57 59 60 62 63 65 67 68 70 72 73 75 77 78  \
	    80 82 83 85 87 88 90 92 94 95 97 99 101 102 104 106 108 110  \
	    112 113 115 117 119 121 123 125 127 129 131 133 135 136 138  \
	    141 143 145 147 149 151 153 155 157 159 161 163 166 168 170  \
	    172 174 177 179 181 183 186 188 190 193 195 197 200 202 205  \
	    207 210 212 215 217 220 222 225 227 230 233 235 238 241 243  \
	    246 249 252 255 257 260 263 266 269 272 275 278 281 284 287  \
            290 294 297 300 303 307 310 313 317 320 323 327 331 334 338  \
	    341 345 349 353 356 360 364 368 372 376 380 384 389 393 397  \
            401 406 410 415 419 424 429 434 439 444 449 454 459 464 469  \
            475 480 486 492 497 503 509 515 522 528 534 541 548 555 562  \
            569 576 584 591 599 607 615 624 632 641 650 660 669 -1 -1 -1 -1 \
		-1 -1 -1 -1 -1 -1 -1 -1 -1 -1 \
	        -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 \
		-1 -1 -1 -1 -1 -1 -1 -1 -1 -1
    }

    variable polargroups 8
    variable polarlimit 1

    variable fractiongroups 8
    variable fractionlimit 40
    variable fractionvalues {20 40}

    variable delaygroups 8
    variable delaylimit 5

    variable coinc_limit 256

#while it was NOT necessary to map the coincidence times, there ARE
#similar glitchs with values "out of range" similar to deadtimes and
#widths.  So, we have to test these too.

    variable coinctimeextrema {0 136}
#timevalues ... these were for a PREVIOUS module, where the maps for
#deadtime and widths were the same.

    variable timevalues { 
	16 16 16 16 17 17 17 18 19 19 20 20 21 22 22 23 \
	24 24 25 25 26 26 27 28 28 29 30 31 31 32 32 33 \
        34 34 35 36 37 37 38 39 39 40 41 41 42 43 43 44 \
        45 45 46 47 47 48 49 50 50 51 52 53 54 54 55 56 \
	56 57 58 59  60 61 62 63 -1 64 65 66 67 -1 68 \
        69 70 71 72 72 73 74 75 76 77 78 79 80 80 81 82 \
        83 84 85 86 87 88 89 90 91 92 93 94 95 96 97 98 \
	99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 115 \
        116 117 118 119 120 122 123 124 125 126 128 129 130 131 133 134 \
        135 137 138 139 140 142 143 145 146 147 149 150 152 153 155 156 \
        158 159 161 162 164 165 167 168 170 172 173 175 177 179 180 182 \
        184 186 187 189 191 193 195 197 199 201 203 205 207 209 211 214 \
        216 218 220 223 225 227 230 232 235 237 240 242 245 248 251 253 \
        256 259 262 265 268 272 275 278 282 285 289 292 296 300 304 308 \
        312 316 321 325 330 335 340 345 350 356 361 367 374 380 387 394 \
	402 409 418 427 436 446 456 468 480 494 509 525 544 565 590 620 
    }


    variable devset "usb"
    variable deverror 0

    namespace eval usb {
        variable device "/dev/ttyUSB0"
	variable termstring "mcfd-16>"
	variable termstringon "mcfd-16>"
	variable termstringoff "mcfd-16>"
	variable errstring "ERROR"
    }
#rcbus notes...
#unlike the mscf modules, the 'common' mode settings are in a separate
#space on the rcbus space, rather than distributed with the individual
#channel settings. :(
#ALSO the rcbus has following deficiencies (from feb2013)
#-- turning on/off remote.  The variable change occurs, but has NO effect
#   (module ALWAYS responds to commands).
#-- There is NO bandwidth limit address!  No way to set this from rcbus.
#-- There is NO cfd/leading edge address! No way to set this from rcbus.

    namespace eval rcbus {
        variable device "/dev/ttyUSB0"
        variable address 0
	variable bus 0
	variable termstring "mrc-1>"
#the mrc1 uses variable error strings!  however "ERR" is common
	variable errstring "*ERR*"
	variable limitData 134

	variable startthreshadr 0
	variable commonthreshadr 64
	variable startgainadr 16
	variable commongainadr 65

        variable startwidthadr 24
	variable commonwidthadr 66

        variable startdeadadr 32
	variable commondeadadr 67

	variable startdelayadr 40
	variable commondelayadr 68
	
	variable startfractionadr 48
	variable commonfractionadr 69

	variable startpolaradr 56
	variable commonpolaradr 70






	variable ctlmodeadr 72
	variable rcadr 73

	variable coincadr 76
	variable monitoradr 78
#unclear in manual if gategenadr is supported
#       variable gategensrcadr 131

#:( wild  guess for bwladr  WILL NOT USE IT. 
	variable bwladr 71
#:( wild  guess for cfdadr  WILL NOT USE IT. 
	variable cfdadr 71

#constantly changing support for 'channel mask' (now a 'group mask')
	variable maskadr 83

	variable pulseradr 118

	variable startmultadr 132

    }

    
#    variable remote
    variable rc 0

    variable bwlactive 0
    variable cfdmode 0
    variable coinc_time 0
    variable version
    variable fwversion
    variable flashversion

    variable thresholds {0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0}
    variable gains      {0 0 0 0 0 0 0 0 0}
    variable widths     {0 0 0 0 0 0 0 0 0}
    variable deadtimes  {0 0 0 0 0 0 0 0 0}
    variable delays     {0 0 0 0 0 0 0 0 0}
    variable fractions  {20 20 20 20 20 20 20 20 20}
    variable polars     {0 0 0 0 0 0 0 0 0}

    variable ctlmode 0
    variable pulser 0
    variable channelmasks {0 0}
    variable maskedinpairs 1
    variable multlimits {0 0}


#end mcfd16 namespace
}
# map
#procedure to return a index for a value from a map (a list). This is used in
#cases where a device has a parameter set in a digital range.
#but returns values in a translated range. (eg. the mcfd16 takes a setting 
#of 0 to 255 for deadtime, but reports numbers from 3 to 620, and highly 
#nonlinear). If there is no value in the map, and a value is provided, 
#the supplied value is added to the map.  If it fails, -1 is returned.
#
#This procedure can be used to create and populate a map, if it is unknown.
#
#This version was written before it became apparent that the extrema of
#map (the minimum and maximum index values for the map) would be required.
#Without the extrema, the module gets to select what it does with values
#outside the mapped region, and in the rcbus case, values set too high
#(above the range) actually came back to 'zero'.  The extrema were found 
#by inspection, but this function could be easily added.
#
proc mcfd16::map { mappedval mapname {value -1} {maprange 0}} {
#for simplicity, work with a copy...
    set locallist [subst $$mapname]
    if { $locallist == {} } {
	for { set i 0 } { $i < $maprange } { incr i } {
	    lappend locallist -1
	}
    }
#see if it is in the map    
    set currentval [lsearch -exact $locallist $mappedval ]
    if { $currentval == -1 } {
	if { $value >= 0 } {
	    set newmap [lreplace $locallist  $value $value $mappedval ]
	    set $mapname $newmap
	    set currentval $value
	}
    }

    return $currentval
}

#need a procedure to run through all set values, for something that
#has a map (that we don't know).

proc mcfd16::usb::mapdeadtimes { handle { group 0 }  } {
    variable ::mcfd16::deadlimit
    variable ::mcfd16::deadvalues
#
#if we intended to use this frequently (rather than for a one time
#map) then we would want to add a step where get the groups initial
#value, and at the end return it to this... if it is possible (when
#the map is not known.
#--    
    for { set i 0 } { $i < $deadlimit } { incr i } {      
	set result [ execcmd $handle "sd $group $i" ] 
	set translated \
	    [scan $result "%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%d" ]

	if { $translated != {} } {
	    mcfd16::map $translated mcfd16::deadvalues $i $deadlimit
	}
    }
    return $deadvalues
}

proc mcfd16::usb::mapwidthtimes { handle {group 0}} {
    variable ::mcfd16::widthlimit
    variable ::mcfd16::widthvalues
#
#if we intended to use this frequently (rather than for a one time
#map) then we would want to add a step where get the groups initial
#value, and at the end return it to this... if it is possible (when
#the map is not known.
#    
        for { set i 0 } { $i < $widthlimit } { incr i } {      
	set result [ execcmd $handle "sw $group $i" ] 
	set translated \
	    [scan $result "%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%d" ]

	if { $translated != {} } {
	    mcfd16::map $translated mcfd16::widthvalues $i $widthlimit
	}
    }
   return $widthvalues
}


#general procedures
#
#return the channel, in 0..16 range (make sure channel is in range).
#Channel 16 is the common channel.
proc mcfd16::channel { chan } {
    variable channels
    return [expr ($chan)%($channels+1)]
}

#return the group to which a channel belongs for the gain setting
#this is 0 to groups-1
proc mcfd16::group { chan } {
    variable gaingroups
    variable channels
    set inrangechan [ eval channel $chan ]
    set chnpergrp [expr $channels/$gaingroups]
    return [expr $inrangechan/$chnpergrp ]
}

#return the group to which a channel belongs for the polarities setting
proc mcfd16::polargroup { chan } {
    variable polargroups
    variable channels
    set inrangechan [ eval channel $chan ]
    set chnpergrp [expr $channels/$polargroups]
    return [expr ($inrangechan)/($chnpergrp)]
}

#return the new list if the value is different from the list
#OR it returns and EMPTY list
proc mcfd16::add_if_new { origlist channel newval {offset 0} } {

    set ind [expr $channel - $offset]
    set oldval [lindex $origlist $ind]
    
    if { $newval == $oldval } { return {} }
    
    set newlist [lreplace $origlist $ind $ind $newval ]

    return $newlist
}

#this function calls the appropriate proc to read ALL values.
proc mcfd16::getall { handle } {
    variable devset
    ${devset}::getall $handle
}

#this function calls the appropriate proc to set the gain values.
#the mcfd16 only permits discrete gains... so a request to
#change gain has to look at the new value and find the 'next' one
#in the list.
proc mcfd16::setgain { handle channel value } {
    variable devset
    variable gains
    variable gainvalues

    set thegroup [group $channel]
#first find the index of the current gain in the list of allowed gains
    set currentgain [lindex $gains $thegroup]
    if { $currentgain == $value } { 
	return $currentgain
    } else {

        set oldindex [lsearch $gainvalues $currentgain]

	if { $value < $currentgain } {
	    set newindex [ expr $oldindex - 1 ]
	} else {
	    set newindex [ expr $oldindex + 1 ]
	}
	set value [ lindex $gainvalues $newindex ]
	if { $value == ""  } { return $currentgain }
    }

    set newgains [ add_if_new $gains $thegroup $value ]

    if { $newgains != {} } {
	${devset}::setgain $handle $thegroup $value
	set gains $newgains
    }

    return $value
}

#this function calls the appropriate proc to set the polarity values.
proc mcfd16::setpolarity { handle channel value } {
    variable devset
    variable polars

    set thegroup [polargroup $channel]
    set newpolarities [ add_if_new $polars $thegroup $value ]

    if { $newpolarities != {} } {
	${devset}::setpolarity $handle $thegroup $value
	set polars $newpolarities
    }

    return
}


#this function calls the appropriate proc to set the fraction values.
#the allowed fraction values are 20 and 40.  So, force with division
#by interval, and adding back offset to restore to interval

proc mcfd16::setfraction { handle channel value } {
    variable devset
    variable fractions

    set thegroup [group $channel]
    set newvalue [expr ( ($value/20-1)%2 +1)*20]

    set newfractions [ add_if_new $fractions $thegroup $newvalue ]

    if { $newfractions != {} } {
	${devset}::setfraction $handle $thegroup $newvalue
	set fractions $newfractions
    }

    return
}

#this function calls the appropriate proc to set the delay tap.
#the allowed fraction values are 1 to delaylimit.  So, force with division
#by interval, and adding back offset (one).  NOTE!! the rc values are
#are 0-4, so they must be returned adjusted!

proc mcfd16::setdelay { handle channel value } {
    variable devset
    variable delays
    variable delaylimit

    set thegroup [group $channel]
    set newvalue [expr ($value-1)%$delaylimit +1]

    set newdelays [ add_if_new $delays $thegroup $newvalue ]

    if { $newdelays != {} } {
	${devset}::setdelay $handle $thegroup $newvalue
	set delays $newdelays
    }

    return
}

proc mcfd16::setthreshold { handle channel value } {
    variable devset
    variable thresholds

    set newthreshs [ add_if_new $thresholds $channel $value ]

    if { $newthreshs != {} } {
	${devset}::setthreshold $handle $channel $value
	set thresholds $newthreshs
    }

    return
}

proc mcfd16::setwidth { handle channel value } {
    variable devset

    variable widths
    variable widthroups
    variable widthextrema

    if { $value < [lindex $widthextrema 0] } \
	{ set value [lindex $widthextrema 0]}
    if { $value > [lindex $widthextrema 1] } \
	{ set value [lindex $widthextrema 1]}

    set thegroup [group $channel]
    set newwidth [ add_if_new $widths $thegroup $value ]

    if { $newwidth != {} } {
	${devset}::setwidth $handle $thegroup $value
	set widths $newwidth
    }

    return
}


proc mcfd16::setdeadtime { handle channel value } {
    variable devset

    variable deadtimes
    variable deadgroups
    variable deadextrema

    if { $value < [lindex $deadextrema 0] } { set value [lindex $deadextrema 0]}
    if { $value > [lindex $deadextrema 1] } { set value [lindex $deadextrema 1]}

    set thegroup [group $channel]
    set newdeadtime [ add_if_new $deadtimes $thegroup $value ]

    if { $newdeadtime != {} } {
	${devset}::setdeadtime $handle $thegroup $value
	set deadtimes $newdeadtime
    }

    return
}


proc mcfd16::setrc { handle value } {
    variable devset
    variable rc

#turn remote control on (value 1) or off (value 0)
    ${devset}::setrc $handle $value
    set rc [expr $value % 2]    
}




proc mcfd16::setmode { handle value } {

    variable devset
    variable ctlmode

    set value [ expr $value % 2 ]
    ${devset}::setmode $handle $value

    set ctlmode $value

    return

}

proc mcfd16::setpulser { handle value } {

    variable devset
    variable pulser

    set value [ expr $value % 2 ]

    ${devset}::setpulser $handle $value
    
    set pulser $value

    return

}

# --ddc jan13 ... MANY changes from evaluation model
proc mcfd16::setmultlimits { handle low high } {

    variable devset
    variable multlimits

    set limit 16
    set low [ expr (($low-1) % $limit + 1) ]
    set high [ expr (($high-1) % $limit + 1) ]

#note! the list of multiplicity limits is LOW then HIGH
    set value [ list $low $high ]
    ${devset}::setmultlimits $handle $value

    set multlimits $value

    return

}

#setbwl
#turns on (1) and off (0) the bandwidth limit
proc mcfd16::setbwl { handle value } {

    variable devset
    variable bwlactive

    set value [ expr $value % 2 ]
    ${devset}::setbwl $handle $value

    set bwlactive $value

    return

}

#setchannelmasks
#this sets a 16bit mask (if changed)
#a 16bit mask is used (for input), even though the module uses
#two 8bit masks
#
# --ddc jan13, Now, it appears that the module only uses ONE 8 bit
# mask, and the channels are masked in PAIRS.
# so it seems this is a change from the prototype 
# that was supplied to us, and STILL counter to the manual in
# the commands sections.  Start by assuming that we _set_ only
# one mask, AND, just to make thing easier, I emulate the double
# mask behavior here, so that any future changes are only HERE,
# (and of course, where ever the mask is read).  
# ALSO!!!! At this time, the command to set the register is foobar.
# It still requires two arguments, BUT it only uses the value of
# the FIRST ONE.  The message if you use it (by hand) with only one argument
# is WRONG.  It does NOT use the register, so, I'll just repeat the
# mask
# 
proc mcfd16::setchannelmasks { handle value } {

    variable devset
    variable channelmasks
    variable maskedinpairs

    set lovalue [ expr $value & 0xff ]
    set hivalue [ expr ($value >> 8) & 0xff ]
    
    set nextmasks [list $lovalue $hivalue ] 

    if { $channelmasks != $nextmasks } {
	if { $maskedinpairs } {
	    set oldlo  [lindex $channelmasks 0]
	    set oldhi  [lindex $channelmasks 1]
	    set lovalue [eval maskjoinif $lovalue $oldlo 2]
	    set hivalue [eval maskjoinif $hivalue $oldhi 2]
	    set onemask [expr $hivalue<<4 | $lovalue]
	    ${devset}::setmask $handle $onemask $onemask
#now, if we were handed mask NOT set in pairs, we set the bits
#in it for the additional channels set.
	    set onemask [eval masksplit $onemask 2]
	    set lovalue [expr $onemask&0xff]
	    set hivalue [expr ($onemask>>8)&0xff]
	    set nextmasks [list $lovalue $hivalue ] 

	} else {
	    ${devset}::setmask $handle 0 $lovalue 
	    ${devset}::setmask $handle 1 $hivalue 
	}
	set channelmasks $nextmasks
    }

    return

}

#setcfd
#turns on (1) and off (0) cfd mode
proc mcfd16::setcfd { handle value } {

    variable devset
    variable cfdmode

    set value [ expr $value % 2 ]
    ${devset}::setcfd $handle $value

    set cfdmode $value

    return

}

#setcoinctime
#sets the coincidence time in the range.
proc mcfd16::setcoinctime { handle value } {

    variable devset
    variable coinc_time
#    variable coinc_limit
    variable coinctimeextrema

#insufficient!    set value [ expr $value % $coinc_limit ]
 
    if { $value < [lindex $coinctimeextrema 0] } \
	{ set value [lindex $coinctimeextrema 0]}
    if { $value > [lindex $coinctimeextrema 1] } \
	{ set value [lindex $coinctimeextrema 1]}
 
    ${devset}::setcoinctime $handle $value

    set coinc_time $value

    return

}

#copy FP to RC parameters.  For the USB bus this is done by the module (at this time,
#appears to be unimplemented for rc bus)
proc mcfd16::cpyf { handle } {

    variable devset
    variable ctlmode

    ${devset}::cpyf $handle

    return

}

#copy common to single.  At this time,
#appears NOT to be a module function.
proc mcfd16::cpyc { handle } {

    variable channels

    variable thresholds 
    variable gains
    variable widths
    variable deadtimes
    variable delays
    variable polars
    variable fractions


    set comval [ lindex $thresholds end ]
    for {set i 0} { $i < $channels } {incr i} {
	setthreshold $handle $i $comval
    }
    
    set comval [ lindex $gains end ]
    for {set i 0} { $i < $channels } {incr i} {
	setgain $handle $i $comval
    }

    set comval [ lindex $widths end ]
    for {set i 0} { $i < $channels } {incr i} {
	setwidth $handle $i $comval
    }

    set comval [ lindex $deadtimes end ]
    for {set i 0} { $i < $channels } {incr i} {
	setdeadtime $handle $i $comval
    }

    set comval [ lindex $delays end ]
    for {set i 0} { $i < $channels } {incr i} {
	setdelay $handle $i $comval
    }

    set comval [ lindex $polars end ]
    for {set i 0} { $i < $channels } {incr i} {
	setpolarity $handle $i $comval
    }


    set comval [ lindex $fractions end ]
    for {set i 0} { $i < $channels } {incr i} {
	setfraction $handle $i $comval
    }

    return

}


#
#setrcbus
#checks, and sets the rcbus parameters.  Note that there
#are not separate procedures for this since there is no
#analog for the "usb" device.
#
proc mcfd16::setrcbus { nextbus nextaddress } {

    variable rcbus::bus
    variable rcbus::address

    set bus [ expr $nextbus % 2 ]
    set address [ expr $nextaddress % 16 ]

    return

}


#--------some utility functions
#found useful... return list of gains for the _channels_
proc mcfd16::channel_gains {} {
    variable gains
    variable gaingroups
    variable channels

    set chnpergrp [expr $channels/$gaingroups]
    set chanlist {}
    for {set i 0} {$i<$channels} {incr i} {
	lappend chanlist [lindex $gains [expr $i/$chnpergrp]]
    }
    lappend chanlist [lindex $gains end]
    return $chanlist
}

#found useful... return list of fractions for the _channels_
proc mcfd16::channel_fractions {} {
    variable fractions
    variable fractiongroups
    variable channels

    set chnpergrp [expr $channels/$fractiongroups]
    set chanlist {}
    for {set i 0} {$i<$channels} {incr i} {
	lappend chanlist [lindex $fractions [expr $i/$chnpergrp]]
    }
    lappend chanlist [lindex $fractions end]
    return $chanlist
}

proc mcfd16::channel_delays {} {
    variable delays
    variable delaygroups
    variable channels

    set chnpergrp [expr $channels/$delaygroups]
    set chanlist {}
    for {set i 0} {$i<$channels} {incr i} {
	lappend chanlist [lindex $delays [expr $i/$chnpergrp]]
    }
    lappend chanlist [lindex $delays end]
    return $chanlist
}



#found useful... return list of polarities for the _channels_
proc mcfd16::channel_polarities {} {
    variable polars
    variable polargroups
    variable channels

    set chnpergrp [expr $channels/$polargroups]
    set chanlist {}
    for {set i 0} {$i<$channels} {incr i} {
	lappend chanlist [lindex $polars [expr $i/$chnpergrp]]
    }
    lappend chanlist [lindex $polars end]
    return $chanlist
}


#found useful... return list of deadtimes for the _channels_
proc mcfd16::channel_deadtimes {} {
    variable deadtimes
    variable deadgroups
    variable channels

    set chnpergrp [expr $channels/$deadgroups]
    set chanlist {}
    for {set i 0} {$i<$channels} {incr i} {
	lappend chanlist [lindex $deadtimes [expr $i/$chnpergrp]]
    }
    lappend chanlist [lindex $deadtimes end]
    return $chanlist
}


#found useful... return list of widths for the _channels_
proc mcfd16::channel_widths {} {
    variable widths
    variable widthgroups
    variable channels

    set chnpergrp [expr $channels/$widthgroups]
    set chanlist {}
    for {set i 0} {$i<$channels} {incr i} {
	lappend chanlist [lindex $widths [expr $i/$chnpergrp]]
    }
    lappend chanlist [lindex $widths end]
    return $chanlist
}


#found useful... return 16bit mask
proc mcfd16::maskedchannels {} {
    variable channelmasks

    set lomask [lindex $channelmasks 0]
    set himask [lindex $channelmasks 1]
    set mask16 [ expr ($himask <<8) | $lomask ]

    return $mask16

}


#procedures for usb bus

proc mcfd16::usb::getall { handle } {
    variable termstring
    variable ::mcfd16::deverror

    set result ""
    set deverror [ catch { serialusb::send $handle "ds" } ]
    if { $deverror } { return $result }
    set deverror [ catch { serialusb::receive $handle $termstring 2000 } result ]
    if { $deverror } { return $result }
#check for a module error
    set deverror [string match "*ERROR*" $result]
#check for a timeout...
    if { $serialusb::timeError } { set deverror 1 }

    ::mcfd16::interpds $result

###
    set dtresult ""
    set deverror [ catch { serialusb::send $handle "dt" } ]
    if { $deverror } { return $dtresult }
    set deverror [ catch { serialusb::receive $handle $termstring 2000 } dtresult ]
    if { $deverror } { return $dtresult }
#check for a module error
    set deverror [string match "*ERROR*" $dtresult]
#check for a timeout...
    if { $serialusb::timeError } { set deverror 1 }

    ::mcfd16::interpdt $dtresult

    append result $dtresult
    

    
    return $result
}

proc mcfd16::usb::setgain { handle group value } {
    return [ execcmd $handle "sg $group $value" ] 
}

proc mcfd16::usb::setpolarity { handle group value } {
    return [ execcmd $handle "sp $group $value" ] 
}

proc mcfd16::usb::setdelay { handle group value } {
    return [ execcmd $handle "sy $group $value" ] 
}

proc mcfd16::usb::setfraction { handle group value } {
    return [ execcmd $handle "sf $group $value" ] 
}

proc mcfd16::usb::setthreshold { handle chan value } {
    return [ execcmd $handle "st $chan $value" ] 
}

proc mcfd16::usb::setwidth { handle group value } {
    variable ::mcfd16::widthlimit
    set result [ execcmd $handle "sw $group $value" ] 
    return $result
}

proc mcfd16::usb::setdeadtime { handle group value } {
#    variable ::mcfd16::deadlimit
#    variable ::mcfd16::deadvalues
    set result [ execcmd $handle "sd $group $value" ] 
#    set translated \
	[scan $result "%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%d" ]

#    if { $translated != {} } {
#	mcfd16::map $translated ::mcfd16::deadvalues $value $deadlimit
#    }

    return $result
}


proc mcfd16::usb::setrc { handle value } {
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
#--ddc jan13 completely changed from evaluation model. only ONE command
#  and the range of values is different.
#"value" is a list of the high and low limits
proc mcfd16::usb::setmultlimits { handle value } {
    set low  [lindex $value 0]
    set high [lindex $value 1]
    set result1 [ execcmd $handle "sm $low $high" ]
#    set result2 [ execcmd $handle "sm 1 $high" ]
    return "$result1"
}


proc mcfd16::usb::setcoinctime { handle value } {
    return [ execcmd $handle "sc $value" ] 
}

proc mcfd16::usb::setmask { handle register value } {
    return [ execcmd $handle "sk $register $value" ] 
}

proc mcfd16::usb::setbwl { handle value } {
    return [ execcmd $handle "bwl $value" ] 
}

proc mcfd16::usb::setcfd { handle value } {
    return [ execcmd $handle "cfd $value" ] 
}


proc mcfd16::usb::setmode { handle value } {
#go to single channel on (value 1) or common mode (value 0)
    if { $value == 0 } {
	return [ execcmd $handle "mc" ] 
    } else {
	return [ execcmd $handle "mi" ] 
    }
}


proc mcfd16::usb::cpyf { handle } {
    return [ execcmd $handle "cpy f" ] 
}

proc mcfd16::usb::setpulser { handle value } {
#turn on pulser (off by default)
    if { $value == 1 } {
	return [ execcmd $handle "p1" ] 
    } else {
	return [ execcmd $handle "p0" ] 
    }
}

proc mcfd16::usb::cpyc { handle } {
    return [ execcmd $handle "cpy c" ] 
}

proc mcfd16::usb::execcmd { handle cmd } {
    variable termstring
    variable ::mcfd16::deverror

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


#mcfd has THREE different commands for getting 
#results: ds, dt, dp.  There IS some overlap of 
#functions...

#interpds
#this a utility procedure, to decode the results, from the formatted
#ouput from the module.  It is NOT used for the rcbus, as there is
#no analog to the 'ds' command on the rc bus
# 

proc mcfd16::interpds { ds_results } {

    variable gains
    variable thresholds
    variable fractions
    variable delays
    variable polars
    variable rc
    variable ctlmode
    variable pulser
    variable bwlactive
    variable cfdmode
    variable widths
    variable deadtimes
    variable channelmasks
    variable maskedinpairs
    variable coinc_time


#first get rid of " - " from the string.
    
    set myresult [ string map -nocase { " - " " " } $ds_results ]

    set mylist [ split $myresult ":,\n" ]

#get the thresholds
    set localthreshs {}
    set i [ lsearch -exact $mylist "Threshold" ]
    if { $i < 0 } {  
	puts Error!
	return
    }
    incr i
    set mystring [string trim [lindex $mylist $i]]
    incr i
    append mystring " " [string trim [lindex $mylist $i]]
    set localthreshs [ split $mystring " " ]


#get the gains,widths,deadtimes,delays,fractions
    set localgains {}
    set localwidths {}
    set localdeadtimes {}
    set localdelays {}
    set localfractions {}

    set i [ lsearch -exact $mylist "Gain" ]
    if { $i < 0 } {  
	puts Error!
	return
    }
    incr i 
    set mystring [string trim [lindex $mylist $i]]
    set localgains [split $mystring " " ] 
    incr i 2
    set mystring [string trim [lindex $mylist $i]]
    set localwidths [split $mystring " " ] 
    incr i 2
    set mystring [string trim [lindex $mylist $i]]
    set localdeadtimes [split $mystring " " ] 
    incr i 2
    set mystring [string trim [lindex $mylist $i]]
    set localdelays [split $mystring " " ] 
    incr i 2
    set mystring [string trim [lindex $mylist $i]]
    set localfractions [split $mystring " " ] 

    set widths {}
    foreach j $localwidths {
	lappend widths [ map $j ::mcfd16::widthvalues ]
    }

    set deadtimes {}
    foreach j $localdeadtimes {
	lappend deadtimes [ map $j ::mcfd16::deadvalues ]
    }

    set gains $localgains
    set delays $localdelays
    set thresholds $localthreshs
    set fractions $localfractions

#get and interpret the polarities 'pos' is positive
    set localpols {}
    incr i 2
    set mystring [string trim [lindex $mylist $i]]
    foreach j $mystring {
	if {[string match $j "pos"]} {
	    lappend localpols 0
	} else {
	    lappend localpols 1
	}
    }

    set polars $localpols

#get and interpret mask registers
    set i [ lsearch -exact $mylist "Mask register" ]
    if { $i < 0 } {  
	puts Error!
	return
    }
#    incr i 2
    incr i 1
    set mystring [lindex $mylist $i]
#--ddc .. oh oh.  there was a change the format from
#   from individual channels, to well, pairs!)

#    set maskHi [scan $mystring "%*s (%d)" ]
#    set maskHi [scan $mystring "%*s (%d)" ]
#    incr i 2
#    set mystring [lindex $mylist $i]
#    set maskLo [scan $mystring "%*s (%d)" ]
#    set mystring2 [ join $mystring ]
#    regsub -all {/} $mystring2 " " mystring
#    global maskHi 
#    global maskLo
#    scan $mystring "%*s %*s %*d %d...%*d %d" maskHi maskLo 
    if { [ string first "pairs" $mystring ] < 0 } {
	set maskedinpairs 0
	incr i 1
	set mystring [lindex $mylist $i]
	set maskHi [scan $mystring "%*s (%d)" ]
	incr i 2
	set mystring [lindex $mylist $i]
	set maskLo [scan $mystring "%*s (%d)" ]
    } else {
	#pairs! only ONE 8bit mask.
	set maskedinpairs 1
	incr i 1
	set mystring [lindex $mylist $i]
	set onemask [scan $mystring "%*s (%d)" ]
	set maskLo 0
	set maskHi 0
	for { set j 0 } {$j < 8} {incr j} {	
	    set maskLo [expr $maskLo | (($onemask>>($j/2))&1) << $j ]
	}
	for { set j 8 } {$j < 16} {incr j} {	
	    set maskHi [expr $maskHi | (($onemask>>($j/2))&1) << ($j-8) ]
	}
	
    }

    set channelmasks [list $maskLo $maskHi]


#get and interpret the remote control descrimination setting
    set i [ lsearch -exact $mylist "Discrimination" ]
    if { $i < 0 } {  
	puts Error!
	return
    }

    incr i
    set mystring [lindex $mylist $i]
    if {[string match $mystring " Constant fraction"]} {
	set localdescrimination 1
    } else {
	set localdescrimination 0
    }

    set cfdmode $localdescrimination

#get and interpret the gate settings

    set i [ lsearch -exact $mylist "Gate" ]
    if { $i < 0 } {  
	puts Error!
	return
    }

    set localgatetimes {}
    incr i 2
    lappend localgatetimes [lindex $mylist $i]
    incr i 2
    lappend localgatetimes [lindex $mylist $i]

#    puts "gate times: $localgatetimes"

#get and interpret the global coincidence time;
#Global coincidence time: 20 (= 13 ns)

    set i [ lsearch -exact $mylist "Global coincidence time" ]
    if { $i < 0 } {  
	puts Error!
	return
    }

    incr i
    set mystring [lindex $mylist $i]
   
    set localglobalcoinctime [scan $mystring " %d %*s"]
    if { $localglobalcoinctime ==  [list ""] } {
	set localglobalcoinctime 0
    }

#    puts "Global coincidence time: $localglobalcoinctime"
    set  coinc_time $localglobalcoinctime
#get the modes ...
#Operating mode: Common
#Bandwidth limit: Off
#Remote Control: Off

    set i [ lsearch -exact $mylist "Operating mode" ]
    if { $i < 0 } {  
	puts Error!
	return
    }

    incr i
    set mystring [lindex $mylist $i]
    if { [string match $mystring " Common"] } {
	set localmode 0
    } else {
	set localmode 1
    }

    set ctlmode $localmode

    incr i 2
    set mystring [lindex $mylist $i]
    if { [string match $mystring " Off"] } {
	set localbwl 0
    } else {
	set localbwl 1
    }

    set bwlactive $localbwl

    incr i 2
    set mystring [lindex $mylist $i]
    if { [string match $mystring " Off"] } {
	set localrc 0
    } else {
	set localrc 1
    }

    set rc $localrc
#    puts "modes: single($localmode) bwl($localbwl) rc($localrc)"

#get the frequency and test pulser settings and interpret.
#Frequency monitor channel: 0
#Test pulser: Off

    set i [ lsearch -exact $mylist "Frequency monitor channel" ]
    if { $i < 0 } {  
	puts Error!
	return
    }

    incr i
    set localmonitor [lindex $mylist $i]

    incr i 2
    set mystring [lindex $mylist $i]
    if { [string match $mystring " Off"] } {
	set localpulser 0
    } else {
	set localpulser 1
    }

     set pulser $localpulser
}

proc mcfd16::interpdt { dt_results } {
    variable multlimits

    set mylist [ split $dt_results ":,\n" ]

#get and interpret the multiplicities
    set localmults {}
    set i [ lsearch -exact $mylist "Multiplicity" ]
    if { $i < 0 } {  
	puts Error!
	return
    }
    incr i 
    set mystring [lindex $mylist $i]
    set localmults [scan $mystring " from %d to %d" ]

#    puts "multiplicities $localmults"
    set multlimits $localmults

#get and interpret the trigger monitor channels..

    set localtrigmons {}
    set i [ lsearch -exact $mylist "Trigger monitor channels" ]
    if { $i < 0 } {  
	puts Error!
	return
    }
    incr i 2 
    lappend localtrigmons [lindex $mylist $i]
    incr i 2 
    lappend localtrigmons [lindex $mylist $i]

#    puts "trigger monitors: $localtrigmons"
#get and interpret the OR patterns..

    set localORpatterns {}
    set i [ lsearch -exact $mylist "Ored patterns" ]
    if { $i < 0 } {  
	puts Error!
	return
    }
    incr i 2 
    set mystring [lindex $mylist $i]
    lappend localORpatterns "0x[string trim $mystring]"
    incr i 2 
    set mystring [lindex $mylist $i]
    lappend localORpatterns "0x[string trim $mystring]"

#    puts "Or patterns: $localORpatterns"


#get and interpret the trigger/gate sources
#the trigger and gate sources are displayed as bit maps.  put them
#back together to get the mask (which is used for setting sources).
    set localtrigs {}

    set i [ lsearch -exact $mylist "Trig0" ]
    if { $i < 0 } {  
	puts Error!
	return
    }

    incr i
    set mystring [string trim [lindex $mylist $i]]
    set mask [makemask $mystring]
    lappend localtrigs $mask

    set i [ lsearch -exact $mylist "Trig1" ]
    if { $i < 0 } {  
	puts Error!
	return
    }

    incr i
    set mystring [string trim [lindex $mylist $i]]
    set mask [makemask $mystring]
    lappend localtrigs $mask


    set i [ lsearch -exact $mylist "Trig2" ]
    if { $i < 0 } {  
	puts Error!
	return
    }

    incr i
    set mystring [string trim [lindex $mylist $i]]
    set mask [makemask $mystring]
    lappend localtrigs $mask

#    puts "trigger masks: $localtrigs"

#get the gate generator trigger source 
#note... the mask has 3 bits, BUT, there are 8 bits listed!
#
    set i [ lsearch -exact $mylist "GG" ]
    if { $i < 0 } {  
	puts Error!
	return
    }

    incr i
    set mystring [string trim [lindex $mylist $i]]
    set localgategentrig [makemask $mystring]
#    puts "Gate Generator trigger mask: $localgategentrig"

    return 

}

#
#make a mask from a bit list, presuming they are ordered high to low.
proc mcfd16::makemask { bitlist { maxbits 8 } } {

    set j [expr 1<<($maxbits-1)]
    set mask 0
    foreach bit $bitlist {
	set mask [expr ($mask + $j*(($bit)%2))]
	set j [expr $j/2]
    }

    return $mask

} 

#interpret the results of dp (which, in demo model, is very simple)

proc interpdp { dp_results } {

    set mylist [ split $dp_results ":,\n" ]

#get and interpret the multiplicities

    set i [ lsearch -exact $mylist "Pair coincidence settings" ]
    if { $i < 0 } {  
	puts Error!
	return
    }
    set localpatterns {}
#there are _15_ patterns.
    for { set j 0 } {$j < 15} {incr j} {
	incr i 2 
	set mystring [lindex $mylist $i]
	lappend localpatterns $mystring
    }

#    puts "patterns: $localpatterns"

    return 

}


#procedures for rc bus
#######
#
proc mcfd16::rcbus::setgain { handle group value } {
    variable bus
    variable address
    variable startgainadr

    set modns [namespace parent]
    variable ${modns}::gaingroups
    variable ${modns}::gainvalues
    variable commongainadr
 
    set rcvalue [lsearch $gainvalues $value]

    if { $rcvalue == -1 } { return "setgain out of range" }

    if { $group == $gaingroups } {
	set varadr $commongainadr
    } else {
	set varadr [expr $group + $startgainadr]
    }

    return [ execcmd $handle "se $bus $address $varadr $rcvalue" ] 

}

proc mcfd16::rcbus::setfraction { handle group value } {
    variable bus
    variable address
    variable startfractionadr

    set modns [namespace parent]
    variable ${modns}::fractiongroups
    variable ${modns}::fractionvalues
    variable commonfractionadr

    set rcvalue [lsearch $fractionvalues $value]
    if { $rcvalue == -1 } { return "setfraction out of range" }
    
    if { $group == $fractiongroups } {
	set varadr $commonfractionadr
    } else {
	set varadr [expr $group + $startfractionadr]
    }

    return [ execcmd $handle "se $bus $address $varadr $rcvalue" ] 

}

proc mcfd16::rcbus::setpolarity { handle group value } {
    variable bus
    variable address
    variable startpolaradr
    variable commonpolaradr

    set modns [namespace parent]
    variable ${modns}::polargroups


    if { $group == $polargroups } {
	set varadr [expr $commonpolaradr]
    } else {
	set varadr [expr $group + $startpolaradr]
    }

    return [ execcmd $handle "se $bus $address $varadr $value" ] 

}
#set the delay.
#Remember, the values from the usb side are in range 1 to 5, and
#rc bus values are 0 to 4 :(
proc mcfd16::rcbus::setdelay { handle group value } {
    variable bus
    variable address
    variable startdelayadr
    variable commondelayadr

    set modns [namespace parent]
    variable ${modns}::delaygroups

    set rcvalue [expr $value - 1]

    if { $group == $delaygroups } {
	set varadr [expr $commondelayadr]
    } else {
	set varadr [expr $group + $startdelayadr]
    }

    return [ execcmd $handle "se $bus $address $varadr $rcvalue" ] 

}

proc mcfd16::rcbus::setwidth { handle group value } {
    variable bus
    variable address
    variable startwidthadr
    variable commonwidthadr

    set modns [namespace parent]
    variable ${modns}::widthgroups

 
    if { $group == $widthgroups } {
	set varadr $commonwidthadr
    } else {
	set varadr [expr $group + $startwidthadr]
    }

    return [ execcmd $handle "se $bus $address $varadr $value" ] 

}

proc mcfd16::rcbus::setdeadtime { handle group value } {
    variable bus
    variable address
    variable startdeadadr
    variable commondeadadr

    set modns [namespace parent]
    variable ${modns}::deadgroups

 
    if { $group == $deadgroups } {
	set varadr $commondeadadr
    } else {
	set varadr [expr $group + $startdeadadr]
    }

    return [ execcmd $handle "se $bus $address $varadr $value" ] 

}


proc mcfd16::rcbus::setthreshold { handle chan value } {
    variable bus
    variable address
    variable startthreshadr

    variable commonthreshadr

    set modns [namespace parent]
    variable ${modns}::channels


    if { $chan == $channels } {
	set varadr $commonthreshadr
    } else {
	set varadr [expr $chan + $startthreshadr]
    }
    return [ execcmd $handle "se $bus $address $varadr $value" ] 
    return 0

}

###########
#turn on and off the rc parameters.
#HAH.  According to the manual, a write to the rcaddress should be
#able to set the module on or off, but it fails!  Have to use the 
#mrc-1 modules "on" and "off" commands.
proc mcfd16::rcbus::setrc { handle value } {
    variable bus
    variable address
    variable rcadr
#turn remote control on (value 1) or off (value 0)

    set rcon [expr $value % 2 ]
    if { $rcon } {
	return [ execcmd $handle "on $bus $address" ] 
	return 0
    } else {
	return [ execcmd $handle "off $bus $address" ] 
	return 0
    }

}

#setmultlimits
#"value" is a list of the high and low limits
proc mcfd16::rcbus::setmultlimits { handle value } {
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


proc mcfd16::rcbus::setcoinctime { handle value } {
    variable bus
    variable address
    variable coincadr

    return [ execcmd $handle "se $bus $address $coincadr $value" ] 

}


proc mcfd16::rcbus::setbwl { handle value } {
    variable bus
    variable address
    variable bwladr

    puts "NO RC bus support for bandwidth limit!"
#    return [ execcmd $handle "se $bus $address $bwladr $value" ] 
    return 0

}


proc mcfd16::rcbus::setcfd { handle value } {
    variable bus
    variable address
    variable cfdadr

    puts "NO RC bus support for bandwidth limit!"
#    return [ execcmd $handle "se $bus $address $cfdadr $value" ] 
    return 0

}


proc mcfd16::rcbus::setmode { handle value } {
    variable bus
    variable address
    variable ctlmodeadr
#go to single channel on (value 1) or common mode (value 0)
    set mode [expr $value % 2 ]
    return [ execcmd $handle "se $bus $address $ctlmodeadr $mode" ] 

}
#
proc mcfd16::rcbus::setmask { handle register value } {
    variable bus
    variable address
    variable maskadr

    set modns [namespace parent]
    variable ${modns}::maskedinpairs
#
#IF they ever bring back two masks... maskedinpairs=0.  Although,
#if this happens, determining the maskedinpairs value, may be difficult.
#For the usb device case, it was done from context from the string for
#reporting the value of the mask :(
#
    if { $maskedinpairs } {
	set regadr $maskadr
    } else {
	set regadr [expr $register + $maskadr]
    }
    return [ execcmd $handle "se $bus $address $regadr $value" ] 
}

#
proc mcfd16::rcbus::setpulser { handle value } {
    variable bus
    variable address
    variable pulseradr
#pulser on (value 1) or off (value 0)
    set mode [expr $value % 2 ]
    return [ execcmd $handle "se $bus $address $pulseradr $mode" ] 

}



proc mcfd16::rcbus::cpyc { handle } {
    variable bus
    variable address
#    return [ execcmd $handle "se $bus $address 99 3 " ] 
    return 0
}



########
proc mcfd16::rcbus::getall { handle } {
    variable bus
    variable address
    variable termstring
    variable errstring
    variable limitData

    variable startgainadr
    variable commongainadr

    variable startfractionadr
    variable commonfractionadr

    variable startpolaradr
    variable commonpolaradr

    variable startdelayadr
    variable commondelayadr

    variable startwidthadr
    variable commonwidthadr

    variable startdeadadr
    variable commondeadadr

    variable startthreshadr
    variable commonthreshadr

    variable startmultadr
    variable monitoradr
    variable ctlmodeadr

    variable rcadr
    variable veradr
    variable bwladr
    variable cfdadr
    variable coincadr


    variable maskadr
    variable pulseradr


    set modns [namespace parent]
#start
    variable ${modns}::channels

    variable ${modns}::gains
    variable ${modns}::gaingroups
    variable ${modns}::gainvalues

    variable ${modns}::fractions
    variable ${modns}::fractiongroups
    variable ${modns}::fractionvalues

    variable ${modns}::delays
    variable ${modns}::delaygroups

    variable ${modns}::polars
    variable ${modns}::polargroups

    variable ${modns}::widths
    variable ${modns}::widthgroups

    variable ${modns}::deadtimes
    variable ${modns}::deadgroups

    variable ${modns}::rc
    variable ${modns}::bwlactive
    variable ${modns}::cfdmode

    variable ${modns}::coinc_time
    variable ${modns}::version

    variable ${modns}::thresholds

    variable ${modns}::ctlmode

    variable ${modns}::monitor
    variable ${modns}::multlimits

    variable ${modns}::maskedinpairs
    variable ${modns}::channelmasks
    variable ${modns}::pulser

#end
    variable ::mcfd16::deverror

#debug..    return 0

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
#note.. when computing the index to the last element of the list, you WILL 
#expect it to be (startindex + number_of_elements - 1).  Unlike the mscf
#module, the common mode values are all at DIFFERENT address ranges :)
#
    set rawgains [lrange $lresults $startgainadr \
		   [expr $startgainadr + $gaingroups - 1]]
    set gains {}
    foreach i $rawgains { lappend gains [ lindex $gainvalues $i] }
    lappend gains [lindex $gainvalues [lindex $lresults $commongainadr]]
#
    set rawfrac [lrange $lresults $startfractionadr \
		   [expr $startfractionadr + $fractiongroups - 1]]
    set fractions {}
    foreach i $rawfrac { lappend fractions [ lindex $fractionvalues $i] }
    lappend fractions \
	[lindex $fractionvalues [lindex $lresults $commonfractionadr]]
#
# yep, need to compute the "values" for the delay taps!
#
    set rawdelays [lrange $lresults $startdelayadr \
			[expr $startdelayadr + $delaygroups - 1]]
    set delays {}
    foreach i $rawdelays { lappend delays [expr  $i+1 ] }    
    lappend delays [ expr [lindex $lresults $commondelayadr] + 1 ]
    set polars [lrange $lresults $startpolaradr \
			[expr $startpolaradr + $polargroups - 1]]
    lappend polars [ lindex $lresults $commonpolaradr ]
    set widths [lrange $lresults $startwidthadr \
			[expr $startwidthadr + $widthgroups - 1]]
    lappend widths [ lindex $lresults $commonwidthadr ]
#
    set deadtimes [lrange $lresults $startdeadadr \
			[expr $startdeadadr + $deadgroups - 1]]
    lappend deadtimes [ lindex $lresults $commondeadadr ]

#
    set thresholds [lrange $lresults $startthreshadr \
			[expr $startthreshadr + $channels - 1]]
    lappend thresholds [ lindex $lresults $commonthreshadr ]

    set multlimits [lrange $lresults $startmultadr [expr $startmultadr + 1]]
    set monitor [lindex $lresults $monitoradr ]
    set ctlmode [lindex $lresults $ctlmodeadr ]
    set rc [lindex $lresults $rcadr ]
#add back next two when we HAVE bwladr and coincadr!
#    set bwlactive [lindex $lresults $bwladr ]
#    set cfdmode [lindex $lresults $cfdadr ]

    set coinc_time [lindex $lresults $coincadr ]

#
    set channelmasks [lrange $lresults $maskadr [expr $maskadr + 1]]

    if { $maskedinpairs } {
	set onemask [lindex $channelmasks 0]
	set maskLo 0
	set maskHi 0
	for { set j 0 } {$j < 8} {incr j} {	
	    set maskLo [expr $maskLo | (($onemask>>($j/2))&1) << $j ]
	}
	for { set j 8 } {$j < 16} {incr j} {	
	    set maskHi [expr $maskHi | (($onemask>>($j/2))&1) << ($j-8) ]
	}
	set channelmasks [list $maskLo $maskHi]
    }

#

    set pulser [lindex $lresults $pulseradr ]

    return $lresults


}

#for the rcbus, there are really only two commands to use:
# to read:  re b a m  
# to write: se b a m value
#however, to stay as close to the original intent (and in case it
#is ever necessary to use other commands) an execcmd is
#used as before, and it is up to the calling procedure to
#format the command.

proc mcfd16::rcbus::execcmd { handle cmd } {
    variable termstring
    variable ::mcfd16::deverror
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

#------------------bit operations..----------------------------

#return a  mask with divided number of bits
proc maskjoin { oldmask divisor {masksize 16} } {

    set newmask 0
    set k 0
    for { set i 0 } { $i < $masksize } {set i [expr $i+$divisor]} {
	if { $oldmask == 0 } break
	for { set j 0 } {$j <$divisor} {incr j} {
	    if { [expr $oldmask&(1<<$j)] } {
		set newmask [expr $newmask|(1<<$k)]
		break
	    }
	}
	incr k
	set oldmask [expr $oldmask >> $divisor]
    }
    return $newmask
}

#return a mask with a greater number of bits
#note... masksize is the size of the INPUT mask.
#the output mask will be bigger by the multiplier.
proc masksplit { oldmask multiplier {masksize 16} } {

    set newmask 0
    set submask 0
    for {set i 0} {$i<$multiplier} {incr i} {
	set submask [expr $submask|(1<<$i)]
    }
    set k 0
    for { set i 0 } { $i < $masksize } {incr i} {
	if { $oldmask == 0 } break
	if { [expr $oldmask&1] } {
	    set newmask [expr $newmask|($submask<<$k)]
	}
	set oldmask [expr $oldmask>>1]
	set k [expr $k+$multiplier]
    }

    return $newmask
}

#return a mask grouped,  conditional on the value of the previous mask.  
#If number bits in a group going up, or the same (and of course NOT zero), the 
#group is high. If number bits in the group go lower, the group goes low.  
#
proc maskjoinif { oldmask oldermask divisor {masksize 16} } {

    set newmask 0
    set k 0
    for { set i 0 } { $i < $masksize } {set i [expr $i+$divisor]} {
	if { $oldmask == 0 } break
	set oldbits 0
	set olderbits 0
	for { set j 0 } {$j <$divisor} {incr j} {
	    set oldbits [expr $oldbits + (($oldmask>>$j)&1)]
	    set olderbits [expr $olderbits + (($oldermask>>$j)&1)]
	}
	if { $oldbits > $olderbits } {
	    set newmask [expr $newmask|(1<<$k)]
	} else {
	    if { $oldbits == $olderbits && $oldbits > 0 } {
		set newmask [expr $newmask|(1<<$k)]
	    }
	}
	incr k
	set oldmask [expr $oldmask >> $divisor]
	set oldermask [expr $oldermask >> $divisor]
    }
    return $newmask
}

#test function
proc testlist { handle loops } {
    set lastlist [ mcfd16::rcbus::getall $handle ]
    puts $lastlist
    for { set i 0 } { $i<$loops } { incr i } {
	puts "$i"
	set thislist [ mcfd16::rcbus::getall $handle ]
	if { $thislist != $lastlist } { break }
    }
}



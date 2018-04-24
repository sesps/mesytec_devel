#!/usr/bin/wish
package require Tk

#source all the other files... which must be in the same location
set mesytecPath [file dirname [info script]]
source [ file join $mesytecPath serialusb.tcl ]
source [ file join $mesytecPath listio.tcl ]
set themod "mcfd16"
source [ file join $mesytecPath ${themod}.tcl ]

#--ddc
#Important note.  For the front panel, I've chosen to use parameters for each
#channel, EVEN IF it has been placed in a group by the device.  So, for 
#example every channel has a gain here, even though the module groups 
#channels for the gain.
#

namespace eval mcfdpanel {

    variable themod "mcfd16"
    variable channels 17
    variable comhandle ""
    variable top ".c"

#scale values or lists
    variable gains {}
    variable fractions {}
    variable delays {}
    variable polars {}
    variable thresholds {}
    variable widths {}
    variable deadtimes {}

    variable rc 0
    variable singlemode 0

    variable bwlactive 0
    variable cfdmode 0

    variable coinctime 128
    variable multlow 1
    variable multhigh 16

#the module uses two 8bit masks, but we keep it as 16bits..
    variable mask16 0
    variable maskbit0
    variable maskbit1
    variable maskbit2
    variable maskbit3
    variable maskbit4
    variable maskbit5
    variable maskbit6
    variable maskbit7
    variable maskbit8
    variable maskbit9
    variable maskbit10
    variable maskbit11
    variable maskbit12
    variable maskbit13
    variable maskbit14
    variable maskbit15

    variable allParams \
	"gains fractions delays polars thresholds widths deadtimes bwlactive coinctime  multlow multhigh singlemode pulser rc mask16"
    variable filepath "mesytec.dat"

    variable devpath "/dev/ttyUSB0"
    variable selectbus 0
    variable openDevpath ""
    variable bus 0
    variable devnum 0

}


proc mcfdpanel::myexit {} {
    variable comhandle

    catch { close $comhandle} 
    
    exit
}

#typical values here are chosen for mesytec mcfd-16

proc mcfdpanel::initpanel { { path ".c"  } } {

    variable channels
    variable gains {}
    variable fractions {}
    variable delays {}
    variable polars {}
    variable widths {}
    variable deadtimes {}
    variable thresholds {}
    variable rc
    variable singlemode
    variable pulser
    variable bwlactive
    variable cfdmode
    variable mask16

    variable coinctime
    variable multhigh 16
    variable multlow 1

    variable selectbus

    variable themod
    variable top
    set top $path

    set disprow 3
    set endrow 3

    set resgain 1
    set bottomgain 1
    set rangegain 11
    set topgain [expr $rangegain - 1 ]
    set gainlen [expr $topgain * 8]

    set respolar 1
    set bottompolar 0
    set rangepolar 2
    set toppolar [expr $rangepolar - 1 ]
    set polarlen [expr $toppolar * 48]

    set resfrac 20
    set rangefrac 40
    set bottomfrac 20
    set topfrac $rangefrac
    set fraclen [expr $rangefrac ]

    set resdelay 1
    set rangedelay 5
    set bottomdelay 1
    set topdelay $rangedelay
    set delaylen [expr $rangedelay*10 ]

    set resthresh 1
    set bottomthresh 0
    set rangethreshold 256
    set topthresh [expr $rangethreshold - 1 ]
    set threshlen [expr $topthresh]

    set reswidth 1
    set bottomwidth 0
    set rangewidth 256
    set topwidth [expr $rangewidth - 1 ]
    set widthlen [expr $topwidth/2]

    set resdead 1
    set bottomdead 0
    set rangedead 256
    set topdead [expr $rangedead - 1 ]
    set deadlen [expr $topdead/2]

    set multres 1
    set bottommult 1
    set topmult 16

    set coincres 1
    set bottomcoinc 0
    set topcoinc 255

    wm title . "$themod panel"
    grid [frame $top ] -column 0 -row 0 -sticky nwes

# get the lists from the module.  Even though there is no connection
# yet, it uses values for initialization.
# 
    updateFromModule


# General note.  I'm trying to keep the controls out of the global namespace.  
# The scale controls DO NOT create a global variable by default (and, I don't
# want these).  Checkbuttons, however DO create global variables
# by default (?!!!!).  So, I do NOT use the -variable command for the scale
# but I do use it for the checkbutton.  

#-------entries panel

    grid [frame $top.entries ] -row 0 -column 0 -sticky nswe
    
#   grid columnconfigure $top.entries 0 -weight 1


    for {set i 1} {$i< [expr $channels + 1 ]} {incr i} {

        if { $i == 1 } {
	    set glbl "gain"
	    set frlbl "CFD%"
	    set dllbl "Del"
	    set slbl "+Pol-"
	    set wdlbl "width"
	    set ddlbl "deadtime"
	    set thlbl "threshold"
	} else {
	    set glbl ""
	    set frlbl ""
	    set dllbl ""
	    set slbl ""
	    set wdlbl ""
	    set ddlbl ""
	    set thlbl ""
	}

        set txtlabel [label $top.label$i -text [format "%02d" [expr $i -1]] ]

#this module has indexing starting at zero, so its functions require
#channel numbers the same as list index (which we compute here)
        set ind [expr $i - 1]

#create scale widgets and set initial values
	set gainscale [scale $top.gains$i -length $gainlen -orient horizontal \
			   -label $glbl -resolution $resgain -from $bottomgain -to $topgain ]
	$gainscale set [lindex $gains $ind]


	set fracscale [scale $top.fractions$i -length $fraclen  -orient horizontal  \
			    -label $frlbl -resolution $resfrac -from $bottomfrac -to $topfrac ]
	$fracscale set [lindex $fractions $ind]


	set delayscale [scale $top.delays$i -length $delaylen  -orient horizontal  \
			    -label $dllbl -resolution $resdelay -from $bottomdelay -to $topdelay ]
	$delayscale set [lindex $delays $ind]

	set polarscale [scale $top.polars$i -length $polarlen  -orient horizontal  \
			    -label $slbl -resolution $respolar -from $bottompolar -to $toppolar ]
	$polarscale set [lindex $polars $ind]


	set widthscale [scale $top.widths$i -length $widthlen -orient horizontal \
			     -label $wdlbl -resolution $reswidth -from $bottomwidth -to $topwidth ]
	$widthscale set [lindex $widths $ind]

	set deadscale [scale $top.deadtimes$i -length $deadlen -orient horizontal \
			     -label $ddlbl -resolution $resdead -from $bottomdead -to $topdead ]
	$deadscale set [lindex $deadtimes $ind]


	set threshscale [scale $top.thresholds$i -length $threshlen -orient horizontal \
			     -label $thlbl -resolution $resthresh -from $bottomthresh -to $topthresh ]
	$threshscale set [lindex $thresholds $ind]


#hook up handlers
	$gainscale configure -command "mcfdpanel::chngGain $ind" 
	$fracscale configure  -command "mcfdpanel::chngFraction $ind"
	$delayscale configure  -command "mcfdpanel::chngDelay $ind"
	$polarscale configure  -command "mcfdpanel::chngPolar $ind"
	$widthscale configure -command "mcfdpanel::chngWidth $ind" 
	$deadscale configure -command "mcfdpanel::chngDeadtime $ind" 
	$threshscale configure -command "mcfdpanel::chngThresh $ind" 

#pack in panel
	grid $txtlabel -in $top.entries -column 0 -row $i -sticky w 
	grid $gainscale -in $top.entries -column 1 -row $i -sticky w
	grid $fracscale -in $top.entries -column 2 -row $i -sticky w
	grid $delayscale -in $top.entries -column 3 -row $i -sticky w
	grid $polarscale -in $top.entries -column 4 -row $i -sticky w
	grid $widthscale -in $top.entries -column 5 -row $i -sticky w
	grid $deadscale -in $top.entries -column 6 -row $i -sticky w
	grid $threshscale -in $top.entries -column 7 -row $i -sticky e

    }


    incr i

    grid [frame $top.modes ] -in $top.entries -row $i -column 0 -columnspan 5 -sticky nsw

#put in the 'mode' commands (use remote settings, use single/common mode)

    set j 1
    set remote [checkbutton $top.rc -text "remote" \
		    -variable mcfdpanel::rc -command "mcfdpanel::remoteCtl"  ]
    if { $rc == 1 } { $remote select } 
    grid $remote -in $top.modes -column $j -row $i -sticky w
 
    incr j
    set mode [checkbutton $top.singlemode -text "single" \
		  -variable mcfdpanel::singlemode -command "mcfdpanel::setmode"  ]
    if { $singlemode == 1 } { $mode select } 
    grid $mode -in $top.modes -column $j -row $i -sticky w

    incr j
    set mode [checkbutton $top.pulser -text "pulser" \
		  -variable mcfdpanel::pulser -command "mcfdpanel::setpulser"  ]
    if { $pulser == 1 } { $mode select } 
    grid $mode -in $top.modes -column $j -row $i -sticky w


#put in the copy commands...
    incr j
    set copy  [button $top.copycommon -text "cp COM" -command "mcfdpanel::cpCommonMode" ]  
    grid $copy -in $top.modes -column $j -row $i -sticky w
    incr j

    grid $copy -in $top.modes -column $j -row $i -sticky w
    incr j

    grid $copy -in $top.modes -column $j -row $i -sticky w

#a frame for the mask.

    grid [frame $top.mask] -in $top.entries -row 1 -column 8 \
	-rowspan [ expr $channels - 1 ] -sticky nsw

    grid rowconfigure $top.mask {0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16} \
	-weight 1 

    for { set i 0 } { $i < 16 } { incr i } {
	if { $i == 0 } { 
	    set masktext "Mask"
	} else {
	    set masktext ""
	}
	set maskbit [checkbutton $top.maskbit$i \
			  -text $masktext  \
			 -variable mcfdpanel::maskbit$i \
			 -command "mcfdpanel::setMask" ]
	grid $maskbit -in $top.mask -row [expr $i +1 ]  \
	    -column 0 -sticky nsw 
	if { [ expr $mask16>>$i & 1 ] } { $maskbit select }
    }
    
#end frame for mask


#We create frames for vertical display of checkboxes and scales. For alignment
#will need to get the font, from the first _scale_

    set rowpos 1
#bwl
    grid [frame $top.extramodes] -in $top.entries -row 1 -column 9 \
	-rowspan $channels -sticky nsw
    grid rowconfigure $top.extramodes {0 1 2 3 4} -weight 1

    set bwl [checkbutton $top.bwlactive -text "bwl on" \
		  -variable mcfdpanel::bwlactive -command "mcfdpanel::setBwl"  ]
    if { $bwlactive == 1 } { $bwl select } 
    grid $bwl -in $top.extramodes -row $rowpos -column 0 -sticky nw

    incr rowpos
    set cfd [checkbutton $top.cfdmode -text "cfd" \
		  -variable mcfdpanel::cfdmode -command "mcfdpanel::setCfd"  ]
    if { $cfdmode == 1 } { $cfd select } 
    grid $cfd -in $top.extramodes -row $rowpos -column 0 -sticky nw

#coincidence time window
    set coinctimescale [scale $top.coinctime  -orient vertical \
		      -label "coinc time" -resolution $coincres \
		      -from $bottomcoinc -to $topcoinc ]
    $coinctimescale set $coinctime
    $coinctimescale configure -command "mcfdpanel::chngCoincTime "
    grid $coinctimescale -in $top.extramodes -row [incr rowpos] -column 0  -sticky nws

#get the size of a digit which is used to pad scales whose range is less than 3 digits
    set digsize [ font measure [ lindex [ $coinctimescale  configure -font ] 3 ] \
		      -displayof $coinctimescale "0" ]

#multiplicity high
    set multhighscale [scale $top.multhigh  -orient vertical \
                      -label "mult hi" -resolution $multres \
                      -from $bottommult -to $topmult ]
    $multhighscale set $multhigh
    $multhighscale configure -command "mcfdpanel::chngMult 1 "
    grid $multhighscale -in $top.extramodes -row [incr rowpos] -column 0  -sticky nws \
        -padx [ expr 1*$digsize ]

#multiplicty low
    set multlowscale [scale $top.multlow  -orient vertical \
                      -label "mult low" -resolution 1 \
                      -from $bottommult -to $topmult ]
    $multlowscale set $multlow
    $multlowscale configure -command "mcfdpanel::chngMult 0 "
    grid $multlowscale -in $top.extramodes -row [incr rowpos] -column 0  -sticky nws \
        -padx  [ expr 1*$digsize ]

#the current module is BROKEN (does not read correct state) for setting..
#cfd or bwl
    
#    $bwl configure -state disabled

#-------run panel
    grid [frame $top.control ] -column 0 -sticky nwes
    grid columnconfigure $top.control {0 1 2 3 4 5 6 7 8 9 10 11} -weight 1

    set colpos 0

    grid [button $top.update -text "Update" -command mcfdpanel::updateVals] \
	-in $top.control -column $colpos -row 0 -sticky nws

    set restore [ button $top.restore  -text "Restore" ]
    $restore configure -command mcfdpanel::restoreVals
    grid $restore -in $top.control -column [incr colpos] -row 0 -sticky nws
    
    set save [ button $top.save  -text "Save" ]
    $save configure -command mcfdpanel::saveVals
    grid $save -in $top.control -column [incr colpos] -row 0 -sticky nws
  
#
# some suggestions for the device to use.
#
    grid [menubutton $top.devicelist -text "Device List" -direction above \
	      -relief raised -menu $top.devicelist.menu ] \
	-in $top.control -column [incr colpos] -row 0 -sticky nes 
    
    menu $top.devicelist.menu  -postcommand mcfdpanel::setdevlist
    mcfdpanel::setdevlist

    
#end of device suggestions.


    grid  [label $top.devicelabel -text "Device Path"] \
	-in $top.control -column [incr colpos] -row 0 -sticky nes
    grid  [entry $top.device -width 15 -textvariable mcfdpanel::devpath ] \
	-in $top.control -column [incr colpos] -row 0 -sticky nws
    bind $top.device <Return> {mcfdpanel::setdevice $mcfdpanel::devpath}

    $top.device icursor end
    focus $top.device

    set rcbus [checkbutton $top.rcbus -text "rc bus" \
		   -variable mcfdpanel::selectbus -command { mcfdpanel::setbus ; mcfdpanel::updateVals } ]
    grid $rcbus -in $top.control -column [incr colpos] -row 0 -sticky w
	   
    grid  [label $top.buslabel -text "Bus"] -in $top.control -column [incr colpos] -row 0 -sticky nes
    set busentry [entry $top.bus -width 5  -textvariable mcfdpanel::bus ] 
    grid $busentry -in $top.control -column [incr colpos] -row 0 -sticky nws
    bind $busentry <Return> { mcfdpanel::setrcbus ; mcfdpanel::updateVals }
####
    grid  [label $top.modulelabel -text "Address"] -in $top.control -column [incr colpos] -row 0 -sticky nes
    set modentry [entry $top.module -width 5  -textvariable mcfdpanel::devnum ]
    grid $modentry  -in $top.control -column [incr colpos] -row 0 -sticky nws
    bind $modentry <Return> { mcfdpanel::setrcbus ; mcfdpanel::updateVals}

    if { $selectbus == 0 } { 
	$busentry configure -state disabled
	$modentry configure -state disabled
    }
   
    set status [checkbutton $top.status -text "errors" -state disabled -variable ${themod}::deverror ]
    grid $status -in $top.control -column [incr colpos] -row 0 -sticky nws

    grid [button $top.exit  -text "Exit" -command mcfdpanel::myexit] \
	-in $top.control -column [incr colpos] -row 0 -sticky nes

}


#listdevices
#this makes the menu for available device list.
proc mcfdpanel::setdevlist { } {

    variable top

    set possibledevs [ serialusb::connectionlist ]

#blank the menu, and rebuild.

    $top.devicelist.menu delete 1 end

    for { set i 0 } { $i < [llength $possibledevs] } { incr i } {
	set usbdev [ lindex $serialusb::usbpaths $i ]
	set adev [ lindex $possibledevs  $i ]
	$top.devicelist.menu add command -label "$i $adev $usbdev " \
	    -command "set mcfdpanel::devpath $adev; mcfdpanel::setdevice $adev" 
	    
    }

}

#setdevice
#this connects to the module.  There will be eventually TWO cases here (USB and RC bus).
proc mcfdpanel::setdevice { thedevice } {
    variable comhandle
    variable openDevpath
    variable themod

    if { [expr ![string equal $thedevice $openDevpath]] } {
	catch { close $comhandle }
	set comhandle ""
	set openDevpath ""
	set status [ catch { serialusb::connect $thedevice } newhandle ]
	if { [ expr  $status == 0 ] } {
	    set comhandle $newhandle 
	    set openDevpath $thedevice
	    
	} else {
	    set ${themod}::deverror 1
	}

    }

    mcfdpanel::updateVals

    return 

}

proc mcfdpanel::remoteCtl { } {
    variable themod
    variable comhandle
    variable rc

    ${themod}::setrc $comhandle $rc

    return

}

proc mcfdpanel::setmode { } {
    variable themod
    variable comhandle
    variable singlemode

    ${themod}::setmode $comhandle $singlemode

    return

}

proc mcfdpanel::setpulser { } {
    variable themod
    variable comhandle
    variable pulser

    ${themod}::setpulser $comhandle $pulser

    return

}

#copy the common mode to the single channels
proc mcfdpanel::cpCommonMode { } {
    variable themod
    variable comhandle

    ${themod}::cpyc $comhandle

    updateVals

    return

}


#copy the FP set to RC (implemented by the module... NOT AVAILABLE)
proc mcfdpanel::cpFromFP { } {
    variable themod
    variable comhandle

    ${themod}::cpyf $comhandle

    updateVals

    return

}

proc mcfdpanel::setMask { } {
    variable themod
    variable comhandle

    variable mask16
    variable maskbit0
    variable maskbit1
    variable maskbit2
    variable maskbit3
    variable maskbit4
    variable maskbit5
    variable maskbit6
    variable maskbit7
    variable maskbit8
    variable maskbit9
    variable maskbit10
    variable maskbit11
    variable maskbit12
    variable maskbit13
    variable maskbit14
    variable maskbit15

    set localmask 0
    for {set i 0} {$i < 16}  {incr i} {
	set bit maskbit$i
	set localmask [ expr $localmask | [ expr $$bit << $i] ]
    }

    ${themod}::setchannelmasks $comhandle $localmask
    set mask16 [eval ${themod}::maskedchannels ]

    for {set i 0} {$i < 16}  {incr i} {
	set bit maskbit$i
	set $bit [ expr ($mask16 >> $i )&1 ]
    }

    
#    set themask [format "%x" $mask16]
#    puts $themask

    return

}

proc mcfdpanel::setBwl { } {
    variable themod
    variable comhandle
    variable bwlactive

    ${themod}::setbwl $comhandle $bwlactive

    return

}

proc mcfdpanel::setCfd { } {
    variable themod
    variable comhandle
    variable cfdmode

    ${themod}::setcfd $comhandle $cfdmode

    return

}


proc mcfdpanel::chngMult { index value } {
    variable themod
    variable comhandle
    variable multhigh
    variable multlow

#NOTE, the order in the list is ther reverse of a normal convention
#of low to high (so 

    if { $index == 0 } {
	set multlow $value
    } else {
	set multhigh $value
    }
    
    ${themod}::setmultlimits $comhandle $multlow $multhigh
    
    return

}


proc mcfdpanel::chngCoincTime { value } {
    variable themod
    variable comhandle
    variable coinctime

    ${themod}::setcoinctime $comhandle $value
    
    return

}


proc mcfdpanel::chngGain { chan value } { 

    variable gains
    variable themod
    variable comhandle

#find the group (our group numbers, returned by the module, start at zero)
    set group [ ${themod}::group $chan ]
#put command to change gain here.  For the mcfd16 module, there are constraints
#on the allowed values, so the 'next' value is set, and the actual value is 
#returned.
    set value [ ${themod}::setgain $comhandle $chan $value ]
#update ALL scales on panel (if this is last group, no others updated.)
    set startindex [ expr ($group)*2 ]
    set stopindex  [ expr $startindex + 1 ]
    if { $stopindex < 16 } {
	set gains [lreplace $gains $startindex $stopindex $value $value] 
    } else {
	set gains [lreplace $gains 16 16 $value ]
    }

    updateScales "gains" $gains
    
    return "$startindex $stopindex $gains"

}

proc mcfdpanel::chngPolar { chan value } { 

    variable polars
    variable themod
    variable comhandle

#put command to change polar here
    ${themod}::setpolarity $comhandle $chan $value

#find the group
    set group [ ${themod}::polargroup $chan ]

#update ALL scales on panel (if this is last group, no others updated.)
    set startindex [ expr ($group)*2 ]
    set stopindex  [ expr $startindex + 1 ]
    if { $stopindex < 16 } {
	set polars [lreplace $polars $startindex $stopindex $value $value] 
    } else {
	set polars [lreplace $polars 16 16 $value ]
    }

    updateScales "polars" $polars
    
    return 

}


proc mcfdpanel::chngFraction { chan value } { 

    variable fractions
    variable themod
    variable comhandle

#put command to change fraction here
    ${themod}::setfraction $comhandle $chan $value

#find the group
    set group [ ${themod}::polargroup $chan ]

#update ALL scales on panel (if this is last group, no others updated.)
    set startindex [ expr ($group)*2 ]
    set stopindex  [ expr $startindex + 1 ]
    if { $stopindex < 16 } {
	set fractions [lreplace $fractions $startindex $stopindex $value $value]
    } else {
	set fractions [lreplace $fractions 16 16 $value ]
    }

    updateScales "fractions" $fractions
    
    return 

}

proc mcfdpanel::chngDelay { chan value } { 

    variable delays
    variable themod
    variable comhandle

#put command to change delay here
    ${themod}::setdelay $comhandle $chan $value

#find the group
    set group [ ${themod}::polargroup $chan ]

#update ALL scales on panel (if this is last group, no others updated.)
    set startindex [ expr ($group)*2 ]
    set stopindex  [ expr $startindex + 1 ]
    if { $stopindex < 16 } {
	set delays [lreplace $delays $startindex $stopindex $value $value]
    } else {
	set delays [lreplace $delays 16 16 $value ]
    }

    updateScales "delays" $delays
    
    return 

}


proc mcfdpanel::chngThresh { chan value } { 

    variable thresholds
    variable themod
    variable comhandle

#put command to change threholds here
    ${themod}::setthreshold $comhandle $chan $value

    set ind $chan 
    set thresholds [lreplace $thresholds $ind $ind $value ]

    return 

}

proc mcfdpanel::chngWidth { chan value } { 

    variable widths
    variable themod
    variable comhandle

#find the group (our group numbers, returned by the module, start at zero)
    set group [ ${themod}::group $chan ]
#on the allowed values, so the 'next' value is set, and the actual value 
#is returned.
    ${themod}::setwidth $comhandle $chan $value
#update ALL scales on panel (if this is last group, no others updated.)
    set startindex [ expr ($group)*2 ]
    set stopindex  [ expr $startindex + 1 ]
    if { $stopindex < 16 } {
	set widths [lreplace $widths $startindex $stopindex $value $value] 
    } else {
	set widths [lreplace $widths 16 16 $value ]
    }

    updateScales "widths" $widths
    
    return 

}

proc mcfdpanel::chngDeadtime { chan value } { 

    variable deadtimes
    variable themod
    variable comhandle

#find the group (our group numbers, returned by the module, start at zero)
    set group [ ${themod}::group $chan ]
#on the allowed values, so the 'next' value is set, and the actual value is returned.
    ${themod}::setdeadtime $comhandle $chan $value
#update ALL scales on panel (if this is last group, no others updated.)
    set startindex [ expr ($group)*2 ]
    set stopindex  [ expr $startindex + 1 ]
    if { $stopindex < 16 } {
	set deadtimes [lreplace $deadtimes $startindex $stopindex $value $value] 
    } else {
	set deadtimes [lreplace $deadtimes 16 16 $value ]
    }

    updateScales "deadtimes" $deadtimes
    
    return 

}


proc mcfdpanel::updateVals { } {

#get current lists from the module
    updateFromModule

#Set all the values on the panel
#Because the panel is event driven, this
#will result in an attempt to set all values on
#module, but as we just updated, they are current
#and there should be no actual communication with
#the module.
 
    setVals

    return

}

proc mcfdpanel::restoreVals { } {

    variable filepath
    variable top
    variable allParams
   
    set filepath [tk_getOpenFile -parent $top -initialfile "mesytec.dat" ]
    if { [string equal $filepath ""]} {
	return
    }

    listio::setio $filepath 0 $top
    
    listio::getlists $allParams mcfdpanel 

    setVals

}

proc mcfdpanel::saveVals { } {

    variable filepath
    variable top
    variable allParams
   
    set filepath [tk_getSaveFile -parent $top -initialfile "mesytec.dat" ]
    if { [string equal $filepath ""]} {
	return
    }

    listio::setio $filepath 0 $top
    
    listio::putlists $allParams mcfdpanel 

}

proc mcfdpanel::setVals { } {
    variable gains 
    variable fractions
    variable delays
    variable polars
    variable widths
    variable deadtimes
    variable thresholds 

    variable rc
    variable singlemode
    variable pulser

    variable bwlactive
    variable cfdmode
    
    variable multlow
    variable multhigh
    variable coinctime

    variable mask16

#update the scales ... NOTE this also CALLS THE FUNCTIONS TO UPDATE THE MODULE 
#(but those should be a 'no-op' since the values are unchanged)
    updateScales "gains" $gains 
    updateScales "fractions" $fractions
    updateScales "delays" $delays
    updateScales "polars" $polars
    updateScales "widths" $widths
    updateScales "deadtimes" $deadtimes
    updateScales "thresholds" $thresholds

#update checkbox values
    updateCheck "rc" $rc
    updateCheck "singlemode" $singlemode
    updateCheck "pulser" $pulser
    updateCheck "bwlactive" $bwlactive
    updateCheck "cfdmode" $cfdmode

    set bitlist {}
    for { set i 0 } { $i < 16} {incr i} { 
	lappend bitlist [ expr ( $mask16 >> $i ) & 1 ]
    }

    updateChecks "maskbit" $bitlist


#update individual Scales
    updateAScale "multlow" $multlow
    updateAScale "multhigh" $multhigh
    updateAScale "coinctime" $coinctime

    return

}    

#updateFromModule gets the parameters FROM the module
#IT DOES NOT SET ANY CONTROLS ON A PANEL Synching
#the panel to the modules is done in updateVals
proc mcfdpanel::updateFromModule { } {
    variable themod
    variable comhandle

    variable gains
    variable fractions
    variable delays
    variable polars
    variable widths
    variable deadtimes
    variable thresholds
    variable rc
    variable singlemode
    variable pulser
 
    variable bwlactive
    variable cfdmode

    variable multlow
    variable multhigh
    variable coinctime

    variable mask16

    ${themod}::getall $comhandle

    set gains [eval ${themod}::channel_gains]
    set fractions [eval ${themod}::channel_fractions]
    set delays [eval ${themod}::channel_delays]
    set polars [eval ${themod}::channel_polarities]
    set widths [eval ${themod}::channel_widths ]
    set deadtimes [eval ${themod}::channel_deadtimes ]
    set thresholds [subst $${themod}::thresholds]
    set rc [subst $${themod}::rc]
    set pulser [subst $${themod}::pulser]
    set singlemode [subst $${themod}::ctlmode ]

    set bwlactive [subst $${themod}::bwlactive]
    set cfdmode [subst $${themod}::cfdmode]

    set coinctime [subst $${themod}::coinc_time]
    set mults [subst $${themod}::multlimits ]
    set multlow [lindex $mults 0]
    set multhigh [lindex $mults 1]
    set mask16 [eval ${themod}::maskedchannels ]

    if { [subst $${themod}::deverror ] != 0 } { bell }
    
    return

}    

proc mcfdpanel::updateScales { type values } {
    variable top
    variable $type
    set i 1
    foreach g $values { 
	$top.${type}$i set $g
	incr i
    }

    return
}


proc mcfdpanel::updateAScale { name value } {
    variable top
    variable $name

    $top.${name} set $value

    return

}

proc mcfdpanel::updateCheck { type value } {
    variable top
    variable $type

    set checkcmd [$top.${type} cget -command]
    if {  [string length $checkcmd] > 0  } { eval $checkcmd } 
    return
}

#for array of related checks (like for a bit mask).  update
#the values of the associated variables, THEN execute the 
#associated command.
proc mcfdpanel::updateChecks { type values } {
    variable top
    variable $type

    set i 0
    foreach chk $values {
	set mcfdpanel::${type}$i  $chk
	incr i
    }
    
#the command is the same for all these checks, so get the first (0)
#one
    set checkcmd [$top.${type}0 cget -command]
    if {  [string length $checkcmd] > 0  } { eval $checkcmd } 
    return
}

proc mcfdpanel::setbus { } {
    variable top
    variable themod
    variable selectbus

    set rcbus $top.rcbus 
    set busentry $top.bus
    set modentry $top.module

    if { $selectbus } {
	$rcbus select
	set ${themod}::devset "rcbus"
    } else {
	$rcbus  deselect
	set ${themod}::devset "usb"
    }


    if { $selectbus == 0 } { 
	 $busentry configure -state disabled
	 $modentry configure -state disabled
    } else {
	 $busentry configure -state normal
	 $modentry configure -state normal
    }	

}
#
#setrcbus
#updates the bus and devnum, makes sure they are numbers 
#and in range, and sets these for the module.
# 
proc mcfdpanel::setrcbus { } {
    variable bus
    variable devnum
    variable themod

#look for a number.  scan returns the number of items it succesfully interprets.
    if {  [scan  $bus {%d} bus] == 0 } { set bus 0 }
    if {  [scan  $devnum {%d} devnum ] == 0 } { set devnum 0 }
    
    set bus [expr $bus % 2]
    set devnum [expr $devnum % 16]

    ${themod}::setrcbus $bus $devnum

    return

}

#spec the bus type to use for commands that are generated for this panel
set ${themod}::devset "usb"

#create the mesytec panel
mcfdpanel::initpanel

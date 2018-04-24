#!/usr/bin/wish
package require Tk

#source all the other files... which must be in the same location
set mesytecPath [file dirname [info script]]
source [ file join $mesytecPath serialusb.tcl ]
source [ file join $mesytecPath listio.tcl ]
set themod "mscf16"
source [ file join $mesytecPath ${themod}.tcl ]


#--ddc
#Important note.  For the front panel, I've chosen to use parameters for each
#channel, EVEN IF it has been placed in a group by the device.  So, for 
#example every channel has a gain here, even though the module groups 
#channels for the gain.
#

namespace eval mscfpanel {

    variable themod "mscf16"
    variable channels 17
    variable comhandle ""
    variable top ".c"

#scale values or lists
    variable gains {}
    variable shapes {}
    variable thresholds {}
    variable pzs {}
    variable monitor 0


    variable rc 0
    variable singlemode 0

    variable blractive 0
    variable ecldelay 0

    variable blrthreshold 1
    variable tfint 1
    
    variable coinctime 128
    variable multlow 4
    variable multhigh 4

    variable allParams \
	"gains shapes thresholds pzs blractive blrthreshold tfint ecldelay coinctime multlow multhigh monitor singlemode rc"
    variable filepath "mesytec.dat"

    variable devpath "/dev/ttyUSB0"
    variable selectbus 0
    variable openDevpath ""
    variable bus 0
    variable devnum 0

}


proc mscfpanel::myexit {} {
    variable comhandle

    catch { close $comhandle} 
    
    exit
}

#typical values here are chosen for mesytec mscf-16

proc mscfpanel::initpanel { {path ".c" } } {
    variable channels
    variable gains {}
    variable shapes {}
    variable thresholds {}
    variable pzs {}
    variable rc
    variable singlemode
    variable blrthreshold
    variable tfint
    variable blractive
    variable ecldelay

    variable coinctime
    variable tfinthigh 3
    variable tfintlow 0
    variable multhigh 8
    variable multlow 0

    variable monitor
    variable selectbus

    variable themod
    variable top

    set top $path

    set disprow 3
    set endrow 3

    set resgain 1
    set bottomgain 0
    set rangegain 16
    set topgain [expr $rangegain - 1 ]
    set gainlen [expr $topgain * 4]

    set resshape 1
    set bottomshape 0
    set rangeshape 4
    set topshape [expr $rangeshape - 1 ]
    set shapelen [expr $topshape * 16]

    set resthresh 1
    set bottomthresh 0
    set rangethreshold 256
    set topthresh [expr $rangethreshold - 1 ]
    set threshlen [expr $topthresh]

    set respz  1
    set bottompz 0
    set rangepz 256
    set toppz [expr $rangepz - 1 ]
    set pzlen [expr $toppz]
    set mscfpanel::channels $channels

    set blrresthresh 1
    set bottomblr 0
    set topblr 255

    set tfintres 1
    set bottomtfint 0
    set toptfint 3

    set multres 1
    set bottommult 1
    set topmult 8

    set coincres 1
    set bottomcoinc 1
    set topcoinc 255

    wm title . "mscfpanel panel"
    grid [frame $top ] -column 0 -row 0 -sticky nwes

# get the lists from the module.

    updateFromModule

# General note.  I'm trying to keep the controls out of the global namespace.  
# The scale controls DO NOT create a global variable by default (and, I don't
# want these).  Checkbuttons, however DO create global variables
# by default (?!!!!).  So, I do NOT use the -variable command for the scale
# but I do use it for the checkbutton.  

#-------entries panel

    grid [frame $top.entries ] -row 0 -column 0 -sticky nswe
    
    for {set i 1} {$i< [expr $channels + 1 ]} {incr i} {

        if { $i == 1 } {
	    set glbl "gain"
	    set slbl "shape"
	    set thlbl "threshold"
	    set pzlbl "polezero"
	} else {
	    set glbl ""
	    set slbl ""
	    set thlbl ""
	    set pzlbl ""
	}

        set txtlabel [label $top.label$i -text [format "%02d" $i] ]

        set ind [expr $i - 1]

#create scale widgets and set initial values
	set gainscale [scale $top.gains$i -length $gainlen -orient horizontal \
			   -label $glbl -resolution $resgain -from $bottomgain -to $topgain ]
	$gainscale set [lindex $gains $ind]

	set shapescale [scale $top.shapes$i -length $shapelen  -orient horizontal \
			    -label $slbl -resolution $resshape -from $bottomshape -to $topshape ]
	$shapescale set [lindex $shapes $ind]

	set threshscale [scale $top.thresholds$i -length $threshlen -orient horizontal \
			     -label $thlbl -resolution $resthresh -from $bottomthresh -to $topthresh ]
	$threshscale set [lindex $thresholds $ind]

	set pzscale [scale $top.pzs$i -length $pzlen  -orient horizontal \
			 -label $pzlbl -resolution $respz -from $bottompz -to $toppz ]
	$pzscale set [lindex $pzs $ind]

#hook up handlers
	$gainscale configure -command "mscfpanel::chngGain $i" 
	$shapescale configure  -command "mscfpanel::chngShape $i"
	$threshscale configure -command "mscfpanel::chngThresh $i" 
	$pzscale configure -command "mscfpanel::chngPz $i" 

#pack in panel
	grid $txtlabel -in $top.entries -column 0 -row $i -sticky w
	grid $gainscale -in $top.entries -column 1 -row $i -sticky w
	grid $shapescale -in $top.entries -column 2 -row $i -sticky w
	grid $threshscale -in $top.entries -column 3 -row $i -sticky e
	grid $pzscale -in $top.entries -column 4 -row $i -sticky e

    }

    incr i

    grid [frame $top.modes ] -in $top.entries -row $i -column 0 -columnspan 5 -sticky nsw

#put in the 'mode' commands (use remote settings, use single/common mode)

    set remote [checkbutton $top.rc -text "remote" \
		    -variable mscfpanel::rc -command "mscfpanel::remoteCtl"  ]
    if { $rc == 1 } { $remote select } 
    grid $remote -in $top.modes -column 1 -row $i -sticky w

    set mode [checkbutton $top.singlemode -text "single" \
		  -variable mscfpanel::singlemode -command "mscfpanel::setmode"  ]
    if { $singlemode == 1 } { $mode select } 
    grid $mode -in $top.modes -column 2 -row $i -sticky w

#put in the copy commands...
    set copy  [button $top.copycommon -text "cp COM" -command "mscfpanel::cpCommonMode" ]  
    grid $copy -in $top.modes -column 3 -row $i -sticky w

    set copy  [button $top.copyFP -text "cp FP" -command "mscfpanel::cpFromFP" ]  
    grid $copy -in $top.modes -column 4 -row $i -sticky w

    set copy  [button $top.copyRC -text "set FP" -command "mscfpanel::cpToFP" ]  
    grid $copy -in $top.modes -column 5 -row $i -sticky w


# put in channel selector for channel items... note that rows started with 1!
# ALSO, for the module, 0 is OFF (and the range is 16) BUT we use 17 for off

    set selectscale [scale $top.monitor  -orient vertical \
			 -label "monitor" -resolution 1 -from 1 -to 17 ]
    $selectscale set $monitor
    $selectscale configure -command "mscfpanel::setmonitor "
    grid $selectscale -in $top.entries -row 1 -column 5 -rowspan $channels -sticky ns

#We create frames for vertical display of checkboxes and scales.  For alignment,
#will need to get the font, from the first _scale_

    set rowpos 0
#blractive
    grid [frame $top.extramodes] -in $top.entries -row 1 -column 6 \
	-rowspan $channels -sticky nsw
    grid rowconfigure $top.extramodes {0 1 2 3 4} -weight 1

    set blr [checkbutton $top.blractive -text "blr on" \
		  -variable mscfpanel::blractive -command "mscfpanel::setBlr"  ]
    if { $blractive == 1 } { $blr select } 
    grid $blr -in $top.extramodes -row $rowpos -column 0 -sticky nw

#ecldelay

    set ecl [checkbutton $top.ecldelay -text "ecldelay on" \
		  -variable mscfpanel::ecldelay -command "mscfpanel::setEcl"  ]
    if { $ecldelay == 1 } { $ecl select }
    grid $ecl -in $top.extramodes -row [incr rowpos] -column 0 -sticky nw

#blrthreshold
    set blrscale [scale $top.blrthreshold  -orient vertical \
		      -label "blr thr" -resolution $blrresthresh \
		      -from $bottomblr -to $topblr ]
    $blrscale set $blrthreshold
    $blrscale configure -command "mscfpanel::chngBlrthresh "
#get the size of a digit which is used to pad scales whose range is less than 3 digits
    set digsize [ font measure [ lindex [ $blrscale  configure -font ] 3 ] \
		      -displayof $blrscale "0" ]
    grid $blrscale -in $top.extramodes -row [incr rowpos] -column 0  -sticky nws


#timing filter integration
    set tfintscale [scale $top.tfint  -orient vertical \
		      -label "tf int" -resolution $tfintres \
		      -from $bottomtfint -to $toptfint ]
    $tfintscale set $tfintlow
    $tfintscale configure -command "mscfpanel::chngTfint "
    grid $tfintscale -in $top.extramodes -row [incr rowpos] -column 0  -sticky nws \
	-padx [ expr 2*$digsize ]

#multiplicity high
    set multhighscale [scale $top.multhigh  -orient vertical \
		      -label "mult hi" -resolution $multres \
		      -from $bottommult -to $topmult ]
    $multhighscale set $multhigh
    $multhighscale configure -command "mscfpanel::chngMult 1 "
    grid $multhighscale -in $top.extramodes -row [incr rowpos] -column 0  -sticky nws \
	-padx [ expr 2*$digsize ]


#multiplicty low
    set multlowscale [scale $top.multlow  -orient vertical \
		      -label "mult low" -resolution 1 \
		      -from $bottommult -to $topmult ]
    $multlowscale set $multlow
    $multlowscale configure -command "mscfpanel::chngMult 0 "
    grid $multlowscale -in $top.extramodes -row [incr rowpos] -column 0  -sticky nws \
	-padx  [ expr 2*$digsize ]


#coincidence time window
    set coinctimescale [scale $top.coinctime  -orient vertical \
		      -label "coinc time" -resolution $coincres \
		      -from $bottomcoinc -to $topcoinc ]
    $coinctimescale set $coinctime
    $coinctimescale configure -command "mscfpanel::chngCoincTime "
    grid $coinctimescale -in $top.extramodes -row [incr rowpos] -column 0  -sticky nws


#-------run panel
    grid [frame $top.control ] -column 0 -sticky nwes
    grid columnconfigure $top.control {0 1 2 3 4 5 6 7 8 9 10 11} -weight 1

    set colpos 0

    grid [button $top.update -text "Update" -command mscfpanel::updateVals] \
	-in $top.control -column $colpos -row 0 -sticky nws

    set restore [ button $top.restore  -text "Restore" ]
    $restore configure -command mscfpanel::restoreVals
    grid $restore -in $top.control -column [incr colpos] -row 0 -sticky nws
    
    set save [ button $top.save  -text "Save" ]
    $save configure -command mscfpanel::saveVals
    grid $save -in $top.control -column [incr colpos] -row 0 -sticky nws
  
#
# some suggestions for the device to use.

#
    grid [menubutton $top.devicelist -text "Device List" -direction above \
	      -relief raised -menu $top.devicelist.menu] \
	-in $top.control -column [incr colpos] -row 0 -sticky nes 
    
    menu $top.devicelist.menu -postcommand mscfpanel::setdevlist
#set the menu first time (so it acts reasonably on first use)
    mscfpanel::setdevlist
    
#end of device suggestions.

    grid  [label $top.devicelabel -text "Device Path"] \
	-in $top.control -column [incr colpos] -row 0 -sticky nes
    grid  [entry $top.device -width 15 -textvariable mscfpanel::devpath ] \
	-in $top.control -column [incr colpos] -row 0 -sticky nws
    bind $top.device <Return> {mscfpanel::setdevice $mscfpanel::devpath }

#set the focus, and the cursor, for the entry (it is the first thing
#the operator must set.
    $top.device icursor end
    focus $top.device

    set rcbus [checkbutton $top.rcbus -text "rc bus" \
		   -variable mscfpanel::selectbus -command { mscfpanel::setbus ; mscfpanel::updateVals } ]
    grid $rcbus -in $top.control -column [incr colpos] -row 0 -sticky w
	   
    grid  [label $top.buslabel -text "Bus"] -in $top.control -column [incr colpos] -row 0 -sticky nes
    set busentry [entry $top.bus -width 5  -textvariable mscfpanel::bus ] 
    grid $busentry -in $top.control -column [incr colpos] -row 0 -sticky nws
    bind $busentry <Return> { mscfpanel::setrcbus ; mscfpanel::updateVals }
####
    grid  [label $top.modulelabel -text "Address"] -in $top.control -column [incr colpos] -row 0 -sticky nes
    set modentry [entry $top.module -width 5  -textvariable mscfpanel::devnum ]
    grid $modentry  -in $top.control -column [incr colpos] -row 0 -sticky nws
    bind $modentry <Return> { mscfpanel::setrcbus ; mscfpanel::updateVals}

    if { $selectbus == 0 } { 
	$busentry configure -state disabled
	$modentry configure -state disabled
    }
   
    set status [checkbutton $top.status -text "errors" -state disabled -variable ${themod}::deverror ]
    grid $status -in $top.control -column [incr colpos] -row 0 -sticky nws

    grid [button $top.exit  -text "Exit" -command mscfpanel::myexit] \
	-in $top.control -column [incr colpos] -row 0 -sticky nes

}

#listdevices
#this makes the menu for available device list.
proc mscfpanel::setdevlist { } {

    variable top

    set possibledevs [ serialusb::connectionlist ]

#blank the menu, and rebuild.

    $top.devicelist.menu delete 1 end

    for { set i 0 } { $i < [llength $possibledevs] } { incr i } {
	set usbdev [ lindex $serialusb::usbpaths $i ]
	set adev [ lindex $possibledevs  $i ]
	$top.devicelist.menu add command -label "$i $adev $usbdev " \
	    -command "set mscfpanel::devpath $adev; mscfpanel::setdevice $adev" 
	    
    }

}

#setdevice
#this connects to the module. (or rcbus)
proc mscfpanel::setdevice { thedevice } {
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

    mscfpanel::updateVals

    return 

}

proc mscfpanel::remoteCtl { } {
    variable themod
    variable comhandle
    variable rc

    ${themod}::setrc $comhandle $rc

    return

}

proc mscfpanel::setmode { } {
    variable themod
    variable comhandle
    variable singlemode

    ${themod}::setmode $comhandle $singlemode

    return

}

#copy the common mode to the single channels (implemented by the module)
proc mscfpanel::cpCommonMode { } {
    variable themod
    variable comhandle

    ${themod}::cpyc $comhandle

    updateVals

    return

}


#copy the FP set to RC (implemented by the module)
proc mscfpanel::cpFromFP { } {
    variable themod
    variable comhandle

    ${themod}::cpyf $comhandle

    updateVals

    return

}


#copy the FP set to RC (implemented by the module)
proc mscfpanel::cpToFP { } {
    variable themod
    variable comhandle

    ${themod}::cpyr $comhandle

    updateVals

    return

}


proc mscfpanel::setmonitor { value } {
    variable themod
    variable comhandle
    variable monitor

#put the monitor value in the range needed for the module
#(we use 1-17, but module uses 0 to 16 with 0 as OFF)

    set value [ expr $value % 17 ]
    ${themod}::setmonitor $comhandle $value
    

    return

}

proc mscfpanel::setBlr { } {
    variable themod
    variable comhandle
    variable blractive

    ${themod}::setblr $comhandle $blractive

    return

}

proc mscfpanel::setEcl { } {
    variable themod
    variable comhandle
    variable ecldelay

    ${themod}::setecl $comhandle $ecldelay

    return

}


proc mscfpanel::chngBlrthresh { value } {
    variable themod
    variable comhandle
    variable blrthreshold

    ${themod}::setblrthresh $comhandle $value

    set blrthreshold $value
    
    return

}


proc mscfpanel::chngTfint { value } {
    variable themod
    variable comhandle
    variable tfint

    ${themod}::settfint $comhandle $value

    set tfint $value

    return
}

proc mscfpanel::chngMult { index value } {
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


proc mscfpanel::chngCoincTime { value } {
    variable themod
    variable comhandle
    variable coinctime

    ${themod}::setcoinctime $comhandle $value

    set coinctime $value
    
    return

}


proc mscfpanel::chngGain { chan value } { 

    variable gains
    variable themod
    variable comhandle

#find the group
    set group [ ${themod}::group $chan ]
#put command to change gain here
    ${themod}::setgain $comhandle $chan $value
#update ALL scales on panel (if this is last group, no others updated.)
    set startindex [ expr ($group-1)*4 ]
    set stopindex  [ expr $startindex + 3 ]
    if { $stopindex < 16 } {
	set gains [lreplace $gains $startindex $stopindex $value $value $value $value] 
    } else {
	set gains [lreplace $gains 16 16 $value ]
    }

    updateScales "gains" $gains
    
    return "$startindex $stopindex $gains"

}

proc mscfpanel::chngShape { chan value } { 

    variable shapes
    variable themod
    variable comhandle

#put command to change shape here
    ${themod}::setshape $comhandle $chan $value

#find the group
    set group [ ${themod}::shpgroup $chan ]

#update ALL scales on panel (if this is last group, no others updated.)
    set startindex [ expr ($group-1)*4 ]
    set stopindex  [ expr $startindex + 3 ]
    if { $stopindex < 16 } {
	set shapes [lreplace $shapes $startindex $stopindex $value $value $value $value] 
    } else {
	set shapes [lreplace $shapes 16 16 $value ]
    }

    updateScales "shapes" $shapes
    
    return 

}

proc mscfpanel::chngThresh { chan value } { 

    variable thresholds
    variable themod
    variable comhandle

#put command to change threholds here
    ${themod}::setthreshold $comhandle $chan $value

    set ind [expr $chan - 1]
    set thresholds [lreplace $thresholds $ind $ind $value ]

    return 

}


proc mscfpanel::chngPz { chan value } { 

    variable pzs
    variable themod
    variable comhandle

#put command to change pzs here
    ${themod}::setpz $comhandle $chan $value

    set ind [expr $chan - 1]
    set pzs [lreplace $pzs $ind $ind $value ]
    
    return 

}

proc mscfpanel::updateVals { } {

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

proc mscfpanel::restoreVals { } {

    variable filepath
    variable top
    variable allParams
   
    set filepath [tk_getOpenFile -parent $top -initialfile "mesytec.dat" ]
    if { [string equal $filepath ""]} {
	return
    }

    listio::setio $filepath 0 $top
    
    listio::getlists $allParams mscfpanel 

    setVals

}

proc mscfpanel::saveVals { } {

    variable filepath
    variable top
    variable allParams
   
    set filepath [tk_getSaveFile -parent $top -initialfile "mesytec.dat" ]
    if { [string equal $filepath ""]} {
	return
    }

    listio::setio $filepath 0 $top
    
    listio::putlists $allParams mscfpanel 


}

proc mscfpanel::setVals { } {
    variable gains 
    variable shapes 
    variable thresholds 
    variable pzs 

    variable rc
    variable singlemode
    variable monitor


    variable blractive
    variable ecldelay
    variable tfint
    variable blrthreshold
    
    variable multlow
    variable multhigh
    variable coinctime


#update the scales ... NOTE this also CALLS THE FUNCTIONS TO UPDATE THE MODULE (but those should be a 'no-op' since
#the values are unchanged)
    updateScales "gains" $gains 
    updateScales "shapes" $shapes
    updateScales "thresholds" $thresholds
    updateScales "pzs" $pzs

#update checkbox values
    updateCheck "rc" $rc
    updateCheck "singlemode" $singlemode
    updateCheck "blractive" $blractive
    updateCheck "ecldelay" $ecldelay

#update individual Scales
    updateAScale "monitor" $monitor
    updateAScale "blrthreshold" $blrthreshold
    updateAScale "tfint" $tfint
    updateAScale "multlow" $multlow
    updateAScale "multhigh" $multhigh
    updateAScale "coinctime" $coinctime

    return

}    

#updateFromModule gets the parameters FROM the module
#IT DOES NOT SET ANY CONTROLS ON A PANEL Synching
#the panel to the modules is done in updateVals
proc mscfpanel::updateFromModule { } {
    variable themod
    variable comhandle

    variable gains
    variable shapes
    variable thresholds
    variable pzs
    variable rc
    variable singlemode
 
    variable monitor

    variable blractive
    variable ecldelay
    variable blrthreshold
    variable tfint

    variable multlow
    variable multhigh
    variable coinctime

    ${themod}::getall $comhandle

    set gains [eval ${themod}::channel_gains]
    set shapes [eval ${themod}::channel_shapetimes]
    set thresholds [subst $${themod}::thresholds]
    set pzs [subst $${themod}::polezeros]
    set rc [subst $${themod}::rc]
    set singlemode [subst $${themod}::ctlmode ]

    set mc [subst $${themod}::monitor]
    set monitor [expr ($mc - 1)%17 + 1 ]

    set blractive [subst $${themod}::blractive]
    set ecldelay [subst $${themod}::ecldelay]
    set tfint [subst $${themod}::tfint]
    set blrthreshold [subst $${themod}::blrthreshold]

    set coinctime [subst $${themod}::coinc_time]
    set mults [subst $${themod}::multlimits ]
    set multhigh [lindex $mults 0]
    set multlow [lindex $mults 1]

    return

}    

proc mscfpanel::updateScales { type values } {
    variable top
    variable $type
    set i 1
    foreach g $values { 
	$top.${type}$i set $g
	incr i
    }

    return
}


proc mscfpanel::updateAScale { name value } {
    variable top
    variable $name

    $top.${name} set $value

    return

}

#--ddc The value has already been set... but the script associated
#the button has NOT been run, and that is most often required.
#proc mscfpanel::updateCheck { type value } {
#    variable top
#    variable $type
#    if {$value} { 
#	$top.${type} select
#    } else {
#	$top.${type} deselect
#    }
#    return
#}

proc mscfpanel::updateCheck { type value } {
    variable top
    variable $type

    set checkcmd [$top.${type} cget -command]
    if {  [string length $checkcmd] > 0  } { eval $checkcmd } 
    return
}

proc mscfpanel::setbus { } {
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
proc mscfpanel::setrcbus { } {
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
mscfpanel::initpanel


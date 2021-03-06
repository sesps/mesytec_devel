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


proc testsplit {{maxsplit 8}} {
    
    for {set i 0} {$i<$maxsplit} {incr i} { puts "$i [masksplit $i 2]"}
}


proc testjoin {{maxjoin 8}} {
    
    for {set i 0} {$i<$maxjoin} {incr i} { puts "$i [maskjoin $i 2]"}
}

proc testjoinif {oldermask {maxjoin 8}} {
    
    for {set i 0} {$i<$maxjoin} {incr i} { 
	puts "$i [maskjoinif $i $oldermask 2]"
    }
}
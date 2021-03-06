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
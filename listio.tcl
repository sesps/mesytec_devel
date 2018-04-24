
namespace eval listio {

    variable winpath ""
    variable filepath "listio.dat"
    variable testoverwrite 1

}

proc listio::setio { fname {testovrwrt 1} {win ""} } {

    variable winpath $win
    variable filepath $fname
    variable testoverwrite $testovrwrt
		
}  

proc listio::putlists {  listolists { listspace "" } } {

    variable filepath
    variable winpath
    variable testoverwrite

    set fh ""
    set answer "Y"

    if { [string equal $filepath ""] } {
	return "No filename to open!"
    }

    if { [ catch { open $filepath r+ } fh ] } { 
#the file did NOT already exist (or possibly another problem to trap on next open)
	set fh [open $filepath w]
        if { [string equal $fh "" ] } { return -errorcode 1 }
    } else {
	#file DID exist... give user opportunity to stop before overwriting,
	#unless, were are not supposed to check (the calling proc has already checked)
	if { $testoverwrite } {
	    if {  [ catch { tk_messageBox -message "Overwrite the file $filepath?" -parent $winpath -type yesno -icon question } answer ] } {
		puts "file exists!"
		puts "Overwrite the file? (Y/N)"
		set answer [gets stdin]
	    }
	}
    }
    

    if { ![string equal -nocase -length 1 $answer "Y"] } {
	close $fh
	return
    }


    foreach i $listolists {
	if { [catch {set output "$i [subst $${listspace}::$i]"}] } continue
	puts $fh $output 
    }
    chan truncate $fh
    close $fh
    return
}


#
#given a file with lists with a listname as the first element, and all
#the values as the remaining elements, read in all these lists, and 
#then extract from them the lists you want to set (in list "listlists")
#the list in the namespace "listspace" is then set to the values.
#
proc listio::getlists { listlists {listspace ""} } {

    variable filepath
    variable winpath

    set fh ""
    set answer ""
    set filelists {}
 
   
#the filelists are lists with the listname as the first element, and the
#values in all other elements.
#------- read all the lists from a file
#
    if { [string equal $filepath ""] } {
	return "No filename to open!"
    }

    if { [ catch { open $filepath r } fh ] } { 
#the file did NOT exist
	if {  [ catch { tk_messageBox -message "No file $filepath !" -parent $winpath -type ok -icon info } answer ] } {
	    puts "file $filepath does NOT exist!"
	}
	return
    }
    
#read in the contentes of the file.

    while { [gets $fh result] >= 0 } {
	lappend filelists $result
    }

    close $fh

#
#--now for each list in the file, see if the listname is in the 
# list of the lists we want to set.  If so, set the values for the list
# named in the namespace requested.
#
    set result ""
    foreach i $filelists {
	set lname [lindex $i 0]
	if { [lsearch -exact $listlists $lname] != -1 } {
	    if { [catch { set ${listspace}::$lname [ lrange $i 1 end ] }] } {
		append result "Error setting: ${listspace}::$lname\n"
	    }
	}
    }

    return $result

}

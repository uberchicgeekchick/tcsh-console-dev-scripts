#!/bin/tcsh -f
#setenv PATH "${PATH}:"
set programs=( "/programs/bin" "/programs/Mozilla/Firefox3/32bit/Nightly" "/programs/Mozilla/Firefox3/32bit/Stable" "/programs/Mozilla/Thunderbird3/32bit/Nightly" "/programs/Mozilla/Thunderbird3/32bit/Stable" "/programs/gizmo-project-3.1.0.79" "/programs/carrier-2.5.0" "/programs/skype_static-2.0.0.72-oss" "/programs/ion/3-20080825/bin" "/programs/linphone/3.0-cvs/2008-09-11/bin" "/programs/Adobe/Reader8/bin/" )
foreach program ( ${programs} )
	set program_test="`echo '${program}' | /usr/bin/sed 's/\//\\\//g'`"
	if ( "`echo '${PATH}' | /usr/bin/sed 's/.*:\(${program_test}\).*/\1/'`" == "${program}" ) continue
	setenv PATH "${PATH}:${program}"
end

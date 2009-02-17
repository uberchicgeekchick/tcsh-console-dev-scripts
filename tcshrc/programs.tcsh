#!/bin/tcsh -f
set programs=( "/programs/bin" "/programs/Mozilla/Firefox3/64bit" "/programs/Mozilla/Thunderbird3/64bit" "/programs/gizmo-project-3.1.0.79" "/programs/carrier-2.5.0" "/programs/skype_static-2.0.0.72-oss" "/programs/ion/3-20080825/bin" "/programs/linphone/3.0-cvs/2008-09-11/bin" )
foreach program ( ${programs} )
	set program_test="`printf '${program}' | sed 's/\//\\\//g'`"
	if ( "`echo '${PATH}' | /usr/bin/sed 's/.*:\(${program_test}\).*/\1/'`" == "${program_test}" ) continue
	setenv PATH "${PATH}:${program}"
end
setenv JAVA_HOME /usr/lib64/jvm/java-openjdk
